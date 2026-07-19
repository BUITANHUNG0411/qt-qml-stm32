#pragma once

#include <QObject>
#include <QString>

struct SongData {
    QString title;
    QString artist;
    QString filePath;
    QString color1;
    QString color2;
    QString coverArt;
};

class MusicScanner : public QObject
{
    Q_OBJECT
public:
    explicit MusicScanner(QObject* parent = nullptr);

public slots:
    void scanLibrary(const QString& path);

signals:
    void songFound(const SongData& song);
    void scanFinished();
};
