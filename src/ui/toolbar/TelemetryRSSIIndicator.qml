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
import QtQuick.Layouts  1.2

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          _hasTelemetry ? telemIcon.width * 1.1 : 0
    visible:        _hasTelemetry

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property bool _hasTelemetry:    _activeVehicle ? _activeVehicle.telemetryLRSSI !== 0 : false

    Component {
        id: telemRSSIInfo
        Rectangle {
            width:  telemCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: telemCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text
            Column {
                id:                 telemCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(telemGrid.width, telemLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent
                QGCLabel {
                    id:             telemLabel
                    text:           qsTr("数传信号强度")
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                GridLayout {
                    id:                 telemGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth
                    columns:            2
                    anchors.horizontalCenter: parent.horizontalCenter
                    QGCLabel { text: qsTr("近端信号强度:") }
                    QGCLabel { text: _activeVehicle.telemetryLRSSI + " dBm"}
                    QGCLabel { text: qsTr("远端信号强度:") }
                    QGCLabel { text: _activeVehicle.telemetryRRSSI + " dBm"}
                    QGCLabel { text: qsTr("接收错误:") }
                    QGCLabel { text: _activeVehicle.telemetryRXErrors }
                    QGCLabel { text: qsTr("错误修复:") }
                    QGCLabel { text: _activeVehicle.telemetryFixed }
                    QGCLabel { text: qsTr("发射缓存:") }
                    QGCLabel { text: _activeVehicle.telemetryTXBuffer }
                    QGCLabel { text: qsTr("近端噪声:") }
                    QGCLabel { text: _activeVehicle.telemetryLNoise }
                    QGCLabel { text: qsTr("远端噪声:") }
                    QGCLabel { text: _activeVehicle.telemetryRNoise }
                }
            }
            Component.onCompleted: {
                var pos = mapFromItem(toolBar, centerX - (width / 2), toolBar.height)
                x = pos.x
                y = pos.y + ScreenTools.defaultFontPixelHeight
            }
        }
    }
    QGCColoredImage {
        id:                 telemIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/TelemRSSI.svg"
        fillMode:           Image.PreserveAspectFit
        color:              qgcPal.buttonText
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            var centerX = mapToItem(toolBar, x, y).x + (width / 2)
            mainWindow.showPopUp(telemRSSIInfo, centerX)
        }
    }
}
