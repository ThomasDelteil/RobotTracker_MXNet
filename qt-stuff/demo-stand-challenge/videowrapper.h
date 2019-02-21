#ifndef VIDEOWRAPPER_H
#define VIDEOWRAPPER_H

#include <QAbstractVideoSurface>
#include <QBuffer>
#include <QCamera>
#include <QDateTime>
#include <QObject>
#include <QVideoFrame>
#include <QVideoSurfaceFormat>
//#include <QImageWriter>
#include "private/qvideoframe_p.h"

class VideoWrapper : public QAbstractVideoSurface {

    Q_OBJECT

    Q_PROPERTY(QObject* source READ get_source WRITE set_source NOTIFY sourceChanged)
    Q_PROPERTY(QAbstractVideoSurface* videoSurface READ get_videoSurface WRITE set_videoSurface)
    Q_PROPERTY(QSize frameSize READ frameSize WRITE setFrameSize NOTIFY frameSizeChanged)

public:
    QList<QVideoFrame::PixelFormat> supportedPixelFormats(
        QAbstractVideoBuffer::HandleType handleType = QAbstractVideoBuffer::NoHandle) const override;

    bool present(const QVideoFrame& frame) override;

    bool start(const QVideoSurfaceFormat& format) override;
    void stop() override;

    QAbstractVideoSurface* get_videoSurface() const;
    void set_videoSurface(QAbstractVideoSurface* m);

    QObject* get_source();
    void set_source(QObject* qsrc);

    void enableSending(bool sendingEnabled);

public slots:
    QSize frameSize() const;
    void setFrameSize(QSize size);

signals:
    void sourceChanged();
    void gotNewFrameImage(QImage img);
    void gotNewFrame();
    void frameSizeChanged();

private:
    QObject* m_source = nullptr;
    QAbstractVideoSurface* surf = nullptr;
    QVideoSurfaceFormat m_format;
    QSize _frameSize;
    bool _sendingEnabled = false; // enabling sending frames to MXNet
};

#endif // VIDEOWRAPPER_H
