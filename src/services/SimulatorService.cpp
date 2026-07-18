#include "SimulatorService.h"
#include <QDebug>

SimulatorService::SimulatorService(QObject *parent)
    : QObject(parent), m_timer(new QTimer(this))
{
    // Cập nhật với tốc độ 30ms (~33fps) để animation mượt mà
    m_timer->setInterval(30); 
    connect(m_timer, &QTimer::timeout, this, &SimulatorService::generateTelemetry);
}

void SimulatorService::startSimulation()
{
    m_timer->start();
}

void SimulatorService::stopSimulation()
{
    m_timer->stop();
}

void SimulatorService::generateTelemetry()
{
    // Truyền delta time = 30ms cho mỗi frame
    m_mockEngine.tick(30.0);
    MockTelemetry data = m_mockEngine.getCurrentTelemetry();

    QString gearStr = (data.gear == 1) ? "N" : QString::number(data.gear);

    emit telemetryUpdated(
        data.speed, 
        (int)data.rpm, 
        gearStr, 
        data.isWarning,
        data.battery,
        data.range,
        data.temperature
    );
}
