/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "SyslinkComponent.h"
#include "AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

SyslinkComponent::SyslinkComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("数字链"))
{

}

QString SyslinkComponent::name(void) const
{
    return _name;
}

QString SyslinkComponent::description(void) const
{
    return tr("数字链用于Crazyflies设置数传.");
}

QString SyslinkComponent::iconResource(void) const
{
    return "/qmlimages/wifi.svg";
}

bool SyslinkComponent::requiresSetup(void) const
{
    return false;
}

bool SyslinkComponent::setupComplete(void) const
{
    return true;
}

QStringList SyslinkComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl SyslinkComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/SyslinkComponent.qml");
}

QUrl SyslinkComponent::summaryQmlSource(void) const
{
    return QUrl();
}

QString SyslinkComponent::prerequisiteSetup(void) const
{
    return QString();
}
