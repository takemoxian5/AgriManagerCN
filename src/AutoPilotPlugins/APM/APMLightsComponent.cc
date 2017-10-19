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
///     @author Rustom Jehangir <rusty@bluerobotics.com>

#include "APMLightsComponent.h"
#include "QGCQmlWidgetHolder.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMLightsComponent::APMLightsComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("灯光"))
{
}

QString APMLightsComponent::name(void) const
{
    return _name;
}

QString APMLightsComponent::description(void) const
{
    return tr("灯光设置是用来设置灯的控制通道.");
}

QString APMLightsComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/LightsComponentIcon.png");
}

bool APMLightsComponent::requiresSetup(void) const
{
    return false;
}

bool APMLightsComponent::setupComplete(void) const
{
    return true;
}

QStringList APMLightsComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMLightsComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMLightsComponent.qml"));
}

QUrl APMLightsComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMLightsComponentSummary.qml"));
}
