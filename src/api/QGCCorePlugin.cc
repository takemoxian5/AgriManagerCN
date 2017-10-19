/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "QGCApplication.h"
#include "QGCCorePlugin.h"
#include "QGCOptions.h"
#include "QGCSettings.h"
#include "FactMetaData.h"
#include "SettingsManager.h"
#include "AppMessages.h"

#include <QtQml>
#include <QQmlEngine>

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

/// @file
///     @brief Core Plugin Interface for QGroundControl - Default Implementation
///     @author Gus Grubba <mavlink@grubba.com>

class QGCCorePlugin_p
{
public:
    QGCCorePlugin_p()
        : pGeneral(NULL)
        , pCommLinks(NULL)
        , pOfflineMaps(NULL)
        , pMAVLink(NULL)
        , pConsole(NULL)
    #if defined(QT_DEBUG)
        , pMockLink(NULL)
        , pDebug(NULL)
    #endif
        , defaultOptions(NULL)
    {
    }

    ~QGCCorePlugin_p()
    {
        if(pGeneral)
            delete pGeneral;
        if(pCommLinks)
            delete pCommLinks;
        if(pOfflineMaps)
            delete pOfflineMaps;
        if(pMAVLink)
            delete pMAVLink;
        if(pConsole)
            delete pConsole;
#if defined(QT_DEBUG)
        if(pMockLink)
            delete pMockLink;
        if(pDebug)
            delete pDebug;
#endif
        if(defaultOptions)
            delete defaultOptions;
    }

    QGCSettings* pGeneral;
    QGCSettings* pCommLinks;
    QGCSettings* pOfflineMaps;
    QGCSettings* pMAVLink;
    QGCSettings* pConsole;
#if defined(QT_DEBUG)
    QGCSettings* pMockLink;
    QGCSettings* pDebug;
#endif
    QVariantList settingsList;
    QGCOptions*  defaultOptions;
};

QGCCorePlugin::~QGCCorePlugin()
{
    if(_p) {
        delete _p;
    }
}

