import QtQuick 2.3
import QtQuick.Controls 1.2

import QGroundControl.FactSystem    1.0
import QGroundControl.FactControls  1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controllers   1.0

FactPanel {
    id:             panel
    anchors.fill:   parent
    color:          qgcPal.windowShadeDark

    QGCPalette          { id: qgcPal; colorGroupEnabled: enabled }
    FactPanelController { id: controller; factPanel: panel }

    ESP8266ComponentController {
        id:         esp8266
        factPanel:  panel
    }

    property Fact debugEnabled:     controller.getParameterFact(esp8266.componentID, "DEBUG_ENABLED")
    property Fact wifiChannel:      controller.getParameterFact(esp8266.componentID, "WIFI_CHANNEL")
    property Fact wifiHostPort:     controller.getParameterFact(esp8266.componentID, "WIFI_UDP_HPORT")
    property Fact wifiClientPort:   controller.getParameterFact(esp8266.componentID, "WIFI_UDP_CPORT")
    property Fact uartBaud:         controller.getParameterFact(esp8266.componentID, "UART_BAUDRATE")
    property Fact wifiMode:         controller.getParameterFact(esp8266.componentID, "WIFI_MODE", false) //-- Don't bitch if missing

    Column {
        anchors.fill:       parent
        VehicleSummaryRow {
            labelText: qsTr("固件版本:")
            valueText: esp8266.version
        }
        VehicleSummaryRow {
            labelText: qsTr("WiFi模式:")
            valueText: wifiMode ? (wifiMode.value === 0 ? "AP Mode" : "Station Mode") : "AP Mode"
        }
        VehicleSummaryRow {
            labelText:  qsTr("WiFi通道:")
            valueText:  wifiChannel ? wifiChannel.valueString : ""
            visible:    wifiMode ? wifiMode.value === 0 : true
        }
        VehicleSummaryRow {
            labelText: qsTr("WiFi热点AP名称:")
            valueText: esp8266.wifiSSID
        }
        VehicleSummaryRow {
            labelText: qsTr("WiFi热点AP密码:")
            valueText: esp8266.wifiPassword
        }
        /* Too much info makes it all crammed
        VehicleSummaryRow {
            labelText: qsTr("WiFi STA SSID:")
            valueText: esp8266.wifiSSIDSta
        }
        VehicleSummaryRow {
            labelText: qsTr("WiFi STA Password:")
            valueText: esp8266.wifiPasswordSta
        }
        */
        VehicleSummaryRow {
            labelText: qsTr("串口波特率:")
            valueText: uartBaud ? uartBaud.valueString : ""
        }
    }
}
