import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RecorderController _recorderController = RecorderController();
  late Directory _appDirectory;
  String? _recordedPath;
  String? _pickedAudioPath;
  bool _isRecording = false;
  bool _recordingComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initDirectoryAndRecorder();
  }

  Future<void> _initDirectoryAndRecorder() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _recordedPath = "${_appDirectory.path}/recording.m4a";
    _initRecorderSettings();
    setState(() => _loading = false);
  }

  void _initRecorderSettings() {
    _recorderController
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        _recorderController.reset();
        _recordedPath = await _recorderController.stop(false);
        if (_recordedPath != null) {
          _recordingComplete = true;
          debugPrint("Recording saved at $_recordedPath");
        }
      } else {
        await _recorderController.record(path: _recordedPath);
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    } finally {
      if (_recorderController.hasPermission) {
        setState(() => _isRecording = !_isRecording);
      }
    }
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      _pickedAudioPath = result.files.single.path!;
      setState(() {});
    }
  }

  void _refreshWaveform() {
    if (_isRecording) _recorderController.refresh();
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF252331),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF252331),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252331),
        elevation: 1,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Simform', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (_, index) => WaveBubble(
                  index: index + 1,
                  isSender: index.isOdd,
                  width: MediaQuery.of(context).size.width / 2,
                  appDirectory: _appDirectory,
                ),
              ),
            ),

            // Newly recorded waveform
            if (_recordingComplete && _recordedPath != null)
              WaveBubble(
                path: _recordedPath,
                isSender: true,
                appDirectory: _appDirectory,
              ),

            // Picked audio waveform
            if (_pickedAudioPath != null)
              WaveBubble(
                path: _pickedAudioPath,
                isSender: true,
                appDirectory: _appDirectory,
              ),

            SafeArea(
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isRecording
                        ? AudioWaveforms(
                            enableGesture: true,
                            size: Size(
                              MediaQuery.of(context).size.width / 2,
                              50,
                            ),
                            recorderController: _recorderController,
                            waveStyle: const WaveStyle(
                              waveColor: Colors.white,
                              extendWaveform: true,
                              showMiddleLine: false,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: const Color(0xFF1E1B26),
                            ),
                            padding: const EdgeInsets.only(left: 18),
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                          )
                        : _buildTextInput(),
                  ),
                  IconButton(
                    onPressed: _refreshWaveform,
                    icon: Icon(
                      _isRecording ? Icons.refresh : Icons.send,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: _toggleRecording,
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.7,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B26),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.only(left: 18),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          hintText: "Type Something...",
          hintStyle: const TextStyle(color: Colors.white54),
          contentPadding: const EdgeInsets.only(top: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: _pickAudioFile,
            icon: Icon(Icons.adaptive.share, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class WaveBubble extends StatefulWidget {
  final String? path;
  final bool isSender;
  final int? index;
  final double? width;
  final Directory appDirectory;

  const WaveBubble({
    super.key,
    this.path,
    this.isSender = true,
    this.index,
    this.width,
    required this.appDirectory,
  });

  @override
  State<WaveBubble> createState() => _WaveBubbleState();
}

class _WaveBubbleState extends State<WaveBubble> {
  late final PlayerController _playerController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();

    if (widget.path != null) {
      _preparePlayer(widget.path!);
    } else {
      // Load dummy audio (optional fallback)
      final dummyPath =
          "${widget.appDirectory.path}/dummy_audio_${widget.index}.m4a";
      if (File(dummyPath).existsSync()) {
        _preparePlayer(dummyPath);
      }
    }
  }

  void _preparePlayer(String path) {
    _playerController.preparePlayer(path: path);
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
      setState(() => _isPlaying = false);
    }

    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = widget.isSender
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final bubbleColor = widget.isSender
        ? Colors.blueAccent
        : Colors.grey.shade800;

    return Align(
      alignment: alignment,
      child: Container(
        width: widget.width ?? MediaQuery.of(context).size.width * 0.6,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _togglePlayPause,
            ),
            Expanded(
              child: AudioFileWaveforms(
                size: const Size(double.infinity, 40),
                playerController: _playerController,
                enableSeekGesture: true,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: Colors.white60,
                  liveWaveColor: Colors.white,
                  spacing: 5,
                  waveThickness: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
