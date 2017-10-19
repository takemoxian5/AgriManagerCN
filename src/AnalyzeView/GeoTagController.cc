/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "GeoTagController.h"
#include "QGCQFileDialog.h"
#include "QGCLoggingCategory.h"
#include "MainWindow.h"
#include <math.h>
#include <QtEndian>
#include <QMessageBox>
#include <QDebug>
#include <cfloat>

#include "ExifParser.h"
#include "ULogParser.h"
#include "PX4LogParser.h"

#if QT_VERSION >= QT_VERSION_CHECK(5,0,0)
    #if defined(_MSC_VER) && (_MSC_VER > 1600)
        // Coding: UTF-8
        #pragma execution_character_set("utf-8")
    #endif
#endif

GeoTagController::GeoTagController(void)
    : _progress(0)
    , _inProgress(false)
{
    connect(&_worker, &GeoTagWorker::progressChanged,   this, &GeoTagController::_workerProgressChanged);
    connect(&_worker, &GeoTagWorker::error,             this, &GeoTagController::_workerError);
    connect(&_worker, &GeoTagWorker::started,           this, &GeoTagController::inProgressChanged);
    connect(&_worker, &GeoTagWorker::finished,          this, &GeoTagController::inProgressChanged);
}

GeoTagController::~GeoTagController()
{

}

void GeoTagController::pickLogFile(void)
{
    QString filename = QGCQFileDialog::getOpenFileName(MainWindow::instance(), tr("选择日志文件加载"), QString(), tr("ULog文件 (*.ulg);;PX4日志文件 (*.px4log);;所有文件 (*.*)"));
    if (!filename.isEmpty()) {
        _worker.setLogFile(filename);
        emit logFileChanged(filename);
    }
}

void GeoTagController::pickImageDirectory(void)
{
    QString dir = QGCQFileDialog::getExistingDirectory(MainWindow::instance(), tr("选择图片路径"));
    if (!dir.isEmpty()) {
        _worker.setImageDirectory(dir);
        emit imageDirectoryChanged(dir);
    }
}

void GeoTagController::pickSaveDirectory(void)
{
    QString dir = QGCQFileDialog::getExistingDirectory(MainWindow::instance(), tr("选择保存路径"));
    if (!dir.isEmpty()) {
        _worker.setSaveDirectory(dir);
        emit saveDirectoryChanged(dir);
    }
}

void GeoTagController::startTagging(void)
{
    _errorMessage.clear();
    emit errorMessageChanged(_errorMessage);

    QDir imageDirectory = QDir(_worker.imageDirectory());
    if(!imageDirectory.exists()) {
        _errorMessage = tr("无法找到图像文件");
        emit errorMessageChanged(_errorMessage);
        return;
    }
    if(_worker.saveDirectory() == "") {
        if(!imageDirectory.mkdir(_worker.imageDirectory() + "/TAGGED")) {
            QMessageBox msgBox(QMessageBox::Question,
                               tr("图片已经被标记了."),
                               tr("这些图像已经被标记了，你想要替换之前被标记的图像吗?"),
                               QMessageBox::Cancel);
            msgBox.setWindowModality(Qt::ApplicationModal);
            msgBox.addButton(tr("替换"), QMessageBox::ActionRole);
            if (msgBox.exec() == QMessageBox::Cancel) {
                _errorMessage = tr("图片已经被标记了");
                emit errorMessageChanged(_errorMessage);
                return;
            }
            QDir oldTaggedFolder = QDir(_worker.imageDirectory() + "/TAGGED");
            oldTaggedFolder.removeRecursively();
            if(!imageDirectory.mkdir(_worker.imageDirectory() + "/TAGGED")) {
                _errorMessage = tr("无法替换");
                emit errorMessageChanged(_errorMessage);
                return;
            }
        }
    } else {
        QDir saveDirectory = QDir(_worker.saveDirectory());
        if(!saveDirectory.exists()) {
            _errorMessage = tr("无法找到保存目录");
            emit errorMessageChanged(_errorMessage);
            return;
        }
        saveDirectory.setFilter(QDir::Files | QDir::Readable | QDir::NoSymLinks | QDir::Writable);
        QStringList nameFilters;
        nameFilters << "*.jpg" << "*.JPG";
        saveDirectory.setNameFilters(nameFilters);
        QStringList imageList = saveDirectory.entryList();
        if(!imageList.isEmpty()) {
            QMessageBox msgBox(QMessageBox::Question,
                               tr("保存文件夹不为空."),
                               tr("保存文件夹已经包含图像，你想要替换它们吗?"),
                               QMessageBox::Cancel);
            msgBox.setWindowModality(Qt::ApplicationModal);
            msgBox.addButton(tr("替换"), QMessageBox::ActionRole);
            if (msgBox.exec() == QMessageBox::Cancel) {
                _errorMessage = tr("保存文件夹不为空");
                emit errorMessageChanged(_errorMessage);
                return;
            }
            foreach(QString dirFile, imageList)
            {
                if(!saveDirectory.remove(dirFile)) {
                    _errorMessage = tr("无法替换");
                    emit errorMessageChanged(_errorMessage);
                    return;
                }
            }
        }
    }
    _worker.start();
}

void GeoTagController::_workerProgressChanged(double progress)
{
    _progress = progress;
    emit progressChanged(progress);
}

void GeoTagController::_workerError(QString errorMessage)
{
    _errorMessage = errorMessage;
    emit errorMessageChanged(errorMessage);
}

GeoTagWorker::GeoTagWorker(void)
    : _cancel(false)
    , _logFile("")
    , _imageDirectory("")
    , _saveDirectory("")
{

}

