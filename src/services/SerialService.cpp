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
    if (m_serial->open(QIODevice::ReadWrite)) {
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

void SerialService::sendCommand(const QString &command)
{
    if (m_serial->isOpen() && m_serial->isWritable()) {
        m_serial->write((command + "\n").toUtf8());
    }
}

void SerialService::emergencyStop()
{
    sendCommand("STOP;");
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
    // Format: TEL,RPM,VBAT,ERROR;CHECKSUM
    if (line.startsWith("TEL,") && line.contains(";")) {
        int semiIndex = line.lastIndexOf(';');
        QString payload = line.mid(4, semiIndex - 4);
        QString checksumStr = line.mid(semiIndex + 1);
        
        QStringList parts = payload.split(",");
        if (parts.size() == 3) {
            bool okRpm, okVbat, okError;
            int rpm = parts[0].toInt(&okRpm);
            double vbat = parts[1].toDouble(&okVbat);
            int error = parts[2].toInt(&okError);

            if (okRpm && okVbat && okError) {
                // Verify checksum
                int expectedChecksum = (rpm + static_cast<int>(vbat) + error) % 256;
                if (checksumStr.isEmpty() || checksumStr.toInt() == expectedChecksum) {
                    m_watchdogTimer->start();
                    if (!m_isConnected) {
                        m_isConnected = true;
                        emit connectionStatusChanged(true);
                    }
                    m_lastRpm = rpm;
                    emit rawTelemetryUpdated(rpm, vbat, error);
                }
            }
        }
    }
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
    emit rawTelemetryUpdated(0, 0.0, 1); // 1 = error/stale data
    
    // Auto-reconnect
    if (!m_reconnectTimer->isActive()) {
        m_reconnectTimer->start();
    }
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
