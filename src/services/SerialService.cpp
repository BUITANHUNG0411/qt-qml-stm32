#include "SerialService.h"
#include <QDebug>
#include <QStringList>

SerialService::SerialService(const QString &portName, QObject *parent)
    : QObject(parent),
      m_portName(portName),
      m_lastSpeed(0.0),
      m_lastRpm(0),
      m_isConnected(false)
{
    m_serial = new QSerialPort(this);
    m_serial->setPortName(m_portName);
    m_serial->setBaudRate(QSerialPort::Baud115200);
    m_serial->setDataBits(QSerialPort::Data8);
    m_serial->setParity(QSerialPort::NoParity);
    m_serial->setStopBits(QSerialPort::OneStop);
    m_serial->setFlowControl(QSerialPort::NoFlowControl);

    connect(m_serial, &QSerialPort::readyRead, this, &SerialService::handleReadyRead);
    connect(m_serial, &QSerialPort::errorOccurred, this, &SerialService::handleError);

    m_watchdogTimer = new QTimer(this);
    m_watchdogTimer->setInterval(500); // 500ms timeout means stale data
    connect(m_watchdogTimer, &QTimer::timeout, this, &SerialService::handleWatchdogTimeout);

    m_reconnectTimer = new QTimer(this);
    m_reconnectTimer->setInterval(2000); // Try reconnect every 2s if disconnected
    connect(m_reconnectTimer, &QTimer::timeout, this, &SerialService::tryReconnect);
}

SerialService::~SerialService()
{
    stopService();
}

void SerialService::startService()
{
    if (m_serial->open(QIODevice::ReadOnly)) {
        qDebug() << "Serial port" << m_portName << "opened successfully. Waiting for data...";
        m_watchdogTimer->start();
        m_reconnectTimer->stop();
    } else {
        qWarning() << "Failed to open serial port" << m_portName << "-" << m_serial->errorString();
        m_reconnectTimer->start();
        if (m_isConnected) {
            m_isConnected = false;
        }
        emit connectionStatusChanged(false);
        handleWatchdogTimeout(); // Trigger warning UI immediately
    }
}

void SerialService::stopService()
{
    if (m_serial->isOpen()) {
        m_serial->close();
    }
    m_watchdogTimer->stop();
    m_reconnectTimer->stop();
}

void SerialService::handleReadyRead()
{
    m_buffer.append(m_serial->readAll());

    // Process line-by-line
    while (m_buffer.contains('\n')) {
        int newlineIndex = m_buffer.indexOf('\n');
        QByteArray line = m_buffer.left(newlineIndex);
        m_buffer.remove(0, newlineIndex + 1);

        QString dataStr = QString::fromUtf8(line).trimmed();
        if (!dataStr.isEmpty()) {
            parseTelemetry(dataStr);
        }
    }
}

void SerialService::parseTelemetry(const QString &line)
{
    // Format: TEL,RPM,VBAT,ERROR;
    if (line.startsWith("TEL,") && line.endsWith(";")) {
        // Reset watchdog timer
        m_watchdogTimer->start();

        if (!m_isConnected) {
            m_isConnected = true;
            emit connectionStatusChanged(true);
        }

        QString payload = line.mid(4, line.length() - 5);
        QStringList parts = payload.split(",");
        
        if (parts.size() == 3) {
            bool okRpm, okVbat, okError;
            int rpm = parts[0].toInt(&okRpm);
            double vbat = parts[1].toDouble(&okVbat);
            int error = parts[2].toInt(&okError);

            if (okRpm && okVbat && okError) {
                updateCalculatedTelemetry(rpm, vbat, error);
            }
        }
    }
}

void SerialService::updateCalculatedTelemetry(int rpm, double vbat, int error)
{
    m_lastRpm = rpm;
    
    // Simulate Speed based on RPM
    m_lastSpeed = static_cast<double>(rpm) * 0.03; // Simple scalar for demo

    // Determine Gear based on Speed
    QString gear = "P";
    if (m_lastSpeed > 0 && m_lastSpeed <= 20) gear = "1";
    else if (m_lastSpeed > 20 && m_lastSpeed <= 40) gear = "2";
    else if (m_lastSpeed > 40 && m_lastSpeed <= 60) gear = "3";
    else if (m_lastSpeed > 60 && m_lastSpeed <= 80) gear = "4";
    else if (m_lastSpeed > 80) gear = "5";

    bool isWarning = (error != 0) || (vbat < 10.5); // Warning if error code or low battery

    emit telemetryUpdated(m_lastSpeed, m_lastRpm, gear, isWarning, 100, 325, 57);
}

void SerialService::handleError(QSerialPort::SerialPortError error)
{
    if (error == QSerialPort::ResourceError) {
        qWarning() << "Serial port resource error, disconnecting...";
        stopService();
        m_reconnectTimer->start();
    }
}

void SerialService::handleWatchdogTimeout()
{
    // Stale data or disconnected
    qWarning() << "Watchdog timeout! No telemetry data received.";
    if (m_isConnected) {
        m_isConnected = false;
        emit connectionStatusChanged(false);
    }
    m_lastSpeed = 0.0;
    m_lastRpm = 0;
    emit telemetryUpdated(m_lastSpeed, m_lastRpm, "P", true, 100, 325, 57);
}

void SerialService::tryReconnect()
{
    qDebug() << "Attempting to reconnect to" << m_portName << "...";
    if (m_serial->open(QIODevice::ReadOnly)) {
        qDebug() << "Reconnected successfully.";
        m_watchdogTimer->start();
        m_reconnectTimer->stop();
    }
}
