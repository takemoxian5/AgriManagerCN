/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtQuick.Controls     1.2
import QtQuick.Dialogs      1.2
import QtQuick.Layouts      1.2

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ScreenTools   1.0

AnalyzePage {
    id:                 logDownloadPage
    pageComponent:      pageComponent
    pageName:           qsTr("日志下载")
    pageDescription:    qsTr("从无人机中下载日志文件. 点击 刷新 按钮获取日志列表.")

    property real _margin:          ScreenTools.defaultFontPixelWidth
    property real _butttonWidth:    ScreenTools.defaultFontPixelWidth * 10

    QGCPalette { id: palette; colorGroupEnabled: enabled }

    Component {
        id: pageComponent

        RowLayout {
            width:  availableWidth
            height: availableHeight

            Connections {
                target: logController
                onSelectionChanged: {
                    tableView.selection.clear()
                    for(var i = 0; i < logController.model.count; i++) {
                        var o = logController.model.get(i)
                        if (o && o.selected) {
                            tableView.selection.select(i, i)
                        }
                    }
                }
            }

            TableView {
                id: tableView
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                model:              logController.model
                selectionMode:      SelectionMode.MultiSelection
                Layout.fillWidth:   true

                TableViewColumn {
                    title: qsTr("序列")
                    width: ScreenTools.defaultFontPixelWidth * 6
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.id : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("日期")
                    width: ScreenTools.defaultFontPixelWidth * 34
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        text: {
                            var o = logController.model.get(styleData.row)
                            if (o) {
                                //-- Have we received this entry already?
                                if(logController.model.get(styleData.row).received) {
                                    var d = logController.model.get(styleData.row).time
                                    if(d.getUTCFullYear() < 2010)
                                        return qsTr("未知日期")
                                    else
                                        return d.toLocaleString()
                                }
                            }
                            return ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("大小")
                    width: ScreenTools.defaultFontPixelWidth * 18
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignRight
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.sizeStr : ""
                        }
                    }
                }

                TableViewColumn {
                    title: qsTr("状态")
                    width: ScreenTools.defaultFontPixelWidth * 22
                    horizontalAlignment: Text.AlignHCenter
                    delegate : Text  {
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            var o = logController.model.get(styleData.row)
                            return o ? o.status : ""
                        }
                    }
                }
            }

            Column {
                spacing:            _margin
                Layout.alignment:   Qt.AlignTop | Qt.AlignLeft

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs
                    text:       qsTr("刷新")
                    width:      _butttonWidth

                    onClicked: {
                        if (!QGroundControl.multiVehicleManager.activeVehicle || QGroundControl.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
                            logDownloadPage.showMessage(qsTr("日志刷新"), qsTr("您必须连接到无人机再进行日志下载."), StandardButton.Ok)
                        } else {
                            logController.refresh()
                        }
                    }
                }

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs && tableView.selection.count > 0
                    text:       qsTr("下载")
                    width:      _butttonWidth
                    onClicked: {
                        //-- Clear selection
                        for(var i = 0; i < logController.model.count; i++) {
                            var o = logController.model.get(i)
                            if (o) o.selected = false
                        }
                        //-- Flag selected log files
                        tableView.selection.forEach(function(rowIndex){
                            var o = logController.model.get(rowIndex)
                            if (o) o.selected = true
                        })
                        fileDialog.qgcView =        logDownloadPage
                        fileDialog.title =          qsTr("选择保存路径")
                        fileDialog.selectExisting = true
                        fileDialog.folder =         QGroundControl.settingsManager.appSettings.telemetrySavePath
                        fileDialog.selectFolder =   true
                        fileDialog.openForLoad()
                    }

                    QGCFileDialog {
                        id: fileDialog

                        onAcceptedForLoad: {
                            logController.download(file)
                            close()
                        }
                    }
                }

                QGCButton {
                    enabled:    !logController.requestingList && !logController.downloadingLogs && logController.model.count > 0
                    text:       qsTr("清除所有")
                    width:      _butttonWidth
                    onClicked:  logDownloadPage.showDialog(eraseAllMessage,
                                                           qsTr("删除所有日志文件"),
                                                           logDownloadPage.showDialogDefaultWidth,
                                                           StandardButton.Yes | StandardButton.No)

                    Component {
                        id: eraseAllMessage

                        QGCViewMessage {
                            message:    qsTr("所有日志文件将永久删除. 请确认?")

                            function accept() {
                                logDownloadPage.hideDialog()
                                logController.eraseAll()
                            }
                        }
                    }
                }

                QGCButton {
                    text:       qsTr("取消")
                    width:      _butttonWidth
                    enabled:    logController.requestingList || logController.downloadingLogs
                    onClicked:  logController.cancel()
                }
            } // Column - Buttons
        } // RowLayout
    } // Component
} // AnalyzePage
