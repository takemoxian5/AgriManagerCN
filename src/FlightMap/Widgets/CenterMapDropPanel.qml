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
import QtPositioning    5.3

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelWidth * 0.5

    property var    map
    property var    fitFunctions
    property bool   showMission:          true
    property bool   showAllItems:         true

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCLabel { text: qsTr("地图居中:") }

    QGCButton {
        text:               qsTr("任务")
        Layout.fillWidth:   true
        visible:            showMission

        onClicked: {
            dropPanel.hide()
            fitFunctions.fitMapViewportToMissionItems()
        }
    }

    QGCButton {
        text:               qsTr("所有项")
        Layout.fillWidth:   true
        visible:            showAllItems

        onClicked: {
            dropPanel.hide()
            fitFunctions.fitMapViewportToAllItems()
        }
    }

    QGCButton {
        text:               qsTr("家")
        Layout.fillWidth:   true

        onClicked: {
            dropPanel.hide()
            map.center = fitFunctions.fitHomePosition()
        }
    }

    QGCButton {
        text:               qsTr("当前位置")
        Layout.fillWidth:   true
        enabled:            map.gcsPosition.isValid

        onClicked: {
            dropPanel.hide()
            map.center = map.gcsPosition
        }
    }

    QGCButton {
        text:               qsTr("无人机")
        Layout.fillWidth:   true
        enabled:            _activeVehicle && _activeVehicle.coordinate.isValid

        onClicked: {
            dropPanel.hide()
            map.center = activeVehicle.coordinate
        }
    }
} // Column
