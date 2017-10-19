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

    property Fact _failsafeBattEnable:  controller.getParameterFact(-1, "FS_BATT_ENABLE")
    property Fact _failsafeThrEnable:   controller.getParameterFact(-1, "FS_THR_ENABLE")

    property Fact _fenceAction: controller.getParameterFact(-1, "FENCE_ACTION")
    property Fact _fenceEnable: controller.getParameterFact(-1, "FENCE_ENABLE")
    property Fact _fenceType:   controller.getParameterFact(-1, "FENCE_TYPE")

    property Fact _rtlAltFact:      controller.getParameterFact(-1, "RTL_ALT")
    property Fact _rtlLoitTimeFact: controller.getParameterFact(-1, "RTL_LOIT_TIME")
    property Fact _rtlAltFinalFact: controller.getParameterFact(-1, "RTL_ALT_FINAL")
    property Fact _landSpeedFact:   controller.getParameterFact(-1, "LAND_SPEED")

    property Fact _armingCheck: controller.getParameterFact(-1, "ARMING_CHECK")

    property string _failsafeBattEnableText
    property string _failsafeThrEnableText

    Component.onCompleted: {
        setFailsafeBattEnableText()
        setFailsafeThrEnableText()
    }

    Connections {
        target: _failsafeBattEnable

        onValueChanged: setFailsafeBattEnableText()
    }

    Connections {
        target: _failsafeThrEnable

        onValueChanged: setFailsafeThrEnableText()
    }

    function setFailsafeThrEnableText() {
        switch (_failsafeThrEnable.value) {
        case 0:
            _failsafeThrEnableText = qsTr("未使能")
            break
        case 1:
            _failsafeThrEnableText = qsTr("总是返航")
            break
        case 2:
            _failsafeThrEnableText = qsTr("在自动模式下继续执行任务")
            break
        case 3:
            _failsafeThrEnableText = qsTr("总是降落")
            break
        default:
            _failsafeThrEnableText = qsTr("未知")
        }
    }

    function setFailsafeBattEnableText() {
        switch (_failsafeBattEnable.value) {
        case 0:
            _failsafeBattEnableText = qsTr("未使能")
            break
        case 1:
            _failsafeBattEnableText = qsTr("降落")
            break
        case 2:
            _failsafeBattEnableText = qsTr("返航")
            break
        default:
            _failsafeThrEnableText = qsTr("未知")
        }
    }

    Column {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("解锁检查:")
            valueText:  _armingCheck.value & 1 ? qsTr("使能") : qsTr("部分禁用")
        }

        VehicleSummaryRow {
            labelText: qsTr("油门失效保护:")
            valueText:  _failsafeThrEnableText
        }

        VehicleSummaryRow {
            labelText: qsTr("电池故障保护:")
            valueText:  _failsafeBattEnableText
        }

        VehicleSummaryRow {
            labelText: qsTr("地理围栏:")
            valueText: _fenceEnable.value == 0 || _fenceType == 0 ?
                           qsTr("未使能") :
                           (_fenceType.value == 1 ?
                                qsTr("高度") :
                                (_fenceType.value == 2 ? qsTr("圆形") : qsTr("高度,圆形")))
        }

        VehicleSummaryRow {
            labelText: qsTr("地理围栏:")
            valueText: _fenceAction.value == 0 ?
                           qsTr("仅报告") :
                           (_fenceAction.value == 1 ? qsTr("返航或降落") : qsTr("未知"))
            visible:    _fenceEnable.value != 0
        }

        VehicleSummaryRow {
            labelText: qsTr("返航最低高度:")
            valueText: _rtlAltFact.value == 0 ? qsTr("当前") : _rtlAltFact.valueString + " " + _rtlAltFact.units
        }

        VehicleSummaryRow {
            labelText: qsTr("返航盘旋时间:")
            valueText: _rtlLoitTimeFact.valueString + " " + _rtlLoitTimeFact.units
        }

        VehicleSummaryRow {
            labelText: qsTr("返航最终高度:")
            valueText: _rtlAltFinalFact.value == 0 ? qsTr("降落") : _rtlAltFinalFact.valueString + " " + _rtlAltFinalFact.units
        }

        VehicleSummaryRow {
            labelText: qsTr("下降速度:")
            valueText: _landSpeedFact.valueString + " " + _landSpeedFact.units
        }
    }
}
