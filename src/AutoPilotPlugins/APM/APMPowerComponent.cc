/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "APMPowerComponent.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"
#include "ParameterManager.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMPowerComponent::APMPowerComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent),
    _name("电源")
{
}

QString APMPowerComponent::name(void) const
{
    return _name;
}

QString APMPowerComponent::description(void) const
{
    return tr("电源用于设置电池参数.");
}

QString APMPowerComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/PowerComponentIcon.png");
}

bool APMPowerComponent::requiresSetup(void) const
{
    return true;
}

bool APMPowerComponent::setupComplete(void) const
{
    return _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, QStringLiteral("BATT_CAPACITY"))->rawValue().toInt() != 0;
}

QStringList APMPowerComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList list;

    list << QStringLiteral("BATT_CAPACITY");

    return list;
}

QUrl APMPowerComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMPowerComponent.qml"));
}

QUrl APMPowerComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMPowerComponentSummary.qml"));
}
