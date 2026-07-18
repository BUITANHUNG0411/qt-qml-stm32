#include "MusicPlayerViewModel.h"
#include <QStandardPaths>
#include <QDebug>
#include <QUrl>

MusicPlayerViewModel::MusicPlayerViewModel(QObject *parent)
    : QAbstractListModel(parent), m_scanner(new MusicScanner())
{
    // Setup Audio Player
    m_player = new QMediaPlayer(this);
    m_audioOutput = new QAudioOutput(this);
    m_player->setAudioOutput(m_audioOutput);

    connect(m_player, &QMediaPlayer::playingChanged, this, &MusicPlayerViewModel::isPlayingChanged);
    connect(m_player, &QMediaPlayer::positionChanged, this, &MusicPlayerViewModel::onPositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &MusicPlayerViewModel::onDurationChanged);

    // Setup Scanner Thread
    m_scanner->moveToThread(&m_scannerThread);

    connect(this, &MusicPlayerViewModel::requestScan, m_scanner, &MusicScanner::scanLibrary);
    connect(m_scanner, &MusicScanner::songFound, this, &MusicPlayerViewModel::onSongFound);
    connect(m_scanner, &MusicScanner::scanFinished, this, &MusicPlayerViewModel::onScanFinished);

    m_scannerThread.start();
}

MusicPlayerViewModel::~MusicPlayerViewModel()
{
    m_scannerThread.requestInterruption();
    m_scanner->deleteLater();
    m_scannerThread.quit();
    m_scannerThread.wait();
}

int MusicPlayerViewModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_songs.count();
}

QVariant MusicPlayerViewModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_songs.count())
        return QVariant();

    const SongData &song = m_songs[index.row()];
    switch (role) {
        case TitleRole: return song.title;
        case ArtistRole: return song.artist;
        case FilePathRole: return song.filePath;
        case Color1Role: return song.color1;
        case Color2Role: return song.color2;
    }
    return QVariant();
}

QHash<int, QByteArray> MusicPlayerViewModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[ArtistRole] = "artist";
    roles[FilePathRole] = "filePath";
    roles[Color1Role] = "color1";
    roles[Color2Role] = "color2";
    return roles;
}

int MusicPlayerViewModel::currentIndex() const
{
    return m_currentIndex;
}

void MusicPlayerViewModel::setCurrentIndex(int index)
{
    if (m_currentIndex == index) return;
    if (index >= 0 && index < m_songs.count()) {
        m_currentIndex = index;
        emit currentIndexChanged();
        
        // Reset progress when changing track
        m_progress = 0.0f;
        emit progressChanged();
        
        m_player->setSource(QUrl::fromLocalFile(m_songs[m_currentIndex].filePath));
        m_player->play();
    }
}

bool MusicPlayerViewModel::isPlaying() const
{
    return m_player->isPlaying();
}

float MusicPlayerViewModel::progress() const
{
    return m_progress;
}

bool MusicPlayerViewModel::isScanning() const
{
    return m_isScanning;
}

void MusicPlayerViewModel::play(int index)
{
    if (index != -1 && index != m_currentIndex) {
        setCurrentIndex(index);
    } else if (m_currentIndex >= 0 && m_currentIndex < m_songs.count()) {
        m_player->play();
    }
}

void MusicPlayerViewModel::pause()
{
    m_player->pause();
}

void MusicPlayerViewModel::togglePlayPause()
{
    if (m_player->isPlaying()) {
        m_player->pause();
    } else {
        if (m_currentIndex >= 0 && m_currentIndex < m_songs.count()) {
            m_player->play();
        } else if (!m_songs.isEmpty()) {
            setCurrentIndex(0);
        }
    }
}

void MusicPlayerViewModel::next()
{
    if (m_songs.isEmpty()) return;
    int nextIdx = (m_currentIndex + 1) % m_songs.count();
    setCurrentIndex(nextIdx);
}

void MusicPlayerViewModel::prev()
{
    if (m_songs.isEmpty()) return;
    int prevIdx = (m_currentIndex - 1 < 0) ? m_songs.count() - 1 : m_currentIndex - 1;
    setCurrentIndex(prevIdx);
}

void MusicPlayerViewModel::scanLibrary()
{
    if (m_isScanning) return;
    
    beginResetModel();
    m_songs.clear();
    m_currentIndex = -1;
    m_player->stop();
    endResetModel();
    emit currentIndexChanged();

    m_isScanning = true;
    emit isScanningChanged();
    
    QString path = QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    emit requestScan(path);
}

void MusicPlayerViewModel::onSongFound(const SongData& song)
{
    beginInsertRows(QModelIndex(), m_songs.count(), m_songs.count());
    m_songs.append(song);
    endInsertRows();

    // Select the first song automatically and start playing
    if (m_songs.count() == 1) {
        m_currentIndex = 0;
        emit currentIndexChanged();
        m_progress = 0.0f;
        emit progressChanged();
        m_player->setSource(QUrl::fromLocalFile(m_songs[0].filePath));
        m_player->play();
    }
}

void MusicPlayerViewModel::onScanFinished()
{
    m_isScanning = false;
    emit isScanningChanged();
}

void MusicPlayerViewModel::onPositionChanged(qint64 position)
{
    if (m_player->duration() > 0) {
        m_progress = static_cast<float>(position) / m_player->duration();
        emit progressChanged();
    }
}

void MusicPlayerViewModel::onDurationChanged(qint64 duration)
{
    if (duration > 0) {
        m_progress = static_cast<float>(m_player->position()) / duration;
        emit progressChanged();
    }
}
