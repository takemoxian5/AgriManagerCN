﻿/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick              2.3
import QtQuick.Controls     1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

SetupPage {
    id:             tuningPage
    pageComponent:  tuningPageComponent

    Component {
        id: tuningPageComponent

        Column {
            width:      availableWidth
            spacing:    _margins

            FactPanelController { id: controller; factPanel: tuningPage.viewPanel }

            QGCPalette { id: palette; colorGroupEnabled: true }

            // Older firmwares use THR_MODE, newer use MOT_THST_HOVER
            property bool _throttleMidExists: controller.parameterExists(-1, "THR_MID")
            property Fact _hoverTuneParam:  controller.getParameterFact(-1, _throttleMidExists ? "THR_MID" : "MOT_THST_HOVER")
            property real _hoverTuneMin:    _throttleMidExists ? 200 : 0
            property real _hoverTuneMax:    _throttleMidExists ? 800 : 1
            property real _hoverTuneStep:   _throttleMidExists ? 10 : 0.01

            property Fact _rcFeel:          controller.getParameterFact(-1, "RC_FEEL_RP")
            property Fact _rateRollP:       controller.getParameterFact(-1, "r.ATC_RAT_RLL_P")
            property Fact _rateRollI:       controller.getParameterFact(-1, "r.ATC_RAT_RLL_I")
            property Fact _ratePitchP:      controller.getParameterFact(-1, "r.ATC_RAT_PIT_P")
            property Fact _ratePitchI:      controller.getParameterFact(-1, "r.ATC_RAT_PIT_I")
            property Fact _rateClimbP:      controller.getParameterFact(-1, "ACCEL_Z_P")
            property Fact _rateClimbI:      controller.getParameterFact(-1, "ACCEL_Z_I")

            property Fact _ch7Opt:  controller.getParameterFact(-1, "CH7_OPT")
            property Fact _ch8Opt:  controller.getParameterFact(-1, "CH8_OPT")
            property Fact _ch9Opt:  controller.getParameterFact(-1, "CH9_OPT")
            property Fact _ch10Opt: controller.getParameterFact(-1, "CH10_OPT")
            property Fact _ch11Opt: controller.getParameterFact(-1, "CH11_OPT")
            property Fact _ch12Opt: controller.getParameterFact(-1, "CH12_OPT")

            readonly property int   _firstOptionChannel:    7
            readonly property int   _lastOptionChannel:     12

            property Fact   _autoTuneAxes:                  controller.getParameterFact(-1, "AUTOTUNE_AXES")
            property int    _autoTuneSwitchChannelIndex:    0
            readonly property int _autoTuneOption:          17

            property real _margins: ScreenTools.defaultFontPixelHeight

            property bool _loadComplete: false

            ExclusiveGroup { id: fenceActionRadioGroup }
            ExclusiveGroup { id: landLoiterRadioGroup }
            ExclusiveGroup { id: returnAltRadioGroup }

            Component.onCompleted: {
                // Qml Sliders have a strange behavior in which they first set Slider::value to some internal
                // setting and then set Slider::value to the bound properties value. If you have an onValueChanged
                // handler which updates your property with the new value, this first value change will trash
                // your bound values. In order to work around this we don't set the values into the Sliders until
                // after Qml load is done. We also don't track value changes until Qml load completes.
                throttleHover.value = _hoverTuneParam.value
                rollPitch.value = _rateRollP.value
                climb.value = _rateClimbP.value
                rcFeel.value = _rcFeel.value
                _loadComplete = true

                calcAutoTuneChannel()
            }

            /// The AutoTune switch is stored in one of the CH#_OPT parameters. We need to loop through those
            /// to find them and setup the ui accordindly.
            function calcAutoTuneChannel() {
                _autoTuneSwitchChannelIndex = 0
                for (var channel=_firstOptionChannel; channel<=_lastOptionChannel; channel++) {
                    var optionFact = controller.getParameterFact(-1, "CH" + channel + "_OPT")
                    if (optionFact.value == _autoTuneOption) {
                        _autoTuneSwitchChannelIndex = channel - _firstOptionChannel + 1
                        break
                    }
                }
            }

            /// We need to clear AutoTune from any previous channel before setting it to a new one
            function setChannelAutoTuneOption(channel) {
                // First clear any previous settings for AutTune
                for (var optionChannel=_firstOptionChannel; optionChannel<=_lastOptionChannel; optionChannel++) {
                    var optionFact = controller.getParameterFact(-1, "CH" + optionChannel + "_OPT")
                    if (optionFact.value == _autoTuneOption) {
                        optionFact.value = 0
                    }
                }

                // Now set the function into the new channel
                if (channel != 0) {
                    var optionFact = controller.getParameterFact(-1, "CH" + channel + "_OPT")
                    optionFact.value = _autoTuneOption
                }
            }

            Connections { target: _ch7Opt; onValueChanged: calcAutoTuneChannel() }
            Connections { target: _ch8Opt; onValueChanged: calcAutoTuneChannel() }
            Connections { target: _ch9Opt; onValueChanged: calcAutoTuneChannel() }
            Connections { target: _ch10Opt; onValueChanged: calcAutoTuneChannel() }
            Connections { target: _ch11Opt; onValueChanged: calcAutoTuneChannel() }
            Connections { target: _ch12Opt; onValueChanged: calcAutoTuneChannel() }

            QGCLabel {
                id:         basicLabel
                text:       qsTr("基本调参")
                font.family: ScreenTools.demiboldFontFamily
            }

            Rectangle {
                id:                 basicTuningRect
                anchors.left:       parent.left
                anchors.right:      parent.right
                height:             basicTuningColumn.y + basicTuningColumn.height + _margins
                color:              palette.windowShade

                Column {
                    id:                 basicTuningColumn
                    anchors.margins:    _margins
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    spacing:            _margins

                    Column {
                        anchors.left:   parent.left
                        anchors.right:  parent.right

                        QGCLabel {
                            text:       qsTr("悬停油门")
                            font.family: ScreenTools.demiboldFontFamily
                        }

                        QGCLabel {
                            text: qsTr("为了保持稳定的悬停，需要多少油门")
                        }

                        Slider {
                            id:                 throttleHover
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            minimumValue:       _hoverTuneMin
                            maximumValue:       _hoverTuneMax
                            stepSize:           _hoverTuneStep
                            tickmarksEnabled:   true

                            onValueChanged: {
                                if (_loadComplete) {
                                    _hoverTuneParam.value = value
                                }
                            }
                        }
                    }

                    Column {
                        anchors.left:   parent.left
                        anchors.right:  parent.right

                        QGCLabel {
                            text:       qsTr("横滚/俯仰灵敏度")
                            font.family: ScreenTools.demiboldFontFamily
                        }

                        QGCLabel {
                            text: qsTr("如果无人机调整缓慢向右滑动或者如果无人机调整灵敏向左滑动")
                        }

                        Slider {
                            id:                 rollPitch
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            minimumValue:       0.08
                            maximumValue:       0.4
                            stepSize:           0.01
                            tickmarksEnabled:   true

                            onValueChanged: {
                                if (_loadComplete) {
                                    _rateRollP.value = value
                                    _rateRollI.value = value
                                    _ratePitchP.value = value
                                    _ratePitchI.value = value
                                }
                            }
                        }
                    }

                    Column {
                        anchors.left:   parent.left
                        anchors.right:  parent.right

                        QGCLabel {
                            text:       qsTr("爬升灵敏度")
                            font.family: ScreenTools.demiboldFontFamily
                        }

                        QGCLabel {
                            text: qsTr("向右滑，爬升速度快，或向左滑，以更轻柔地爬升")
                        }

                        Slider {
                            id:                 climb
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            minimumValue:       0.3
                            maximumValue:       1.0
                            stepSize:           0.02
                            tickmarksEnabled:   true
                            value:              _rateClimbP.value

                            onValueChanged: {
                                if (_loadComplete) {
                                    _rateClimbP.value = value
                                    _rateClimbI.value = value * 2
                                }
                            }
                        }
                    }

                    Column {
                        anchors.left:   parent.left
                        anchors.right:  parent.right

                        QGCLabel {
                            text:       qsTr("遥控器横滚/俯仰感度")
                            font.family: ScreenTools.demiboldFontFamily
                        }

                        QGCLabel {
                            text: qsTr("滑到左边，进行平和的控制，滑到右边，进行强烈的控制")
                        }

                        Slider {
                            id:                 rcFeel
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            minimumValue:       0
                            maximumValue:       100
                            stepSize:           5.0
                            tickmarksEnabled:   true

                            onValueChanged: {
                                if (_loadComplete) {
                                    _rcFeel.value = value
                                }
                            }
                        }
                    }
                }
            } // Rectangle - Basic tuning

            Flow {
                id:             flowLayout
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margins

                Rectangle {
                    height: autoTuneLabel.height + autoTuneRect.height
                    width:  autoTuneRect.width
                    color:  palette.window

                    QGCLabel {
                        id:                 autoTuneLabel
                        text:               qsTr("自动调参")
                        font.family:        ScreenTools.demiboldFontFamily
                    }

                    Rectangle {
                        id:             autoTuneRect
                        width:          autoTuneColumn.x + autoTuneColumn.width + _margins
                        height:         autoTuneColumn.y + autoTuneColumn.height + _margins
                        anchors.top:    autoTuneLabel.bottom
                        color:          palette.windowShade

                        Column {
                            id:                 autoTuneColumn
                            anchors.margins:    _margins
                            anchors.left:       parent.left
                            anchors.top:        parent.top
                            spacing:            _margins

                            Row {
                                spacing: _margins

                                QGCLabel { text: qsTr("自动调参的轴:") }
                                FactBitmask { fact: _autoTuneAxes }
                            }

                            Row {
                                spacing:    _margins

                                QGCLabel {
                                    anchors.baseline:   autoTuneChannelCombo.baseline
                                    text:               qsTr("自动调参开关通道:")
                                }

                                QGCComboBox {
                                    id:             autoTuneChannelCombo
                                    width:          ScreenTools.defaultFontPixelWidth * 14
                                    model:          [qsTr("None"), qsTr("Channel 7"), qsTr("Channel 8"), qsTr("Channel 9"), qsTr("Channel 10"), qsTr("Channel 11"), qsTr("Channel 12") ]
                                    currentIndex:   _autoTuneSwitchChannelIndex

                                    onActivated: {
                                        var channel = index

                                        if (channel > 0) {
                                            channel += 6
                                        }
                                        setChannelAutoTuneOption(channel)
                                    }
                                }
                            }
                        }
                    } // Rectangle - AutoTune
                } // Rectangle - AutoTuneWrap

                Rectangle {
                    height:     inFlightTuneLabel.height + channel6TuningOption.height
                    width:      channel6TuningOption.width
                    color:      palette.window

                    QGCLabel {
                        id:                 inFlightTuneLabel
                        text:               qsTr("在飞行中调参")
                        font.family:        ScreenTools.demiboldFontFamily
                    }

                    Rectangle {
                        id:             channel6TuningOption
                        width:          channel6TuningOptColumn.width + (_margins * 2)
                        height:         channel6TuningOptColumn.height + ScreenTools.defaultFontPixelHeight
                        anchors.top:    inFlightTuneLabel.bottom
                        color:          qgcPal.windowShade

                        Column {
                            id:                 channel6TuningOptColumn
                            anchors.margins:    ScreenTools.defaultFontPixelWidth
                            anchors.left:       parent.left
                            anchors.top:        parent.top
                            spacing:            ScreenTools.defaultFontPixelHeight

                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                property Fact nullFact: Fact { }

                                QGCLabel {
                                    anchors.baseline:   optCombo.baseline
                                    text:               qsTr("通道选项 6 (调参):")
                                    //color:            controller.channelOptionEnabled[modelData] ? "yellow" : qgcPal.text
                                }

                                FactComboBox {
                                    id:         optCombo
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       controller.getParameterFact(-1, "TUNE")
                                    indexModel: false
                                }
                            }

                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth
                                property Fact nullFact: Fact { }

                                QGCLabel {
                                    anchors.baseline:   tuneMinField.baseline
                                    text:               qsTr("最小:")
                                    //color:            controller.channelOptionEnabled[modelData] ? "yellow" : qgcPal.text
                                }

                                FactTextField {
                                    id:                 tuneMinField
                                    validator:          DoubleValidator {bottom: 0; top: 32767;}
                                    fact:               controller.getParameterFact(-1, "TUNE_LOW")
                                }

                                QGCLabel {
                                    anchors.baseline:   tuneMaxField.baseline
                                    text:               qsTr("最大:")
                                    //color:            controller.channelOptionEnabled[modelData] ? "yellow" : qgcPal.text
                                }

                                FactTextField {
                                    id:                 tuneMaxField
                                    validator:          DoubleValidator {bottom: 0; top: 32767;}
                                    fact:               controller.getParameterFact(-1, "TUNE_HIGH")
                                }
                            }
                        } // Column - Channel 6 Tuning option
                    } // Rectangle - Channel 6 Tuning options
                } // Rectangle - Channel 6 Tuning options wrap
            } // Flow - Tune
        } // Column
    } // Component
} // SetupView
