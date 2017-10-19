/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "MotorComponent.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

MotorComponent::MotorComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("电机"))
{

}

QString MotorComponent::name(void) const
{
    return _name;
}

QString MotorComponent::description(void) const
{
    return tr("电机设置用于手动测试电机控制和方向.");
}

QString MotorComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/MotorComponentIcon.svg");
}

bool MotorComponent::requiresSetup(void) const
{
    return false;
}

bool MotorComponent::setupComplete(void) const
{
    return true;
}

QStringList MotorComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl MotorComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/MotorComponent.qml"));
}

QUrl MotorComponent::summaryQmlSource(void) const
{
    return QUrl();
}
