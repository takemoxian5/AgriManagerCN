import QtQuick          2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    property Fact _nullFact
    property Fact _rcMapFltmode:    controller.parameterExists(-1, "RC_MAP_FLTMODE") ? controller.getParameterFact(-1, "RC_MAP_FLTMODE") : _nullFact
    property Fact _rcMapModeSw:     controller.getParameterFact(-1, "RC_MAP_MODE_SW")
    property bool _simpleMode:      _rcMapFltmode.value > 0 || _rcMapModeSw.value == 0

    Loader {
        anchors.fill:       parent
        sourceComponent:    _simpleMode ? simple : advanced
    }

    Component {
        id: simple
        Column {
            VehicleSummaryRow {
                labelText: qsTr("模式切换:")
                valueText: _rcMapFltmode.value === 0 ? qsTr("未设置") : _rcMapFltmode.enumStringValue
            }
            Repeater {
                model: 6
                VehicleSummaryRow {
                    labelText: qsTr("飞行模式 %1 :").arg(index + 1)
                    valueText: controller.getParameterFact(-1, "COM_FLTMODE" + (index + 1)).enumStringValue
                }
            }
        }
    }

    Component {
        id: advanced
        Column {
            property Fact posCtlSwFact: controller.getParameterFact(-1, "RC_MAP_POSCTL_SW")
            property Fact loiterSwFact: controller.getParameterFact(-1, "RC_MAP_LOITER_SW")
            property Fact returnSwFact: controller.getParameterFact(-1, "RC_MAP_RETURN_SW")
            VehicleSummaryRow {
                labelText: qsTr("模式切换:")
                valueText: _rcMapModeSw.value === 0 ? qsTr("未设置") : _rcMapModeSw.valueString
            }
            VehicleSummaryRow {
                labelText: qsTr("位置控制开关:")
                valueText: posCtlSwFact.value === 0 ? qsTr("未用") : posCtlSwFact.valueString
            }
            VehicleSummaryRow {
                labelText: qsTr("盘旋开关:")
                valueText: loiterSwFact.value === 0 ? qsTr("未用") : loiterSwFact.valueString
            }
            VehicleSummaryRow {
                labelText: qsTr("返航开关:")
                valueText: returnSwFact.value === 0 ? qsTr("未用") : returnSwFact.valueString
            }
        }
    }
}
