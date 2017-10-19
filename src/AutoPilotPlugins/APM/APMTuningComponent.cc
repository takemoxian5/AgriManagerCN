/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


#include "APMTuningComponent.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"
#include "ParameterManager.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMTuningComponent::APMTuningComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name("调参")
{
}

QString APMTuningComponent::name(void) const
{
    return _name;
}

QString APMTuningComponent::description(void) const
{
    return tr("调参设置用于调整无人机的飞行特性.");
}

QString APMTuningComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/TuningComponentIcon.png");
}

bool APMTuningComponent::requiresSetup(void) const
{
    return false;
}

bool APMTuningComponent::setupComplete(void) const
{
    return true;
}

QStringList APMTuningComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMTuningComponent::setupSource(void) const
{
    QString qmlFile;

    switch (_vehicle->vehicleType()) {
        case MAV_TYPE_QUADROTOR:
        case MAV_TYPE_COAXIAL:
        case MAV_TYPE_HELICOPTER:
        case MAV_TYPE_HEXAROTOR:
        case MAV_TYPE_OCTOROTOR:
        case MAV_TYPE_TRICOPTER:
            // Older firmwares do not have CH9_OPT, we don't support Tuning on older firmwares
            if (_vehicle->parameterManager()->parameterExists(-1, QStringLiteral("CH9_OPT"))) {
                qmlFile = QStringLiteral("qrc:/qml/APMTuningComponentCopter.qml");
            }
            break;
        default:
            // No tuning panel
            break;
    }

    return QUrl::fromUserInput(qmlFile);
}

QUrl APMTuningComponent::summaryQmlSource(void) const
{
    return QUrl();
}
