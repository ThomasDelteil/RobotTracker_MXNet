#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend.h"

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

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QString basePath = getBasePath(app.applicationDirPath());
    //qDebug() << basePath;
    engine.rootContext()->setContextProperty("basePath", basePath);

    qmlRegisterType<Backend>("io.qt.Backend", 1, 0, "Backend");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty()) { return -1; }

    return app.exec();
}
