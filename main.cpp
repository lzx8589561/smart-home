#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QApplication>
#include "fpslabel.h"

int main(int argc, char *argv[])
{
#if defined(Q_OS_WIN)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);

    // 注册控件
    qmlRegisterType<FPSLabel>("FPS", 1, 0, "FPSLabel");

    QQmlApplicationEngine engine;
    QApplication::setOverrideCursor(Qt::BlankCursor);
    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
