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
import QtQuick.Dialogs          1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

SetupPage {
    id:             sensorsPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  availableWidth
            height: availableHeight

            // Help text which is shown both in the status text area prior to pressing a cal button and in the
            // pre-calibration dialog.

            readonly property string boardRotationText: qsTr("如果飞控方向和飞行方向一致, 选择 ROTATION_NONE.")
            readonly property string compassRotationText: qsTr("如果飞控方向和飞行方向一致, 选择 ROTATION_NONE.")

            readonly property string compassHelp:   qsTr("罗盘校准，你需要在一系列的位置旋转无人机. 点击确认开始校准.")
            readonly property string gyroHelp:      qsTr("陀螺仪校准，你需要将飞行器放在一个表面上然后离开它. 点击确认开始校准.")
            readonly property string accelHelp:     qsTr("加速计校准，你需要将无人机放置在一个完美的表面上，并且在每一个方向上保持几秒钟静止不动. 点击确认开始校准.")
            readonly property string levelHelp:     qsTr("要校准水平，你需要将飞行器放置在它的水平飞行位置并点击确认.")
            readonly property string airspeedHelp:  qsTr("空速校准，你需要让空速传感器远离任何风然后吹过传感器. 在校准过程中不要碰到传感器或堵塞通道.")

            readonly property string statusTextAreaDefaultText: qsTr("通过单击左侧的一个按钮来启动单个校准步骤.")

            // Used to pass what type of calibration is being performed to the preCalibrationDialog
            property string preCalibrationDialogType

            // Used to pass help text to the preCalibrationDialog dialog
            property string preCalibrationDialogHelp

            readonly property int rotationColumnWidth: ScreenTools.defaultFontPixelWidth * 30
            readonly property var rotations: [
                "ROTATION_NONE",
                "ROTATION_YAW_45",
                "ROTATION_YAW_90",
                "ROTATION_YAW_135",
                "ROTATION_YAW_180",
                "ROTATION_YAW_225",
                "ROTATION_YAW_270",
                "ROTATION_YAW_315",
                "ROTATION_ROLL_180",
                "ROTATION_ROLL_180_YAW_45",
                "ROTATION_ROLL_180_YAW_90",
                "ROTATION_ROLL_180_YAW_135",
                "ROTATION_PITCH_180",
                "ROTATION_ROLL_180_YAW_225",
                "ROTATION_ROLL_180_YAW_270",
                "ROTATION_ROLL_180_YAW_315",
                "ROTATION_ROLL_90",
                "ROTATION_ROLL_90_YAW_45",
                "ROTATION_ROLL_90_YAW_90",
                "ROTATION_ROLL_90_YAW_135",
                "ROTATION_ROLL_270",
                "ROTATION_ROLL_270_YAW_45",
                "ROTATION_ROLL_270_YAW_90",
                "ROTATION_ROLL_270_YAW_135",
                "ROTATION_PITCH_90",
                "ROTATION_PITCH_270",
                "ROTATION_ROLL_270_YAW_270",
                "ROTATION_ROLL_180_PITCH_270",
                "ROTATION_PITCH_90_YAW_180",
                "ROTATION_ROLL_90_PITCH_90"
            ]

            property Fact cal_mag0_id:      controller.getParameterFact(-1, "CAL_MAG0_ID")
            property Fact cal_mag1_id:      controller.getParameterFact(-1, "CAL_MAG1_ID")
            property Fact cal_mag2_id:      controller.getParameterFact(-1, "CAL_MAG2_ID")
            property Fact cal_mag0_rot:     controller.getParameterFact(-1, "CAL_MAG0_ROT")
            property Fact cal_mag1_rot:     controller.getParameterFact(-1, "CAL_MAG1_ROT")
            property Fact cal_mag2_rot:     controller.getParameterFact(-1, "CAL_MAG2_ROT")

            property Fact cal_gyro0_id:     controller.getParameterFact(-1, "CAL_GYRO0_ID")
            property Fact cal_acc0_id:      controller.getParameterFact(-1, "CAL_ACC0_ID")

            property Fact sens_board_rot:   controller.getParameterFact(-1, "SENS_BOARD_ROT")
            property Fact sens_board_x_off: controller.getParameterFact(-1, "SENS_BOARD_X_OFF")
            property Fact sens_board_y_off: controller.getParameterFact(-1, "SENS_BOARD_Y_OFF")
            property Fact sens_board_z_off: controller.getParameterFact(-1, "SENS_BOARD_Z_OFF")
            property Fact sens_dpres_off:   controller.getParameterFact(-1, "SENS_DPRES_OFF")

            // Id > = signals compass available, rot < 0 signals internal compass
            property bool showCompass0Rot: cal_mag0_id.value > 0 && cal_mag0_rot.value >= 0
            property bool showCompass1Rot: cal_mag1_id.value > 0 && cal_mag1_rot.value >= 0
            property bool showCompass2Rot: cal_mag2_id.value > 0 && cal_mag2_rot.value >= 0

            property bool   _sensorsHaveFixedOrientation:   QGroundControl.corePlugin.options.sensorsHaveFixedOrientation
            property bool   _wifiReliableForCalibration:    QGroundControl.corePlugin.options.wifiReliableForCalibration
            property int    _buttonWidth:                   ScreenTools.defaultFontPixelWidth * 15


            SensorsComponentController {
                id:                         controller
                factPanel:                  sensorsPage.viewPanel
                statusLog:                  statusTextArea
                progressBar:                progressBar
                compassButton:              compassButton
                gyroButton:                 gyroButton
                accelButton:                accelButton
                airspeedButton:             airspeedButton
                levelButton:                levelButton
                cancelButton:               cancelButton
                setOrientationsButton:      setOrientationsButton
                orientationCalAreaHelpText: orientationCalAreaHelpText

                onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

                onSetCompassRotations: {
                    if (!_sensorsHaveFixedOrientation && (showCompass0Rot || showCompass1Rot || showCompass2Rot)) {
                        setOrientationsDialogShowBoardOrientation = false
                        showDialog(setOrientationsDialogComponent, qsTr("设置指南针方向(s)"), sensorsPage.showDialogDefaultWidth, StandardButton.Ok)
                    }
                }

                onWaitingForCancelChanged: {
                    if (controller.waitingForCancel) {
                        showMessage(qsTr("校准取消"), qsTr("等待无人机响应取消操作. 将会花费几秒钟."), 0)
                    } else {
                        hideDialog()
                    }
                }

            }

            Component.onCompleted: {
                var usingUDP = controller.usingUDPLink()
                if (usingUDP && !_wifiReliableForCalibration) {
                    showMessage("传感器校准", "通过WiFi连接上执行传感器校准是不可靠的. 您应该断开连接，使用一个USB连接来执行校准.", StandardButton.Ok)
                }
            }

            Component {
                id: preCalibrationDialogComponent

                QGCViewDialog {
                    id: preCalibrationDialog

                    function accept() {
                        if (preCalibrationDialogType == "gyro") {
                            controller.calibrateGyro()
                        } else if (preCalibrationDialogType == "accel") {
                            controller.calibrateAccel()
                        } else if (preCalibrationDialogType == "level") {
                            controller.calibrateLevel()
                        } else if (preCalibrationDialogType == "compass") {
                            controller.calibrateCompass()
                        } else if (preCalibrationDialogType == "airspeed") {
                            controller.calibrateAirspeed()
                        }
                        preCalibrationDialog.hideDialog()
                    }

                    Column {
                        anchors.fill:   parent
                        spacing:        ScreenTools.defaultFontPixelWidth / 2

                        QGCLabel {
                            width:      parent.width
                            wrapMode:   Text.WordWrap
                            text:       preCalibrationDialogHelp
                        }

                        Column {
                            spacing:        5
                            visible:        !_sensorsHaveFixedOrientation

                            QGCLabel {
                                id:         boardRotationHelp
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                visible:    (preCalibrationDialogType != "airspeed") && (preCalibrationDialogType != "gyro")
                                text:       boardRotationText
                            }

                            Column {
                                visible:    boardRotationHelp.visible
                                QGCLabel {
                                    text: qsTr("控制器方向:")
                                }

                                FactComboBox {
                                    id:     boardRotationCombo
                                    width:  rotationColumnWidth;
                                    model:  rotations
                                    fact:   sens_board_rot
                                }
                            }
                        }
                    }
                }
            }

            property bool setOrientationsDialogShowBoardOrientation: true

            Component {
                id: setOrientationsDialogComponent

                QGCViewDialog {
                    id: setOrientationsDialog

                    QGCFlickable {
                        anchors.fill:   parent
                        contentHeight:  columnLayout.height
                        clip:           true

                        Column {
                            id:                 columnLayout
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        parent.top
                            spacing:            ScreenTools.defaultFontPixelHeight

                            QGCLabel {
                                width:      parent.width
                                wrapMode:   Text.WordWrap
                                text:       boardRotationText
                            }

                            Column {
                                visible: setOrientationsDialogShowBoardOrientation

                                QGCLabel {
                                    text: qsTr("控制器方向:")
                                }

                                FactComboBox {
                                    id:     boardRotationCombo
                                    width:  rotationColumnWidth;
                                    model:  rotations
                                    fact:   sens_board_rot
                                }
                            }

                            Column {
                                // Compass 0 rotation
                                Component {
                                    id: compass0ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("外部指南针方向:")
                                    }
                                }

                                Component {
                                    id: compass0ComponentCombo2

                                    FactComboBox {
                                        id:     compass0RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag0_rot
                                    }
                                }

                                Loader { sourceComponent: showCompass0Rot ? compass0ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass0Rot ? compass0ComponentCombo2 : null }
                            }

                            Column {
                                // Compass 1 rotation
                                Component {
                                    id: compass1ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("外部指南针 1 方向:")
                                    }
                                }

                                Component {
                                    id: compass1ComponentCombo2

                                    FactComboBox {
                                        id:     compass1RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag1_rot
                                    }
                                }

                                Loader { sourceComponent: showCompass1Rot ? compass1ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass1Rot ? compass1ComponentCombo2 : null }
                            }

                            Column {
                                spacing: ScreenTools.defaultFontPixelWidth

                                // Compass 2 rotation
                                Component {
                                    id: compass2ComponentLabel2

                                    QGCLabel {
                                        text: qsTr("指南针 2 方向")
                                    }
                                }

                                Component {
                                    id: compass2ComponentCombo2

                                    FactComboBox {
                                        id:     compass1RotationCombo
                                        width:  rotationColumnWidth
                                        model:  rotations
                                        fact:   cal_mag2_rot
                                    }
                                }
                                Loader { sourceComponent: showCompass2Rot ? compass2ComponentLabel2 : null }
                                Loader { sourceComponent: showCompass2Rot ? compass2ComponentCombo2 : null }
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - setOrientationsDialogComponent

            QGCFlickable {
                id:             buttonFlickable
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width:          _buttonWidth
                contentHeight:  buttonColumn.height + buttonColumn.spacing

                Column {
                    id:         buttonColumn
                    spacing:    ScreenTools.defaultFontPixelHeight / 2

                    IndicatorButton {
                        id:             compassButton
                        width:          _buttonWidth
                        text:           qsTr("指南针")
                        indicatorGreen: cal_mag0_id.value != 0
                        visible:        QGroundControl.corePlugin.options.showSensorCalibrationCompass

                        onClicked: {
                            preCalibrationDialogType = "compass"
                            preCalibrationDialogHelp = compassHelp
                            showDialog(preCalibrationDialogComponent, qsTr("指南针校准"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                        }
                    }

                    IndicatorButton {
                        id:             gyroButton
                        width:          _buttonWidth
                        text:           qsTr("陀螺仪")
                        indicatorGreen: cal_gyro0_id.value != 0
                        visible:        QGroundControl.corePlugin.options.showSensorCalibrationGyro

                        onClicked: {
                            preCalibrationDialogType = "gyro"
                            preCalibrationDialogHelp = gyroHelp
                            showDialog(preCalibrationDialogComponent, qsTr("陀螺仪校准"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                        }
                    }

                    IndicatorButton {
                        id:             accelButton
                        width:          _buttonWidth
                        text:           qsTr("加速度计")
                        indicatorGreen: cal_acc0_id.value != 0
                        visible:        QGroundControl.corePlugin.options.showSensorCalibrationAccel

                        onClicked: {
                            preCalibrationDialogType = "accel"
                            preCalibrationDialogHelp = accelHelp
                            showDialog(preCalibrationDialogComponent, qsTr("加速度计校准"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                        }
                    }

                    IndicatorButton {
                        id:             levelButton
                        width:          _buttonWidth
                        text:           qsTr("水平")
                        indicatorGreen: sens_board_x_off.value != 0 || sens_board_y_off != 0 | sens_board_z_off != 0
                        enabled:        cal_acc0_id.value != 0 && cal_gyro0_id.value != 0
                        visible:        QGroundControl.corePlugin.options.showSensorCalibrationLevel

                        onClicked: {
                            preCalibrationDialogType = "level"
                            preCalibrationDialogHelp = levelHelp
                            showDialog(preCalibrationDialogComponent, qsTr("水平校准"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                        }
                    }

                    IndicatorButton {
                        id:             airspeedButton
                        width:          _buttonWidth
                        text:           qsTr("空速计")
                        visible:        (controller.vehicle.fixedWing || controller.vehicle.vtol) && controller.getParameterFact(-1, "CBRK_AIRSPD_CHK").value != 162128 && QGroundControl.corePlugin.options.showSensorCalibrationAirspeed
                        indicatorGreen: sens_dpres_off.value != 0

                        onClicked: {
                            preCalibrationDialogType = "airspeed"
                            preCalibrationDialogHelp = airspeedHelp
                            showDialog(preCalibrationDialogComponent, qsTr("空速计校准"), sensorsPage.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                        }
                    }

                    QGCButton {
                        id:         cancelButton
                        width:      _buttonWidth
                        text:       qsTr("取消")
                        enabled:    false
                        onClicked:  controller.cancelCalibration()
                    }

                    QGCButton {
                        id:         setOrientationsButton
                        width:      _buttonWidth
                        text:       qsTr("设置方向")
                        visible:    !_sensorsHaveFixedOrientation

                        onClicked:  {
                            setOrientationsDialogShowBoardOrientation = true
                            showDialog(setOrientationsDialogComponent, qsTr("设置方向"), sensorsPage.showDialogDefaultWidth, StandardButton.Ok)
                        }
                    }
                } // Column - Buttons
            } // QGCFLickable - Buttons

            Column {
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                anchors.left:       buttonFlickable.right
                anchors.right:      parent.right
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom

                ProgressBar {
                    id:             progressBar
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

                Item {
                    property int calDisplayAreaWidth: parent.width

                    width:  parent.width
                    height: parent.height - y

                    TextArea {
                        id:             statusTextArea
                        width:          parent.calDisplayAreaWidth
                        height:         parent.height
                        readOnly:       true
                        frameVisible:   false
                        text:           statusTextAreaDefaultText

                        style: TextAreaStyle {
                            textColor: qgcPal.text
                            backgroundColor: qgcPal.windowShade
                        }
                    }

                    Rectangle {
                        id:         orientationCalArea
                        width:      parent.calDisplayAreaWidth
                        height:     parent.height
                        visible:    controller.showOrientationCalArea
                        color:      qgcPal.windowShade

                        QGCLabel {
                            id:                 orientationCalAreaHelpText
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalArea.top
                            anchors.left:       orientationCalArea.left
                            width:              parent.width
                            wrapMode:           Text.WordWrap
                            font.pointSize:     ScreenTools.mediumFontPointSize
                        }

                        Flow {
                            anchors.topMargin:  ScreenTools.defaultFontPixelWidth
                            anchors.top:        orientationCalAreaHelpText.bottom
                            anchors.bottom:     parent.bottom
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            spacing:            ScreenTools.defaultFontPixelWidth / 2

                            property real indicatorWidth:   (width / 3) - (spacing * 2)
                            property real indicatorHeight:  (height / 2) - spacing

                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalDownSideVisible
                                calValid:           controller.orientationCalDownSideDone
                                calInProgress:      controller.orientationCalDownSideInProgress
                                calInProgressText:  controller.orientationCalDownSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalDownSideRotate ? "qrc:///qmlimages/VehicleDownRotate.png" : "qrc:///qmlimages/VehicleDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalUpsideDownSideVisible
                                calValid:           controller.orientationCalUpsideDownSideDone
                                calInProgress:      controller.orientationCalUpsideDownSideInProgress
                                calInProgressText:  controller.orientationCalUpsideDownSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalUpsideDownSideRotate ? "qrc:///qmlimages/VehicleUpsideDownRotate.png" : "qrc:///qmlimages/VehicleUpsideDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalNoseDownSideVisible
                                calValid:           controller.orientationCalNoseDownSideDone
                                calInProgress:      controller.orientationCalNoseDownSideInProgress
                                calInProgressText:  controller.orientationCalNoseDownSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalNoseDownSideRotate ? "qrc:///qmlimages/VehicleNoseDownRotate.png" : "qrc:///qmlimages/VehicleNoseDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalTailDownSideVisible
                                calValid:           controller.orientationCalTailDownSideDone
                                calInProgress:      controller.orientationCalTailDownSideInProgress
                                calInProgressText:  controller.orientationCalTailDownSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalTailDownSideRotate ? "qrc:///qmlimages/VehicleTailDownRotate.png" : "qrc:///qmlimages/VehicleTailDown.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalLeftSideVisible
                                calValid:           controller.orientationCalLeftSideDone
                                calInProgress:      controller.orientationCalLeftSideInProgress
                                calInProgressText:  controller.orientationCalLeftSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalLeftSideRotate ? "qrc:///qmlimages/VehicleLeftRotate.png" : "qrc:///qmlimages/VehicleLeft.png"
                            }
                            VehicleRotationCal {
                                width:              parent.indicatorWidth
                                height:             parent.indicatorHeight
                                visible:            controller.orientationCalRightSideVisible
                                calValid:           controller.orientationCalRightSideDone
                                calInProgress:      controller.orientationCalRightSideInProgress
                                calInProgressText:  controller.orientationCalRightSideRotate ? qsTr("旋转") : qsTr("静止不动")
                                imageSource:        controller.orientationCalRightSideRotate ? "qrc:///qmlimages/VehicleRightRotate.png" : "qrc:///qmlimages/VehicleRight.png"
                            }
                        }
                    }
                }
            }
        } // Row
    } // Component
} // SetupPage
