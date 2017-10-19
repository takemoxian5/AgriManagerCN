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

#include "APMCameraComponent.h"
#include "QGCQmlWidgetHolder.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMCameraComponent::APMCameraComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("相机"))
{
}

QString APMCameraComponent::name(void) const
{
    return _name;
}

QString APMCameraComponent::description(void) const
{
    return tr("相机设置用于调整相机和云台的设置.");
}

QString APMCameraComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/CameraComponentIcon.png");
}

bool APMCameraComponent::requiresSetup(void) const
{
    return false;
}

bool APMCameraComponent::setupComplete(void) const
{
    return true;
}

QStringList APMCameraComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMCameraComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMCameraComponent.qml"));
}

QUrl APMCameraComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMCameraComponentSummary.qml"));
}
