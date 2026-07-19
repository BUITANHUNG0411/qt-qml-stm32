#pragma once

#include <QObject>
#include <QString>
#include <QtQml/qqmlregistration.h>

class VehicleStatusViewModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(int displaySpeed READ displaySpeed NOTIFY speedChanged)
    Q_PROPERTY(int rpm READ rpm WRITE setRpm NOTIFY rpmChanged)
    Q_PROPERTY(QString gear READ gear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(bool isWarning READ isWarning WRITE setIsWarning NOTIFY isWarningChanged)
    Q_PROPERTY(int battery READ battery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int range READ range WRITE setRange NOTIFY rangeChanged)
    Q_PROPERTY(int temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)

public:
    explicit VehicleStatusViewModel(QObject *parent = nullptr);

    double speed() const;
    int displaySpeed() const;
    void setSpeed(double newSpeed);

    int rpm() const;
    void setRpm(int newRpm);

    QString gear() const;
    void setGear(const QString &newGear);

    bool isWarning() const;
    void setIsWarning(bool newIsWarning);

    int battery() const;
    void setBattery(int newBattery);

    int range() const;
    void setRange(int newRange);

    int temperature() const;
    void setTemperature(int newTemperature);

public slots:
    void updateTelemetry(double speed, int rpm, const QString &gear, bool isWarning, int battery = 100, int range = 325, int temperature = 57);

signals:
    void speedChanged();
    void rpmChanged();
    void gearChanged();
    void isWarningChanged();
    void batteryChanged();
    void rangeChanged();
    void temperatureChanged();

private:
    double m_speed;
    int m_rpm;
    QString m_gear;
    bool m_isWarning;
    int m_battery;
    int m_range;
    int m_temperature;
};
