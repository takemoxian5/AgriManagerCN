import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs  1.2
import QtQuick.Extras   1.4
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Palette       1.0
import QGroundControl.FlightMap     1.0


import QGroundControl.SettingsManager   1.0
import QGroundControl.Controllers       1.0

// Editor for Survery mission items
Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      qgcPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:            ScreenTools.defaultFontPixelWidth / 2
    property int    _cameraIndex:       1
    property real   _fieldWidth:        ScreenTools.defaultFontPixelWidth * 10.5
    property var    _cameraList:        [ qsTr("植保设置"), qsTr("航拍通用设置"), qsTr("自用相机设置") ]
    property var    _vehicle:           QGroundControl.multiVehicleManager.activeVehicle ? QGroundControl.multiVehicleManager.activeVehicle : QGroundControl.multiVehicleManager.offlineEditingVehicle
    property var    _vehicleCameraList: _vehicle.cameraList

    readonly property int _agriTypeManual:          0
    readonly property int _gridTypeManual:			1
    readonly property int _gridTypeCustomCamera:    2
    readonly property int _gridTypeCamera:          3




    Component.onCompleted: {
        for (var i=0; i<_vehicle.cameraList.length; i++) {
            _cameraList.push(_vehicle.cameraList[i].name)
        }
        gridTypeCombo.model = _cameraList
        if (missionItem.manualGrid.value) {
            gridTypeCombo.currentIndex = _gridTypeManual
        } else {
            var index = -1
            for (index=0; index<_cameraList.length; index++) {
                if (_cameraList[index] == missionItem.camera.value) {
                    break;
                }
            }
            missionItem.cameraOrientationFixed = false
            if (index == _cameraList.length) {
                gridTypeCombo.currentIndex = _gridTypeCustomCamera
            } else {
                gridTypeCombo.currentIndex = index
                if (index != _gridTypeCustomCamera) {
                    // Specific camera is selected
                    var camera = _vehicleCameraList[index - _gridTypeCamera]
                    missionItem.cameraOrientationFixed = camera.fixedOrientation
                    missionItem.cameraMinTriggerInterval = camera.minTriggerInterval
                }
            }
        }
    }

    function recalcFromCameraValues() {
        var focalLength     = missionItem.cameraFocalLength.rawValue
        var sensorWidth     = missionItem.cameraSensorWidth.rawValue
        var sensorHeight    = missionItem.cameraSensorHeight.rawValue
        var imageWidth      = missionItem.cameraResolutionWidth.rawValue
        var imageHeight     = missionItem.cameraResolutionHeight.rawValue

        var altitude        = missionItem.gridAltitude.rawValue
        var groundResolution= missionItem.groundResolution.rawValue
        var frontalOverlap  = missionItem.frontalOverlap.rawValue
        var sideOverlap     = missionItem.sideOverlap.rawValue

        if (focalLength <= 0 || sensorWidth <= 0 || sensorHeight <= 0 || imageWidth <= 0 || imageHeight <= 0 || groundResolution <= 0) {
            return
        }

        var imageSizeSideGround     //size in side (non flying) direction of the image on the ground
        var imageSizeFrontGround    //size in front (flying) direction of the image on the ground
        var gridSpacing
        var cameraTriggerDistance

        if (missionItem.fixedValueIsAltitude.value) {
            groundResolution = (altitude * sensorWidth * 100) / (imageWidth * focalLength)
        } else {
            altitude = (imageWidth * groundResolution * focalLength) / (sensorWidth * 100)
        }

        if (missionItem.cameraOrientationLandscape.value) {
            imageSizeSideGround  = (imageWidth  * groundResolution) / 100
            imageSizeFrontGround = (imageHeight * groundResolution) / 100
        } else {
            imageSizeSideGround  = (imageHeight * groundResolution) / 100
            imageSizeFrontGround = (imageWidth  * groundResolution) / 100
        }

        gridSpacing = imageSizeSideGround * ( (100-sideOverlap) / 100 )
        cameraTriggerDistance = imageSizeFrontGround * ( (100-frontalOverlap) / 100 )

        if (missionItem.fixedValueIsAltitude.value) {
            missionItem.groundResolution.rawValue = groundResolution
        } else {
            missionItem.gridAltitude.rawValue = altitude
        }
        missionItem.gridSpacing.rawValue = gridSpacing
        missionItem.cameraTriggerDistance.rawValue = cameraTriggerDistance
    }

    function polygonCaptureStarted() {
        missionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }

    property bool _noCameraValueRecalc: false   ///< Prevents uneeded recalcs

    Connections {
        target: missionItem.camera

        onValueChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera && !_noCameraValueRecalc) {
                recalcFromCameraValues()
            }
        }
    }

    Connections {
        target: missionItem.gridAltitude

        onValueChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera && missionItem.fixedValueIsAltitude.value && !_noCameraValueRecalc) {
                recalcFromCameraValues()
            }
        }
    }

    Connections {
        target: missionItem

        onCameraValueChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera && !_noCameraValueRecalc) {
                recalcFromCameraValues()
            }
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    ExclusiveGroup {
        id: cameraOrientationGroup

        onCurrentChanged: {
            if (gridTypeCombo.currentIndex >= _gridTypeCustomCamera) {
                recalcFromCameraValues()
            }
        }
    }

    ExclusiveGroup { id: fixedValueGroup }

    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin

        QGCLabel {
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("WARNING: Photo interval is below minimum interval (%1 secs) supported by camera.").arg(missionItem.cameraMinTriggerInterval.toFixed(1))
            wrapMode:       Text.WordWrap
            color:          qgcPal.warningText
            visible:        missionItem.manualGrid.value !== true && missionItem.cameraShots > 0 && missionItem.cameraMinTriggerInterval !== 0 && missionItem.cameraMinTriggerInterval > missionItem.timeBetweenShots
        }

        SectionHeader {
            id:         cameraHeader
            text:       qsTr("功能设置")
            showSpacer: false
        }

        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        cameraHeader.checked

            QGCComboBox {
                id:             gridTypeCombo
                anchors.left:   parent.left
                anchors.right:  parent.right
                model:          _cameraList
                currentIndex:   -1

                onActivated: {
                    if (index == _gridTypeManual) {
                        missionItem.manualGrid.value = true
                        missionItem.fixedValueIsAltitude.value = true
                    } else if (index == _gridTypeCustomCamera) {
                        missionItem.manualGrid.value = false
                        missionItem.camera.value = gridTypeCombo.textAt(index)
                        missionItem.cameraOrientationFixed = false
                        missionItem.cameraMinTriggerInterval = 0
                    }
                    //Start G201710111285 ChenYang  _agriTypeManual 植保模式
                    else if (index == _agriTypeManual) {
                        missionItem.manualGrid.value = false
                        missionItem.camera.value = gridTypeCombo.textAt(index)
                        missionItem.cameraOrientationFixed = false
                        missionItem.cameraMinTriggerInterval = 0
                    }
                    //End G201710111285 ChenYang
                    else {
                        missionItem.manualGrid.value = false
                        missionItem.camera.value = gridTypeCombo.textAt(index)
                        _noCameraValueRecalc = true
                        var listIndex = index - _gridTypeCamera
                        missionItem.cameraSensorWidth.rawValue          = _vehicleCameraList[listIndex].sensorWidth
                        missionItem.cameraSensorHeight.rawValue         = _vehicleCameraList[listIndex].sensorHeight
                        missionItem.cameraResolutionWidth.rawValue      = _vehicleCameraList[listIndex].imageWidth
                        missionItem.cameraResolutionHeight.rawValue     = _vehicleCameraList[listIndex].imageHeight
                        missionItem.cameraFocalLength.rawValue          = _vehicleCameraList[listIndex].focalLength
                        missionItem.cameraOrientationLandscape.rawValue = _vehicleCameraList[listIndex].landscape ? 1 : 0
                        missionItem.cameraOrientationFixed              = _vehicleCameraList[listIndex].fixedOrientation
                        missionItem.cameraMinTriggerInterval            = _vehicleCameraList[listIndex].minTriggerInterval
                        _noCameraValueRecalc = false
                        recalcFromCameraValues()
                    }
                }
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        missionItem.manualGrid.value == true

                QGCCheckBox {
                    id:                 cameraTriggerDistanceCheckBox
                    anchors.baseline:   cameraTriggerDistanceField.baseline
                    text:               qsTr("触发距离")
                    checked:            missionItem.cameraTriggerDistance.rawValue > 0
                    onClicked: {
                        if (checked) {
                            missionItem.cameraTriggerDistance.value = missionItem.cameraTriggerDistance.defaultValue
                        } else {
                            missionItem.cameraTriggerDistance.value = 0
                        }
                    }
                }
				

                FactTextField {
                    id:                 cameraTriggerDistanceField
                    Layout.fillWidth:   true
                    fact:               missionItem.cameraTriggerDistance
                    enabled:            cameraTriggerDistanceCheckBox.checked
                }
            }
        }

        // Camera based grid ui
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        _margin
            visible:        gridTypeCombo.currentIndex >  _gridTypeManual

            Row {
                spacing:                    _margin
                anchors.horizontalCenter:   parent.horizontalCenter
                visible:                    !missionItem.cameraOrientationFixed

                QGCRadioButton {
                    width:          _editFieldWidth
                    text:           "Landscape"
                    checked:        !!missionItem.cameraOrientationLandscape.value
                    exclusiveGroup: cameraOrientationGroup
                    onClicked:      missionItem.cameraOrientationLandscape.value = 1
                }

                QGCRadioButton {
                    id:             cameraOrientationPortrait
                    text:           "Portrait"
                    checked:        !missionItem.cameraOrientationLandscape.value
                    exclusiveGroup: cameraOrientationGroup
                    onClicked:      missionItem.cameraOrientationLandscape.value = 0
                }
            }

            Column {
                id:             custCameraCol
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                visible:        gridTypeCombo.currentIndex === _gridTypeCustomCamera

                RowLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        _margin
                    Item { Layout.fillWidth: true }
                    QGCLabel {
                        Layout.preferredWidth:  _root._fieldWidth
                        text:                   qsTr("宽度")
                    }
                    QGCLabel {
                        Layout.preferredWidth:  _root._fieldWidth
                        text:                   qsTr("高度")
                    }
                }

                RowLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        _margin
                    QGCLabel {
                        text: qsTr("传感器")
                        Layout.fillWidth: true }
                    FactTextField {
                        Layout.preferredWidth:  _root._fieldWidth
                        fact:                   missionItem.cameraSensorWidth
                    }
                    FactTextField {
                        Layout.preferredWidth:  _root._fieldWidth
                        fact:                   missionItem.cameraSensorHeight
                    }
                }

                RowLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        _margin
                    QGCLabel {
                        text: qsTr("像素")
                        Layout.fillWidth: true
                    }
                    FactTextField {
                        Layout.preferredWidth:  _root._fieldWidth
                        fact:                   missionItem.cameraResolutionWidth
                    }
                    FactTextField {
                        Layout.preferredWidth:  _root._fieldWidth
                        fact:                   missionItem.cameraResolutionHeight
                    }
                }

                RowLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing:        _margin
                    QGCLabel {
                        text:                   qsTr("焦距")
                        Layout.fillWidth:       true
                    }
                    FactTextField {
                        Layout.preferredWidth:  _root._fieldWidth
                        fact:                   missionItem.cameraFocalLength
                    }
                }

            } // Column - custom camera

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                Item { Layout.fillWidth: true }
                QGCLabel {
                    Layout.preferredWidth:  _root._fieldWidth
                    text:                   qsTr("前向重叠")
                }
                QGCLabel {
                    Layout.preferredWidth:  _root._fieldWidth
                    text:                   qsTr("旁向重叠")
                }
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing:        _margin
                QGCLabel {
                    text: qsTr("覆盖率")
                    Layout.fillWidth: true
                }
                FactTextField {
                    Layout.preferredWidth:  _root._fieldWidth
                    fact:                   missionItem.frontalOverlap
                }
                FactTextField {
                    Layout.preferredWidth:  _root._fieldWidth
                    fact:                   missionItem.sideOverlap
                }
            }

            FactCheckBox {
                text:       qsTr("悬停和捕捉图像")
                fact:       missionItem.hoverAndCapture
                visible:    missionItem.hoverAndCaptureAllowed
                onClicked: {
                    if (checked) {
                        missionItem.cameraTriggerInTurnaround.rawValue = false
                    }
                }
            }

            FactCheckBox {
                text:       qsTr("周转时拍照")
                fact:       missionItem.cameraTriggerInTurnaround
                enabled:    !missionItem.hoverAndCapture.rawValue
            }

            SectionHeader {
                id:     gridHeader
                text:   qsTr("网格")
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  _margin
                rowSpacing:     _margin
                columns:        2
                visible:        gridHeader.checked

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  _margin
                    rowSpacing:     _margin
                    columns:        2
                    visible:        gridHeader.checked

                    QGCLabel {
                        id:                 angleText
                        text:               qsTr("角度")
                        Layout.fillWidth:   true
                    }

                    ToolButton {
                        id:                     windRoseButton
                        anchors.verticalCenter: angleText.verticalCenter
                        iconSource:             qgcPal.globalTheme === QGCPalette.Light ? "/res/wind-roseBlack.svg" : "/res/wind-rose.svg"
                        // Wind Rose is temporarily turned off until bugs are fixed
                      //  visible:                false//_vehicle.fixedWing

                        onClicked: {
                            windRosePie.angle = Number(gridAngleText.text)
                            var cords = windRoseButton.mapToItem(_root, 0, 0)
                            windRosePie.popup(cords.x + windRoseButton.width / 2, cords.y + windRoseButton.height / 2);
                        }
                    }
                }

                FactTextField {
                    id:                 gridAngleText
                    fact:               missionItem.gridAngle
                    Layout.fillWidth:   true
                }

                QGCLabel { text: qsTr("周转距离") }
                FactTextField {
                    fact:                   missionItem.turnaroundDist
                    Layout.fillWidth:       true
                }

                QGCLabel { text: qsTr("入口") }
                FactComboBox {
                    fact:                   missionItem.gridEntryLocation
                    indexModel:             false
                    Layout.fillWidth:       true
                }

                QGCCheckBox {
                    text:               qsTr("添加垂直方向扫描")
                    checked:            missionItem.refly90Degrees
                    onClicked:          missionItem.refly90Degrees = checked
                    Layout.columnSpan:  2
                }

                QGCLabel {
                    wrapMode:               Text.WordWrap
                    text:                   qsTr("选择一个:")
                    Layout.preferredWidth:  parent.width
                    Layout.columnSpan:      2
                }

                QGCRadioButton {
                    id:                     fixedAltitudeRadio
                    text:                   qsTr("高度")
                    checked:                !!missionItem.fixedValueIsAltitude.value
                    exclusiveGroup:         fixedValueGroup
                    onClicked:              missionItem.fixedValueIsAltitude.value = 1
                }

                FactTextField {
                    fact:                   missionItem.gridAltitude
                    enabled:                fixedAltitudeRadio.checked
                    Layout.fillWidth:       true
                }

                QGCRadioButton {
                    id:                     fixedGroundResolutionRadio
                    text:                   qsTr("地面解决方案")
                    checked:                !missionItem.fixedValueIsAltitude.value
                    exclusiveGroup:         fixedValueGroup
                    onClicked:              missionItem.fixedValueIsAltitude.value = 0
                }

                FactTextField {
                    fact:                   missionItem.groundResolution
                    enabled:                fixedGroundResolutionRadio.checked
                    Layout.fillWidth:       true
                }
            }
        }




        // agri based  ui    //G201710111285 ChenYang
        Column {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing: 	   _margin
            visible: 	   gridTypeCombo.currentIndex === _agriTypeManual

            //            Row {
            //                spacing: 				   _margin
            //                anchors.horizontalCenter:   parent.horizontalCenter
            //                visible: 				   !missionItem.cameraOrientationFixed

            //                QGCRadioButton {
            //                    width:		   _editFieldWidth
            //                    text:		   "Landscape"
            //                    checked: 	   !!missionItem.cameraOrientationLandscape.value
            //                    exclusiveGroup: cameraOrientationGroup
            //                    onClicked:	   missionItem.cameraOrientationLandscape.value = 1
            //                }

            //                QGCRadioButton {
            //                    id:			   agricameraOrientationPortrait
            //                    text:		   "Portrait"
            //                    checked: 	   !missionItem.cameraOrientationLandscape.value
            //                    exclusiveGroup: cameraOrientationGroup
            //                    onClicked:	   missionItem.cameraOrientationLandscape.value = 0
            //                }
            //            }

            Column {
                id:			   agriCol
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing: 	   _margin
                visible: 	   gridTypeCombo.currentIndex === _agriTypeManual//_agriTypeManual

                //                RowLayout {
                //                    anchors.left:   parent.left
                //                    anchors.right:  parent.right
                //                    spacing: 	   _margin
                //                    Item { Layout.fillWidth: true }
                //                    QGCLabel {
                //                        Layout.preferredWidth:  _root._fieldWidth
                //                        text:				   qsTr("宽度")
                //                    }
                //                    QGCLabel {
                //                        Layout.preferredWidth:  _root._fieldWidth
                //                        text:				   qsTr("长度")
                //                    }
                //                    //						   QGCLabel {
                //                    //							   Layout.preferredWidth:  _root._fieldWidth
                //                    //							   text:				   qsTr("高度")
                //                    //						   }
                //                }

                //					   RowLayout {
                //						   anchors.left:   parent.left
                //						   anchors.right:  parent.right
                //						   spacing: 	   _margin
                //						   QGCLabel { text: qsTr("喷幅"); Layout.fillWidth: true }
                //						   FactTextField {
                //							   Layout.preferredWidth:  _root._fieldWidth
                //							   fact:				   missionItem.cameraSensorWidth
                //						   }
                //						   FactTextField {
                //							   Layout.preferredWidth:  _root._fieldWidth
                //							   fact:				   missionItem.cameraSensorHeight
                //						   }
                //					   }

                RowLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    spacing: 	   _margin
                    QGCLabel { text: qsTr("5米喷幅")
                        Layout.fillWidth: true
                    }
                    FactTextField {
                        fact:					missionItem.gridSpacing
                        Layout.fillWidth:		true
                    }
                    //                    FactTextField {
                    //                        Layout.preferredWidth:  _root._fieldWidth
                    //                        fact:				   missionItem.cameraResolutionWidth
                    //                    }
                    //                    FactTextField {
                    //                        Layout.preferredWidth:  _root._fieldWidth
                    //                        fact:				   missionItem.cameraResolutionHeight
                    //                    }
                }

                //                RowLayout {
                //                    anchors.left:   parent.left
                //                    anchors.right:  parent.right
                //                    spacing: 	   _margin
                //                    QGCLabel {
                //                        text:				   qsTr("10米喷幅")
                //                        Layout.fillWidth:	   true
                //                    }
                //                    FactTextField {
                //                        Layout.preferredWidth:  _root._fieldWidth
                //                        fact:				   missionItem.cameraResolutionHeight
                //                    }
                //				    FactTextField {
                //					   Layout.preferredWidth:  _root._fieldWidth
                //					   fact:				   missionItem.cameraFocalLength
                //				   }
                //                }

            }      //G201710111285 ChenYang  Column -  agri mode

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing: 	   _margin
                Item { Layout.fillWidth: true }
                QGCLabel {
                    Layout.preferredWidth:  _root._fieldWidth
                    text:				   qsTr("正面")
                }
                QGCLabel {
                    Layout.preferredWidth:  _root._fieldWidth
                    text:				   qsTr("侧面")
                }
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                spacing: 	   _margin
                QGCLabel {
                    text: qsTr("覆盖率")
                    Layout.fillWidth: true }
                FactTextField {
                    Layout.preferredWidth:  _root._fieldWidth
                    fact:				   missionItem.frontalOverlap
                }
                FactTextField {
                    Layout.preferredWidth:  _root._fieldWidth
                    fact:				   missionItem.sideOverlap
                }
            }

            FactCheckBox {
                text:	   qsTr("允许悬停")
                fact:	   missionItem.hoverAndCapture
                visible:    missionItem.hoverAndCaptureAllowed
                onClicked: {
                    if (checked) {
                        missionItem.cameraTriggerInTurnaround.rawValue = false
                    }
                }
            }

            FactCheckBox {
                text:	   qsTr("转弯处喷洒")
                fact:	   missionItem.cameraTriggerInTurnaround
                enabled:    !missionItem.hoverAndCapture.rawValue
            }

            SectionHeader {
                id:	   agriHeader
                text:   qsTr("航线设置")
            }

            GridLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                columnSpacing:  _margin
                rowSpacing:	   _margin
                columns: 	   2
                visible: 	   agriHeader.checked

                GridLayout {
                    anchors.left:   parent.left
                    anchors.right:  parent.right
                    columnSpacing:  _margin
                    rowSpacing:	   _margin
                    columns: 	   2
                    visible: 	   agriHeader.checked

                    QGCLabel {
                        id:				   tempangleText
                        text:			   qsTr("航线角度")
                        Layout.fillWidth:   true
                    }

                    ToolButton {
                        id:					   agriwindRoseButton
                        //                        anchors.verticalCenter:  mapPolygonVisuals.verticalCenter// QGroundControl.flightMapPosition//tempangleText.verticalCenter
                        anchors.verticalCenter:  missionItem.gridEntryLocation//.flightMapPosition//tempangleText.verticalCenter

                        //                        iconSource:			    "/res/wind-roseBlack.svg"
                        iconSource:			   qgcPal.globalTheme === QGCPalette.Light ? "/res/wind-roseBlack.svg" : "/res/wind-rose.svg"
                        visible: 	   agriHeader.checked
                        //                        visible: 			   _vehicle.fixedWing

                        onClicked: {
                            windRosePie.angle = Number(tempangleText.text)

                            //                                                        var cords =QGroundControl.flightMapPosition// windRoseButton.mapToItem(_root, 0, 0)
                            //                                                        windRosePie.popup(cords.x , cords.y )//+ windRoseButton.height / 2)+ windRoseButton.width / 2
                            var cords = agriwindRoseButton.mapToItem(_root, 0, 0)
                            windRosePie.popup(cords.x + agriwindRoseButton.width / 2, cords.y + agriwindRoseButton.height / 2)
                        }
                    }
                }

                FactTextField {
                    id:				   agriAngleText
                    fact:			   missionItem.gridAngle
                    Layout.fillWidth:   true
                }
                //Start G201710111285 ChenYang  转弯模式选择
                QGCCheckBox {
                    text:			   qsTr("曲线转弯")
                    //						   checked: 		   missionItem.refly90Degrees
                    //						   onClicked:		   missionItem.refly90Degrees = checked
                    Layout.columnSpan:  2
                }
                QGCCheckBox {
                    text:			   qsTr("保持机头朝向")
                    checked: 		   true
                    //						   onClicked:		   missionItem.refly90Degrees = checked
                    Layout.columnSpan:  2
                }
                //End G201710111285 ChenYang
                QGCCheckBox {
					text:		qsTr("结束返航")
					checked:	missionItem.missionEndRTL
					onClicked:	missionItem.missionEndRTL = checked
                    Layout.columnSpan:  2
                }