void GeoTagWorker::run(void)
{
    _cancel = false;
    emit progressChanged(1);
    double nSteps = 5;

    // Load Images
    _imageList.clear();
    QDir imageDirectory = QDir(_imageDirectory);
    imageDirectory.setFilter(QDir::Files | QDir::Readable | QDir::NoSymLinks | QDir::Writable);
    imageDirectory.setSorting(QDir::Name);
    QStringList nameFilters;
    nameFilters << "*.jpg" << "*.JPG";
    imageDirectory.setNameFilters(nameFilters);
    _imageList = imageDirectory.entryInfoList();
    if(_imageList.isEmpty()) {
        emit error(tr("目录不包含图片，确保你的图像是JPG格式"));
        return;
    }
    emit progressChanged((100/nSteps));

    // Parse EXIF
    ExifParser exifParser;
    _imageTime.clear();
    for (int i = 0; i < _imageList.size(); ++i) {
        QFile file(_imageList.at(i).absoluteFilePath());
        if (!file.open(QIODevice::ReadOnly)) {
            emit error(tr("地理标记失败了，不能打开图像."));
            return;
        }
        QByteArray imageBuffer = file.readAll();
        file.close();

        _imageTime.append(exifParser.readTime(imageBuffer));

        emit progressChanged((100/nSteps) + ((100/nSteps) / _imageList.size())*i);

        if (_cancel) {
            qCDebug(GeotaggingLog) << "Tagging cancelled";
            emit error(tr("标记取消"));
            return;
        }
    }

    // Load log
    bool isULog = _logFile.endsWith(".ulg", Qt::CaseSensitive);
    QFile file(_logFile);
    if (!file.open(QIODevice::ReadOnly)) {
        emit error(tr("地理标记失败了，不能打开的日志文件."));
        return;
    }
    QByteArray log = file.readAll();
    file.close();

    // Instantiate appropriate parser
    _triggerList.clear();
    bool parseComplete = false;
    if(isULog) {
        ULogParser parser;
        parseComplete = parser.getTagsFromLog(log, _triggerList);

    } else {
        PX4LogParser parser;
        parseComplete = parser.getTagsFromLog(log, _triggerList);

    }

    if (!parseComplete) {
        if (_cancel) {
            qCDebug(GeotaggingLog) << "Tagging cancelled";
            emit error(tr("标记取消"));
            return;
        } else {
            qCDebug(GeotaggingLog) << "Log parsing failed";
            emit error(tr("日志解析失败，取消标记"));
            return;
        }
    }
    emit progressChanged(3*(100/nSteps));

    qCDebug(GeotaggingLog) << "Found " << _triggerList.count() << " trigger logs.";

    if (_cancel) {
        qCDebug(GeotaggingLog) << "Tagging cancelled";
        emit error(tr("标记取消"));
        return;
    }

    // Filter Trigger
    if (!triggerFiltering()) {
        qCDebug(GeotaggingLog) << "Geotagging failed in trigger filtering";
        emit error(tr("在触发过滤中进行地理标记失败"));
        return;
    }
    emit progressChanged(4*(100/nSteps));

    if (_cancel) {
        qCDebug(GeotaggingLog) << "Tagging cancelled";
        emit error(tr("标记取消"));
        return;
    }

    // Tag images
    int maxIndex = std::min(_imageIndices.count(), _triggerIndices.count());
    maxIndex = std::min(maxIndex, _imageList.count());
    for(int i = 0; i < maxIndex; i++) {
        QFile fileRead(_imageList.at(_imageIndices[i]).absoluteFilePath());
        if (!fileRead.open(QIODevice::ReadOnly)) {
            emit error(tr("地理标记失败了，不能打开一个图像."));
            return;
        }
        QByteArray imageBuffer = fileRead.readAll();
        fileRead.close();

        if (!exifParser.write(imageBuffer, _triggerList[_triggerIndices[i]])) {
            emit error(tr("地理标记失败了，不能写到图片."));
            return;
        } else {
            QFile fileWrite;
            if(_saveDirectory == "") {
                fileWrite.setFileName(_imageDirectory + "/TAGGED/" + _imageList.at(_imageIndices[i]).fileName());
            } else {
                fileWrite.setFileName(_saveDirectory + "/" + _imageList.at(_imageIndices[i]).fileName());
            }
            if (!fileWrite.open(QFile::WriteOnly)) {
                emit error(tr("地理标记失败了，不能写到图片."));
                return;
            }
            fileWrite.write(imageBuffer);
            fileWrite.close();
        }
        emit progressChanged(4*(100/nSteps) + ((100/nSteps) / maxIndex)*i);

        if (_cancel) {
            qCDebug(GeotaggingLog) << "Tagging cancelled";
            emit error(tr("标记取消"));
            return;
        }
    }

    if (_cancel) {
        qCDebug(GeotaggingLog) << "Tagging cancelled";
        emit error(tr("标记取消"));
        return;
    }

    emit progressChanged(100);
}

bool GeoTagWorker::triggerFiltering()
{
    _imageIndices.clear();
    _triggerIndices.clear();

    if(_imageList.count() > _triggerList.count()) {             // Logging dropouts
        qCDebug(GeotaggingLog) << "Detected missing feedback packets.";
    } else if (_imageList.count() < _triggerList.count()) {     // Camera skipped frames
        qCDebug(GeotaggingLog) << "Detected missing image frames.";
    }

    for(int i = 0; i < _imageList.count() && i < _triggerList.count(); i++) {
        _imageIndices.append(_triggerList[i].imageSequence);
        _triggerIndices.append(i);
    }

    return true;
}
