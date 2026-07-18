#include "MusicScanner.h"
#include <QDirIterator>
#include <QFileInfo>
#include <QThread>
#include <QHash>

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

        emit songFound(song);
        QThread::msleep(10); // Artificial slight delay to prevent UI flooding
    }
    emit scanFinished();
}
