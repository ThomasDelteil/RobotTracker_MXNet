#include "backend.h"
#include <QCameraInfo>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

QString getBasePath(QString applicationDirPath)
{
    QString baseFolder = QString();
    QString pathLastMile = baseFolder.prepend("/");
#if defined(Q_OS_MAC)
    pathLastMile = baseFolder.prepend("/../../..");
#elif defined(Q_OS_WIN)
    pathLastMile = baseFolder.prepend("/..");
#endif
    return QString("%1%2").arg(applicationDirPath).arg(pathLastMile);
}

int main(int argc, char* argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    //    qDebug() << "cameras found:";
    //    QListIterator<QCameraInfo> cameras(QCameraInfo::availableCameras());
    //    while (cameras.hasNext()) {
    //        qDebug() << "-" << cameras.next();
    //    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString basePath = getBasePath(app.applicationDirPath());
    //qDebug() << basePath;
    engine.rootContext()->setContextProperty("basePath", basePath);

    qmlRegisterType<Backend>("io.qt.Backend", 1, 0, "Backend");

    auto palmProvider = new PalmImageProvider;
    engine.addImageProvider("palms", palmProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    auto rootObjects = engine.rootObjects();
    if (rootObjects.isEmpty()) {
        return -1;
    }

    auto parent = rootObjects.first();
    auto backend = parent->findChild<Backend*>();

    palmProvider->setProperty("backend", QVariant::fromValue(backend));

    return app.exec();
}
