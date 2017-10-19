import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0
import QGroundControl.ArduPilot     1.0

/*
    IMPORTANT NOTE: Any changes made here must also be made to SensorsComponentSummary.qml
*/

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }

    APMSensorsComponentController { id: controller; factPanel: panel }

    APMSensorParams {
        id:                     sensorParams
        factPanelController:    controller
    }

    Column {
        anchors.fill:       parent

        Repeater {
            model: 3

            VehicleSummaryRow {
                labelText:  qsTr("指南针 ") + (index + 1) + ":"
                valueText:  sensorParams.rgCompassAvailable[index] ?
                                (sensorParams.rgCompassCalibrated[index] ?
                                     (sensorParams.rgCompassPrimary[index] ? "主要" : "次要") +
                                     (sensorParams.rgCompassExternalParamAvailable[index] ?
                                          (sensorParams.rgCompassExternal[index] ? ", 外部" : ", 内部" ) :
                                          "") :
                                     qsTr("需要设定")) :
                                qsTr("未安装")
            }
        }

        VehicleSummaryRow {
            labelText: qsTr("加速度计(s):")
            valueText: controller.accelSetupNeeded ? qsTr("需要设定") : qsTr("完成")
        }
    }
}
