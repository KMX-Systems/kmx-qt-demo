cmake_minimum_required(VERSION 3.21)

project(QtDemo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.11 REQUIRED COMPONENTS Quick QuickControls2 LinguistTools)

qt_standard_project_setup(REQUIRES 6.11)

qt_add_executable(appqtdemo
    src/main.cpp
    src/Engine.h
    src/Engine.cpp
    src/NotificationModel.h
    src/NotificationModel.cpp
    src/UserModel.h
    src/UserModel.cpp
    src/JobModel.h
    src/JobModel.cpp
)

qt_add_qml_module(appqtdemo
    URI QtDemo
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/DashboardPage.qml
        qml/ControlsPage.qml
        qml/DataPage.qml
        qml/SlidesPage.qml
        qml/LauncherPage.qml
        qml/CompactCheckBox.qml
        qml/AnalyticsWindow.qml
        qml/OperationsWindow.qml
        qml/MonitoringWindow.qml
        qml/SettingsWindow.qml
)

target_link_libraries(appqtdemo
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

qt_add_translations(appqtdemo
    TS_FILES
        translations/qtdemo_en.ts
        translations/qtdemo_ro.ts
)

install(TARGETS appqtdemo
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
