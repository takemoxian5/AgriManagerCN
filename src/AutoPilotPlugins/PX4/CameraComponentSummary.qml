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

    property Fact _camTriggerMode:  controller.getParameterFact(-1, "TRIG_MODE", false)
    property Fact _camTriggerInterface:  controller.getParameterFact(-1, "TRIG_INTERFACE", false)
    property Fact _camTriggerPol:   controller.getParameterFact(-1, "TRIG_POLARITY", false) // Don't bitch about missing as these only exist if trigger mode is enabled
    property Fact _auxPins:         controller.getParameterFact(-1, "TRIG_PINS",     false) // Ditto
    property Fact _timeInterval:    controller.getParameterFact(-1, "TRIG_INTERVAL", false) // Ditto
    property Fact _distanceInterval:controller.getParameterFact(-1, "TRIG_DISTANCE", false) // Ditto

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("触发接口:")
            valueText: _camTriggerInterface ? _camTriggerInterface.enumStringValue : ""
        }

        VehicleSummaryRow {
            labelText: qsTr("触发模式:")
            valueText: _camTriggerMode ? _camTriggerMode.enumStringValue : ""
        }

        VehicleSummaryRow {
            visible:    _timeInterval && _camTriggerMode.value === 2
            labelText:  qsTr("时间间隔:")
            valueText:  _timeInterval ? _timeInterval.value : ""
        }

        VehicleSummaryRow {
            visible:    _distanceInterval && _camTriggerMode.value === 3
            labelText:  qsTr("距离间隔:")
            valueText:  _distanceInterval ? _distanceInterval.value : ""
        }

        VehicleSummaryRow {
            visible:    _auxPins
            labelText:  qsTr("AUX引脚:")
            valueText:  _auxPins ? _auxPins.value : ""
        }

        VehicleSummaryRow {
            visible:    _camTriggerPol
            labelText:  qsTr("AUX引脚极性:")
            valueText:  _camTriggerPol ? (_camTriggerPol.value ? "高电平 (3.3V)" : "低电平 (0V)") : ""
        }

    }
}
