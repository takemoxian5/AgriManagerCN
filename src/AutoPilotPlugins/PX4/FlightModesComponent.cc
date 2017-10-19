/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Don Gagne <don@thegagnes.com>

#include "FlightModesComponent.h"
#include "PX4AutoPilotPlugin.h"
#include "QGCQmlWidgetHolder.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

struct SwitchListItem {
    const char* param;
    const char* name;
};

FlightModesComponent::FlightModesComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("飞行模式"))
{
}

QString FlightModesComponent::name(void) const
{
    return _name;
}

QString FlightModesComponent::description(void) const
{
    return tr("飞行模式设置用于配置与飞行模式相关的遥控器开关.");
}

QString FlightModesComponent::iconResource(void) const
{
    return "/qmlimages/FlightModesComponentIcon.png";
}

bool FlightModesComponent::requiresSetup(void) const
{
    return _vehicle->parameterManager()->getParameter(-1, "COM_RC_IN_MODE")->rawValue().toInt() == 1 ? false : true;
}

bool FlightModesComponent::setupComplete(void) const
{
    if (_vehicle->parameterManager()->getParameter(-1, "COM_RC_IN_MODE")->rawValue().toInt() == 1) {
        return true;
    }

    if (_vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "RC_MAP_MODE_SW")->rawValue().toInt() != 0 ||
            (_vehicle->parameterManager()->parameterExists(FactSystem::defaultComponentId, "RC_MAP_FLTMODE") && _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "RC_MAP_FLTMODE")->rawValue().toInt() != 0)) {
        return true;
    }

    return false;
}

QStringList FlightModesComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList list;

    list << QStringLiteral("RC_MAP_MODE_SW") << QStringLiteral("RC_MAP_FLTMODE");

    return list;
}

QUrl FlightModesComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/PX4FlightModes.qml");
}

QUrl FlightModesComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/FlightModesComponentSummary.qml");
}
