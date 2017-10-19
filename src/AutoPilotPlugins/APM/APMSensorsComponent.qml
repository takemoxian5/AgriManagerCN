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
import QtQuick.Layouts          1.2

import QGroundControl               1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ArduPilot     1.0

SetupPage {
    id:             sensorsPage
    pageComponent:  sensorsPageComponent

    Component {
        id:             sensorsPageComponent

        Item {
            width:  availableWidth
            height: availableHeight

            // Help text which is shown both in the status text area prior to pressing a cal button and in the
            // pre-calibration dialog.

            readonly property string orientationHelpSet:    "如果方向在飞行方向，选择None."
            readonly property string orientationHelpCal:    "在校准之前确定方位设置是正确的. " + orientationHelpSet
            readonly property string compassRotationText:   "如果指南针或GPS模块和飞行方向安装的一致, 使用默认值 (None)"

            readonly property string compassHelp:   "对于罗盘的校准，你需要通过一系列的位置旋转你的无人机."
            readonly property string gyroHelp:      "陀螺仪的校准，你需要将你的飞行器放在一个表面上然后离开它."
            readonly property string accelHelp:     "对于加速计的校准，你需要将你的无人机放置在一个完美的表面上并且在每一个方向上保持它在每一个方向上几秒钟."
            readonly property string levelHelp:     "要达到水平校准，你需要将飞行器放置在它的水平飞行位置并按下OK."

            readonly property string statusTextAreaDefaultText: "通过单击左侧的一个按钮来启动单个校准步骤."

            // Used to pass help text to the preCalibrationDialog dialog
            property string preCalibrationDialogHelp

            property string _postCalibrationDialogText
            property var    _postCalibrationDialogParams

            readonly property string _badCompassCalText: "指南针1%的校准似乎很差. " +
                                                         "检查你无人机里的罗盘位置并重新校准."

            readonly property int sideBarH1PointSize:  ScreenTools.mediumFontPointSize
            readonly property int mainTextH1PointSize: ScreenTools.mediumFontPointSize // Seems to be unused

            readonly property int rotationColumnWidth: 250

            property Fact noFact: Fact { }

            property bool accelCalNeeded:                   controller.accelSetupNeeded
            property bool compassCalNeeded:                 controller.compassSetupNeeded

            property Fact boardRot:                         controller.getParameterFact(-1, "AHRS_ORIENTATION")

            readonly property int _calTypeCompass:  1   ///< Calibrate compass
            readonly property int _calTypeAccel:    2   ///< Calibrate accel
            readonly property int _calTypeSet:      3   ///< Set orientations only
            readonly property int _buttonWidth:     ScreenTools.defaultFontPixelWidth * 15

            property bool   _orientationsDialogShowCompass: true
            property string _orientationDialogHelp:         orientationHelpSet
            property int    _orientationDialogCalType
            property var    _activeVehicle:                 QGroundControl.multiVehicleManager.activeVehicle
            property real   _margins:                       ScreenTools.defaultFontPixelHeight / 2

            function showOrientationsDialog(calType) {
                var dialogTitle
                var buttons = StandardButton.Ok

                _orientationDialogCalType = calType
                switch (calType) {
                case _calTypeCompass:
                    _orientationsDialogShowCompass = true
                    _orientationDialogHelp = orientationHelpCal
                    dialogTitle = qsTr("校准指南针")
                    buttons |= StandardButton.Cancel
                    break
                case _calTypeAccel:
                    _orientationsDialogShowCompass = false
                    _orientationDialogHelp = orientationHelpCal
                    dialogTitle = qsTr("校准加速度计")
                    buttons |= StandardButton.Cancel
                    break
                case _calTypeSet:
                    _orientationsDialogShowCompass = true
                    _orientationDialogHelp = orientationHelpSet
                    dialogTitle = qsTr("传感器设置")
                    break
                }

                showDialog(orientationsDialogComponent, dialogTitle, qgcView.showDialogDefaultWidth, buttons)
            }

            APMSensorParams {
                id:                     sensorParams
                factPanelController:    controller
            }

            APMSensorsComponentController {
                id:                         controller
                factPanel:                  sensorsPage.viewPanel
                statusLog:                  statusTextArea
                progressBar:                progressBar
                nextButton:                 nextButton
                cancelButton:               cancelButton
                orientationCalAreaHelpText: orientationCalAreaHelpText

                property var rgCompassCalFitness: [ controller.compass1CalFitness, controller.compass2CalFitness, controller.compass3CalFitness ]

                onResetStatusTextArea: statusLog.text = statusTextAreaDefaultText

                onWaitingForCancelChanged: {
                    if (controller.waitingForCancel) {
                        showMessage(qsTr("校准取消"), qsTr("等待无人机响应取消。这可能需要几秒钟."), 0)
                    } else {
                        hideDialog()
                    }
                }

                onCalibrationComplete: {
                    switch (calType) {
                    case APMSensorsComponentController.CalTypeAccel:
                        showMessage(qsTr("校准完成"), qsTr("加速度计校准完成."), StandardButton.Ok)
                        break
                    case APMSensorsComponentController.CalTypeOffboardCompass:
                        showMessage(qsTr("校准完成"), qsTr("指南针校准完成."), StandardButton.Ok)
                        break
                    case APMSensorsComponentController.CalTypeOnboardCompass:
                        showDialog(postOnboardCompassCalibrationComponent, qsTr("校准完成"), qgcView.showDialogDefaultWidth, StandardButton.Ok)
                        break
                    }
                }

                onSetAllCalButtonsEnabled: {
                    buttonColumn.enabled = enabled
                }
            }

            Component.onCompleted: {
                var usingUDP = controller.usingUDPLink()
                if (usingUDP) {
                    showMessage("Sensor Calibration", "Performing sensor calibration over a WiFi connection can be unreliable. If you run into problems try using a direct USB connection instead.", StandardButton.Ok)
                }
            }

            QGCPalette { id: qgcPal; colorGroupEnabled: true }

            Component {
                id: singleCompassOnboardResultsComponent

                Column {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        Math.round(ScreenTools.defaultFontPixelHeight / 2)
                    visible:        sensorParams.rgCompassAvailable[index]

                    property real greenMaxThreshold:   8 * (sensorParams.rgCompassExternal[index] ? 1 : 2)
                    property real yellowMaxThreshold:  15 * (sensorParams.rgCompassExternal[index] ? 1 : 2)
                    property real fitnessRange:        25 * (sensorParams.rgCompassExternal[index] ? 1 : 2)

                    Item {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height:         ScreenTools.defaultFontPixelHeight

                        Row {
                            id:             fitnessRow
                            anchors.fill:   parent

                            Rectangle {
                                width:  parent.width * (greenMaxThreshold / fitnessRange)
                                height: parent.height
                                color:  "green"
                            }
                            Rectangle {
                                width:  parent.width * ((yellowMaxThreshold - greenMaxThreshold) / fitnessRange)
                                height: parent.height
                                color:  "yellow"
                            }
                            Rectangle {
                                width:  parent.width * ((fitnessRange - yellowMaxThreshold) / fitnessRange)
                                height: parent.height
                                color:  "red"
                            }
                        }

                        Rectangle {
                            height:                 fitnessRow.height * 0.66
                            width:                  height
                            anchors.verticalCenter: fitnessRow.verticalCenter
                            x:                      (fitnessRow.width * (Math.min(Math.max(controller.rgCompassCalFitness[index], 0.0), fitnessRange) / fitnessRange)) - (width / 2)
                            radius:                 height / 2
                            color:                  "white"
                            border.color:           "black"
                        }
                    }

                    Column {
                        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            Math.round(ScreenTools.defaultFontPixelHeight / 4)

                        QGCLabel {
                            text: "指南针 " + (index+1) + " " +
                                  (sensorParams.rgCompassPrimary[index] ? "(主要" : "(次要") +
                                  (sensorParams.rgCompassExternalParamAvailable[index] ?
                                       (sensorParams.rgCompassExternal[index] ? ", 外部" : ", 内部" ) :
                                       "") +
                                  ")"
                        }

                        FactCheckBox {
                            text:       "使用指南针"
                            fact:       sensorParams.rgCompassUseFact[index]
                            visible:    sensorParams.rgCompassUseParamAvailable[index] && !sensorParams.rgCompassPrimary[index]
                        }
                    }
                }
            }

            Component {
                id: postOnboardCompassCalibrationComponent

                QGCViewDialog {
                    Column {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        spacing:            ScreenTools.defaultFontPixelHeight

                        Repeater {
                            model:      3
                            delegate:   singleCompassOnboardResultsComponent
                        }

                        QGCLabel {
                            anchors.left:   parent.left
                            anchors.right:  parent.right
                            wrapMode:       Text.WordWrap
                            text:           qsTr("在指示条中显示的是每个罗盘的校准质量.\n\n") +
                                            qsTr("- 绿色表示一个运转良好的罗盘.\n") +
                                            qsTr("- 黄色表示有问题的罗盘或校准.\n") +
                                            qsTr("- 红色表示不应该使用的指南针.\n\n") +
                                            qsTr("你必须在每次校准之后重新启动你的无人机.")
                        }
                    }
                }
            }

            Component {
                id: singleCompassSettingsComponent

                Column {
                    spacing: Math.round(ScreenTools.defaultFontPixelHeight / 2)
                    visible: sensorParams.rgCompassAvailable[index]

                    QGCLabel {
                        text: "指南针 " + (index+1) + " " +
                              (sensorParams.rgCompassPrimary[index] ? "(主要" : "(次要") +
                              (sensorParams.rgCompassExternalParamAvailable[index] ?
                                   (sensorParams.rgCompassExternal[index] ? ", 外部" : ", 内部" ) :
                                   "") +
                              ")"
                    }

                    Column {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth * 2
                        anchors.left:       parent.left
                        spacing:            Math.round(ScreenTools.defaultFontPixelHeight / 4)

                        FactCheckBox {
                            text:       "使用指南针"
                            fact:       sensorParams.rgCompassUseFact[index]
                            visible:    sensorParams.rgCompassUseParamAvailable[index] && !sensorParams.rgCompassPrimary[index]
                        }

                        Column {
                            visible: sensorParams.rgCompassExternal[index] && sensorParams.rgCompassRotParamAvailable[index]

                            QGCLabel { text: qsTr("方向:") }

                            FactComboBox {
                                width:      rotationColumnWidth
                                indexModel: false
                                fact:       sensorParams.rgCompassRotFact[index]
                            }
                        }
                    }
                }
            }

            Component {
                id: orientationsDialogComponent

                QGCViewDialog {
                    id: orientationsDialog

                    function accept() {
                        if (_orientationDialogCalType == _calTypeAccel) {
                            controller.calibrateAccel()
                        } else if (_orientationDialogCalType == _calTypeCompass) {
                            controller.calibrateCompass()
                        }
                        orientationsDialog.hideDialog()
                    }

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
                                text:       _orientationDialogHelp
                            }

                            Column {
                                QGCLabel { text: qsTr("无人机方向:") }

                                FactComboBox {
                                    width:      rotationColumnWidth
                                    indexModel: false
                                    fact:       boardRot
                                }
                            }

                            Repeater {
                                model:      _orientationsDialogShowCompass ? 3 : 0
                                delegate:   singleCompassSettingsComponent
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - orientationsDialogComponent

            Component {
                id: compassMotDialogComponent

                QGCViewDialog {
                    id: compassMotDialog

                    function accept() {
                        controller.calibrateMotorInterference()
                        compassMotDialog.hideDialog()
                    }

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
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           "这是推荐给那些只有内部罗盘的无人机以及那些对罗盘有严重干扰的电机，电线，等等. " +
                                                "如果你有一个电池电流监测器你就可以很好地工作因为磁场干扰是线性的. " +
                                                "从技术上讲，在使用遥控器的情况下，设置CompassMot是可行的，但这是不推荐的."
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           "把你的桨叶拆下来，把它们翻转过来，然后把它们转到机架上的一个位置. " +
                                                "在这种配置中，当油门被提升时，他们应该将无人机推向地面."
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           "确保飞机的安全(也许是带着磁带)，这样它就不会移动了."
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           "打开你的发射机，把油门保持在零."
                            }

                            QGCLabel {
                                anchors.left:   parent.left
                                anchors.right:  parent.right
                                wrapMode:       Text.WordWrap
                                text:           "点击Ok开始CompassMot校准."
                            }
                        } // Column
                    } // QGCFlickable
                } // QGCViewDialog
            } // Component - compassMotDialogComponent

            Component {
                id: levelHorizonDialogComponent

                QGCViewDialog {
                    id: levelHorizonDialog

                    function accept() {
                        controller.levelHorizon()
                        levelHorizonDialog.hideDialog()
                    }

                    QGCLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           qsTr("要达到水平校准，你需要将飞行器放置在它的水平飞行位置并按下Ok.")
                    }
                } // QGCViewDialog
            } // Component - levelHorizonDialogComponent

            Component {
                id: calibratePressureDialogComponent

                QGCViewDialog {
                    id: calibratePressureDialog

                    function accept() {
                        controller.calibratePressure()
                        calibratePressureDialog.hideDialog()
                    }

                    QGCLabel {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        wrapMode:       Text.WordWrap
                        text:           _helpText

                        readonly property string _altText:      _activeVehicle.sub ? qsTr("深度") : qsTr("高度")
                        readonly property string _helpText:     qsTr("压力校准将在当前压力读数下将%1设为零. %2").arg(_altText).arg(_helpTextFW)
                        readonly property string _helpTextFW:   _activeVehicle.fixedWing ? qsTr("为了校准空气速度传感器，可以将其从风中屏蔽. 在校准过程中不要碰到或堵塞传感器.") : ""
                    }
                } // QGCViewDialog
            } // Component - calibratePressureDialogComponent

            QGCFlickable {
                id:             buttonFlickable
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                width:          _buttonWidth
                contentHeight:  nextCancelColumn.y + nextCancelColumn.height + _margins

                // Calibration button column - Calibratin buttons are kept in a separate column from Next/Cancel buttons
                // so we can enable/disable them all as a group
                Column {
                    id:                 buttonColumn
                    spacing:            _margins
                    Layout.alignment:   Qt.AlignLeft | Qt.AlignTop

                    IndicatorButton {
                        width:          _buttonWidth
                        text:           qsTr("加速度计")
                        indicatorGreen: !accelCalNeeded

                        onClicked: showOrientationsDialog(_calTypeAccel)
                    }

                    IndicatorButton {
                        width:          _buttonWidth
                        text:           qsTr("指南针")
                        indicatorGreen: !compassCalNeeded

                        onClicked: {
                            if (controller.accelSetupNeeded) {
                                showMessage(qsTr("校准指南针"), qsTr("加速度计必须在指南针之前校准."), StandardButton.Ok)
                            } else {
                                showOrientationsDialog(_calTypeCompass)
                            }
                        }
                    }

                    QGCButton {
                        width:  _buttonWidth
                        text:   _levelHorizonText

                        readonly property string _levelHorizonText: qsTr("水平校准")

                        onClicked: {
                            if (controller.accelSetupNeeded) {
                                showMessage(_levelHorizonText, qsTr("加速度计必须在水平校准之前进行校准."), StandardButton.Ok)
                            } else {
                                showDialog(levelHorizonDialogComponent, _levelHorizonText, qgcView.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)
                            }
                        }
                    }

                    QGCButton {
                        width:      _buttonWidth
                        text:       _calibratePressureText
                        onClicked:  showDialog(calibratePressureDialogComponent, _calibratePressureText, qgcView.showDialogDefaultWidth, StandardButton.Cancel | StandardButton.Ok)

                        readonly property string _calibratePressureText: _activeVehicle.fixedWing ? qsTr("校准气压/空速") : qsTr("调整气压")
                    }

                    QGCButton {
                        width:      _buttonWidth
                        text:       qsTr("指南针/电机")
                        visible:    _activeVehicle ? _activeVehicle.supportsMotorInterference : false

                        onClicked:  showDialog(compassMotDialogComponent, qsTr("指南针/电机干涉校准"), qgcView.showDialogFullWidth, StandardButton.Cancel | StandardButton.Ok)
                    }

                    QGCButton {
                        width:      _buttonWidth
                        text:       qsTr("传感器设置")
                        onClicked:  showOrientationsDialog(_calTypeSet)
                    }
                } // Column - Cal Buttons

                Column {
                    id:                 nextCancelColumn
                    anchors.topMargin:  buttonColumn.spacing
                    anchors.top:        buttonColumn.bottom
                    anchors.left:       buttonColumn.left
                    spacing:            buttonColumn.spacing

                    QGCButton {
                        id:         nextButton
                        width:      _buttonWidth
                        text:       qsTr("下一步")
                        enabled:    false
                        onClicked:  controller.nextClicked()
                    }

                    QGCButton {
                        id:         cancelButton
                        width:      _buttonWidth
                        text:       qsTr("取消")
                        enabled:    false
                        onClicked:  controller.cancelCalibration()
                    }
                }
            } // QGCFlickable - buttons

            /// Right column - cal area
            Column {
                anchors.leftMargin: _margins
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                anchors.left:       buttonFlickable.right
                anchors.right:      parent.right

                ProgressBar {
                    id:             progressBar
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                }

                Item { height: ScreenTools.defaultFontPixelHeight; width: 10 } // spacer

                Item {
                    id:     centerPanel
                    width:  parent.width
                    height: parent.height - y

                    TextArea {
                        id:             statusTextArea
                        anchors.fill:   parent
                        readOnly:       true
                        frameVisible:   false
                        text:           statusTextAreaDefaultText

                        style: TextAreaStyle {
                            textColor:          qgcPal.text
                            backgroundColor:    qgcPal.windowShade
                        }
                    }

                    Rectangle {
                        id:             orientationCalArea
                        anchors.fill:   parent
                        visible:        controller.showOrientationCalArea
                        color:          qgcPal.windowShade

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
                            spacing:            ScreenTools.defaultFontPixelWidth

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
                } // Item - Cal display area
            } // Column - cal display
        } // Row
    } // Component - sensorsPageComponent
} // SetupPage
