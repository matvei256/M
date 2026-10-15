import 'package:flutter/material.dart';

void main() {
  runApp(const DotifyMurglarApp());
}

// --- ЦВЕТОВАЯ ПАЛИТРА DOTIFY / SPOTIFY ---
class AppColors {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF181818);
  static const Color surfaceElevated = Color(0xFF282828);
  static const Color accent = Color(0xFF1DB954);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
}

// --- МОДЕЛИ ДАННЫХ (ФУНКЦИОНАЛ MURGLAR) ---
enum MusicSource { vk, yandex, deezer, soundcloud }

class Track {
  final String id;
  final String title;
  final String artist;
  final String duration;
  final String bitrate;
  final MusicSource source;
  final Color coverColor;
  bool isDownloaded;
  bool isDownloading;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.duration,
    this.bitrate = '320 kbps',
    required this.source,
    required this.coverColor,
    this.isDownloaded = false,
    this.isDownloading = false,
  });
}

class DotifyMurglarApp extends StatelessWidget {
  const DotifyMurglarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Murgify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.accent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 0;
  MusicSource _selectedSource = MusicSource.vk;
  Track? _currentTrack;
  bool _isPlaying = false;

  // Тестовая база треков из разных сервисов
  final List<Track> _tracks = [
    Track(
      id: '1',
      title: 'KERAUNOS',
      artist: 'PlayaPhonk',
      duration: '2:14',
      bitrate: 'FLAC • 1040 kbps',
      source: MusicSource.vk,
      coverColor: Colors.deepPurple,
    ),
    Track(
      id: '2',
      title: 'Close Eyes',
      artist: 'DVRST',
      duration: '2:12',
      bitrate: 'MP3 • 320 kbps',
      source: MusicSource.yandex,
      coverColor: Colors.teal,
      isDownloaded: true,
    ),
    Track(
      id: '3',
      title: 'Murder In My Mind',
      artist: 'Kordhell',
      duration: '2:25',
      bitrate: 'FLAC • 980 kbps',
      source: MusicSource.deezer,
      coverColor: Colors.redAccent,
    ),
    Track(
      id: '4',
      title: 'Shadow',
      artist: 'ONIMXRU, SMITHMANE',
      duration: '2:08',
      bitrate: 'MP3 • 320 kbps',
      source: MusicSource.soundcloud,
      coverColor: Colors.indigo,
    ),
  ];

  // Имитация скачивания трека через менеджер загрузок Murglar
  Future<void> _downloadTrack(Track track) async {
    if (track.isDownloaded || track.isDownloading) return;

    setState(() => track.isDownloading = true);

    // Здесь в реальном проекте вызывается Dio().download(url, savePath)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      track.isDownloading = false;
      track.isDownloaded = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceElevated,
          content: Text(
            'Трек "${track.title}" сохранен в память (${track.bitrate})',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }
  }

