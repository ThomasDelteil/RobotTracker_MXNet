#include "videowrapper.h"

QList<QVideoFrame::PixelFormat> VideoWrapper::supportedPixelFormats(QAbstractVideoBuffer::HandleType handleType) const
{
    Q_UNUSED(handleType);
    return QList<QVideoFrame::PixelFormat>() << QVideoFrame::Format_UYVY << QVideoFrame::Format_BGR32;
}

bool VideoWrapper::present(const QVideoFrame &frame)
{
    if (surf) { surf->present(frame); }

    if (_sendingEnabled)
    {
        _sendingEnabled = false;

        QVideoFrame frameCopy = frame;
        frameCopy.map(QAbstractVideoBuffer::ReadOnly);

        //qDebug() << "got frame:" << frameCopy.mappedBytes() << frameCopy.size() << frameCopy.width() << "x" << frameCopy.height();
        QImage shot = qt_imageFromVideoFrame(frameCopy);
        // apparently, 384x288 is enough for MXNet
        shot = shot.scaled(384, 288);
        //shot = shot.mirrored(true, false);
        //qDebug() << shot.save(QString("%1-some.jpg").arg(QDateTime::currentDateTime().toString("hh-mm-ss-zzz")));

        QBuffer *imgBuffer = new QBuffer();
        //QImageWriter iw(imgBuffer, "JPG");
        //bool shotSaved = iw.write(shot);
        bool shotSaved = shot.save(imgBuffer, "JPG");
        if (!shotSaved) { qDebug() << "[error saving shot]" << imgBuffer->errorString(); }
        else
        {
            emit gotNewShotBytes(imgBuffer);
        }

        frameCopy.unmap();
    }

    emit gotNewFrame();

    return true;
}

bool VideoWrapper::start(const QVideoSurfaceFormat &format)
{
    if(supportedPixelFormats().count(format.pixelFormat()) == 0)
    { return false; }

    if(!QAbstractVideoSurface::start(format))
    { return false; }

    if( surf && !surf->start(format) )
    { return false; }

    m_format = format;
    return true;
}

void VideoWrapper::stop()
{
    QAbstractVideoSurface::stop();
}

QAbstractVideoSurface *VideoWrapper::get_videoSurface() const
{
    return surf;
}

void VideoWrapper::set_videoSurface(QAbstractVideoSurface *m)
{
    if (surf == m)
        return;

    if (surf && surf->isActive())
        surf->stop();

    surf = m;

    if (surf && isActive())
        surf->start(m_format);
}

QObject *VideoWrapper::get_source()
{
    return m_source;
}

void VideoWrapper::set_source(QObject *qsrc)
{
//    //m_source = nullptr;

//    if (m_source)
//    {
//        QCamera *camera = qvariant_cast<QCamera*>(m_source->property("mediaObject"));
//        if (camera)
//        {
//            camera->setViewfinder((QAbstractVideoSurface*)0);
//        }
//        else
//        {
//            qsrc->setProperty("videoSurface", QVariant::fromValue<QAbstractVideoSurface*>(NULL));
//        }
//    }

    m_source = qsrc;

    if (qsrc)
    {
        QCamera *camera = qvariant_cast<QCamera*>(qsrc->property("mediaObject"));
        if(camera)
        {
            camera->setCaptureMode(QCamera::CaptureViewfinder);
            camera->setViewfinder(this);
        }
        else
        {
            qsrc->setProperty("videoSurface", QVariant::fromValue<QAbstractVideoSurface*>(this));
        }
    }

    emit sourceChanged();
}

void VideoWrapper::enableSending(bool sendingEnabled)
{
    _sendingEnabled = sendingEnabled;
}
