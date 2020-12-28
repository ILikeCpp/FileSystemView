#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "filesystemmodel.h"
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    FileSystemModel fileSystemModel;
    fileSystemModel.setRootPath("");
    fileSystemModel.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    engine.rootContext()->setContextProperty("fileSystemModel", &fileSystemModel);

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
