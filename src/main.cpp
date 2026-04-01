#include <QGuiApplication>
#include <QFont>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QTranslator>
#include "Engine.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("QtDemo");
    app.setApplicationVersion("1.0");

    QFont uiFont = app.font();
    uiFont.setPointSizeF(8.5);
    app.setFont(uiFont);

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_MATERIAL_VARIANT"))
        qputenv("QT_QUICK_CONTROLS_MATERIAL_VARIANT", "Dense");

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_MATERIAL_THEME"))
        qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", "Dark");

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        QQuickStyle::setStyle(QStringLiteral("Material"));

    Engine backendEngine;

    QQmlApplicationEngine qmlEngine;
    qmlEngine.rootContext()->setContextProperty("engine", &backendEngine);

    auto *translator = new QTranslator(&app);
    QObject::connect(&backendEngine, &Engine::languageChangeRequested,
        [translator, &qmlEngine](const QString &locale) {
            QCoreApplication::removeTranslator(translator);
            if (locale != QLatin1String("en")) {
                const QString path = QStringLiteral(":/i18n/qtdemo_") + locale + QStringLiteral(".qm");
                if (translator->load(path))
                    QCoreApplication::installTranslator(translator);
            }
            qmlEngine.retranslate();
        });

    QObject::connect(
        &qmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    qmlEngine.loadFromModule("QtDemo", "Main");

    return app.exec();
}
