import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact mapRollFact:      controller.getParameterFact(-1, "RC_MAP_ROLL")
    property Fact mapPitchFact:     controller.getParameterFact(-1, "RC_MAP_PITCH")
    property Fact mapYawFact:       controller.getParameterFact(-1, "RC_MAP_YAW")
    property Fact mapThrottleFact:  controller.getParameterFact(-1, "RC_MAP_THROTTLE")
    property Fact mapFlapsFact:     controller.getParameterFact(-1, "RC_MAP_FLAPS")
    property Fact mapAux1Fact:      controller.getParameterFact(-1, "RC_MAP_AUX1")
    property Fact mapAux2Fact:      controller.getParameterFact(-1, "RC_MAP_AUX2")

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("横滚:")
            valueText: mapRollFact ? (mapRollFact.value === 0 ? qsTr("需要设定") : mapRollFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("俯仰:")
            valueText: mapPitchFact ? (mapPitchFact.value === 0 ? qsTr("需要设定") : mapPitchFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("偏航:")
            valueText: mapYawFact ? (mapYawFact.value === 0 ? qsTr("需要设定") : mapYawFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("油门:")
            valueText: mapThrottleFact ? (mapThrottleFact.value === 0 ? qsTr("需要设定") : mapThrottleFact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText:  qsTr("分版原图:")
            valueText:  mapFlapsFact ? (mapFlapsFact.value === 0 ? qsTr("不使能") : mapFlapsFact.valueString) : ""
            visible:    !controller.vehicle.multiRotor
        }

        VehicleSummaryRow {
            labelText: qsTr("辅助通道1:")
            valueText: mapAux1Fact ? (mapAux1Fact.value === 0 ? qsTr("不使能") : mapAux1Fact.valueString) : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("辅助通道2:")
            valueText: mapAux2Fact ? (mapAux2Fact.value === 0 ? qsTr("不使能") : mapAux2Fact.valueString) : ""
        }
    }
}
