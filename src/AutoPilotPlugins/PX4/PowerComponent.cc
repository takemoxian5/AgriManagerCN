/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @author Gus Grubba <mavlink@grubba.com>

#include "PowerComponent.h"
#include "QGCQmlWidgetHolder.h"
#include "PX4AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

PowerComponent::PowerComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("电源"))
{
}

QString PowerComponent::name(void) const
{
    return _name;
}

QString PowerComponent::description(void) const
{
    return tr("电源设置用于设置电池参数以及螺旋桨的高级设置.");
}

QString PowerComponent::iconResource(void) const
{
    return "/qmlimages/PowerComponentIcon.png";
}

bool PowerComponent::requiresSetup(void) const
{
    return true;
}

bool PowerComponent::setupComplete(void) const
{
    QVariant cvalue, evalue, nvalue;
    return _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "BAT_V_CHARGED")->rawValue().toFloat() != 0.0f &&
        _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "BAT_V_EMPTY")->rawValue().toFloat() != 0.0f &&
        _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "BAT_N_CELLS")->rawValue().toInt() != 0;
}

QStringList PowerComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList triggerList;

    triggerList << "BAT_V_CHARGED" << "BAT_V_EMPTY" << "BAT_N_CELLS";
    return triggerList;
}

QUrl PowerComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/PowerComponent.qml");
}

QUrl PowerComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/PowerComponentSummary.qml");
}
