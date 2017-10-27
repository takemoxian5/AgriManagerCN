/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.3
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

/// Camera controls used in InstrumentSwipeView
QGCFlickable {
    id:                 _root
    height:             Math.min(maxHeight, column.height)
    contentHeight:      column.height
    flickableDirection: Flickable.VerticalFlick
    clip:               true

    property var    qgcView
    property color  textColor
    property var    maxHeight

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    MouseArea {
        anchors.fill:   parent
        onClicked:      showNextPage()
    }

    Column {
        id:         column
        width:      parent.width
        spacing:    ScreenTools.defaultFontPixelHeight

        QGCLabel {
            anchors.horizontalCenter:   parent.horizontalCenter
            color:                      textColor
            text:                       qsTr("功能测试")
        }

        QGCButton {
            anchors.horizontalCenter:   parent.horizontalCenter
            text:                       qsTr("相机触发")
            onClicked:                  _activeVehicle.triggerCamera()
            enabled:                    _activeVehicle
        }
	    QGCButton {
            anchors.horizontalCenter:   parent.horizontalCenter
            text:                       qsTr("喷头触发")
            onClicked:                  _activeVehicle.triggerAgri()
            enabled:                    _activeVehicle
        }
    }
	
}
