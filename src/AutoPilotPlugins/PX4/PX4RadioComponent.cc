/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "PX4RadioComponent.h"
#include "PX4AutoPilotPlugin.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

PX4RadioComponent::PX4RadioComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent) :
    VehicleComponent(vehicle, autopilot, parent),
    _name(tr("遥控器"))
{
}

QString PX4RadioComponent::name(void) const
{
    return _name;
}

QString PX4RadioComponent::description(void) const
{
    return tr("遥控器的设置是用来校准你的发射机的. "
              "它还分配了滚转、俯仰、偏航和油门控制的通道，以及确定它们是否被反转.");
}

QString PX4RadioComponent::iconResource(void) const
{
    return "/qmlimages/RadioComponentIcon.png";
}

bool PX4RadioComponent::requiresSetup(void) const
{
    return _vehicle->parameterManager()->getParameter(-1, "COM_RC_IN_MODE")->rawValue().toInt() == 1 ? false : true;
}

bool PX4RadioComponent::setupComplete(void) const
{
    if (_vehicle->parameterManager()->getParameter(-1, "COM_RC_IN_MODE")->rawValue().toInt() != 1) {
        // The best we can do to detect the need for a radio calibration is look for attitude
        // controls to be mapped.
        QStringList attitudeMappings;
        attitudeMappings << "RC_MAP_ROLL" << "RC_MAP_PITCH" << "RC_MAP_YAW" << "RC_MAP_THROTTLE";
        foreach(const QString &mapParam, attitudeMappings) {
            if (_vehicle->parameterManager()->getParameter(FactSystem::defaultComponentId, mapParam)->rawValue().toInt() == 0) {
                return false;
            }
        }
    }
    
    return true;
}

QStringList PX4RadioComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList triggers;
    
    triggers << "COM_RC_IN_MODE" << "RC_MAP_ROLL" << "RC_MAP_PITCH" << "RC_MAP_YAW" << "RC_MAP_THROTTLE";
    
    return triggers;
}

QUrl PX4RadioComponent::setupSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/RadioComponent.qml");
}

QUrl PX4RadioComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput("qrc:/qml/PX4RadioComponentSummary.qml");
}