  String _getSourceName(MusicSource source) {
    switch (source) {
      case MusicSource.vk:
        return 'VK Музыка';
      case MusicSource.yandex:
        return 'Я.Музыка';
      case MusicSource.deezer:
        return 'Deezer';
      case MusicSource.soundcloud:
        return 'SoundCloud';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Основной контент с градиентной подложкой сверху (как в Spotify/Dotify)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E3A2F), // Тёмно-изумрудный отблеск сверху
                  AppColors.background,
                  AppColors.background,
                ],
                stops: [0.0, 0.35, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSourceSelector(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Популярное в выбранном источнике',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Expanded(child: _buildTrackList()),
                ],
              ),
            ),
          ),

          // Плавающий мини-плеер в стиле Spotify
          if (_currentTrack != null)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: _buildMiniPlayer(_currentTrack!),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- ВЕРХНЯЯ ПАНЕЛЬ ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Добрый вечер',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.download_done_rounded),
                tooltip: 'Очередь загрузок (Murglar)',
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Токены и прокси',
                onPressed: () => _showTokenSettings(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ПЕРЕКЛЮЧАТЕЛЬ ПРОВАЙДЕРОВ (ФИШКА MURGLAR В ДИЗАЙНЕ PILLS ОТ SPOTIFY) ---
  Widget _buildSourceSelector() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: MusicSource.values.map((source) {
          final isSelected = _selectedSource == source;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getSourceName(source)),
              selected: isSelected,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.surfaceElevated,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide.none,
              ),
              onSelected: (_) => setState(() => _selectedSource = source),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- СПИСОК ТРЕКОВ ---
  Widget _buildTrackList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final track = _tracks[index];
        final isCurrent = _currentTrack?.id == track.id;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () {
            setState(() {
              _currentTrack = track;
              _isPlaying = true;
            });
          },
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: track.coverColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.music_note, color: Colors.white70),
          ),
          title: Text(
            track.title,
            style: TextStyle(
              color: isCurrent ? AppColors.accent : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              // Иконка скачанного трека (как в Spotify)
              if (track.isDownloaded)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.arrow_circle_down_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                ),
              Expanded(
                child: Text(
                  '${track.artist} • ${track.bitrate}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Кнопка прямого скачивания из Murglar
              if (track.isDownloading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.accent,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    track.isDownloaded ? Icons.check_circle : Icons.download_outlined,
                    color: track.isDownloaded ? AppColors.accent : AppColors.textSecondary,
                  ),
                  onPressed: () => _downloadTrack(track),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  // --- МИНИ-ПЛЕЕР DOTIFY ---
  Widget _buildMiniPlayer(Track track) {
    return GestureDetector(
      onTap: () => _openFullPlayer(context, track),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: track.coverColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.music_note, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${track.artist} (${_getSourceName(track.source)})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                  ],
                ),
              ),
            ),
            // Тонкая полоска прогресса внизу мини-плеера
            LinearProgressIndicator(
              value: 0.35,
              minHeight: 2,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }

  // --- ПОЛНОЭКРАННЫЙ ПЛЕЕР (ДИЗАЙН DOTIFY + ТЕХ. ИНФО MURGLAR) ---
  void _openFullPlayer(BuildContext context, Track track) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [track.coverColor.withOpacity(0.8), AppColors.background],
              stops: const [0.0, 0.7],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    children: [
                      const Text(
                        'ИГРАЕТ ИЗ ИСТОЧНИКА',
                        style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: AppColors.textSecondary),
                      ),
                      Text(
                        _getSourceName(track.source),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_for_offline_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadTrack(track);
                    },
                  ),
                ],
              ),
              const Spacer(),
              // Большая обложка
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: track.coverColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 24)],
                ),
                child: const Icon(Icons.album, size: 120, color: Colors.white54),
              ),
              const Spacer(),
              // Название и битрейт
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.artist,
                        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      track.bitrate,
                      style: const TextStyle(fontSize: 11, color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.textPrimary,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: AppColors.textPrimary,
                  trackHeight: 3,
                ),
                child: Slider(value: 0.35, onChanged: (v) {}),
              ),
              // Кнопки управления
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.shuffle, color: AppColors.accent),
                  const Icon(Icons.skip_previous_rounded, size: 42),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause_rounded, color: Colors.black, size: 38),
                  ),
                  const Icon(Icons.skip_next_rounded, size: 42),
                  const Icon(Icons.repeat, color: AppColors.textSecondary),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // --- ОКНО АВТОРИЗАЦИИ ПО ТОКЕНАМ (КАК В MURGLAR) ---
  void _showTokenSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Подключение сервисов (Murglar Core)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTokenTile('VK Музыка', 'Авторизован через Kate Mobile Token', true),
              _buildTokenTile('Яндекс.Музыка', 'OAuth-токен активен (HQ / FLAC)', true),
              _buildTokenTile('Deezer', 'Ввести ARL cookie для загрузки FLAC', false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTokenTile(String title, String subtitle, bool c
