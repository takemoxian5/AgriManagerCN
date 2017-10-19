import QtQuick          2.3
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

    property Fact _mountRCInTilt:   controller.getParameterFact(-1, "MNT_RC_IN_TILT")
    property Fact _mountRCInRoll:   controller.getParameterFact(-1, "MNT_RC_IN_ROLL")
    property Fact _mountRCInPan:    controller.getParameterFact(-1, "MNT_RC_IN_PAN")

    // MNT_TYPE parameter is not in older firmware versions
    property bool   _mountTypeExists: controller.parameterExists(-1, "MNT_TYPE")
    property string _mountTypeValue: _mountTypeExists ? controller.getParameterFact(-1, "MNT_TYPE").enumStringValue : ""

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            visible:    _mountTypeExists
            labelText:  qsTr("云台类型:")
            valueText:  _mountTypeValue
        }

        VehicleSummaryRow {
            labelText:  qsTr("倾斜的输入通道:")
            valueText:  _mountRCInTilt.enumStringValue
        }

        VehicleSummaryRow {
            labelText:  qsTr("摇头输入通道:")
            valueText:  _mountRCInPan.enumStringValue
        }

        VehicleSummaryRow {
            labelText:  qsTr("横滚输入通道:")
            valueText:  _mountRCInRoll.enumStringValue
        }
    }
}
