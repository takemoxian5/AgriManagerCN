/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "APMFlightModesComponent.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"
#include "APMRadioComponent.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMFlightModesComponent::APMFlightModesComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("飞行模式"))
{
}

QString APMFlightModesComponent::name(void) const
{
    return _name;
}

QString APMFlightModesComponent::description(void) const
{
    return tr("飞行模式设置用于配置与飞行模式相关的遥控器开关.");
}

QString APMFlightModesComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/FlightModesComponentIcon.png");
}

bool APMFlightModesComponent::requiresSetup(void) const
{
    return true;
}

bool APMFlightModesComponent::setupComplete(void) const
{
    return true;
}

QStringList APMFlightModesComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMFlightModesComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMFlightModesComponent.qml"));
}

QUrl APMFlightModesComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMFlightModesComponentSummary.qml"));
}
