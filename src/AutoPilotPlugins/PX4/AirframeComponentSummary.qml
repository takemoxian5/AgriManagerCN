import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Palette 1.0

FactPanel {
    id:                 panel
    anchors.fill:       parent
    color:              qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    AirframeComponentController { id: controller; factPanel: panel }

    property Fact sysIdFact:        controller.getParameterFact(-1, "MAV_SYS_ID")
    property Fact sysAutoStartFact: controller.getParameterFact(-1, "SYS_AUTOSTART")

    property bool autoStartSet: sysAutoStartFact ? (sysAutoStartFact.value !== 0) : false

    Column {
        anchors.fill:       parent
        VehicleSummaryRow {
            labelText: qsTr("系统ID:")
            valueText: sysIdFact ? sysIdFact.valueString : ""
        }
        VehicleSummaryRow {
            labelText: qsTr("机架类型:")
            valueText: autoStartSet ? controller.currentAirframeType : qsTr("未设置")
        }
        VehicleSummaryRow {
            labelText: qsTr("无人机:")
            valueText: autoStartSet ? controller.currentVehicleName : qsTr("未设置")
        }

        VehicleSummaryRow {
            labelText: qsTr("固件版本:")
            valueText: activeVehicle.firmwareMajorVersion == -1 ? qsTr("位置") : activeVehicle.firmwareMajorVersion + "." + activeVehicle.firmwareMinorVersion + "." + activeVehicle.firmwarePatchVersion + activeVehicle.firmwareVersionTypeString
        }
    }
}
