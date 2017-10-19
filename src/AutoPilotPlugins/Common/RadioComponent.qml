/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs  1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Palette       1.0

SetupPage {
    id:             radioPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: Math.max(leftColumn.height, rightColumn.height)

            readonly property string    dialogTitle:            qsTr("遥控器")
            readonly property real      labelToMonitorMargin:   defaultTextWidth * 3

            property bool controllerCompleted:      false
            property bool controllerAndViewReady:   false

            Component.onCompleted: {
                if (controllerCompleted) {
                    controllerAndViewReady = true
                    controller.start()
                    updateChannelCount()
                }
            }

            function updateChannelCount()
            {
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: radioPage.enabled }

            RadioComponentController {
                id:             controller
                factPanel:      radioPage.viewPanel
                statusText:     statusText
                cancelButton:   cancelButton
                nextButton:     nextButton
                skipButton:     skipButton

                Component.onCompleted: {
                    controllerCompleted = true
                    if (qgcView.completedSignalled) {
                        controllerAndViewReady = true
                        controller.start()
                        updateChannelCount()
                    }
                }

                onChannelCountChanged:              updateChannelCount()
                onFunctionMappingChangedAPMReboot:  showMessage(qsTr("需要重启"), qsTr("您的摇杆映射已修改, 必须重启飞控以进行正确操作."), StandardButton.Ok)
                onThrottleReversedCalFailure:       showMessage(qsTr("油门通道反向"), qsTr("校准失败. 遥控器油门通道反向. 您需要调整过来以完成校准."), StandardButton.Ok)
            }

            Component {
                id: copyTrimsDialogComponent

                QGCViewMessage {
                    message: qsTr("摇杆居中，油门打到最低, 然后点击确认得到数值. 完成后, 将您的遥控器重置为0.")

                    function accept() {
                        hideDialog()
                        controller.copyTrims()
                    }
                }
            }

            Component {
                id: zeroTrimsDialogComponent

                QGCViewMessage {
                    message: qsTr("校准之前您应该把所有位置都置于0. 点击确认开始校准.\n\n%1").arg(
                                 (QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ? "" : qsTr("请确认电机没有供电并且螺旋桨都去掉了.")))

                    function accept() {
                        hideDialog()
                        controller.nextButtonClicked()
                    }
                }
            }

            Component {
                id: channelCountDialogComponent

                QGCViewMessage {
                    message: controller.channelCount == 0 ? qsTr("请打开遥控器.") : qsTr("用于飞行需要 %1 通道或更多的通道.").arg(controller.minChannelCount)
                }
            }

            Component {
                id: spektrumBindDialogComponent

                QGCViewDialog {

                    function accept() {
                        controller.spektrumBindMode(radioGroup.current.bindMode)
                        hideDialog()
                    }

                    function reject() {
                        hideDialog()
                    }

                    Column {
                        anchors.fill:   parent
                        spacing:        5

                        QGCLabel {
                            width:      parent.width
                            wrapMode:   Text.WordWrap
                            text:       qsTr("点击确认进入Spektrum接收机对码模式. 从以下列表中选择接收机类型:")
                        }

                        ExclusiveGroup { id: radioGroup }

                        QGCRadioButton {
                            exclusiveGroup: radioGroup
                            text:           qsTr("DSM2模式")

                            property int bindMode: RadioComponentController.DSM2
                        }

                        QGCRadioButton {
                            exclusiveGroup: radioGroup
                            text:           qsTr("DSMX (7 通道或者更少)")

                            property int bindMode: RadioComponentController.DSMX7
                        }

                        QGCRadioButton {
                            exclusiveGroup: radioGroup
                            checked:        true
                            text:           qsTr("DSMX (8 通道或者更多)")

                            property int bindMode: RadioComponentController.DSMX8
                        }
                    }
                }
            } // Component - spektrumBindDialogComponent

            // Live channel monitor control component
            Component {
                id: channelMonitorDisplayComponent

                Item {
                    property int    rcValue:    1500


                    property int            __lastRcValue:      1500
                    readonly property int   __rcValueMaxJitter: 2
                    property color          __barColor:         qgcPal.windowShade

                    readonly property int _pwmMin:      800
                    readonly property int _pwmMax:      2200
                    readonly property int _pwmRange:    _pwmMax - _pwmMin

                    // Bar
                    Rectangle {
                        id:                     bar
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.width
                        height:                 parent.height / 2
                        color:                  __barColor
                    }

                    // Center point
                    Rectangle {
                        anchors.horizontalCenter:   parent.horizontalCenter
                        width:                      defaultTextWidth / 2
                        height:                     parent.height
                        color:                      qgcPal.window
                    }

                    // Indicator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width:                  parent.height * 0.75
                        height:                 width
                        radius:                 width / 2
                        color:                  qgcPal.text
                        visible:                mapped
                        x:                      (((reversed ? _pwmMax - rcValue : rcValue - _pwmMin) / _pwmRange) * parent.width) - (width / 2)
                    }

                    QGCLabel {
                        anchors.fill:           parent
                        horizontalAlignment:    Text.AlignHCenter
                        verticalAlignment:      Text.AlignVCenter
                        text:                   qsTr("未映射")
                        visible:                !mapped
                    }

                    ColorAnimation {
                        id:         barAnimation
                        target:     bar
                        property:   "color"
                        from:       "yellow"
                        to:         __barColor
                        duration:   1500
                    }
                }
            } // Component - channelMonitorDisplayComponent

            // Left side column
            Column {
                id:             leftColumn
                anchors.left:   parent.left
                anchors.right:  columnSpacer.left
                spacing:        10

                // Attitude Controls
                Column {
                    width:      parent.width
                    spacing:    5
                    QGCLabel { text: qsTr("姿态控制") }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2
                        QGCLabel {
                            id:     rollLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("横滚")
                        }

                        Loader {
                            id:                 rollLoader
                            anchors.left:       rollLabel.right
                            anchors.right:      parent.right
                            height:             radioPage.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.rollChannelMapped
                            property bool reversed:         controller.rollChannelReversed
                        }

                        Connections {
                            target: controller

                            onRollChannelRCValueChanged: rollLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     pitchLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("俯仰")
                        }

                        Loader {
                            id:                 pitchLoader
                            anchors.left:       pitchLabel.right
                            anchors.right:      parent.right
                            height:             radioPage.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.pitchChannelMapped
                            property bool reversed:         controller.pitchChannelReversed
                        }

                        Connections {
                            target: controller

                            onPitchChannelRCValueChanged: pitchLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     yawLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("偏航")
                        }

                        Loader {
                            id:                 yawLoader
                            anchors.left:       yawLabel.right
                            anchors.right:      parent.right
                            height:             radioPage.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.yawChannelMapped
                            property bool reversed:         controller.yawChannelReversed
                        }

                        Connections {
                            target: controller

                            onYawChannelRCValueChanged: yawLoader.item.rcValue = rcValue
                        }
                    }

                    Item {
                        width:  parent.width
                        height: defaultTextHeight * 2

                        QGCLabel {
                            id:     throttleLabel
                            width:  defaultTextWidth * 10
                            text:   qsTr("油门")
                        }

                        Loader {
                            id:                 throttleLoader
                            anchors.left:       throttleLabel.right
                            anchors.right:      parent.right
                            height:             radioPage.defaultTextHeight
                            width:              100
                            sourceComponent:    channelMonitorDisplayComponent

                            property real defaultTextWidth: radioPage.defaultTextWidth
                            property bool mapped:           controller.throttleChannelMapped
                            property bool reversed:         controller.throttleChannelReversed
                        }

                        Connections {
                            target: controller

                            onThrottleChannelRCValueChanged: throttleLoader.item.rcValue = rcValue
                        }
                    }
                } // Column - Attitude Control labels

                // Command Buttons
                Row {
                    spacing: 10

                    QGCButton {
                        id:         skipButton
                        text:       qsTr("跳过")

                        onClicked: controller.skipButtonClicked()
                    }

                    QGCButton {
                        id:         cancelButton
                        text:       qsTr("取消")

                        onClicked: controller.cancelButtonClicked()
                    }

                    QGCButton {
                        id:         nextButton
                        primary:    true
                        text:       qsTr("校准")

                        onClicked: {
                            if (text == qsTr("校准")) {
                                showDialog(zeroTrimsDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                            } else {
                                controller.nextButtonClicked()
                            }
                        }
                    }
                } // Row - Buttons

                // Status Text
                QGCLabel {
                    id:         statusText
                    width:      parent.width
                    wrapMode:   Text.WordWrap
                }

                Item {
                    width: 10
                    height: defaultTextHeight * 4
                }

                Rectangle {
                    width:          parent.width
                    height:         1
                    border.color:   qgcPal.text
                    border.width:   1
                }

                QGCLabel { text: qsTr("其他设置:") }

                QGCButton {
                    id:         bindButton
                    text:       qsTr("Spektrum对码")

                    onClicked: showDialog(spektrumBindDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                }

                QGCButton {
                    text:       qsTr("复制数值")
                    onClicked:  showDialog(copyTrimsDialogComponent, dialogTitle, radioPage.showDialogDefaultWidth, StandardButton.Ok | StandardButton.Cancel)
                }

                Repeater {
                    model: QGroundControl.multiVehicleManager.activeVehicle.px4Firmware ?
                               (QGroundControl.multiVehicleManager.activeVehicle.multiRotor ?
                                   [ "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"] :
                                   [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3"]) :
                               0

                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth
                        property Fact fact: controller.getParameterFact(-1, modelData)

                        QGCLabel {
                            anchors.baseline:   optCombo.baseline
                            text:               fact.shortDescription + ":"
                        }

                        FactComboBox {
                            id:         optCombo
                            width:      ScreenTools.defaultFontPixelWidth * 15
                            fact:       parent.fact
                            indexModel: false
                        }
                    }
                } // Repeater
            } // Column - Left Column

            Item {
                id:             columnSpacer
                anchors.right:  rightColumn.left
                width:          20
            }

            // Right side column
            Column {
                id:             rightColumn
                anchors.top:    parent.top
                anchors.right:  parent.right
                width:          Math.min(radioPage.defaultTextWidth * 35, availableWidth * 0.4)
                spacing:        ScreenTools.defaultFontPixelHeight / 2

                Row {
                    spacing: ScreenTools.defaultFontPixelWidth

                    ExclusiveGroup { id: modeGroup }

                    QGCRadioButton {
                        exclusiveGroup: modeGroup
                        text:           qsTr("模式 1")
                        checked:        controller.transmitterMode == 1

                        onClicked: controller.transmitterMode = 1
                    }

                    QGCRadioButton {
                        exclusiveGroup: modeGroup
                        text:           qsTr("模式 2")
                        checked:        controller.transmitterMode == 2

                        onClicked: controller.transmitterMode = 2
                    }
                }

                Image {
                    width:      parent.width
                    fillMode:   Image.PreserveAspectFit
                    smooth:     true
                    source:     controller.imageHelp
                }

                RCChannelMonitor {
                    width: parent.width
                }
            } // Column - Right Column
        } // Item    
    } // Component - pageComponent
} // SetupPage
