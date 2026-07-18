#pragma once

#include <QObject>
#include <QTimer>
#include <QString>
#include "MockScenarioEngine.h"

class SimulatorService : public QObject
{
    Q_OBJECT

public:
    explicit SimulatorService(QObject *parent = nullptr);
    void startSimulation();
    void stopSimulation();

signals:
    void telemetryUpdated(double speed, int rpm, const QString &gear, bool isWarning, int battery, int range, int temperature);

private slots:
    void generateTelemetry();

private:
    QTimer *m_timer;
    MockScenarioEngine m_mockEngine;
};
