#include "backend.h"

Backend::Backend(QObject* parent)
    : QObject(parent)
{
    videoWrapper = new VideoWrapper();
    connect(
        videoWrapper, &VideoWrapper::gotNewFrameImage,
        this, &Backend::uploadPose);
    connect(
        videoWrapper, &VideoWrapper::gotNewFrame,
        this, [=]() { this->counterIncreased(); });

    managerPose = new QNetworkAccessManager(this);
    connect(
        managerPose, &QNetworkAccessManager::finished,
        this, &Backend::requestPoseFinished);

    managerHand = new QNetworkAccessManager(this);
    connect(
        managerHand, &QNetworkAccessManager::finished,
        this, &Backend::requestHandFinished);

    // for debugging with HTTP proxy
    //QNetworkProxy proxy;
    //proxy.setType(QNetworkProxy::HttpProxy);
    //proxy.setHostName("localhost");
    //proxy.setPort(4321);
    //manager->setProxy(proxy);

    _currentProfile = 0;
    _currentScore = 0;
}

void Backend::uploadPose(QImage img)
{
    // apparently, 384x288 is enough for MXNet
    QImage shotScaled = img.scaled(384, 288);
    shotScaled = shotScaled.mirrored(true, false);
    //qDebug() << shotScaled.save(QString("%1-some.jpg").arg(QDateTime::currentDateTime().toString("hh-mm-ss-zzz")));

    auto imgBuffer = new QBuffer();
    //QImageWriter iw(imgBuffer, "JPG");
    //bool shotSaved = iw.write(shot);
    bool shotSaved = shotScaled.save(imgBuffer, "JPG");
    if (!shotSaved) {
        qCritical() << "[error] Couldn't save the original shot]" << imgBuffer->errorString();
    } else {
        const QByteArray reqID = QUuid::createUuid().toByteArray();
        _frames.insert(reqID, img);

        //qDebug() << "uploading" << imgBuffer->size() << "bytes";
        QNetworkRequest request = QNetworkRequest(QUrl(_endpointPose));
        request.setRawHeader("Content-Type", "multipart/form-data");
        request.setRawHeader("reqID", reqID);

        imgBuffer->open(QIODevice::ReadOnly);
        QNetworkReply* reply = managerPose->post(request, imgBuffer);
        connect(reply, &QNetworkReply::finished, imgBuffer, &QBuffer::deleteLater);
    }
}

void Backend::uploadHand(QImage img, bool isRight)
{
    if (!isRight) {
        setRightPalm(img);
    } else {
        setLeftPalm(img);
    }

    auto imgBuffer = new QBuffer();
    bool shotSaved = img.save(imgBuffer, "JPG");
    if (!shotSaved) {
        qCritical() << "[error] Couldn't save the shot for cropping]" << imgBuffer->errorString();
    } else {
        QNetworkRequest request = QNetworkRequest(QUrl(_endpointHand));
        request.setRawHeader("Content-Type", "multipart/form-data");
        request.setRawHeader("isRight", QString::number(isRight).toUtf8());

        imgBuffer->open(QIODevice::ReadOnly);
        QNetworkReply* reply = managerHand->post(request, imgBuffer);
        connect(reply, &QNetworkReply::finished, imgBuffer, &QBuffer::deleteLater);
    }
}

void Backend::requestPoseFinished(QNetworkReply* reply)
{
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    //qDebug() << status << "|" << data;

    if (status != 200) {
        QString errorMessage = data;
        QNetworkReply::NetworkError err = reply->error();
        if (status == 0) {
            // dictionary: http://doc.qt.io/qt-5/qnetworkreply.html#NetworkError-enum
            errorMessage = QString("QNetworkReply::NetworkError code: %1").arg(QString::number(err));
        }

        // TODO make a dedicated endpoint and method for pinging
        _connected = false;
        emit connectedChanged(false);

        emit requestFailed(QString("Code %1 | %2").arg(status).arg(errorMessage));
        return;
    }

    // TODO make a dedicated endpoint and method for pinging
    _connected = true;
    emit connectedChanged(true);

    emit requestPoseDone(data);

    // --- now we need to crop palm regions and send those

    QJsonParseError err;
    QJsonDocument jsn = QJsonDocument::fromJson(data, &err);
    if (err.error == QJsonParseError::NoError) {
        QJsonObject jsnObj = jsn.object();
        QVariantMap root_map = jsnObj.toVariantMap();
        QVariantMap skeleton_map = root_map["skeleton"].toMap();
        QVariantMap left_elbow = skeleton_map["left_elbow"].toMap();
        QVariantMap left_wrist = skeleton_map["left_wrist"].toMap();
        QVariantMap right_elbow = skeleton_map["right_elbow"].toMap();
        QVariantMap right_wrist = skeleton_map["right_wrist"].toMap();

        QByteArray reqID = reply->request().rawHeader("reqID");
        QImage palmLeft = cropPalmRegion(_frames.value(reqID), left_elbow, left_wrist);
        QImage palmRight = cropPalmRegion(_frames.value(reqID), right_elbow, right_wrist);
        // original frame is no longer needed
        _frames.remove(reqID);

        uploadHand(palmLeft, false);
        uploadHand(palmRight, true);
    } else {
        qCritical() << "Error parsing MXNet [pose] response: " << err.error;
    }
}

