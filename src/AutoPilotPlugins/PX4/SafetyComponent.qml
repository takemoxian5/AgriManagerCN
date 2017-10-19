/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Layouts          1.2
import QtGraphicalEffects       1.0

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0


SetupPage {
    id:             safetyPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, outerGrid.width)
            height: lastRect.y + lastRect.height

            FactPanelController {
                id:         controller
                factPanel:  safetyPage.viewPanel
            }

            property real _margins:         ScreenTools.defaultFontPixelHeight
            property real _editFieldWidth:  ScreenTools.defaultFontPixelWidth * 20
            property real _imageWidth:      ScreenTools.defaultFontPixelWidth * 15
            property real _imageHeight:     ScreenTools.defaultFontPixelHeight * 3

            property Fact _fenceAction:     controller.getParameterFact(-1, "GF_ACTION")
            property Fact _fenceRadius:     controller.getParameterFact(-1, "GF_MAX_HOR_DIST")
            property Fact _fenceAlt:        controller.getParameterFact(-1, "GF_MAX_VER_DIST")
            property Fact _rtlLandDelay:    controller.getParameterFact(-1, "RTL_LAND_DELAY")
            property Fact _lowBattAction:   controller.getParameterFact(-1, "COM_LOW_BAT_ACT")
            property Fact _rcLossAction:    controller.getParameterFact(-1, "NAV_RCL_ACT")
            property Fact _dlLossAction:    controller.getParameterFact(-1, "NAV_DLL_ACT")
            property Fact _disarmLandDelay: controller.getParameterFact(-1, "COM_DISARM_LAND")
            property Fact _landSpeedMC:     controller.getParameterFact(-1, "MPC_LAND_SPEED", false)

            ExclusiveGroup { id: homeLoiterGroup }

            Rectangle {
                x:      lowBattGrid.x + outerGrid.x - _margins
                y:      lowBattGrid.y + outerGrid.y - _margins
                width:  lowBattGrid.width + (_margins * 2)
                height: lowBattGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            Rectangle {
                x:      rcLossGrid.x + outerGrid.x - _margins
                y:      rcLossGrid.y + outerGrid.y - _margins
                width:  rcLossGrid.width + (_margins * 2)
                height: rcLossGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            Rectangle {
                x:      dataLinkLossGrid.x + outerGrid.x - _margins
                y:      dataLinkLossGrid.y + outerGrid.y - _margins
                width:  dataLinkLossGrid.width + (_margins * 2)
                height: dataLinkLossGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            Rectangle {
                x:      geoFenceGrid.x + outerGrid.x - _margins
                y:      geoFenceGrid.y + outerGrid.y - _margins
                width:  geoFenceGrid.width + (_margins * 2)
                height: geoFenceGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            Rectangle {
                x:      returnHomeGrid.x + outerGrid.x - _margins
                y:      returnHomeGrid.y + outerGrid.y - _margins
                width:  returnHomeGrid.width + (_margins * 2)
                height: returnHomeGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            Rectangle {
                id:     lastRect
                x:      landModeGrid.x + outerGrid.x - _margins
                y:      landModeGrid.y + outerGrid.y - _margins
                width:  landModeGrid.width + (_margins * 2)
                height: landModeGrid.height + (_margins * 2)
                color:  qgcPal.windowShade
            }

            GridLayout {
                id:         outerGrid
                columns:    3
                anchors.horizontalCenter:   parent.horizontalCenter

                QGCLabel {
                    text:               qsTr("低电压失效保护触发")
                    Layout.columnSpan:  3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         lowBattGrid
                    columns:    3

                    Image {
                        mipmap:             true
                        fillMode:           Image.PreserveAspectFit
                        source:             qgcPal.globalTheme === qgcPal.Light ? "/qmlimages/LowBatteryLight.svg" : "/qmlimages/LowBattery.svg"
                        Layout.rowSpan:     3
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                        width:                  _imageWidth
                        height:                 _imageHeight
                    }

                    QGCLabel {
                        text:               qsTr("失效时动作:")
                        Layout.fillWidth:   true
                    }
                    FactComboBox {
                        fact:                   _lowBattAction
                        indexModel:             false
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("电池报警电压:")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "BAT_LOW_THR")
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("电池失效保护电压:")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "BAT_CRIT_THR")
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                QGCLabel {
                    text:               qsTr("遥控器失效保护触发")
                    Layout.columnSpan: 3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         rcLossGrid
                    columns:    3

                    Image {
                        mipmap:             true
                        fillMode:           Image.PreserveAspectFit
                        source:             qgcPal.globalTheme === qgcPal.Light ? "/qmlimages/RCLossLight.svg" : "/qmlimages/RCLoss.svg"
                        Layout.rowSpan:     3
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                        width:                  _imageWidth
                        height:                 _imageHeight
                    }

                    QGCLabel {
                        text:               qsTr("失效时动作:")
                        Layout.fillWidth:   true
                    }
                    FactComboBox {
                        fact:                   _rcLossAction
                        indexModel:             false
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("遥控信号丢失超时:")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "COM_RC_LOSS_T")
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                QGCLabel {
                    text:               qsTr("数据链失效保护触发")
                    Layout.columnSpan: 3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         dataLinkLossGrid
                    columns:    3

                    Image {
                        mipmap:             true
                        fillMode:           Image.PreserveAspectFit
                        source:             qgcPal.globalTheme === qgcPal.Light ? "/qmlimages/DatalinkLossLight.svg" : "/qmlimages/DatalinkLoss.svg"
                        Layout.rowSpan:     3
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                        width:                  _imageWidth
                        height:                 _imageHeight
                    }

                    QGCLabel {
                        text:               qsTr("失效时动作:")
                        Layout.fillWidth:   true
                    }
                    FactComboBox {
                        fact:                   _dlLossAction
                        indexModel:             false
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("数据链信号丢失超时:")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "COM_DL_LOSS_T")
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                QGCLabel {
                    text:               qsTr("地理标签失效保护触发")
                    Layout.columnSpan:  3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         geoFenceGrid
                    columns:    3

                    Image {
                        mipmap:             true
                        fillMode:           Image.PreserveAspectFit
                        source:             qgcPal.globalTheme === qgcPal.Light ? "/qmlimages/GeoFenceLight.svg" : "/qmlimages/GeoFence.svg"
                        Layout.rowSpan:     3
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                        width:                  _imageWidth
                        height:                 _imageHeight
                    }

                    QGCLabel {
                        text:               qsTr("超过设置时动作:")
                        Layout.fillWidth:   true
                    }
                    FactComboBox {
                        fact:                   _fenceAction
                        indexModel:             false
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCCheckBox {
                        id:                 fenceRadiusCheckBox
                        text:               qsTr("最大半径:")
                        checked:            _fenceRadius.value > 0
                        onClicked:          _fenceRadius.value = checked ? 100 : 0
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   _fenceRadius
                        enabled:                fenceRadiusCheckBox.checked
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCCheckBox {
                        id:                 fenceAltMaxCheckBox
                        text:               qsTr("最大高度:")
                        checked:            _fenceAlt ? _fenceAlt.value > 0 : false
                        onClicked:          _fenceAlt.value = checked ? 100 : 0
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   _fenceAlt
                        enabled:                fenceAltMaxCheckBox.checked
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                QGCLabel {
                    text:               qsTr("返航设置")
                    Layout.columnSpan:  3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         returnHomeGrid
                    columns:    3

                    QGCColoredImage {
                        color:                  qgcPal.text
                        mipmap:                 true
                        fillMode:               Image.PreserveAspectFit
                        source:                 controller.vehicle.fixedWing ? "/qmlimages/ReturnToHomeAltitude.svg" : "/qmlimages/ReturnToHomeAltitudeCopter.svg"
                        Layout.rowSpan:         7
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                        width:                  _imageWidth
                        height:                 _imageHeight
                    }

                    QGCLabel {
                        text:               qsTr("爬升到高度:")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "RTL_RETURN_ALT")
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("返航, 然后:")
                        Layout.columnSpan:  2
                    }
                    Row {
                        Layout.columnSpan:  2
                        Item { width: ScreenTools.defaultFontPixelWidth; height: 1 }
                        QGCRadioButton {
                            id:                 homeLandRadio
                            checked:            _rtlLandDelay ? _rtlLandDelay.value === 0 : false
                            exclusiveGroup:     homeLoiterGroup
                            text:               qsTr("立即降落")
                            onClicked:          _rtlLandDelay.value = 0
                        }
                    }
                    Row {
                        Layout.columnSpan:  2
                        Item { width: ScreenTools.defaultFontPixelWidth; height: 1 }
                        QGCRadioButton {
                            id:                 homeLoiterNoLandRadio
                            checked:            _rtlLandDelay ? _rtlLandDelay.value < 0 : false
                            exclusiveGroup:     homeLoiterGroup
                            text:               qsTr("盘旋不降落")
                            onClicked:          _rtlLandDelay.value = -1
                        }
                    }
                    Row {
                        Layout.columnSpan:  2
                        Item { width: ScreenTools.defaultFontPixelWidth; height: 1 }
                        QGCRadioButton {
                            id:                 homeLoiterLandRadio
                            checked:            _rtlLandDelay ? _rtlLandDelay.value > 0 : false
                            exclusiveGroup:     homeLoiterGroup
                            text:               qsTr("盘旋然后在指定时间降落")
                            onClicked:          _rtlLandDelay.value = 60
                        }
                    }

                    QGCLabel {
                        text:               qsTr("盘旋时间")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "RTL_LAND_DELAY")
                        enabled:                homeLoiterLandRadio.checked === true
                        Layout.minimumWidth:    _editFieldWidth
                    }

                    QGCLabel {
                        text:               qsTr("盘旋高度")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   controller.getParameterFact(-1, "RTL_DESCEND_ALT")
                        enabled:                homeLoiterLandRadio.checked === true || homeLoiterNoLandRadio.checked === true
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                QGCLabel {
                    text:               qsTr("降落模式设置")
                    Layout.columnSpan:  3
                }

                Item { width: 1; height: _margins; Layout.columnSpan: 3 }

                Item { width: _margins; height: 1 }

                GridLayout {
                    id:         landModeGrid
                    columns:    3

                    QGCColoredImage {
                        color:                  qgcPal.text
                        mipmap:                 true
                        fillMode:               Image.PreserveAspectFit
                        source:                 controller.vehicle.fixedWing ? "/qmlimages/LandMode.svg" : "/qmlimages/LandModeCopter.svg"
                        Layout.rowSpan:         landVelocityLabel.visible ? 2 : 1
                        width:                  _imageWidth
                        height:                 _imageHeight
                        Layout.maximumWidth:    _imageWidth
                        Layout.maximumHeight:   _imageHeight
                    }

                    QGCLabel {
                        id:                 landVelocityLabel
                        text:               qsTr("降落下降速率:")
                        Layout.fillWidth:   true
                        visible:            controller.vehicle && !controller.vehicle.fixedWing
                    }
                    FactTextField {
                        fact:                   _landSpeedMC
                        Layout.minimumWidth:    _editFieldWidth
                        visible:                controller.vehicle && !controller.vehicle.fixedWing
                    }

                    QGCCheckBox {
                        id:                 disarmDelayCheckBox
                        text:               qsTr("然后加锁:")
                        checked:            _disarmLandDelay.value > 0
                        onClicked:          _disarmLandDelay.value = checked ? 2 : 0
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:                   _disarmLandDelay
                        enabled:                disarmDelayCheckBox.checked
                        Layout.minimumWidth:    _editFieldWidth
                    }
                }
            }
        }
    }
}