//				Column {
//						anchors.left:	parent.left
//						anchors.right:	parent.right
//						spacing:		_margin
//						QGCCheckBox {
//							text:		qsTr("结束返航")
//							checked:	missionItem.missionEndRTL
//							onClicked:	missionItem.missionEndRTL = checked
//						}
//					}
//				}

				
                QGCLabel { text: qsTr("转弯距离") }
                FactTextField {
                    fact:				   missionItem.turnaroundDist
                    Layout.fillWidth:	   true
                }

                QGCLabel {
                    text: qsTr("起点")
                }
                FactComboBox {
                    fact:				   missionItem.gridEntryLocation
                    indexModel:			   false
                    Layout.fillWidth:	   true
                }
                //					   QGCCheckBox {
                //						   text:			   qsTr("添加垂直方向扫描")
                //						   checked: 		   missionItem.refly90Degrees
                //						   onClicked:		   missionItem.refly90Degrees = checked
                //						   Layout.columnSpan:  2
                //					   }
                QGCLabel {
                    wrapMode:			   Text.WordWrap
                    text:				   qsTr("选择基准参数:")
                    Layout.preferredWidth:  parent.width
                    Layout.columnSpan:	   2
                }
                //                QGCRadioButton {
                //                    id:					   agrifixedAltitudeRadio
                //                    text:				   qsTr("固定高度")
                //                    checked: 			   !!missionItem.fixedValueIsAltitude.value
                //                    exclusiveGroup:		   fixedValueGroup
                //                    onClicked:			   missionItem.fixedValueIsAltitude.value = 1
                //                }

                //                FactTextField {
                //                    fact:				   missionItem.gridAltitude
                //                    enabled: 			   agrifixedAltitudeRadio.checked
                //                    Layout.fillWidth:	   true
                //                }
                QGCRadioButton {
                    id:					   agrifixedAltitudeRadio
                    text:				   qsTr("固定高度")
                    //                    checked: 			   !!missionItem.fixedValueIsAltitude.value
                    exclusiveGroup:		   fixedValueGroup
                    //                    onClicked:			   missionItem.fixedValueIsAltitude.value = 1
                }
                FactTextField {
                    fact: 			missionItem.gridAltitude
                    //				   fact:			   QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                    Layout.fillWidth:   true
                }
				 QGCCheckBox {
                        id:         agriflightSpeedCheckBox
                        text:       qsTr("飞行速度")
                        visible:    !_missionVehicle.vtol
                        checked:    missionItem.speedSection.specifyFlightSpeed
                        onClicked:   missionItem.speedSection.specifyFlightSpeed = checked
                    }
                    FactTextField {
                        Layout.fillWidth:   true
                        fact:               missionItem.speedSection.flightSpeed
                        visible:            agriflightSpeedCheckBox.visible
                        enabled:            agriflightSpeedCheckBox.checked
                    }
