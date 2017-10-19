/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "ESP8266Component.h"
#include "AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

ESP8266Component::ESP8266Component(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("WIFI设置"))
{

}

QString ESP8266Component::name(void) const
{
    return _name;
}

QString ESP8266Component::description(void) const
{
    return tr("使用了ESP8266 WiFi桥组件来设置WiFi连接.");
}

QString ESP8266Component::iconResource(void) const
{
    return "/qmlimages/wifi.svg";
}

bool ESP8266Component::requiresSetup(void) const
{
    return false;
}

bool ESP8266Component::setupComplete(void) const
{
    return true;
}

QStringList ESP8266Component::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl ESP8266Component::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/ESP8266Component.qml");
}

QUrl ESP8266Component::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/ESP8266ComponentSummary.qml");
}
