import 'dart:ui';
import 'dart:async';
import 'package:ai_interview_coach/models/interview_message.dart';
import 'package:ai_interview_coach/services/backend_service.dart';
import 'package:ai_interview_coach/views/interview_summary_screen.dart';
import 'package:ai_interview_coach/widgets/sound_wave_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/agora_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InterviewRoomScreen extends StatefulWidget{
  final String selectedRole;
  final String selectedDifficulty;

  const InterviewRoomScreen({
    super.key,
    required this.selectedRole,
    required this.selectedDifficulty
  });

  @override
  State<InterviewRoomScreen> createState() => _InterviewRoomScreenState();
}

class _InterviewRoomScreenState extends State<InterviewRoomScreen> {
  final AgoraService _agoraService = AgoraService();
  bool _isMuted = false;
  bool _isAiSpeaking = true;
  Timer? _silenceTimer;

  String _currentQuestion = "Connecting to AI Backend...";
  bool _isLoading = true;

  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _lastWords = "";

  final List<InterviewMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTtsEngine();
    _initInterviewSession();
  }

  void _initTtsEngine() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      setState(() {
        _isAiSpeaking = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isAiSpeaking = false;
        _lastWords = "";
      });

      Future.delayed(const Duration(seconds: 1), () {
        _startListening();
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isAiSpeaking = false;
      });
    });
  }

  void _startListening() async {
    if (_isListening) {
      await _speech.stop();
    }

    await _agoraService.muteMicrophone(true);

    bool available = await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (error) => print('STT Error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
        _lastWords = "";
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
          });

          _silenceTimer?.cancel();
          _silenceTimer = Timer(const Duration(seconds: 7), () {
            if (_isListening && _lastWords.isNotEmpty) {
              _silenceTimer?.cancel();
              _stopListeningAndSubmit();
            }
          });
        },

        listenFor: const Duration(seconds: 120),
        pauseFor: const Duration(seconds: 5),
        localeId: "en_US",
      );
    }
  }

  void _stopListeningAndSubmit() {
    _silenceTimer?.cancel();
    _speech.stop();

    _agoraService.muteMicrophone(_isMuted);

    setState(() => _isListening = false);

    String finalAnswer = _lastWords.isNotEmpty ? _lastWords : "Explained the concepts clearly.";
    _submitAnswerAndGetNext(finalAnswer);
    _lastWords = "";
  }


  Future<void> speakQuestion(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _initInterviewSession() async {
    try {
      await _agoraService.joinChannel();

      String question = await BackendService.fetchNextQuestion(
          widget.selectedRole,
          widget.selectedDifficulty,
          "Starting the mock interview session"
      );

      setState(() {
        _currentQuestion = question;
        _isLoading = false;

        _messages.add(InterviewMessage(
            sender: 'AI Interview',
            text: question,
            timestamp: DateTime.now()
        ));

        speakQuestion(question);
      });

      speakQuestion(question);
    } catch (e) {
      setState(() {
        _currentQuestion = "What are the core architectural components of ${widget.selectedRole}?";
        _isLoading = false;
        _messages.add(InterviewMessage(
            sender: 'AI Interview',
            text: _currentQuestion,
            timestamp: DateTime.now()
        ));
      });
      await speakQuestion(_currentQuestion);
    }
  }


  Future<void> _submitAnswerAndGetNext(String candidateAnswer) async {
    _silenceTimer?.cancel();
    _speech.stop();

    setState(() {
      _messages.add(InterviewMessage(
          sender: 'You',
          text: candidateAnswer,
          timestamp: DateTime.now(),
      ));
      _isLoading = true;
      _isListening = false;
      _currentQuestion = "Analyzing answer& fetching next question...";
    });

    try {
      String nextQuestion = await BackendService.fetchNextQuestion(
          widget.selectedRole,
          widget.selectedDifficulty,
          candidateAnswer,
      );

      setState(() {
        _currentQuestion = nextQuestion;
        _isLoading = false;
        _lastWords = "";

        _messages.add(InterviewMessage(
            sender: 'AI Interview',
            text: nextQuestion,
            timestamp: DateTime.now(),
        ));
      });

      speakQuestion(nextQuestion);
    } catch (e) {
      setState(() {
        _currentQuestion = "Could not fetch next question. Please try again.";
        _isLoading = false;
      });
    }
  }

  void _showTranscriptSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E2C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Transcript Log',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isAi = msg.sender == 'AI Interview' || msg.sender == 'AI Interviewer';
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isAi ? const Color(0xFF2A293D) : const Color(0xFF6C63FF).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAi ? Colors.transparent : const Color(0xFF6C63FF).withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.sender,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isAi ? const Color(0xFF6C63FF) : Colors.greenAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                    ),
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _flutterTts.stop();
    _speech.stop();
    _agoraService.leaveChannel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        title: Text(
          'Agora AI Interview',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              _agoraService.leaveChannel();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: _showTranscriptSheet,
              icon: const Icon(Icons.history_rounded, color: Color(0xFF6C63FF), size: 28),
            tooltip: 'View Transcript',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF6C63FF)),
              ),
              child: Text(
                'Role: ${widget.selectedRole}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Column(
              children: [
                SoundWaveWidget(isSpeaking: _isAiSpeaking || _isListening),
                const SizedBox(height: 24),
                Text(
                  _isAiSpeaking
                      ? 'Agora AI Interviewer is asking...'
                      : (_isListening ? 'Listening to your answer...' : 'Processing...'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$_currentQuestion"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (_isListening && _lastWords.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'You said: "$_lastWords"',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'muteBtn',
                    backgroundColor: _isMuted ? Colors.red : const Color(0xFF1E1E2C),
                    onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                    _agoraService.muteMicrophone(_isMuted);
                    },
                  child: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),

                if (!_isAiSpeaking && !_isLoading)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => _stopListeningAndSubmit(),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      'Next Question',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(width: 16),

                FloatingActionButton.small(
                  heroTag: 'endCallBtn',
                    backgroundColor: Colors.redAccent,
                    onPressed: () async {
                        _agoraService.leaveChannel();
                        _flutterTts.stop();
                        _speech.stop();

                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                            ),
                        );

                        String fullTranscript = _messages.map((m) => "${m.sender}: ${m.text}").join("\n");

                        var summary = await BackendService.fetchInterviewSummary(
                          widget.selectedRole,
                          fullTranscript.isNotEmpty ? fullTranscript : "Candidate completed the interview for ${widget.selectedRole}",
                        );

                        Navigator.pop(context);

                        if (summary != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InterviewSummaryScreen(summary: summary),
                            ),
                          );
                        }else {
                          Navigator.pop(context);
                        }
                    },
                  child: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}