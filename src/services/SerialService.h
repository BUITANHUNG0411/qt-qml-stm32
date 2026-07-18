#pragma once

#include <QObject>
#include <QSerialPort>
#include <QTimer>
#include <QString>
#include <QByteArray>

class SerialService : public QObject
{
    Q_OBJECT

public:
    explicit SerialService(const QString &portName = "/dev/ttyUSB0", QObject *parent = nullptr);
    ~SerialService();

    void startService();
    void stopService();
    void sendCommand(const QString &command);
    void emergencyStop();

signals:
    void rawTelemetryUpdated(int rpm, double vbat, int error);
    void connectionStatusChanged(bool isConnected);

private slots:
    void handleReadyRead();
    void handleError(QSerialPort::SerialPortError error);
    void handleWatchdogTimeout();
    void tryReconnect();

private:
    void parseTelemetry(const QString &line);

    QSerialPort *m_serial;
    QTimer *m_watchdogTimer;
    QTimer *m_reconnectTimer;
    
    QString m_portName;
    QByteArray m_buffer;

    // Cache to prevent jumpy UI on stale data
    double m_lastSpeed;
    int m_lastRpm;
    bool m_isConnected;
};
