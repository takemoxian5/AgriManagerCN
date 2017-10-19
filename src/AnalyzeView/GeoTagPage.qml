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

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controllers   1.0

AnalyzePage {
    id:                 geoTagPage
    pageComponent:      pageComponent
    pageName:           qsTr("地理标签图")
    pageDescription:    qsTr("地理标签图是添加了航测时GPS坐标位置的图片. 需要提供日志文件及要添加坐标信息的图片路径.")

    property real _margin: ScreenTools.defaultFontPixelWidth * 2

    Component {
        id:                 pageComponent

        Column {
            id:         mainColumn
            width:      availableWidth
            spacing:    _margin

            Row {
                spacing: ScreenTools.defaultFontPixelWidth * 2

                ProgressBar {
                    id:             progressBar
                    width:          qgcView.width -_margin * 5
                    maximumValue:   100
                    value:          geoController.progress
                }

                BusyIndicator {
                    running:        geoController.progress > 0 && geoController.progress < 100 && geoController.errorMessage === ""
                    width:          progressBar.height
                    height:         progressBar.height
                }
            }

            QGCLabel {
                text:           geoController.errorMessage
                font.bold:      true
                font.pointSize: ScreenTools.largeFontPointSize
                color:          "red"
            }

            // Horizontal spacer line
            Rectangle {
              height:                     1
              width:                      qgcView.width * 1.0
              color:                      qgcPal.windowShadeDark
              anchors.horizontalCenter:   parent.horizontalCenter
            }

            Row {
                spacing: _margin

                QGCButton {
                    text:       qsTr("选择日志文件")
                    width:      ScreenTools.defaultFontPixelWidth * 30
                    onClicked:  geoController.pickLogFile()
                    anchors.verticalCenter:   parent.verticalCenter
                }

                QGCLabel {
                    text: geoController.logFile
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }

            Row {
                spacing: _margin

                QGCButton {
                    text:       qsTr("选择图片位置")
                    width:      ScreenTools.defaultFontPixelWidth * 30
                    onClicked:  geoController.pickImageDirectory()
                    anchors.verticalCenter:   parent.verticalCenter
                }

                QGCLabel {
                    text: geoController.imageDirectory
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }

            Row {
                spacing: _margin

                QGCButton {
                    text:       qsTr("(可选) 选择保存路径")
                    width:      ScreenTools.defaultFontPixelWidth * 30
                    onClicked:  geoController.pickSaveDirectory()
                    anchors.verticalCenter:   parent.verticalCenter
                }

                QGCLabel {
                    text: geoController.saveDirectory != "" ? geoController.saveDirectory : "/添加标记的文件在您的图片文件夹"
                    anchors.verticalCenter:   parent.verticalCenter
                }
            }

            // Horizontal spacer line
            Rectangle {
              height:                     1
              width:                      qgcView.width * 1.0
              color:                      qgcPal.windowShadeDark
              anchors.horizontalCenter:   parent.horizontalCenter
            }

            QGCButton {
                text: geoController.inProgress ? qsTr("取消标签添加") : qsTr("开始添加标签")
                width:      ScreenTools.defaultFontPixelWidth * 30
                onClicked: {
                    if (geoController.inProgress) {
                        geoController.cancelTagging()
                    } else {
                        geoController.startTagging()
                    }
                }
            }
        } // Column
    } // Component
} // AnalyzePage
