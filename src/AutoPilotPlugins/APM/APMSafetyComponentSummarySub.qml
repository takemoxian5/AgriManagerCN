import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl              1.0
import QGroundControl.FactSystem   1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls     1.0
import QGroundControl.Palette      1.0

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    property var _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool _firmware34: _activeVehicle.firmwareMajorVersion == 3 && _activeVehicle.firmwareMinorVersion == 4

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    // Enable/Action parameters
    property Fact _failsafeBatteryEnable:     controller.getParameterFact(-1, "FS_BATT_ENABLE")
    property Fact _failsafeEKFEnable:         controller.getParameterFact(-1, "FS_EKF_ACTION")
    property Fact _failsafeGCSEnable:         controller.getParameterFact(-1, "FS_GCS_ENABLE")
    property Fact _failsafeLeakEnable:        controller.getParameterFact(-1, "FS_LEAK_ENABLE")
    property Fact _failsafePilotEnable:       _firmware34 ? null : controller.getParameterFact(-1, "FS_PILOT_INPUT")
    property Fact _failsafePressureEnable:    controller.getParameterFact(-1, "FS_PRESS_ENABLE")
    property Fact _failsafeTemperatureEnable: controller.getParameterFact(-1, "FS_TEMP_ENABLE")

    // Threshold parameters
    property Fact _failsafePressureThreshold:    controller.getParameterFact(-1, "FS_PRESS_MAX")
    property Fact _failsafeTemperatureThreshold: controller.getParameterFact(-1, "FS_TEMP_MAX")
    property Fact _failsafePilotTimeout:         _firmware34 ? null : controller.getParameterFact(-1, "FS_PILOT_TIMEOUT")
    property Fact _failsafeLeakPin:              controller.getParameterFact(-1, "LEAK1_PIN")
    property Fact _failsafeLeakLogic:            controller.getParameterFact(-1, "LEAK1_LOGIC")
    property Fact _failsafeEKFThreshold:         controller.getParameterFact(-1, "FS_EKF_THRESH")
    property Fact _failsafeBatteryVoltage:       controller.getParameterFact(-1, "FS_BATT_VOLTAGE")
    property Fact _failsafeBatteryCapacity:      controller.getParameterFact(-1, "FS_BATT_MAH")

    property Fact _armingCheck: controller.getParameterFact(-1, "ARMING_CHECK")

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("解锁检查:")
            valueText:  _armingCheck.value & 1 ? qsTr("使能") : qsTr("部分禁用")
        }
        VehicleSummaryRow {
            labelText: qsTr("地面站失效保护:")
            valueText: _failsafeGCSEnable.enumOrValueString
        }
        VehicleSummaryRow {
            labelText: qsTr("漏水故障保护:")
            valueText:  _failsafeLeakEnable.enumOrValueString
        }
        VehicleSummaryRow {
            visible: !_firmware34
            labelText: qsTr("电池故障保护:")
            valueText: _firmware34 ? "" : _failsafeBatteryEnable.enumOrValueString
        }
        VehicleSummaryRow {
            visible: !_firmware34
            labelText: qsTr("EKF失效保护:")
            valueText: _firmware34 ? "" : _failsafeEKFEnable.enumOrValueString
        }
        VehicleSummaryRow {
            visible: !_firmware34
            labelText: qsTr("操作员输入故障保护:")
            valueText: _firmware34 ? "" : _failsafePilotEnable.enumOrValueString
        }
        VehicleSummaryRow {
            labelText: qsTr("温度故障保护:")
            valueText:  _failsafeTemperatureEnable.enumOrValueString
        }
        VehicleSummaryRow {
            labelText: qsTr("压力故障保护:")
            valueText:  _failsafePressureEnable.enumOrValueString
        }
    }
}