//                QGCRadioButton {
//                    id:					   agrifixedGroundResolutionRadio
//                    text:				   qsTr("固定速度")
//                    checked:    missionItem.speedSection.specifyFlightSpeed
//                    onClicked:   missionItem.speedSection.specifyFlightSpeed = checked
//                }
//                FactTextField {
//                    Layout.fillWidth:   true
//                    fact:               missionItem.speedSection.flightSpeed
////					visible:			agrifixedGroundResolutionRadio.visible
////					enabled:			agrifixedGroundResolutionRadio.checked	

//                }
            }
        }




        // Manual grid ui
        SectionHeader {
            id:         manualGridHeader
            text:       qsTr("网格")
            visible:    gridTypeCombo.currentIndex == _gridTypeManual
        }
        GridLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            columnSpacing:  _margin
            rowSpacing:     _margin
            columns:        2
            visible:        manualGridHeader.visible && manualGridHeader.checked

            RowLayout {
                spacing: _margin

                QGCLabel {
                    id:                 manualAngleText
                    text:               qsTr("角度")
                    Layout.fillWidth:  true
                }

                ToolButton {
                    id:                     manualWindRoseButton
                    anchors.verticalCenter: manualAngleText.verticalCenter
                    Layout.columnSpan:      1
                    iconSource:             qgcPal.globalTheme === QGCPalette.Light ? "/res/wind-roseBlack.svg" : "/res/wind-rose.svg"
                    // Wind Rose is temporarily turned off until bugs are fixed
 //                   visible:                false//_vehicle.fixedWing

                    onClicked: {
		      	windRosePie.angle = Number(manualAngleText.text)
                        var cords = manualWindRoseButton.mapToItem(_root, 0, 0)
                        windRosePie.popup(cords.x + manualWindRoseButton.width / 2, cords.y + manualWindRoseButton.height / 2);
                    }
                }
            }

            FactTextField {
                id:                 manualGridAngleText
                fact:               missionItem.gridAngle
                Layout.fillWidth:   true
            }

            QGCLabel { text: qsTr("间隔") }
            FactTextField {
                fact:                   missionItem.gridSpacing
                Layout.fillWidth:       true
            }

            QGCLabel { text: qsTr("高度") }
            FactTextField {
                fact:                   missionItem.gridAltitude
                Layout.fillWidth:       true
            }
            QGCLabel { text: qsTr("周转距离") }
            FactTextField {
                fact:                   missionItem.turnaroundDist
                Layout.fillWidth:       true
            }
            QGCLabel {
                text: qsTr("入口")
                visible: !windRoseButton.visible
            }
            FactComboBox {
                id: gridAngleBox
                fact:                   missionItem.gridEntryLocation
                visible:                !windRoseButton.visible
                indexModel:             false
                Layout.fillWidth:       true
            }

            FactCheckBox {
                text:               qsTr("允许悬停和捕捉图像")
                fact:               missionItem.hoverAndCapture
                visible:            missionItem.hoverAndCaptureAllowed
                Layout.columnSpan:  2
                onClicked: {
                    if (checked) {
                        missionItem.cameraTriggerInTurnaround.rawValue = false
                    }
                }
            }

            FactCheckBox {
                text:               qsTr("转弯处拍照")
                fact:               missionItem.cameraTriggerInTurnaround
                enabled:            !missionItem.hoverAndCapture.rawValue
                Layout.columnSpan:  2
            }

            QGCCheckBox {
                text:               qsTr("添加垂直扫描")
                checked:            missionItem.refly90Degrees
                onClicked:          missionItem.refly90Degrees = checked
                Layout.columnSpan:  2
            }

            FactCheckBox {
                anchors.left:       parent.left
                text:               qsTr("相对高度")
                fact:               missionItem.gridAltitudeRelative
                Layout.columnSpan:  2
            }
        }

        SectionHeader {
            id:     statsHeader
            text:   qsTr("统计") }
        //植保模式参数
        Grid {
            columns:        2
            columnSpacing:  ScreenTools.defaultFontPixelWidth
            visible:        statsHeader.checked&&gridTypeCombo.currentIndex === _agriTypeManual

            QGCLabel { text: qsTr("测量面积") }
            //    QGCLabel { text: QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.appSettingsAreaUnitsString }
            //G201709261286 ChenYang  显示精度修改
            QGCLabel {
                text: {
                    var squaretemp = QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea)
                    var squaretempH = (squaretemp/1000)
                    squaretemp=squaretemp%1000+0.4 //偏小0.4
                    if(squaretemp.toFixed(0)&&squaretemp.toFixed(0)!=1000 ){
                        //高位不能四舍五入进位，只是去除小数,低位进位后为000才能真进位
                        //                                     if(squaretemp.toFixed(0)==1000 ){
                        //                                    return (squaretempH).toFixed(0)+ ", "+squaretemp.toFixed(0) + " "+ QGroundControl.appSettingsAreaUnitsString
                        //                                     }
                        //无进位
                        return  (squaretempH-0.6).toFixed(0)+ ", "+squaretemp.toFixed(1) + " "+ QGroundControl.appSettingsAreaUnitsString
                    }
                    //进位
                    return squaretempH.toFixed(0)+ ", " +"000.0"+ " "+ QGroundControl.appSettingsAreaUnitsString
                }
            }
            QGCLabel { text: qsTr("预计喷洒时间") }
            QGCLabel { text: missionItem.cameraShots/2+ qsTr("min") }

            QGCLabel { text: qsTr("喷洒速度") }
            QGCLabel {
                text: {
                    var timeVal = missionItem.timeBetweenShots
                    if(!isFinite(timeVal) || missionItem.cameraShots === 0) {
                        return qsTr("N/A")
                    }
                    return timeVal.toFixed(1) + " " + qsTr("m/s")
                }
            }
        }

        Grid {
            columns:        2
            columnSpacing:  ScreenTools.defaultFontPixelWidth
            visible:        statsHeader.checked&&gridTypeCombo.currentIndex != _agriTypeManual

            QGCLabel { text: qsTr("测量面积") }
            //    QGCLabel { text: QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.appSettingsAreaUnitsString }
            //G201709261286 ChenYang  显示精度修改
            QGCLabel {
                text: {
                    var squaretemp = QGroundControl.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea)
                    var squaretempH = (squaretemp/1000)
                    squaretemp=squaretemp%1000+0.4 //偏小0.4
                    if(squaretemp.toFixed(0)&&squaretemp.toFixed(0)!=1000 ){
                        //高位不能四舍五入进位，只是去除小数,低位进位后为000才能真进位
                        //                                     if(squaretemp.toFixed(0)==1000 ){
                        //                                    return (squaretempH).toFixed(0)+ ", "+squaretemp.toFixed(0) + " "+ QGroundControl.appSettingsAreaUnitsString
                        //                                     }
                        //无进位
                        return  (squaretempH-0.6).toFixed(0)+ ", "+squaretemp.toFixed(1) + " "+ QGroundControl.appSettingsAreaUnitsString
                    }
                    //进位
                    return squaretempH.toFixed(0)+ ", " +"000.0"+ " "+ QGroundControl.appSettingsAreaUnitsString
                }
            }
            QGCLabel { text: qsTr("拍照数量") }
            QGCLabel { text: missionItem.cameraShots }

            QGCLabel { text: qsTr("照片时间间隔") }
            QGCLabel {
                text: {
                    var timeVal = missionItem.timeBetweenShots
                    if(!isFinite(timeVal) || missionItem.cameraShots === 0) {
                        return qsTr("N/A")
                    }
                    return timeVal.toFixed(1) + " " + qsTr("秒")
                }
            }
        }
    }

    QGCColoredImage {
        id:      windRoseArrow
        source:  "/res/wind-rose-arrow.svg"
        visible: windRosePie.visible
        width:   windRosePie.width / 5
        height:  width * 1.454
        smooth:  true
        color:   qgcPal.colorGrey
        transform: Rotation {
            origin.x: windRoseArrow.width / 2
            origin.y: windRoseArrow.height / 2
            axis { x: 0; y: 0; z: 1 } angle: windRosePie.angle
        }
        x: windRosePie.x + Math.sin(- windRosePie.angle*Math.PI/180 - Math.PI/2)*(windRosePie.width/2 - windRoseArrow.width/2) + windRosePie.width / 2 - windRoseArrow.width / 2
        y: windRosePie.y + Math.cos(- windRosePie.angle*Math.PI/180 - Math.PI/2)*(windRosePie.width/2 - windRoseArrow.width/2) + windRosePie.height / 2 - windRoseArrow.height / 2
        z: windRosePie.z + 1
    }

    QGCColoredImage {
        id:      windGuru
        source:  "/res/wind-guru.svg"
        visible: windRosePie.visible
        width:   windRosePie.width / 3
        height:  width * 4.28e-1
        smooth:  true
        color:   qgcPal.colorGrey
        transform: Rotation {
            origin.x: windGuru.width / 2
            origin.y: windGuru.height / 2
            axis { x: 0; y: 0; z: 1 } angle: windRosePie.angle + 180
        }
        x: windRosePie.x + Math.sin(- windRosePie.angle*Math.PI/180 - 3*Math.PI/2)*(windRosePie.width/2) + windRosePie.width / 2 - windGuru.width / 2
        y: windRosePie.y + Math.cos(- windRosePie.angle*Math.PI/180 - 3*Math.PI/2)*(windRosePie.height/2) + windRosePie.height / 2 - windGuru.height / 2
        z: windRosePie.z + 1
    }

    Item {
        id:          windRosePie
        height:      2.6*windRoseButton.height
        width:       2.6*windRoseButton.width
        visible:     false
        focus:       true

        property string colorCircle: qgcPal.windowShade
        property string colorBackground: qgcPal.colorGrey
        property real lineWidth: windRoseButton.width / 3
        property real angle: Number(gridAngleText.text)
        

        //    property real angle: Number(agriAngleText.text)    //G201710121286 ChenYang   不显示界面 排查

        Canvas {
            id: windRoseCanvas
            anchors.fill: parent

            onPaint: {
                var ctx = getContext("2d")
                var x = width / 2
                var y = height / 2
                var angleWidth = 0.03 * Math.PI
                var start = windRosePie.angle*Math.PI/180 - angleWidth
                var end = windRosePie.angle*Math.PI/180 + angleWidth
                ctx.reset()

                ctx.beginPath();
                ctx.arc(x, y, (width / 3) - windRosePie.lineWidth / 2, 0, 2*Math.PI, false)
                ctx.lineWidth = windRosePie.lineWidth
                ctx.strokeStyle = windRosePie.colorBackground
                ctx.stroke()

                ctx.beginPath();
                ctx.arc(x, y, (width / 3) - windRosePie.lineWidth / 2, start, end, false)
                ctx.lineWidth = windRosePie.lineWidth
                ctx.strokeStyle = windRosePie.colorCircle
                ctx.stroke()
            }
        }

        onFocusChanged: {
            visible = focus
        }

        function popup(x, y) {
            if (x !== undefined)
                windRosePie.x =  x - windRosePie.width / 2 -40
            if (y !== undefined)
                windRosePie.y =  y - windRosePie.height / 2

            windRosePie.visible = true;
            windRosePie.focus = true
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: {     //G201710121285 ChenYang 点击已有点
                windRosePie.visible = false
                missionItemEditorListView.interactive = true
            }
            onPositionChanged: {            //G201710121285 ChenYang  点击拖动已有点
                var point = Qt.point(mouseX - parent.width / 2, mouseY - parent.height / 2)
                var angle = Math.round(Math.atan2(point.y, point.x) * 180 / Math.PI)
                windRoseCanvas.requestPaint()
                windRosePie.angle = angle
                gridAngleText.text = angle
                gridAngleText.editingFinished()


                //				agriangleText.text = angle
                //                agriangleText.editingFinished()

                if(angle > -135 && angle <= -45) {
                    gridAngleBox.activated(2) // or 3
                } else if(angle > -45 && angle <= 45) {
                    gridAngleBox.activated(2) // or 0
                } else if(angle > 45 && angle <= 135) {
                    gridAngleBox.activated(1) // or 0
                } else if(angle > 135 || angle <= -135) {
                    gridAngleBox.activated(1) // or 3
                }
            }
        }
    }
}
