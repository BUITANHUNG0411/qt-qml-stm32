#include "MockScenarioEngine.h"
#include <QRandomGenerator>
#include <cmath>
#include <algorithm>

MockScenarioEngine::MockScenarioEngine() 
    : m_currentScenario(Scenario::DragRace), m_elapsedTimeMs(0)
{
}

void MockScenarioEngine::setScenario(Scenario scenario) {
    m_currentScenario = scenario;
    m_telemetry = MockTelemetry();
}

MockTelemetry MockScenarioEngine::getCurrentTelemetry() const {
    return m_telemetry;
}

void MockScenarioEngine::tick(double deltaTimeMs) {
    m_elapsedTimeMs += deltaTimeMs;

    if (m_currentScenario == Scenario::DragRace) {
        updateDragRace(deltaTimeMs);
    } else if (m_currentScenario == Scenario::BatteryDrain) {
        updateBatteryDrain(deltaTimeMs);
    } else if (m_currentScenario == Scenario::ErrorInjection) {
        updateErrorInjection(deltaTimeMs);
    }
}

void MockScenarioEngine::updateDragRace(double dt) {
    // Accelerate from 0 to 160 over 8s, brake over 2s
    double t = std::fmod(m_elapsedTimeMs / 1000.0, 10.0);
    
    m_telemetry.isWarning = false;
    m_telemetry.temperature = 25 + (int)(t * 2);
    m_telemetry.battery = 100;
    m_telemetry.range = 400;
    
    if (t < 8.0) { // Accelerate
        m_telemetry.speed = std::min(160.0f, (float)(t * 20.0f)); 
        // Gear calculation (every 32 km/h)
        float gearSpeed = std::fmod(m_telemetry.speed, 32.0f);
        m_telemetry.rpm = 1000.0f + (gearSpeed / 32.0f) * 5000.0f;
        m_telemetry.gear = 1 + (int)(m_telemetry.speed / 32.0f);
    } else { // Brake
        float brakeTime = t - 8.0f;
        m_telemetry.speed = std::max(0.0f, 160.0f - (brakeTime * 80.0f));
        m_telemetry.rpm = 1000.0f + (m_telemetry.speed / 160.0f) * 2000.0f;
        m_telemetry.gear = std::max(1, (int)(m_telemetry.speed / 32.0f));
    }
    
    if (m_telemetry.gear > 5) m_telemetry.gear = 5;
}

void MockScenarioEngine::updateBatteryDrain(double dt) {
    // Cruise at ~80 km/h, fast battery drain simulation
    double t = std::fmod(m_elapsedTimeMs / 1000.0, 10.0);
    
    // Slight oscillation in speed and rpm
    m_telemetry.speed = 80.0f + std::sin(t * 2.0) * 3.0f;
    m_telemetry.rpm = 2500.0f + std::sin(t * 2.0) * 100.0f;
    m_telemetry.gear = 4;
    
    // Battery drops from 100 to 0 in 10 seconds
    m_telemetry.battery = std::max(0, 100 - (int)(t * 10));
    m_telemetry.range = m_telemetry.battery * 4; // 4km per %
    
    // Warning triggers when battery is critically low (< 20%)
    m_telemetry.isWarning = (m_telemetry.battery < 20);
    m_telemetry.temperature = 35 + (int)(std::sin(t) * 2);
}

void MockScenarioEngine::updateErrorInjection(double dt) {
    // Erratic behavior and overheating
    double t = std::fmod(m_elapsedTimeMs / 1000.0, 10.0);
    
    // Speed slowly drops to 0
    m_telemetry.speed = std::max(0.0f, 30.0f - (float)(t * 3.0f));
    // Engine struggling (random rpm)
    m_telemetry.rpm = 1000.0f + QRandomGenerator::global()->generateDouble() * 800.0f;
    m_telemetry.gear = 2;
    
    // Blinking warning light (half second interval)
    m_telemetry.isWarning = ((int)(t * 4) % 2 == 0); 
    
    // Overheating simulation
    m_telemetry.temperature = 80 + (int)(t * 3);
    m_telemetry.battery = 15;
    m_telemetry.range = 60;
}
