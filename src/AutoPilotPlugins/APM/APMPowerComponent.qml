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
import QtQuick.Layouts  1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             powerPage
    pageComponent:  powerPageComponent

    Component {
        id: powerPageComponent

        Column {
            spacing: _margins

            property Fact battAmpPerVolt:   controller.getParameterFact(-1, "BATT_AMP_PERVOLT")
            property Fact battCapacity:     controller.getParameterFact(-1, "BATT_CAPACITY")
            property Fact battCurrPin:      controller.getParameterFact(-1, "BATT_CURR_PIN")
            property Fact battMonitor:      controller.getParameterFact(-1, "BATT_MONITOR")
            property Fact battVoltMult:     controller.getParameterFact(-1, "BATT_VOLT_MULT")
            property Fact battVoltPin:      controller.getParameterFact(-1, "BATT_VOLT_PIN")

            property real _margins:         ScreenTools.defaultFontPixelHeight / 2
            property bool _showAdvanced:    sensorCombo.currentIndex == sensorModel.count - 1
            property real _fieldWidth:      ScreenTools.defaultFontPixelWidth * 25

            Component.onCompleted: calcSensor()

            function calcSensor() {
                for (var i=0; i<sensorModel.count - 1; i++) {
                    if (sensorModel.get(i).voltPin == battVoltPin.value &&
                            sensorModel.get(i).currPin == battCurrPin.value &&
                            Math.abs(sensorModel.get(i).voltMult - battVoltMult.value) < 0.001 &&
                            Math.abs(sensorModel.get(i).ampPerVolt - battAmpPerVolt.value) < 0.0001) {
                        sensorCombo.currentIndex = i
                        return
                    }
                }
                sensorCombo.currentIndex = sensorModel.count - 1
            }

            QGCPalette { id: palette; colorGroupEnabled: true }

            FactPanelController {
                id:         controller
                factPanel:  powerPage.viewPanel
            }

            ListModel {
                id: sensorModel

                ListElement {
                    text:       qsTr("电源模块 90A")
                    voltPin:    2
                    currPin:    3
                    voltMult:   10.1
                    ampPerVolt: 17.0
                }

                ListElement {
                    text:       qsTr("电源模块 HV")
                    voltPin:    2
                    currPin:    3
                    voltMult:   12.02
                    ampPerVolt: 39.877
                }

                ListElement {
                    text:       "3DR Iris"
                    voltPin:    2
                    currPin:    3
                    voltMult:   12.02
                    ampPerVolt: 17.0
                }

                ListElement {
                    text:       qsTr("其他")
                }
            }

            Component {
                id: calcVoltageMultiplierDlgComponent

                QGCViewDialog {
                    id: calcVoltageMultiplierDlg

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  column.height
                        contentWidth:   column.width

                        Column {
                            id:         column
                            width:      calcVoltageMultiplierDlg.width
                            spacing:    ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       "使用外部电压表测量电池电压，并输入下面。点击计算，设置新的电压倍增器."
                            }

                            Grid {
                                columns: 2
                                spacing: ScreenTools.defaultFontPixelHeight / 2
                                verticalItemAlignment: Grid.AlignVCenter

                                QGCLabel {
                                    text: "实测电压:"
                                }
                                QGCTextField { id: measuredVoltage }

                                QGCLabel { text: "无人机电压:" }
                                QGCLabel { text: controller.vehicle.battery.voltage.valueString }

                                QGCLabel { text: "电压倍增器:" }
                                FactLabel { fact: battVoltMult }
                            }

                            QGCButton {
                                text: "计算"

                                onClicked:  {
                                    var measuredVoltageValue = parseFloat(measuredVoltage.text)
                                    if (measuredVoltageValue == 0 || isNaN(measuredVoltageValue)) {
                                        return
                                    }
                                    var newVoltageMultiplier = (measuredVoltageValue * battVoltMult.value) / controller.vehicle.battery.voltage.value
                                    if (newVoltageMultiplier > 0) {
                                        battVoltMult.value = newVoltageMultiplier
                                    }
                                }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - calcVoltageMultiplierDlgComponent

            Component {
                id: calcAmpsPerVoltDlgComponent

                QGCViewDialog {
                    id: calcAmpsPerVoltDlg

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  column.height
                        contentWidth:   column.width

                        Column {
                            id:         column
                            width:      calcAmpsPerVoltDlg.width
                            spacing:    ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       "使用外部电流表测量当前电流，并输入下面。点击计算，设置新的每伏特安培数."
                            }

                            Grid {
                                columns: 2
                                spacing: ScreenTools.defaultFontPixelHeight / 2
                                verticalItemAlignment: Grid.AlignVCenter

                                QGCLabel {
                                    text: "实测电流:"
                                }
                                QGCTextField { id: measuredCurrent }

                                QGCLabel { text: "无人机电流:" }
                                QGCLabel { text: controller.vehicle.battery.current.valueString }

                                QGCLabel { text: "安培每伏特:" }
                                FactLabel { fact: battAmpPerVolt }
                            }

                            QGCButton {
                                text: "计算"

                                onClicked:  {
                                    var measuredCurrentValue = parseFloat(measuredCurrent.text)
                                    if (measuredCurrentValue == 0) {
                                        return
                                    }
                                    var newAmpsPerVolt = (measuredCurrentValue * battAmpPerVolt.value) / controller.vehicle.battery.current.value
                                    if (newAmpsPerVolt != 0) {
                                        battAmpPerVolt.value = newAmpsPerVolt
                                    }
                                }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - calcAmpsPerVoltDlgComponent

            GridLayout {
                columns:        3
                rowSpacing:     _margins
                columnSpacing:  _margins

                QGCLabel { text: qsTr("电池监测器:") }

                FactComboBox {
                    id:                     monitorCombo
                    Layout.minimumWidth:    _fieldWidth
                    fact:                   battMonitor
                    indexModel:             false
                }

                QGCLabel {
                    Layout.row:     1
                    Layout.column:  0
                    text:           qsTr("电池容量:")
                }

                FactTextField {
                    id:     capacityField
                    width:  _fieldWidth
                    fact:   battCapacity
                }

                QGCLabel {
                    Layout.row:     2
                    Layout.column:  0
                    text:           qsTr("功率传感器:")
                }

                QGCComboBox {
                    id:                     sensorCombo
                    Layout.minimumWidth:    _fieldWidth
                    model:                  sensorModel

                    onActivated: {
                        if (index < sensorModel.count - 1) {
                            battVoltPin.value = sensorModel.get(index).voltPin
                            battCurrPin.value = sensorModel.get(index).currPin
                            battVoltMult.value = sensorModel.get(index).voltMult
                            battAmpPerVolt.value = sensorModel.get(index).ampPerVolt
                        } else {

                        }
                    }
                }

                QGCLabel {
                    Layout.row:     3
                    Layout.column:  0
                    text:           qsTr("电流引脚:")
                    visible:        _showAdvanced
                }

                FactComboBox {
                    Layout.minimumWidth:    _fieldWidth
                    fact:                   battCurrPin
                    visible:                _showAdvanced
                }

                QGCLabel {
                    Layout.row:     4
                    Layout.column:  0
                    text:           qsTr("电压引脚:")
                    visible:        _showAdvanced
                }

                FactComboBox {
                    Layout.minimumWidth:    _fieldWidth
                    fact:                   battVoltPin
                    indexModel:             false
                    visible:                _showAdvanced
                }

                QGCLabel {
                    Layout.row:     5
                    Layout.column:  0
                    text:           qsTr("电压倍增器:")
                    visible:        _showAdvanced
                }

                FactTextField {
                    width:      _fieldWidth
                    fact:       battVoltMult
                    visible:    _showAdvanced
                }

                QGCButton {
                    text:       qsTr("计算")
                    onClicked:  showDialog(calcVoltageMultiplierDlgComponent, qsTr("计算电压倍增器"), qgcView.showDialogDefaultWidth, StandardButton.Close)
                    visible:    _showAdvanced
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("如果无人机所报告的电池电压很大程度上不同于外部使用电压表的电压你可以调整电压倍增器的值来校正这个. 单击计算按钮以帮助计算新值.")
                    visible:            _showAdvanced
                }

                QGCLabel {
                    text:       qsTr("安培每伏特:")
                    visible:    _showAdvanced
                }

                FactTextField {
                    width:      _fieldWidth
                    fact:       battAmpPerVolt
                    visible:    _showAdvanced
                }

                QGCButton {
                    text:       qsTr("计算")
                    onClicked:  showDialog(calcAmpsPerVoltDlgComponent, qsTr("计算安培每伏特"), qgcView.showDialogDefaultWidth, StandardButton.Close)
                    visible:    _showAdvanced
                }

                QGCLabel {
                    Layout.columnSpan:  3
                    Layout.fillWidth:   true
                    font.pointSize:     ScreenTools.smallFontPointSize
                    wrapMode:           Text.WordWrap
                    text:               qsTr("如果无人机所报告的电流很大程度上不同于当前使用的电流表你可以调整每个伏特的安培值来校正这个值. 单击计算按钮以帮助计算新值.")
                    visible:        _showAdvanced
                }
            } // GridLayout
        } // Column
    } // Component
} // SetupPage