QGCCorePlugin::QGCCorePlugin(QGCApplication *app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
    , _showTouchAreas(false)
    , _showAdvancedUI(true)
{
    _p = new QGCCorePlugin_p;
}

void QGCCorePlugin::setToolbox(QGCToolbox *toolbox)
{
    QGCTool::setToolbox(toolbox);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    qmlRegisterUncreatableType<QGCCorePlugin>("QGroundControl.QGCCorePlugin", 1, 0, "QGCCorePlugin", "Reference only");
    qmlRegisterUncreatableType<QGCOptions>("QGroundControl.QGCOptions",       1, 0, "QGCOptions",    "Reference only");
}

QVariantList &QGCCorePlugin::settingsPages()
{
    //-- If this hasn't been overridden, create default set of settings
    if(!_p->pGeneral) {
        //-- Default Settings
        _p->pGeneral = new QGCSettings(tr("常用"),
                                       QUrl::fromUserInput("qrc:/qml/GeneralSettings.qml"),
                                       QUrl::fromUserInput("qrc:/res/gear-white.svg"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pGeneral));
        _p->pCommLinks = new QGCSettings(tr("通信连接"),
                                         QUrl::fromUserInput("qrc:/qml/LinkSettings.qml"),
                                         QUrl::fromUserInput("qrc:/res/waves.svg"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pCommLinks));
        _p->pOfflineMaps = new QGCSettings(tr("离线地图"),
                                           QUrl::fromUserInput("qrc:/qml/OfflineMap.qml"),
                                           QUrl::fromUserInput("qrc:/res/waves.svg"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pOfflineMaps));
        _p->pMAVLink = new QGCSettings(tr("MAVLink设置"),
                                       QUrl::fromUserInput("qrc:/qml/MavlinkSettings.qml"),
                                       QUrl::fromUserInput("qrc:/res/waves.svg"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pMAVLink));
        _p->pConsole = new QGCSettings(tr("终端"),
                                       QUrl::fromUserInput("qrc:/qml/QGroundControl/Controls/AppMessages.qml"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pConsole));
#if defined(QT_DEBUG)
        //-- These are always present on Debug builds
        _p->pMockLink = new QGCSettings(tr("Mock Link"),
                                        QUrl::fromUserInput("qrc:/qml/MockLink.qml"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pMockLink));
        _p->pDebug = new QGCSettings(tr("Debug"),
                                     QUrl::fromUserInput("qrc:/qml/DebugWindow.qml"));
        _p->settingsList.append(QVariant::fromValue((QGCSettings*)_p->pDebug));
#endif
    }
    return _p->settingsList;
}

int QGCCorePlugin::defaultSettings()
{
    return 0;
}

QGCOptions* QGCCorePlugin::options()
{
    if(!_p->defaultOptions) {
        _p->defaultOptions = new QGCOptions();
    }
    return _p->defaultOptions;
}

bool QGCCorePlugin::overrideSettingsGroupVisibility(QString name)
{
    Q_UNUSED(name);

    // Always show all
    return true;
}

bool QGCCorePlugin::adjustSettingMetaData(FactMetaData& metaData)
{
    //-- Default Palette
    if (metaData.name() == AppSettings::indoorPaletteName) {
        QVariant outdoorPalette;
#if defined (__mobile__)
        outdoorPalette = 0;
#else
        outdoorPalette = 1;
#endif
        metaData.setRawDefaultValue(outdoorPalette);
        return true;
    //-- Auto Save Telemetry Logs
    } else if (metaData.name() == AppSettings::telemetrySaveName) {
#if defined (__mobile__)
        metaData.setRawDefaultValue(false);
        return true;
#else
        metaData.setRawDefaultValue(true);
        return true;
#endif
#if defined(__ios__)
    } else if (metaData.name() == AppSettings::savePathName) {
        QString appName = qgcApp()->applicationName();
        QDir rootDir = QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
        metaData.setRawDefaultValue(rootDir.filePath(appName));
        return false;
#endif
    }
    return true; // Show setting in ui
}

void QGCCorePlugin::setShowTouchAreas(bool show)
{
    if (show != _showTouchAreas) {
        _showTouchAreas = show;
        emit showTouchAreasChanged(show);
    }
}

void QGCCorePlugin::setShowAdvancedUI(bool show)
{
    if (show != _showAdvancedUI) {
        _showAdvancedUI = show;
        emit showAdvancedUIChanged(show);
    }
}

void QGCCorePlugin::paletteOverride(QString colorName, QGCPalette::PaletteColorInfo_t& colorInfo)
{
    Q_UNUSED(colorName);
    Q_UNUSED(colorInfo);
}

QString QGCCorePlugin::showAdvancedUIMessage(void) const
{
    return tr("警告: 进入高级模式. "
              "如果使用不当，可能导致无人机出现故障，从而导致保修无效. "
              "只有在客户的支持下才会这样做. "
              "请确认?");
}

void QGCCorePlugin::valuesWidgetDefaultSettings(QStringList& largeValues, QStringList& smallValues)
{
    Q_UNUSED(smallValues);
    largeValues << "Vehicle.altitudeRelative" << "Vehicle.groundSpeed" << "Vehicle.flightTime";
}

QQmlApplicationEngine* QGCCorePlugin::createRootWindow(QObject *parent)
{
    QQmlApplicationEngine* pEngine = new QQmlApplicationEngine(parent);
    pEngine->addImportPath("qrc:/qml");
    pEngine->rootContext()->setContextProperty("joystickManager", qgcApp()->toolbox()->joystickManager());
    pEngine->rootContext()->setContextProperty("debugMessageModel", AppMessages::getModel());
    pEngine->load(QUrl(QStringLiteral("qrc:/qml/MainWindowNative.qml")));
    return pEngine;
}
