/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "APMAirframeComponent.h"
#include "ArduCopterFirmwarePlugin.h"
#include "ParameterManager.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

const char* APMAirframeComponent::_oldFrameParam = "FRAME";
const char* APMAirframeComponent::_newFrameParam = "FRAME_CLASS";

APMAirframeComponent::APMAirframeComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _requiresFrameSetup(false)
    , _name("机架类型")
{
    if (qobject_cast<ArduCopterFirmwarePlugin*>(_vehicle->firmwarePlugin()) != NULL) {
        ParameterManager* paramMgr = _vehicle->parameterManager();
        _requiresFrameSetup = true;
        if (paramMgr->parameterExists(FactSystem::defaultComponentId, _oldFrameParam)) {
            _useNewFrameParam = false;
            _frameParamFact = paramMgr->getParameter(FactSystem::defaultComponentId, _oldFrameParam);
            MAV_TYPE vehicleType = vehicle->vehicleType();
            if (vehicleType == MAV_TYPE_TRICOPTER || vehicleType == MAV_TYPE_HELICOPTER) {
                _requiresFrameSetup = false;
            }
        } else {
            _useNewFrameParam = true;
            _frameParamFact = paramMgr->getParameter(FactSystem::defaultComponentId, _newFrameParam);
        }
    }
}

QString APMAirframeComponent::name(void) const
{
    return _name;
}

QString APMAirframeComponent::description(void) const
{
    return tr("几家类型设置用于选择与你的无人机匹配的类型. "
              "这将可以为飞行参数设置各种调优值.");
}

QString APMAirframeComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/AirframeComponentIcon.png");
}

bool APMAirframeComponent::requiresSetup(void) const
{
    return _requiresFrameSetup;
}

bool APMAirframeComponent::setupComplete(void) const
{
    if (_requiresFrameSetup) {
        if (_useNewFrameParam) {
            return _frameParamFact->rawValue().toInt() > 0;
        } else {
            return _frameParamFact->rawValue().toInt() >= 0;
        }
    } else {
        return true;
    }
}

QStringList APMAirframeComponent::setupCompleteChangedTriggerList(void) const
{
    QStringList list;

    if (_requiresFrameSetup) {
        list << (_useNewFrameParam ? _newFrameParam : _oldFrameParam);
    }

    return list;
}

QUrl APMAirframeComponent::setupSource(void) const
{
    if (_requiresFrameSetup) {
        return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMAirframeComponent.qml"));
    } else {
        return QUrl();
    }
}

QUrl APMAirframeComponent::summaryQmlSource(void) const
{
    if (_requiresFrameSetup) {
        return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMAirframeComponentSummary.qml"));
    } else {
        return QUrl();
    }
}
