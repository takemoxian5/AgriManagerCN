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

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0

Rectangle {
    id:             __mavlinkRoot
    color:          qgcPal.window
    anchors.fill:   parent

    property real _labelWidth:          ScreenTools.defaultFontPixelWidth * 28
    property real _valueWidth:          ScreenTools.defaultFontPixelWidth * 24
    property int  _selectedCount:       0
    property real _columnSpacing:       ScreenTools.defaultFontPixelHeight * 0.25
    property bool _uploadedSelected:    false

    QGCPalette { id: qgcPal }

    Connections {
        target: QGroundControl.mavlinkLogManager
        onSelectedCountChanged: {
            _uploadedSelected = false
            var selected = 0
            for(var i = 0; i < QGroundControl.mavlinkLogManager.logFiles.count; i++) {
                var logFile = QGroundControl.mavlinkLogManager.logFiles.get(i)
                if(logFile.selected) {
                    selected++
                    //-- If an uploaded file is selected, disable "Upload" button
                    if(logFile.uploaded) {
                        _uploadedSelected = true
                    }
                }
            }
            _selectedCount = selected
        }
    }

    function saveItems()
    {
        QGroundControl.mavlinkSystemID = parseInt(sysidField.text)
        QGroundControl.mavlinkLogManager.videoURL = videoUrlField.text
        QGroundControl.mavlinkLogManager.feedback = feedbackTextArea.text
        QGroundControl.mavlinkLogManager.emailAddress = emailField.text
        QGroundControl.mavlinkLogManager.description = descField.text
        QGroundControl.mavlinkLogManager.uploadURL = urlField.text
        QGroundControl.mavlinkLogManager.emailAddress = emailField.text
        if(autoUploadCheck.checked && QGroundControl.mavlinkLogManager.emailAddress === "") {
            autoUploadCheck.checked = false
        } else {
            QGroundControl.mavlinkLogManager.enableAutoUpload = autoUploadCheck.checked
        }
    }

    MessageDialog {
        id:         emptyEmailDialog
        visible:    false
        icon:       StandardIcon.Warning
        standardButtons: StandardButton.Close
        title:      qsTr("MAVLink记录")
        text:       qsTr("请使用邮箱地址登陆后上传MAVLINK日志文件")
    }

    QGCFlickable {
        clip:               true
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        contentHeight:      settingsColumn.height
        contentWidth:       settingsColumn.width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:                 settingsColumn
            width:              __mavlinkRoot.width
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            //-----------------------------------------------------------------
            //-- Ground Station
            Item {
                width:              __mavlinkRoot.width * 0.8
                height:             gcsLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             gcsLabel
                    text:           qsTr("地面站")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:         gcsColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          __mavlinkRoot.width * 0.8
                color:          qgcPal.windowShade
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         gcsColumn
                    spacing:    _columnSpacing
                    anchors.centerIn: parent
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   sysidField.baseline
                            text:               qsTr("MAVLink系统ID:")
                        }
                        QGCTextField {
                            id:     sysidField
                            text:   QGroundControl.mavlinkSystemID.toString()
                            width:  _valueWidth
                            inputMethodHints:       Qt.ImhFormattedNumbersOnly
                            anchors.verticalCenter: parent.verticalCenter
                            onEditingFinished: {
                                saveItems();
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Mavlink Heartbeats
                    QGCCheckBox {
                        text:       qsTr("发送心跳包")
                        checked:    QGroundControl.multiVehicleManager.gcsHeartBeatEnabled
                        onClicked: {
                            QGroundControl.multiVehicleManager.gcsHeartBeatEnabled = checked
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Mavlink Version Check
                    QGCCheckBox {
                        text:       qsTr("只接收同一个协议版本的MAV消息")
                        checked:    QGroundControl.isVersionCheckEnabled
                        onClicked: {
                            QGroundControl.isVersionCheckEnabled = checked
                        }
                    }
                }
            }
            //-----------------------------------------------------------------
            //-- Mavlink Logging
            Item {
                width:              __mavlinkRoot.width * 0.8
                height:             mavlogLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             mavlogLabel
                    text:           qsTr("MAVLink 2.0记录(仅PX4固件)")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:         mavlogColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          __mavlinkRoot.width * 0.8
                color:          qgcPal.windowShade
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         mavlogColumn
                    width:      gcsColumn.width
                    spacing:    _columnSpacing
                    anchors.centerIn: parent
                    //-----------------------------------------------------------------
                    //-- Manual Start/Stop
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        QGCLabel {
                            width:              _labelWidth
                            text:               qsTr("手动开始/停止:")
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        QGCButton {
                            text:               qsTr("开始记录")
                            width:              (_valueWidth * 0.5) - (ScreenTools.defaultFontPixelWidth * 0.5)
                            enabled:            !QGroundControl.mavlinkLogManager.logRunning && QGroundControl.mavlinkLogManager.canStartLog
                            onClicked:          QGroundControl.mavlinkLogManager.startLogging()
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        QGCButton {
                            text:               qsTr("停止记录")
                            width:              (_valueWidth * 0.5) - (ScreenTools.defaultFontPixelWidth * 0.5)
                            enabled:            QGroundControl.mavlinkLogManager.logRunning
                            onClicked:          QGroundControl.mavlinkLogManager.stopLogging()
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Enable auto log on arming
                    QGCCheckBox {
                        text:       qsTr("使能自动记录日志")
                        checked:    QGroundControl.mavlinkLogManager.enableAutoStart
                        onClicked: {
                            QGroundControl.mavlinkLogManager.enableAutoStart = checked
                        }
                    }
                }
            }
            //-----------------------------------------------------------------
            //-- Mavlink Logging
            Item {
                width:              __mavlinkRoot.width * 0.8
                height:             logLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             logLabel
                    text:           qsTr("MAVLink 2.0日志上传(仅PX4固件)")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:         logColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          __mavlinkRoot.width * 0.8
                color:          qgcPal.windowShade
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         logColumn
                    spacing:    _columnSpacing
                    anchors.centerIn: parent
                    //-----------------------------------------------------------------
                    //-- Email address Field
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   emailField.baseline
                            text:               qsTr("用于日志上传的邮箱地址:")
                        }
                        QGCTextField {
                            id:     emailField
                            text:   QGroundControl.mavlinkLogManager.emailAddress
                            width:  _valueWidth
                            inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly
                            anchors.verticalCenter: parent.verticalCenter
                            onEditingFinished: {
                                saveItems();
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Description Field
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   descField.baseline
                            text:               qsTr("默认描述:")
                        }
                        QGCTextField {
                            id:     descField
                            text:   QGroundControl.mavlinkLogManager.description
                            width:  _valueWidth
                            anchors.verticalCenter: parent.verticalCenter
                            onEditingFinished: {
                                saveItems();
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Upload URL
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   urlField.baseline
                            text:               qsTr("默认上传URL地址")
                        }
                        QGCTextField {
                            id:     urlField
                            text:   QGroundControl.mavlinkLogManager.uploadURL
                            width:  _valueWidth
                            inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                            anchors.verticalCenter: parent.verticalCenter
                            onEditingFinished: {
                                saveItems();
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Video URL
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   videoUrlField.baseline
                            text:               qsTr("视频URL地址:")
                        }
                        QGCTextField {
                            id:     videoUrlField
                            text:   QGroundControl.mavlinkLogManager.videoURL
                            width:  _valueWidth
                            inputMethodHints:       Qt.ImhNoAutoUppercase | Qt.ImhUrlCharactersOnly
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Wind Speed
                    Row {
                        spacing:                ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   windCombo.baseline
                            text:               qsTr("风速:")
                        }
                        QGCComboBox {
                            id:                 windCombo
                            width:              _valueWidth
                            model: ListModel {
                                id: windItems
                                ListElement { text: "请选择"; value: -1 }
                                ListElement { text: "无风";     value: 0 }
                                ListElement { text: "微风";   value: 5 }
                                ListElement { text: "大风";     value: 8 }
                                ListElement { text: "暴风";    value: 10 }
                            }
                            onActivated: {
                                saveItems();
                                QGroundControl.mavlinkLogManager.windSpeed = windItems.get(index).value
                                console.log('Set Wind: ' + windItems.get(index).value)
                            }
                            Component.onCompleted: {
                                for(var i = 0; i < windItems.count; i++) {
                                    if(windItems.get(i).value === QGroundControl.mavlinkLogManager.windSpeed) {
                                        windCombo.currentIndex = i;
                                        console.log('Wind: ' + windItems.get(i).value)
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Flight Rating
                    Row {
                        spacing:                ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            anchors.baseline:   ratingCombo.baseline
                            text:               qsTr("飞行等级:")
                        }
                        QGCComboBox {
                            id:                 ratingCombo
                            width:              _valueWidth
                            model: ListModel {
                                id: ratingItems
                                ListElement { text: "请选择";            value: "notset"}
                                ListElement { text: "坠落炸机 (飞手失误)";    value: "crash_pilot" }
                                ListElement { text: "坠落炸机 (软件或硬件问题)";   value: "crash_sw_hw" }
                                ListElement { text: "未达标";           value: "unsatisfactory" }
                                ListElement { text: "好";                     value: "good" }
                                ListElement { text: "很好";                    value: "great" }
                            }
                            onActivated: {
                                saveItems();
                                QGroundControl.mavlinkLogManager.rating = ratingItems.get(index).value
                                console.log('Set Rating: ' + ratingItems.get(index).value)
                            }
                            Component.onCompleted: {
                                for(var i = 0; i < ratingItems.count; i++) {
                                    if(ratingItems.get(i).value === QGroundControl.mavlinkLogManager.rating) {
                                        ratingCombo.currentIndex = i;
                                        console.log('Rating: ' + ratingItems.get(i).value)
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Feedback
                    Row {
                        spacing:                ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            width:              _labelWidth
                            text:               qsTr("其它反馈:")
                        }
                        TextArea {
                            id:                 feedbackTextArea
                            width:              _valueWidth
                            height:             ScreenTools.defaultFontPixelHeight * 4
                            frameVisible:       false
                            font.pointSize:     ScreenTools.defaultFontPointSize
                            text:               QGroundControl.mavlinkLogManager.feedback
                            style: TextAreaStyle {
                                textColor:          qgcPal.windowShade
                                backgroundColor:    qgcPal.text
                            }
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Public Log
                    QGCCheckBox {
                        text:       qsTr("公开日志")
                        checked:    QGroundControl.mavlinkLogManager.publicLog
                        onClicked: {
                            QGroundControl.mavlinkLogManager.publicLog = checked
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Automatic Upload
                    QGCCheckBox {
                        id:         autoUploadCheck
                        text:       qsTr("使能日志自动上传")
                        checked:    QGroundControl.mavlinkLogManager.enableAutoUpload
                        onClicked: {
                            saveItems();
                            if(checked && QGroundControl.mavlinkLogManager.emailAddress === "")
                                emptyEmailDialog.open()
                        }
                    }
                    //-----------------------------------------------------------------
                    //-- Delete log after upload
                    QGCCheckBox {
                        text:       qsTr("上传后删除日志文件")
                        checked:    QGroundControl.mavlinkLogManager.deleteAfterUpload
                        enabled:    autoUploadCheck.checked
                        onClicked: {
                            QGroundControl.mavlinkLogManager.deleteAfterUpload = checked
                        }
                    }
                }
            }
            //-----------------------------------------------------------------
            //-- Log Files
            Item {
                width:              __mavlinkRoot.width * 0.8
                height:             logFilesLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             logFilesLabel
                    text:           qsTr("保存日志文件")
                    font.family:    ScreenTools.demiboldFontFamily
                }
            }
            Rectangle {
                height:         logFilesColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          __mavlinkRoot.width * 0.8
                color:          qgcPal.windowShade
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         logFilesColumn
                    spacing:    _columnSpacing * 4
                    anchors.centerIn: parent
                    width:          ScreenTools.defaultFontPixelWidth * 68
                    Rectangle {
                        width:          ScreenTools.defaultFontPixelWidth  * 64
                        height:         ScreenTools.defaultFontPixelHeight * 14
                        anchors.horizontalCenter: parent.horizontalCenter
                        color:          qgcPal.window
                        border.color:   qgcPal.text
                        border.width:   0.5
                        QGCListView {
                            width:          ScreenTools.defaultFontPixelWidth  * 56
                            height:         ScreenTools.defaultFontPixelHeight * 12
                            anchors.centerIn: parent
                            orientation:    ListView.Vertical
                            model:          QGroundControl.mavlinkLogManager.logFiles
                            clip:           true
                            delegate: Rectangle {
                                width:          ScreenTools.defaultFontPixelWidth  * 52
                                height:         selectCheck.height
                                color:          qgcPal.window
                                Row {
                                    width:  ScreenTools.defaultFontPixelWidth  * 50
                                    anchors.centerIn: parent
                                    spacing: ScreenTools.defaultFontPixelWidth
                                    QGCCheckBox {
                                        id:         selectCheck
                                        width:      ScreenTools.defaultFontPixelWidth * 4
                                        checked:    object.selected
                                        enabled:    !object.writing && !object.uploading
                                        anchors.verticalCenter: parent.verticalCenter
                                        onClicked:  {
                                            object.selected = checked
                                        }
                                    }
                                    QGCLabel {
                                        text:       object.name
                                        width:      ScreenTools.defaultFontPixelWidth * 28
                                        color:      object.writing ? qgcPal.warningText : qgcPal.text
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    QGCLabel {
                                        text:       Number(object.size).toLocaleString(Qt.locale(), 'f', 0)
                                        visible:    !object.uploading && !object.uploaded
                                        width:      ScreenTools.defaultFontPixelWidth * 20;
                                        color:      object.writing ? qgcPal.warningText : qgcPal.text
                                        horizontalAlignment: Text.AlignRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    QGCLabel {
                                        text:      qsTr("上传")
                                        visible:    object.uploaded
                                        width:      ScreenTools.defaultFontPixelWidth * 20;
                                        horizontalAlignment: Text.AlignRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    ProgressBar {
                                        visible:    object.uploading && !object.uploaded
                                        width:      ScreenTools.defaultFontPixelWidth * 20;
                                        height:     ScreenTools.defaultFontPixelHeight
                                        anchors.verticalCenter: parent.verticalCenter
                                        minimumValue:   0
                                        maximumValue:   100
                                        value:          object.progress * 100.0
                                    }
                                }
                            }
                        }
                    }
                    Row {
                        spacing:    ScreenTools.defaultFontPixelWidth
                        anchors.horizontalCenter: parent.horizontalCenter
                        QGCButton {
                            text:      qsTr("检查所有")
                            enabled:    !QGroundControl.mavlinkLogManager.uploading && !QGroundControl.mavlinkLogManager.logRunning
                            onClicked: {
                                for(var i = 0; i < QGroundControl.mavlinkLogManager.logFiles.count; i++) {
                                    var logFile = QGroundControl.mavlinkLogManager.logFiles.get(i)
                                    logFile.selected = true
                                }
                            }
                        }
                        QGCButton {
                            text:      qsTr("不检查")
                            enabled:    !QGroundControl.mavlinkLogManager.uploading && !QGroundControl.mavlinkLogManager.logRunning
                            onClicked: {
                                for(var i = 0; i < QGroundControl.mavlinkLogManager.logFiles.count; i++) {
                                    var logFile = QGroundControl.mavlinkLogManager.logFiles.get(i)
                                    logFile.selected = false
                                }
                            }
                        }
                        QGCButton {
                            text:      qsTr("删除所选")
                            enabled:    _selectedCount > 0 && !QGroundControl.mavlinkLogManager.uploading && !QGroundControl.mavlinkLogManager.logRunning
                            onClicked:  deleteDialog.open()
                            MessageDialog {
                                id:         deleteDialog
                                visible:    false
                                icon:       StandardIcon.Warning
                                standardButtons: StandardButton.Yes | StandardButton.No
                                title:      qsTr("删除选择的日志文件")
                                text:       qsTr("确认删除选择的日志文件?")
                                onYes: {
                                    QGroundControl.mavlinkLogManager.deleteLog()
                                }
                            }
                        }
                        QGCButton {
                            text:      qsTr("上传选择的文件")
                            enabled:    _selectedCount > 0 && !QGroundControl.mavlinkLogManager.uploading && !QGroundControl.mavlinkLogManager.logRunning && !_uploadedSelected
                            visible:    !QGroundControl.mavlinkLogManager.uploading
                            onClicked:  {
                                saveItems();
                                if(QGroundControl.mavlinkLogManager.emailAddress === "")
                                    emptyEmailDialog.open()
                                else
                                    uploadDialog.open()
                            }
                            MessageDialog {
                                id:         uploadDialog
                                visible:    false
                                icon:       StandardIcon.Question
                                standardButtons: StandardButton.Yes | StandardButton.No
                                title:      qsTr("上传选择的日志文件")
                                text:       qsTr("确认上传选择的日志文件?")
                                onYes: {
                                    QGroundControl.mavlinkLogManager.uploadLog()
                                }
                            }
                        }
                        QGCButton {
                            text:      qsTr("取消")
                            enabled:    QGroundControl.mavlinkLogManager.uploading && !QGroundControl.mavlinkLogManager.logRunning
                            visible:    QGroundControl.mavlinkLogManager.uploading
                            onClicked:  cancelDialog.open()
                            MessageDialog {
                                id:         cancelDialog
                                visible:    false
                                icon:       StandardIcon.Warning
                                standardButtons: StandardButton.Yes | StandardButton.No
                                title:      qsTr("取消上传")
                                text:       qsTr("确认取消上传操作?")
                                onYes: {
                                    QGroundControl.mavlinkLogManager.cancelUpload()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
