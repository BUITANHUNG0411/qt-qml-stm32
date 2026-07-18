#include "VehicleStatusViewModel.h"

VehicleStatusViewModel::VehicleStatusViewModel(QObject *parent)
    : QObject(parent),
      m_speed(0.0),
      m_rpm(0),
      m_gear("P"),
      m_isWarning(false),
      m_battery(100),
      m_range(325),
      m_temperature(57)
{
}

double VehicleStatusViewModel::speed() const
{
    return m_speed;
}

void VehicleStatusViewModel::setSpeed(double newSpeed)
{
    if (qFuzzyCompare(m_speed, newSpeed))
        return;
    m_speed = newSpeed;
    emit speedChanged();
}

int VehicleStatusViewModel::rpm() const
{
    return m_rpm;
}

void VehicleStatusViewModel::setRpm(int newRpm)
{
    if (m_rpm == newRpm)
        return;
    m_rpm = newRpm;
    emit rpmChanged();
}

QString VehicleStatusViewModel::gear() const
{
    return m_gear;
}

void VehicleStatusViewModel::setGear(const QString &newGear)
{
    if (m_gear == newGear)
        return;
    m_gear = newGear;
    emit gearChanged();
}

bool VehicleStatusViewModel::isWarning() const
{
    return m_isWarning;
}

void VehicleStatusViewModel::setIsWarning(bool newIsWarning)
{
    if (m_isWarning == newIsWarning)
        return;
    m_isWarning = newIsWarning;
    emit isWarningChanged();
}

int VehicleStatusViewModel::battery() const
{
    return m_battery;
}

void VehicleStatusViewModel::setBattery(int newBattery)
{
    if (m_battery == newBattery)
        return;
    m_battery = newBattery;
    emit batteryChanged();
}

int VehicleStatusViewModel::range() const
{
    return m_range;
}

void VehicleStatusViewModel::setRange(int newRange)
{
    if (m_range == newRange)
        return;
    m_range = newRange;
    emit rangeChanged();
}

int VehicleStatusViewModel::temperature() const
{
    return m_temperature;
}

void VehicleStatusViewModel::setTemperature(int newTemperature)
{
    if (m_temperature == newTemperature)
        return;
    m_temperature = newTemperature;
    emit temperatureChanged();
}

void VehicleStatusViewModel::updateTelemetry(double speed, int rpm, const QString &gear, bool isWarning, int battery, int range, int temperature)
{
    setSpeed(speed);
    setRpm(rpm);
    setGear(gear);
    setIsWarning(isWarning);
    setBattery(battery);
    setRange(range);
    setTemperature(temperature);
}

void VehicleStatusViewModel::updateRawTelemetry(int rpm, double vbat, int error)
{
    setRpm(rpm);
    
    double calcSpeed = static_cast<double>(rpm) * 0.03;
    setSpeed(calcSpeed);

    QString calcGear = "N";
    if (calcSpeed > 0 && calcSpeed <= 20) calcGear = "1";
    else if (calcSpeed > 20 && calcSpeed <= 40) calcGear = "2";
    else if (calcSpeed > 40 && calcSpeed <= 60) calcGear = "3";
    else if (calcSpeed > 60 && calcSpeed <= 80) calcGear = "4";
    else if (calcSpeed > 80) calcGear = "5";
    setGear(calcGear);

    bool warning = (error != 0) || (vbat < 10.5);
    setIsWarning(warning);
    
    // Default values if hardware doesn't provide them
    setBattery(100);
    setRange(325);
    setTemperature(57);
}
