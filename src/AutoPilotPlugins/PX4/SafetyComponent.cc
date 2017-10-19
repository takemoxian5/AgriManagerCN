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

#include "SafetyComponent.h"
#include "PX4AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

SafetyComponent::SafetyComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("安全设置"))
{
}

QString SafetyComponent::name(void) const
{
    return _name;
}

QString SafetyComponent::description(void) const
{
    return tr("安全设置用于设置返回陆地的触发点以及返回陆地的设置.");
}

QString SafetyComponent::iconResource(void) const
{
    return "/qmlimages/SafetyComponentIcon.png";
}

bool SafetyComponent::requiresSetup(void) const
{
    return false;
}

bool SafetyComponent::setupComplete(void) const
{
    // FIXME: What aboout invalid settings?
    return true;
}

QStringList SafetyComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl SafetyComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/SafetyComponent.qml");
}

QUrl SafetyComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/SafetyComponentSummary.qml");
}
