#include "MusicScanner.h"
#include <QDirIterator>
#include <QFileInfo>
#include <QThread>
#include <QHash>
#include <QFile>
#include <QByteArray>

static QString extractCoverArtBase64(const QString& filePath) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) return "";

    char header[10];
    if (file.read(header, 10) != 10) return "";
    if (qstrncmp(header, "ID3", 3) != 0) return "";

    int version = header[3];
    int tagSize = ((header[6] & 0x7F) << 21) | ((header[7] & 0x7F) << 14) | ((header[8] & 0x7F) << 7) | (header[9] & 0x7F);

    bool hasExtendedHeader = header[5] & 0x40;
    if (hasExtendedHeader) {
        char extHeader[4];
        if (file.read(extHeader, 4) != 4) return "";
        int extSize = ((extHeader[0] & 0x7F) << 21) | ((extHeader[1] & 0x7F) << 14) | ((extHeader[2] & 0x7F) << 7) | (extHeader[3] & 0x7F);
        file.seek(file.pos() + extSize - 4);
    }

    qint64 startPos = file.pos();
    while (file.pos() < startPos + tagSize) {
        char frameHeader[10];
        if (file.read(frameHeader, 10) != 10) break;
        if (frameHeader[0] == 0) break; 

        QString frameId = QString::fromLatin1(frameHeader, 4);
        int frameSize = 0;
        if (version == 3) {
            frameSize = (static_cast<unsigned char>(frameHeader[4]) << 24) |
                        (static_cast<unsigned char>(frameHeader[5]) << 16) |
                        (static_cast<unsigned char>(frameHeader[6]) << 8) |
                        (static_cast<unsigned char>(frameHeader[7]));
        } else if (version == 4) {
            frameSize = ((frameHeader[4] & 0x7F) << 21) | ((frameHeader[5] & 0x7F) << 14) | ((frameHeader[6] & 0x7F) << 7) | (frameHeader[7] & 0x7F);
        } else {
            break; 
        }

        if (frameId == "APIC") {
            QByteArray frameData = file.read(frameSize);
            int pos = 1;
            while (pos < frameData.size() && frameData[pos] != 0) pos++;
            pos++; // skip null
            pos++; // skip picture type
            
            char encoding = frameData[0];
            if (encoding == 0 || encoding == 3) {
                while (pos < frameData.size() && frameData[pos] != 0) pos++;
                pos++;
            } else if (encoding == 1 || encoding == 2) {
                while (pos < frameData.size() - 1 && (frameData[pos] != 0 || frameData[pos+1] != 0)) pos += 2;
                pos += 2;
            }
            
            if (pos < frameData.size()) {
                QByteArray imgData = frameData.mid(pos);
                return "data:image/jpeg;base64," + QString::fromLatin1(imgData.toBase64());
            }
        } else {
            file.seek(file.pos() + frameSize);
        }
    }
    return "";
}

MusicScanner::MusicScanner(QObject* parent) : QObject(parent) {}

void MusicScanner::scanLibrary(const QString& path) {
    QDirIterator it(path, QStringList() << "*.mp3" << "*.flac" << "*.wav", QDir::Files, QDirIterator::Subdirectories);
    
    while (it.hasNext() && !QThread::currentThread()->isInterruptionRequested()) {
        QString filePath = it.next();
        QFileInfo fi(filePath);
        
        SongData song;
        song.filePath = filePath;
        
        // Mock metadata extraction from filename to avoid heavy dependencies
        QString baseName = fi.completeBaseName();
        QStringList parts = baseName.split("-");
        if (parts.size() >= 2) {
            song.artist = parts[0].trimmed();
            song.title = parts[1].trimmed();
        } else {
            song.artist = "Unknown Artist";
            song.title = baseName;
        }

        // Generate consistent mock colors based on filename hash to maintain Neon aesthetic
        uint hash = qHash(baseName);
        song.color1 = QString("#%1").arg(hash & 0xFFFFFF, 6, 16, QChar('0'));
        song.color2 = QString("#%1").arg((hash >> 8) & 0xFFFFFF, 6, 16, QChar('0'));

        song.coverArt = extractCoverArtBase64(filePath);

        emit songFound(song);
        QThread::msleep(10); // Artificial slight delay to prevent UI flooding
    }
    emit scanFinished();
}
