#include "videowrapper.h"

QList<QVideoFrame::PixelFormat> VideoWrapper::supportedPixelFormats(
        QAbstractVideoBuffer::HandleType handleType
        ) const
{
    Q_UNUSED(handleType);
    return QList<QVideoFrame::PixelFormat>() << QVideoFrame::Format_UYVY << QVideoFrame::Format_BGR32;
}

bool VideoWrapper::present(const QVideoFrame &frame)
{
    if (surf) { surf->present(frame); }
    QVideoFrame frameCopy = frame;

    frameCopy.map(QAbstractVideoBuffer::ReadOnly);

    //qDebug() << "got frame:" << frameCopy.mappedBytes() << frameCopy.size() << frameCopy.width() << "x" << frameCopy.height();
    QImage shot = qt_imageFromVideoFrame(frameCopy);
    bool shotSaved = shot.save(QString("%1-some.jpg").arg(QDateTime::currentDateTime().toString("hh-mm-ss-zzz")));
    if (!shotSaved) { qDebug() << "couldn't save this one"; }

    frameCopy.unmap();

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
    if (m_source)
    {
        QCamera *camera = qvariant_cast<QCamera*>(m_source->property("mediaObject"));
        if (camera)
        {
            camera->setViewfinder((QAbstractVideoSurface*)0);
        }
        else
        {
            qsrc->setProperty("videoSurface", QVariant::fromValue<QAbstractVideoSurface*>(NULL));
        }
    }

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
