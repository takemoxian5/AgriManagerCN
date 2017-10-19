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

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

SetupPage {
    id:             powerPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, innerColumn.width)
            height: innerColumn.height

            property int textEditWidth:    ScreenTools.defaultFontPixelWidth * 8

            property Fact battNumCells:         controller.getParameterFact(-1, "BAT_N_CELLS")
            property Fact battHighVolt:         controller.getParameterFact(-1, "BAT_V_CHARGED")
            property Fact battLowVolt:          controller.getParameterFact(-1, "BAT_V_EMPTY")
            property Fact battVoltLoadDrop:     controller.getParameterFact(-1, "BAT_V_LOAD_DROP")
            property Fact battVoltageDivider:   controller.getParameterFact(-1, "BAT_V_DIV")
            property Fact battAmpsPerVolt:      controller.getParameterFact(-1, "BAT_A_PER_V")
            property Fact uavcanEnable:         controller.getParameterFact(-1, "UAVCAN_ENABLE", false)

            readonly property string highlightPrefix:   "<font color=\"" + qgcPal.warningText + "\">"
            readonly property string highlightSuffix:   "</font>"

            ColumnLayout {
                id:                         innerColumn
                anchors.horizontalCenter:   parent.horizontalCenter
                spacing:                    ScreenTools.defaultFontPixelHeight

                function getBatteryImage()
                {
                    switch(battNumCells.value) {
                    case 1:  return "/qmlimages/PowerComponentBattery_01cell.svg";
                    case 2:  return "/qmlimages/PowerComponentBattery_02cell.svg"
                    case 3:  return "/qmlimages/PowerComponentBattery_03cell.svg"
                    case 4:  return "/qmlimages/PowerComponentBattery_04cell.svg"
                    case 5:  return "/qmlimages/PowerComponentBattery_05cell.svg"
                    case 6:  return "/qmlimages/PowerComponentBattery_06cell.svg"
                    default: return "/qmlimages/PowerComponentBattery_01cell.svg";
                    }
                }

                function drawArrowhead(ctx, x, y, radians)
                {
                    ctx.save();
                    ctx.beginPath();
                    ctx.translate(x,y);
                    ctx.rotate(radians);
                    ctx.moveTo(0,0);
                    ctx.lineTo(5,10);
                    ctx.lineTo(-5,10);
                    ctx.closePath();
                    ctx.restore();
                    ctx.fill();
                }

                function drawLineWithArrow(ctx, x1, y1, x2, y2)
                {
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                    var rd = Math.atan((y2 - y1) / (x2 - x1));
                    rd += ((x2 > x1) ? 90 : -90) * Math.PI/180;
                    drawArrowhead(ctx, x2, y2, rd);
                }

                PowerComponentController {
                    id:         controller
                    factPanel:  powerPage.viewPanel

                    onOldFirmware:          showMessage(qsTr("电调校准"), qsTr("%1 当前固件版本不能进行电调校准. 需要升级固件版本.").arg(QGroundControl.appName), StandardButton.Ok)
                    onNewerFirmware:        showMessage(qsTr("电调校准"), qsTr("%1 当前固件版本不能进行电调校准. 需要升级固件版本 %1.").arg(QGroundControl.appName), StandardButton.Ok)
                    onBatteryConnected:     showMessage(qsTr("电调校准"), qsTr("执行校准. 这需要几秒钟的时间.."), 0)
                    onCalibrationFailed:    showMessage(qsTr("电调校准失败"), errorMessage, StandardButton.Ok)
                    onCalibrationSuccess:   showMessage(qsTr("电调校准"), qsTr("校准完成. 您可以断开电池连接了."), StandardButton.Ok)
                    onConnectBattery:       showMessage(qsTr("电调校准"), highlightPrefix + qsTr("警告: 需要先将桨叶拿掉再进行电调校准.") + highlightSuffix + qsTr(" 连接电池，开始进行校准."), 0)
                    onDisconnectBattery:    showMessage(qsTr("电调校准失败"), qsTr("需要先将电池断开以执行电调校准. 断开电池重试."), StandardButton.Ok)
                }

                Component {
                    id: calcVoltageDividerDlgComponent

                    QGCViewDialog {
                        id: calcVoltageDividerDlg

                        QGCFlickable {
                            anchors.fill:   parent
                            contentHeight:  column.height
                            contentWidth:   column.width

                            Column {
                                id:         column
                                width:      calcVoltageDividerDlg.width
                                spacing:    ScreenTools.defaultFontPixelHeight

                                QGCLabel {
                                    width:      parent.width
                                    wrapMode:   Text.WordWrap
                                    text:       "使用外部电压表测量电池电压，并在下方输入. 点击计算，设置新的分压比."
                                }

                                Grid {
                                    columns: 2
                                    spacing: ScreenTools.defaultFontPixelHeight / 2
                                    verticalItemAlignment: Grid.AlignVCenter

                                    QGCLabel {
                                        text: "测量电压值:"
                                    }
                                    QGCTextField { id: measuredVoltage }

                                    QGCLabel { text: "电压值:" }
                                    QGCLabel { text: controller.vehicle.battery.voltage.valueString }

                                    QGCLabel { text: "分压:" }
                                    FactLabel { fact: battVoltageDivider }
                                }

                                QGCButton {
                                    text: "计算"

                                    onClicked:  {
                                        var measuredVoltageValue = parseFloat(measuredVoltage.text)
                                        if (measuredVoltageValue == 0 || isNaN(measuredVoltageValue)) {
                                            return
                                        }
                                        var newVoltageDivider = (measuredVoltageValue * battVoltageDivider.value) / controller.vehicle.battery.voltage.value
                                        if (newVoltageDivider > 0) {
                                            battVoltageDivider.value = newVoltageDivider
                                        }
                                    }
                                }
                            } // Column
                        } // QGCFlickable
                    } // QGCViewDialog
                } // Component - calcVoltageDividerDlgComponent

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
                                    text:       "使用外部电流表和下面的输入值测量电流消耗. 点击计算设置新的安培每伏特."
                                }

                                Grid {
                                    columns: 2
                                    spacing: ScreenTools.defaultFontPixelHeight / 2
                                    verticalItemAlignment: Grid.AlignVCenter

                                    QGCLabel {
                                        text: "测量电流值:"
                                    }
                                    QGCTextField { id: measuredCurrent }

                                    QGCLabel { text: "电流:" }
                                    QGCLabel { text: controller.vehicle.battery.current.valueString }

                                    QGCLabel { text: "安培每伏特:" }
                                    FactLabel { fact: battAmpsPerVolt }
                                }

                                QGCButton {
                                    text: "计算"

                                    onClicked:  {
                                        var measuredCurrentValue = parseFloat(measuredCurrent.text)
                                        if (measuredCurrentValue == 0) {
                                            return
                                        }
                                        var newAmpsPerVolt = (measuredCurrentValue * battAmpsPerVolt.value) / controller.vehicle.battery.current.value
                                        if (newAmpsPerVolt != 0) {
                                            battAmpsPerVolt.value = newAmpsPerVolt
                                        }
                                    }
                                }
                            } // Column
                        } // QGCFlickable
                    } // QGCViewDialog
                } // Component - calcAmpsPerVoltDlgComponent

                QGCGroupBox {
                    id:     batteryGroup
                    title:  qsTr("电池")

                    GridLayout {
                        id:             batteryGrid
                        columns:        5
                        columnSpacing:  ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            text:               qsTr("电芯数量 (串联)")
                        }

                        FactTextField {
                            id:         cellsField
                            width:      textEditWidth
                            fact:       battNumCells
                            showUnits:  true
                        }

                        QGCColoredImage {
                            id:                     batteryImage
                            Layout.rowSpan:         3
                            width:                  height * 0.75
                            height:                 100
                            sourceSize.height:      height
                            fillMode:               Image.PreserveAspectFit
                            smooth:                 true
                            color:                  qgcPal.text
                            cache:                  false
                            source:                 getBatteryImage();
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 battHighLabel
                            text:               qsTr("满电压值 (单芯)")
                        }

                        FactTextField {
                            id:         battHighField
                            width:      textEditWidth
                            fact:       battHighVolt
                            showUnits:  true
                        }

                        QGCLabel {
                            text:   qsTr("电池最大电压:")
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battHighVolt.value).toFixed(1) + ' V'
                        }

                        QGCLabel {
                            id:                 battLowLabel
                            text:               qsTr("低电压 (单芯)")
                        }

                        FactTextField {
                            id:         battLowField
                            width:      textEditWidth
                            fact:       battLowVolt
                            showUnits:  true
                        }

                        QGCLabel {
                            text:   qsTr("电池最小电压:")
                        }

                        QGCLabel {
                            text:   (battNumCells.value * battLowVolt.value).toFixed(1) + ' V'
                        }

                        QGCLabel {
                            text:               qsTr("分压")
                        }

                        FactTextField {
                            id:                 voltMultField
                            fact:               battVoltageDivider
                        }

                        QGCButton {
                            id:                 voltMultCalculateButton
                            text:               "计算"
                            onClicked:          showDialog(calcVoltageDividerDlgComponent, qsTr("计算分压"), powerPage.showDialogDefaultWidth, StandardButton.Close)
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 voltMultHelp
                            Layout.columnSpan:  batteryGrid.columns
                            Layout.fillWidth:   true
                            font.pointSize:     ScreenTools.smallFontPointSize
                            wrapMode:           Text.WordWrap
                            text:               "如果无人机检测到的电池电压和外部使用电压表测得的电压差别较大，您可以调整分压比来进行校正. " +
                                                "单击计算按钮以计算新值."
                        }

                        QGCLabel {
                            id:                 ampPerVoltLabel
                            text:               qsTr("安培每伏特")
                        }

                        FactTextField {
                            id:                 ampPerVoltField
                            fact:               battAmpsPerVolt
                        }

                        QGCButton {
                            id:                 ampPerVoltCalculateButton
                            text:               "计算"
                            onClicked:          showDialog(calcAmpsPerVoltDlgComponent, qsTr("计算安培每伏特"), powerPage.showDialogDefaultWidth, StandardButton.Close)
                        }

                        Item { width: 1; height: 1; Layout.columnSpan: 2 }

                        QGCLabel {
                            id:                 ampPerVoltHelp
                            Layout.columnSpan:  batteryGrid.columns
                            Layout.fillWidth:   true
                            font.pointSize:     ScreenTools.smallFontPointSize
                            wrapMode:           Text.WordWrap
                            text:               "如果无人机检测到的电流和外部使用电流表测得的电流差别较大，您可以调整安培每伏特来进行校正. " +
                                                "单击计算按钮以计算新值."
                        }
                    } // Grid
                } // QGCGroupBox - Battery settings

                QGCGroupBox {
                    anchors.left:   batteryGroup.left
                    anchors.right:  batteryGroup.right
                    title:          qsTr("电调最大最小PWM值校准")

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            color:              qgcPal.warningText
                            wrapMode:           Text.WordWrap
                            text:               qsTr("警告: 需要先将桨叶拿掉再进行电调校准.")
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            text: qsTr("执行当前操作需要连接USB.")
                        }

                        QGCButton {
                            text:       qsTr("校准")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.calibrateEsc()
                        }
                    }
                }

                QGCCheckBox {
                    id:         showUAVCAN
                    text:       qsTr("显示UAVCAN设置")
                    checked:    uavcanEnable.rawValue != 0
                }

                QGCGroupBox {
                    anchors.left:   batteryGroup.left
                    anchors.right:  batteryGroup.right
                    title:          qsTr("UAVCAN总线设置")
                    visible:        showUAVCAN.checked

                    Row {
                        id:         uavCanConfigRow
                        spacing:    ScreenTools.defaultFontPixelWidth

                        FactComboBox {
                            id:                 uavcanEnabledCheckBox
                            width:              ScreenTools.defaultFontPixelWidth * 20
                            fact:               uavcanEnable
                            indexModel:         false
                        }

                        QGCLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            text:                   qsTr("修改需要重启")
                        }
                    }
                }

                QGCGroupBox {
                    anchors.left:   batteryGroup.left
                    anchors.right:  batteryGroup.right
                    title:          qsTr("UAVCAN电机运动指数和方向分配")
                    visible:        showUAVCAN.checked

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            color:              qgcPal.warningText
                            text:               qsTr("警告: 需要先将桨叶拿掉再进行UAVCAN电调设置.")
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("电调参数在设置好后可以从编辑器中查看.")
                            Layout.fillWidth:   true
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("开始执行, 然后按照他们的运动指数把每个马达转到它的转向方向.")
                            Layout.fillWidth:   true
                        }

                        QGCButton {
                            text:       qsTr("开始配置")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.busConfigureActuators()
                        }

                        QGCButton {
                            text:       qsTr("停止配置")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.stopBusConfigureActuators()
                        }
                    }
                }

                QGCCheckBox {
                    id:     showAdvanced
                    text:   qsTr("显示高级设置")
                }

                QGCGroupBox {
                    anchors.left:   batteryGroup.left
                    anchors.right:  batteryGroup.right
                    title:          qsTr("高级电源设置")
                    visible:        showAdvanced.checked

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel {
                                text:               qsTr("全负载压降 (单芯)")
                                anchors.baseline:   battDropField.baseline
                            }

                            FactTextField {
                                id:         battDropField
                                width:      textEditWidth
                                fact:       battVoltLoadDrop
                                showUnits:  true
                            }
                        }

                        QGCLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("电池在大油门时显示低电压. 输入最低油门和满油门时的压差 ") +
                                                qsTr("油门, 除以电芯数量. 不确认时请使用默认值. ") +
                                                highlightPrefix + qsTr("如果数值过高, 电池将过放而受到损坏.") + highlightSuffix
                            Layout.fillWidth:   true
                        }

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth

                            QGCLabel {
                                text: qsTr("最小补偿电压:")
                            }

                            QGCLabel {
                                text: ((battNumCells.value * battLowVolt.value) - (battNumCells.value * battVoltLoadDrop.value)).toFixed(1) + qsTr(" V")
                            }
                        }
                    } // Column
                } // QGCGroupBox - Advanced power settings
            } // Column
        } // Item
    } // Component
} // SetupPage
