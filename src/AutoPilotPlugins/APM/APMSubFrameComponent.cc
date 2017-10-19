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
///     @author Jacob Walser <jwalser90@gmail.com>

#include "APMSubFrameComponent.h"
#include "QGCQmlWidgetHolder.h"
#include "APMAutoPilotPlugin.h"
#include "APMAirframeComponent.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

APMSubFrameComponent::APMSubFrameComponent(Vehicle* vehicle, AutoPilotPlugin* autopilot, QObject* parent)
    : VehicleComponent(vehicle, autopilot, parent)
    , _name(tr("结构"))
{
}

QString APMSubFrameComponent::name(void) const
{
    return _name;
}

QString APMSubFrameComponent::description(void) const
{
    return tr("结构设置允许你选择你的无人机的马达配置，顺时针方向安装" \
              "\n绿色推进器上的螺旋桨和蓝色推进器上的逆时针螺旋桨" \
              "\n(反之亦然). 需要重启飞行控制器来应用更改.");
}

QString APMSubFrameComponent::iconResource(void) const
{
    return QStringLiteral("/qmlimages/SubFrameComponentIcon.png");
}

bool APMSubFrameComponent::requiresSetup(void) const
{
    return false;
}

bool APMSubFrameComponent::setupComplete(void) const
{
    return true;
}

QStringList APMSubFrameComponent::setupCompleteChangedTriggerList(void) const
{
    return QStringList();
}

QUrl APMSubFrameComponent::setupSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSubFrameComponent.qml"));
}

QUrl APMSubFrameComponent::summaryQmlSource(void) const
{
    return QUrl::fromUserInput(QStringLiteral("qrc:/qml/APMSubFrameComponentSummary.qml"));
}
