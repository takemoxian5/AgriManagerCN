/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.ScreenTools 1.0

SetupPage {
    id:             airframePage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Column {
            id:     mainColumn
            width:  availableWidth

            property real _minW:        ScreenTools.defaultFontPixelWidth * 30
            property real _boxWidth:    _minW
            property real _boxSpace:    ScreenTools.defaultFontPixelWidth

            readonly property real spacerHeight: ScreenTools.defaultFontPixelHeight

            onWidthChanged: {
                computeDimensions()
            }

            Component.onCompleted: computeDimensions()

            function computeDimensions() {
                var sw  = 0
                var rw  = 0
                var idx = Math.floor(mainColumn.width / (_minW + ScreenTools.defaultFontPixelWidth))
                if(idx < 1) {
                    _boxWidth = mainColumn.width
                    _boxSpace = 0
                } else {
                    _boxSpace = 0
                    if(idx > 1) {
                        _boxSpace = ScreenTools.defaultFontPixelWidth
                        sw = _boxSpace * (idx - 1)
                    }
                    rw = mainColumn.width - sw
                    _boxWidth = rw / idx
                }
            }

            AirframeComponentController {
                id:         controller
                factPanel:  airframePage.viewPanel

                Component.onCompleted: {
                    if (controller.showCustomConfigPanel) {
                        showDialog(customConfigDialogComponent, qsTr("自定义机架类型"), qgcView.showDialogDefaultWidth, StandardButton.Reset)
                    }
                }
            }

            Component {
                id: customConfigDialogComponent

                QGCViewMessage {
                    id:       customConfigDialog
                    message:  qsTr("当前无人机使用了自定义机架设置. ") +
                              qsTr("这个设置只能通过参数编辑器修改.\n\n") +
                              qsTr("如果你想重置机架设置为标准设置, 点击上面“重置”按钮.")

                    property Fact sys_autostart: controller.getParameterFact(-1, "SYS_AUTOSTART")

                    function accept() {
                        sys_autostart.value = 0
                        customConfigDialog.hideDialog()
                    }
                }
            }

            Component {
                id: applyRestartDialogComponent

                QGCViewDialog {
                    id: applyRestartDialog

                    function accept() {
                        controller.changeAutostart()
                        applyRestartDialog.hideDialog()
                    }

                    QGCLabel {
                        anchors.fill:   parent
                        wrapMode:       Text.WordWrap
                        text:           qsTr("点击“应用”可以保存机架类型设置改动.<br><br>\
除了无线校准的无人机参数设置都将被重置.<br><br>\
为了应用设置，你的无人机将会重启.")
                    }
                }
            }

            Item {
                id:             helpApplyRow
                anchors.left:   parent.left
                anchors.right:  parent.right
                height:         Math.max(helpText.contentHeight, applyButton.height)

                QGCLabel {
                    id:             helpText
                    width:          parent.width - applyButton.width - 5
                    text:           (controller.currentVehicleName != "" ?
                                         qsTr("已连接 %1.").arg(controller.currentVehicleName) :
                                         qsTr("机架类型未设置.")) +
                                    qsTr("为了修改设置, 请选择需要机型并点击“应用并重启”按钮.")
                    font.family:    ScreenTools.demiboldFontFamily
                    wrapMode:       Text.WordWrap
                }

                QGCButton {
                    id:             applyButton
                    anchors.right:  parent.right
                    text:           qsTr("应用并重启")

                    onClicked:      showDialog(applyRestartDialogComponent, qsTr("应用并重启"), qgcView.showDialogDefaultWidth, StandardButton.Apply | StandardButton.Cancel)
                }
            }

            Item {
                id:             lastSpacer
                height:         parent.spacerHeight
                width:          10
            }

            Flow {
                id:         flowView
                width:      parent.width
                spacing:    _boxSpace

                ExclusiveGroup {
                    id: airframeTypeExclusive
                }

                Repeater {
                    model: controller.airframeTypes

                    // Outer summary item rectangle
                    Rectangle {
                        width:  _boxWidth
                        height: ScreenTools.defaultFontPixelHeight * 14
                        color:  qgcPal.window

                        readonly property real titleHeight: ScreenTools.defaultFontPixelHeight * 1.75
                        readonly property real innerMargin: ScreenTools.defaultFontPixelWidth

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                applyButton.primary = true
                                airframeCheckBox.checked = true
                            }
                        }

                        QGCLabel {
                            id:     title
                            text:   modelData.name
                        }

                        Rectangle {
                            anchors.topMargin:  ScreenTools.defaultFontPixelHeight / 2
                            anchors.top:        title.bottom
                            anchors.bottom:     parent.bottom
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            color:              airframeCheckBox.checked ? qgcPal.buttonHighlight : qgcPal.windowShade

                            Image {
                                id:                 image
                                anchors.margins:    innerMargin
                                anchors.top:        parent.top
                                anchors.bottom:     combo.top
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                fillMode:           Image.PreserveAspectFit
                                smooth:             true
                                mipmap:             true
                                source:             modelData.imageResource
                            }

                            QGCCheckBox {
                                // Although this item is invisible we still use it to manage state
                                id:             airframeCheckBox
                                checked:        modelData.name == controller.currentAirframeType
                                exclusiveGroup: airframeTypeExclusive
                                visible:        false

                                onCheckedChanged: {
                                    if (checked && combo.currentIndex != -1) {
                                        console.log("check box change", combo.currentIndex)
                                        controller.autostartId = modelData.airframes[combo.currentIndex].autostartId
                                    }
                                }
                            }

                            QGCComboBox {
                                id:                 combo
                                objectName:         modelData.airframeType + "ComboBox"
                                anchors.margins:    innerMargin
                                anchors.bottom:     parent.bottom
                                anchors.left:       parent.left
                                anchors.right:      parent.right
                                model:              modelData.airframes

                                Component.onCompleted: {
                                    if (airframeCheckBox.checked) {
                                        currentIndex = controller.currentVehicleIndex
                                    }
                                }

                                onActivated: {
                                    applyButton.primary = true
                                    airframeCheckBox.checked = true;
                                    console.log("combo change", index)
                                    controller.autostartId = modelData.airframes[index].autostartId
                                }
                            }
                        }
                    }
                } // Repeater - summary boxes
            } // Flow - summary boxes
        } // Column
    } // Component
} // SetupPage
