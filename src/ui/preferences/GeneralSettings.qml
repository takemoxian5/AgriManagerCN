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
import QtMultimedia             5.5
import QtQuick.Layouts          1.2

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.SettingsManager       1.0

QGCView {
    id:                 _qgcView
    viewPanel:          panel
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property Fact _percentRemainingAnnounce:    QGroundControl.settingsManager.appSettings.batteryPercentRemainingAnnounce
    property Fact _savePath:                    QGroundControl.settingsManager.appSettings.savePath
    property Fact _appFontPointSize:            QGroundControl.settingsManager.appSettings.appFontPointSize
    property real _labelWidth:                  ScreenTools.defaultFontPixelWidth * 15
    property real _editFieldWidth:              ScreenTools.defaultFontPixelWidth * 30
    property Fact _mapProvider:                 QGroundControl.settingsManager.flightMapSettings.mapProvider
    property Fact _mapType:                     QGroundControl.settingsManager.flightMapSettings.mapType

    readonly property string _requiresRestart:  qsTr("(需要重启)")

    QGCPalette { id: qgcPal }

    QGCViewPanel {
        id:             panel
        anchors.fill:   parent
        QGCFlickable {
            clip:               true
            anchors.fill:       parent
            contentHeight:      settingsColumn.height
            contentWidth:       settingsColumn.width
            Column {
                id:                 settingsColumn
                width:              _qgcView.width
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                anchors.margins:    ScreenTools.defaultFontPixelWidth

                //-----------------------------------------------------------------
                //-- Units
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     unitLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.unitsSettings.visible
                    QGCLabel {
                        id:             unitLabel
                        text:           qsTr("计量 (需要重启)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     unitsCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.unitsSettings.visible
                    Column {
                        id:         unitsCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Repeater {
                            id:     unitsRepeater
                            model:  [ QGroundControl.settingsManager.unitsSettings.distanceUnits, QGroundControl.settingsManager.unitsSettings.areaUnits, QGroundControl.settingsManager.unitsSettings.speedUnits ]

                            property var names: [ qsTr("距离:"), qsTr("面积:"), qsTr("速度:") ]

                            Row {
                                spacing:    ScreenTools.defaultFontPixelWidth
                                visible:    modelData.visible

                                QGCLabel {
                                    width:              _labelWidth
                                    anchors.baseline:   factCombo.baseline
                                    text:               unitsRepeater.names[index]
                                }
                                FactComboBox {
                                    id:                 factCombo
                                    width:              _editFieldWidth
                                    fact:               modelData
                                    indexModel:         false
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Miscellaneous
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     miscLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.appSettings.visible
                    QGCLabel {
                        id:             miscLabel
                        text:           qsTr("其他参数")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     miscCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.appSettings.visible
                    Column {
                        id:         miscCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent
                        //-----------------------------------------------------------------
                        //-- Base UI Font Point Size
                        Row {
                            visible: _appFontPointSize ? _appFontPointSize.visible : false
                            spacing: ScreenTools.defaultFontPixelWidth
                            QGCLabel {
                                id:     baseFontLabel
                                text:   qsTr("字体大小:")
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Row {
                                id:         baseFontRow
                                spacing:    ScreenTools.defaultFontPixelWidth / 2
                                anchors.verticalCenter: parent.verticalCenter
                                QGCButton {
                                    id:     decrementButton
                                    width:  height
                                    height: baseFontEdit.height
                                    text:   "-"
                                    onClicked: {
                                        if (_appFontPointSize.value > _appFontPointSize.min) {
                                            _appFontPointSize.value = _appFontPointSize.value - 1
                                        }
                                    }
                                }
                                FactTextField {
                                    id:     baseFontEdit
                                    width:  _editFieldWidth - (decrementButton.width * 2) - (baseFontRow.spacing * 2)
                                    fact:   QGroundControl.settingsManager.appSettings.appFontPointSize
                                }
                                QGCButton {
                                    width:  height
                                    height: baseFontEdit.height
                                    text:   "+"
                                    onClicked: {
                                        if (_appFontPointSize.value < _appFontPointSize.max) {
                                            _appFontPointSize.value = _appFontPointSize.value + 1
                                        }
                                    }
                                }
                            }
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:                   _requiresRestart
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Palette Styles
                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            visible: QGroundControl.settingsManager.appSettings.indoorPalette.visible
                            QGCLabel {
                                text:           qsTr("主题颜色:")
                                width:          _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:          _editFieldWidth
                                fact:           QGroundControl.settingsManager.appSettings.indoorPalette
                                indexModel:     false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Map Provider
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _mapProvider.visible
                            QGCLabel {
                                text:       qsTr("地图种类:")
                                width:      _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:      _editFieldWidth
                                fact:       _mapProvider
                                indexModel: false
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Map Type
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _mapType.visible
                            QGCLabel {
                                text:               qsTr("地图类型:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                id:         mapTypes
                                width:      _editFieldWidth
                                fact:       _mapType
                                indexModel: false
                                anchors.verticalCenter: parent.verticalCenter
                                Connections {
                                    target: QGroundControl.settingsManager.flightMapSettings
                                    onMapTypeChanged: {
                                        mapTypes.model = _mapType.enumStrings
                                    }
                                }
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Audio preferences
                        FactCheckBox {
                            text:       qsTr("关闭声音")
                            fact:       _audioMuted
                            visible:    _audioMuted.visible
                            property Fact _audioMuted: QGroundControl.settingsManager.appSettings.audioMuted
                        }
                        //-----------------------------------------------------------------
                        //-- Save telemetry log
                        FactCheckBox {
                            id:         promptSaveLog
                            text:       qsTr("每次飞行时保存数传记录")
                            fact:       _telemetrySave
                            visible:    _telemetrySave.visible
                            property Fact _telemetrySave: QGroundControl.settingsManager.appSettings.telemetrySave
                        }
                        //-----------------------------------------------------------------
                        //-- Save even if not armed
                        FactCheckBox {
                            text:       qsTr("无人机未解锁时就开始保存数传记录")
                            fact:       _telemetrySaveNotArmed
                            visible:    _telemetrySaveNotArmed.visible
                            enabled:    promptSaveLog.checked
                            property Fact _telemetrySaveNotArmed: QGroundControl.settingsManager.appSettings.telemetrySaveNotArmed
                        }
                        //-----------------------------------------------------------------
                        //-- Clear settings
                        QGCCheckBox {
                            id:         clearCheck
                            text:       qsTr("重新开始时清除所有设置")
                            checked:    false
                            onClicked: {
                                checked ? clearDialog.visible = true : QGroundControl.clearDeleteAllSettingsNextBoot()
                            }
                            MessageDialog {
                                id:         clearDialog
                                visible:    false
                                icon:       StandardIcon.Warning
                                standardButtons: StandardButton.Yes | StandardButton.No
                                title:      qsTr("清除设置")
                                text:       qsTr("下次开始时将清除所有设置 %1. 确认?").arg(QGroundControl.appName)
                                onYes: {
                                    QGroundControl.deleteAllSettingsNextBoot()
                                    clearDialog.visible = false
                                }
                                onNo: {
                                    clearCheck.checked  = false
                                    clearDialog.visible = false
                                }
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Battery talker
                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth
                            QGCCheckBox {
                                id:                 announcePercentCheckbox
                                text:               qsTr("电压警报:")
                                checked:            _percentRemainingAnnounce.value !== 0
                                width:              (_labelWidth + _editFieldWidth) * 0.65
                                anchors.verticalCenter: parent.verticalCenter
                                onClicked: {
                                    if (checked) {
                                        _percentRemainingAnnounce.value = _percentRemainingAnnounce.defaultValueString
                                    } else {
                                        _percentRemainingAnnounce.value = 0
                                    }
                                }
                            }
                            FactTextField {
                                id:                 announcePercent
                                fact:               _percentRemainingAnnounce
                                width:              (_labelWidth + _editFieldWidth) * 0.35
                                enabled:            announcePercentCheckbox.checked
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        //-----------------------------------------------------------------
                        //-- Virtual joystick settings
                        FactCheckBox {
                            text:       qsTr("虚拟摇杆")
                            visible:    _virtualJoystick.visible
                            fact:       _virtualJoystick

                            property Fact _virtualJoystick: QGroundControl.settingsManager.appSettings.virtualJoystick
                        }
                        //-----------------------------------------------------------------
                        //-- Default mission item altitude
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude.visible
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                width:  (_labelWidth + _editFieldWidth) * 0.65
                                text:   qsTr("默认自动航线高度:")
                            }
                            FactTextField {
                                id:     defaultItemAltitudeField
                                width:  (_labelWidth + _editFieldWidth) * 0.35
                                fact:   QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        //-----------------------------------------------------------------
                        //-- Mission AutoLoad
                        FactCheckBox {
                            text:       qsTr("自动加载航线规划")
                            fact:       _autoLoad
                            visible:    _autoLoad.visible

                            property Fact _autoLoad: QGroundControl.settingsManager.appSettings.autoLoadMissions
                        }

                        //-----------------------------------------------------------------
                        //-- Save path
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    _savePath.visible

                            QGCLabel {
                                anchors.baseline:   savePathBrowse.baseline
                                text:               qsTr("文件保存路径:")
                            }
                            QGCLabel {
                                anchors.baseline:   savePathBrowse.baseline
                                text:               _savePath.rawValue === "" ? qsTr("<为设置>") : _savePath.value
                            }
                            QGCButton {
                                id:         savePathBrowse
                                text:       "浏览"
                                onClicked:  savePathBrowseDialog.openForLoad()

                                QGCFileDialog {
                                    id:             savePathBrowseDialog
                                    qgcView:        _qgcView
                                    title:          qsTr("选择文件保存路径:")
                                    folder:         _savePath.rawValue
                                    selectExisting: true
                                    selectFolder:   true

                                    onAcceptedForLoad: _savePath.rawValue = file
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- RTK GPS
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     unitLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.rtkSettings.visible
                    QGCLabel {
                        id:             rtkLabel
                        text:           qsTr("RTK差分GPS (需要重启)")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     rtkGrid.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.rtkSettings.visible
                    GridLayout {
                        id:                 rtkGrid
                        anchors.centerIn:   parent
                        columns:            2
                        rowSpacing:         ScreenTools.defaultFontPixelWidth
                        columnSpacing:      ScreenTools.defaultFontPixelWidth

                        QGCLabel {
                            text:               qsTr("准确度计算:")
                        }
                        FactTextField {
                            fact:               QGroundControl.settingsManager.rtkSettings.surveyInAccuracyLimit
                        }

                        QGCLabel {
                            text:               qsTr("最短观测时间:")
                        }
                        FactTextField {
                            fact:               QGroundControl.settingsManager.rtkSettings.surveyInMinObservationDuration
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Autoconnect settings
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     autoConnectLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.autoConnectSettings.visible
                    QGCLabel {
                        id:             autoConnectLabel
                        text:           qsTr("自动连接到以下设备:")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     autoConnectCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.autoConnectSettings.visible

                    Column {
                        id:         autoConnectCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Row {
                            spacing: ScreenTools.defaultFontPixelWidth * 2

                            Repeater {
                                id:     autoConnectRepeater
                                model:  [ QGroundControl.settingsManager.autoConnectSettings.autoConnectPixhawk,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectSiKRadio,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectPX4Flow,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectLibrePilot,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectUDP,
                                    QGroundControl.settingsManager.autoConnectSettings.autoConnectRTKGPS
                                ]

                                property var names: [ qsTr("飞控"), qsTr("数传"), qsTr("光流"), qsTr("飞机库"), qsTr("UDP"), qsTr("RTK差分GPS") ]

                                FactCheckBox {
                                    text:       autoConnectRepeater.names[index]
                                    fact:       modelData
                                    visible:    !ScreenTools.isiOS && modelData.visible
                                }
                            }
                        }
                    }
                }

                //-----------------------------------------------------------------
                //-- Video Source
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     videoLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible
                    QGCLabel {
                        id:             videoLabel
                        text:           qsTr("视频")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     videoCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible

                    Column {
                        id:         videoCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent

                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.videoSource.visible
                            QGCLabel {
                                text:               qsTr("视频源:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                id:         videoSource
                                width:      _editFieldWidth
                                indexModel: false
                                fact:       QGroundControl.settingsManager.videoSettings.videoSource
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.udpPort.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 1
                            QGCLabel {
                                text:               qsTr("UDP端口:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.udpPort
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.settingsManager.videoSettings.rtspUrl.visible && QGroundControl.videoManager.isGStreamer && videoSource.currentIndex === 2
                            QGCLabel {
                                anchors.verticalCenter: parent.verticalCenter
                                text:               qsTr("RTSP地址:")
                                width:              _labelWidth
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.rtspUrl
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.aspectRatio.visible
                            QGCLabel {
                                text:               qsTr("显示比例:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.aspectRatio
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.gridLines.visible
                            QGCLabel {
                                text:               qsTr("栅格线:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.gridLines
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                } // Video Source - Rectangle
                //-----------------------------------------------------------------
                //-- Video Source
                Item {
                    width:                      _qgcView.width * 0.8
                    height:                     videoRecLabel.height
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible
                    QGCLabel {
                        id:             videoRecLabel
                        text:           qsTr("录像")
                        font.family:    ScreenTools.demiboldFontFamily
                    }
                }
                Rectangle {
                    height:                     videoRecCol.height + (ScreenTools.defaultFontPixelHeight * 2)
                    width:                      _qgcView.width * 0.8
                    color:                      qgcPal.windowShade
                    anchors.margins:            ScreenTools.defaultFontPixelWidth
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    QGroundControl.settingsManager.videoSettings.visible

                    Column {
                        id:         videoRecCol
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.centerIn: parent
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.maxVideoSize.visible
                            QGCLabel {
                                text:               qsTr("最大存储量:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactTextField {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.maxVideoSize
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        Row {
                            spacing:    ScreenTools.defaultFontPixelWidth
                            visible:    QGroundControl.videoManager.isGStreamer && videoSource.currentIndex && videoSource.currentIndex < 3 && QGroundControl.settingsManager.videoSettings.recordingFormat.visible
                            QGCLabel {
                                text:               qsTr("视频文件格式:")
                                width:              _labelWidth
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            FactComboBox {
                                width:              _editFieldWidth
                                fact:               QGroundControl.settingsManager.videoSettings.recordingFormat
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }

                QGCLabel {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    text:                       qsTr("%1 版本: %2").arg(QGroundControl.appName).arg(QGroundControl.qgcVersion)
                }
            } // settingsColumn
        } // QGCFlickable
    } // QGCViewPanel
} // QGCView
