#pragma once

#include <QString>

struct MockTelemetry {
    float speed = 0.0f;
    float rpm = 0.0f;
    int gear = 1;
    bool isWarning = false;
    int battery = 100;
    int range = 400;
    int temperature = 25;
};

class MockScenarioEngine {
public:
    enum class Scenario {
        DragRace,
        BatteryDrain,
        ErrorInjection
    };

    explicit MockScenarioEngine();

    void setScenario(Scenario scenario);
    void tick(double deltaTimeMs);

    MockTelemetry getCurrentTelemetry() const;

private:
    Scenario m_currentScenario;
    MockTelemetry m_telemetry;
    
    double m_elapsedTimeMs;
    
    void updateDragRace(double dt);
    void updateBatteryDrain(double dt);
    void updateErrorInjection(double dt);
};
