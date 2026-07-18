#pragma once

#include <QAbstractListModel>
#include <QThread>
#include <QMediaPlayer>
#include <QAudioOutput>
#include "../services/MusicScanner.h"

class MusicPlayerViewModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(float progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool isScanning READ isScanning NOTIFY isScanningChanged)

public:
    enum SongRoles {
        TitleRole = Qt::UserRole + 1,
        ArtistRole,
        FilePathRole,
        Color1Role,
        Color2Role
    };

    explicit MusicPlayerViewModel(QObject *parent = nullptr);
    ~MusicPlayerViewModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentIndex() const;
    void setCurrentIndex(int index);

    bool isPlaying() const;
    float progress() const;
    bool isScanning() const;

public slots:
    void play(int index = -1);
    void pause();
    void togglePlayPause();
    void next();
    void prev();
    void scanLibrary();

private slots:
    void onSongFound(const SongData& song);
    void onScanFinished();
    void onPositionChanged(qint64 position);
    void onDurationChanged(qint64 duration);

signals:
    void currentIndexChanged();
    void isPlayingChanged();
    void progressChanged();
    void isScanningChanged();
    void requestScan(const QString& path);

private:
    QList<SongData> m_songs;
    int m_currentIndex = -1;
    bool m_isScanning = false;
    float m_progress = 0.0f;

    QThread m_scannerThread;
    MusicScanner* m_scanner;

    QMediaPlayer* m_player;
    QAudioOutput* m_audioOutput;
};
