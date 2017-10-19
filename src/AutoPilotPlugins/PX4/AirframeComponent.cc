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

#include "AirframeComponent.h"
#include "QGCQmlWidgetHolder.h"
#include "ParameterManager.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

AirframeComponent::AirframeComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("机架类型"))
{

}

QString AirframeComponent::name(void) const
{
    return _name;
}

QString AirframeComponent::description(void) const
{
    return tr("几家类型设置用于选择与你的无人机匹配的类型. "
              "这将可以为飞行参数设置各种调优值.");
}

QString AirframeComponent::iconResource(void) const
{
    return "/qmlimages/AirframeComponentIcon.png";
}

bool AirframeComponent::requiresSetup(void) const
{
    return true;
}

bool AirframeComponent::setupComplete(void) const
{
    return _vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, "SYS_AUTOSTART")->rawValue().toInt() != 0;
}

QStringList AirframeComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList("SYS_AUTOSTART");
}

QUrl AirframeComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/AirframeComponent.qml");
}

QUrl AirframeComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/AirframeComponentSummary.qml");
}