void Backend::requestHandFinished(QNetworkReply* reply)
{
    int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray data = reply->readAll();

    //qDebug() << status << "|" << data;

    if (status != 200) {
        QString errorMessage = data;
        QNetworkReply::NetworkError err = reply->error();
        if (status == 0) {
            // dictionary: http://doc.qt.io/qt-5/qnetworkreply.html#NetworkError-enum
            errorMessage = QString("QNetworkReply::NetworkError code: %1").arg(QString::number(err));
        }
        emit requestFailed(QString("Code %1 | %2").arg(status).arg(errorMessage));
    }

    bool isRight = reply->request().rawHeader("isRight").toInt();
    //qDebug() << "isRight:" << isRight;

    QJsonParseError err;
    QJsonDocument jsn = QJsonDocument::fromJson(data, &err);
    if (err.error == QJsonParseError::NoError) {
        QJsonObject jsnObj = jsn.object();
        QVariantMap root_map = jsnObj.toVariantMap();
        //QVariantMap confidence_map = root_map["confidence"].toMap();

        QString predicted = jsnObj["predicted"].toString();

        // only keep predictions values that are not "background" and above threshold (0.6)
        if (predicted == "background" || predicted == "middle" || jsnObj["value"].toDouble() < 0.6) {
            predicted = "2";
        } else {
            auto prediction = accumulatedPalmPrediction(predicted == "open", isRight);
            // TODO use majority vote of the last [n] values | n = 3

            if (prediction) {
                predicted = "0";
            } else {
                predicted = "1";
            }
        }

        if (isRight) {
            emit requestLeftHandDone(predicted);
        } else {
            emit requestRightHandDone(predicted);
        }
    } else {
        qCritical() << "Error parsing MXNet [hand] response: " << err.error;
    }
}

QImage Backend::cropPalmRegion(QImage originalFrame, QVariantMap elbow, QVariantMap wrist)
{
    if (!videoWrapper) {
        qDebug() << __PRETTY_FUNCTION__ << ": videoWrapper not set";
        return QImage();
    }

    auto frameSize = videoWrapper->frameSize();

    float e_x = elbow["x"].toFloat();
    float e_y = elbow["y"].toFloat();
    float w_x = wrist["x"].toFloat();
    float w_y = wrist["y"].toFloat();
    int x = qRound(frameSize.width() * (w_x + (w_x - e_x) / 2) - _cropRegionWidth / 2);
    int y = qRound(frameSize.height() * (w_y + (w_y - e_y) / 2) - _cropRegionWidth / 2);
    //qDebug() << e_x << e_y << w_x << w_y << x << y;

    x = qRound(frameSize.width() * w_x);
    y = qRound(frameSize.height() * w_y);

    QRect cropRegionLeft(x-_cropRegionWidth, y-_cropRegionWidth, _cropRegionWidth*2, _cropRegionWidth*2);
    //qDebug() << "cpp rect:" << cropRegionLeft;

    QImage palm = originalFrame.mirrored(true, false).copy(cropRegionLeft);
    //    palm.save(QString(
    //                  "%1-%2.jpg")
    //                  .arg(wrist["name"].toString())
    //                  .arg(QDateTime::currentDateTime().toString("hh-mm-ss-zzz"))
    //                  );
    return palm;
}

void Backend::setLeftPalm(QImage palm)
{
    _leftPalm = palm;
    emit leftPalmChanged();
}

void Backend::setRightPalm(QImage palm)
{
    _rightPalm = palm;
    emit rightPalmChanged();
}

bool Backend::accumulatedPalmPrediction(bool isOpen, bool isRight)
{
    auto& list = isRight ? _lastRightPalmPredictions : _lastLeftPalmPredictions;

    if (list.size() == _lastPalmPredictionsCount) {
        list.takeFirst();
    }

    list.push_back(isOpen);

    int openCount = list.count(true);
    int closedCount = list.count(false);

    //qDebug() << list << (isRight ? "Right " : "Left ") << "yes count: " << openCount << ", no count: " << closedCount;

    return openCount > closedCount;
}

void Backend::set_currentProfile(int id)
{
    _currentProfile = id;
}

int Backend::get_currentProfile()
{
    return _currentProfile;
}

void Backend::set_currentScore(int score)
{
    _currentScore = score;
}

int Backend::get_currentScore()
{
    return _currentScore;
}

VideoWrapper* Backend::get_videoWrapper()
{
    return videoWrapper;
}

int Backend::cropRegionWidth() const
{
    return _cropRegionWidth;
}

void Backend::enableSendingToMXNet(bool sendingEnabled)
{
    videoWrapper->enableSending(sendingEnabled);
}

QString Backend::dbServer()
{
    return QString("%1:%2").arg(_dbServerHost).arg(_dbServerPort);
}

QImage PalmImageProvider::requestImage(const QString& id, QSize* size, const QSize& requestedSize)
{
    if (!_backend) {
        qDebug() << "No backend assigned, returning empty image";
        return QImage();
    }

    QImage palm;

    if (id == "left") {
        palm = _backend->leftPalm();
    } else if (id == "right") {
        palm = _backend->rightPalm();
    } else {
        qDebug() << id << " could not be found";
        return QImage();
    }

    auto width = palm.width();
    auto height = palm.height();
    if (size) {
        *size = QSize(width, height);
    }

    QSize resizedSize(requestedSize.width() > 0 ? requestedSize.width() : width,
        requestedSize.height() > 0 ? requestedSize.height() : height);

    if (resizedSize != *size) {
        return palm.scaled(resizedSize);
    }

    return palm;
}
