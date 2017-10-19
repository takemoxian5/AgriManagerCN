/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


/// @file
///     @brief  The Camera VehicleComponent is used to setup the camera modes and hardware
///             configuration to use it.
///     @author Gus Grubba <mavlink@grubba.com>

#include "CameraComponent.h"
#include "PX4AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

CameraComponent::CameraComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("相机"))
{
}

QString CameraComponent::name(void) const
{
    return _name;
}

QString CameraComponent::description(void) const
{
    return tr("相机设置用于调整相机和云台的设置.");
}

QString CameraComponent::iconResource(void) const
{
    return "/qmlimages/CameraComponentIcon.png";
}

bool CameraComponent::requiresSetup(void) const
{
    return false;
}

bool CameraComponent::setupComplete(void) const
{
    return true;
}

QStringList CameraComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl CameraComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/CameraComponent.qml");
}

QUrl CameraComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/CameraComponentSummary.qml");
}
