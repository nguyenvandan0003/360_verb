import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/verb.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/verb_providers.dart';

class SpeedQuizScreen extends ConsumerStatefulWidget {
  const SpeedQuizScreen({super.key});

  @override
  ConsumerState<SpeedQuizScreen> createState() => _SpeedQuizScreenState();
}

class _SpeedQuizScreenState extends ConsumerState<SpeedQuizScreen> {
  Timer? _timer;
  int _secondsLeft = 60;
  int _score = 0;
  int _combo = 0;
  int _currentVerbIndex = 0;
  bool _isGameOver = false;
  late bool _askForV2; // true = ask V2, false = ask V3
  List<String> _options = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isGameOver = true);
        ref.read(gamificationProvider.notifier).addXp(_score);
      }
    });
  }

  void _generateOptions(Verb current, List<Verb> all) {
    _askForV2 = _random.nextBool();
    final correctAnswer = _askForV2 ? current.v2 : current.v3;

    final wrongAnswers = <String>{};
    while (wrongAnswers.length < 3) {
      final randVerb = all[_random.nextInt(all.length)];
      final candidate = _askForV2 ? randVerb.v2 : randVerb.v3;
      if (candidate != correctAnswer) {
        wrongAnswers.add(candidate);
      }
    }

    _options = [correctAnswer, ...wrongAnswers]..shuffle();
  }

  void _chooseOption(String choice, Verb current, List<Verb> all) {
    if (_isGameOver) return;
    final correctAnswer = _askForV2 ? current.v2 : current.v3;

    if (choice == correctAnswer) {
      _combo++;
      _score += 10 + (_combo > 3 ? 5 : 0);
    } else {
      _combo = 0;
    }

    setState(() {
      _currentVerbIndex = (_currentVerbIndex + 1) % all.length;
      _generateOptions(all[_currentVerbIndex], all);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allVerbsAsync = ref.watch(allVerbsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản xạ 60 Giây'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _secondsLeft <= 10 ? Colors.red.shade100 : Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: _secondsLeft <= 10 ? Colors.red : AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  '$_secondsLeft s',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _secondsLeft <= 10 ? Colors.red : AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: allVerbsAsync.when(
        data: (verbs) {
          if (verbs.isEmpty) return const Center(child: Text('Không có dữ liệu'));

          if (_options.isEmpty) {
            _generateOptions(verbs[_currentVerbIndex], verbs);
          }

          if (_isGameOver) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏁', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    const Text('Hết giờ!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Tổng điểm của bạn: $_score điểm', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('+ $_score XP đã được cộng vào tài khoản!', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _secondsLeft = 60;
                          _score = 0;
                          _combo = 0;
                          _isGameOver = false;
                          _options = [];
                        });
                        _startTimer();
                      },
                      child: const Text('Chơi lại', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentVerb = verbs[_currentVerbIndex];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Điểm: $_score', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_combo > 1)
                      Text('🔥 Combo x$_combo', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ],
                ),
                const SizedBox(height: 24),

                // Question Box
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          _askForV2 ? 'Dạng Quá khứ (V2) của:' : 'Dạng Phân từ (V3) của:',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentVerb.v1,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '(${currentVerb.meaningVi})',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4 Choices
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: _options.map((opt) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E293B),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onPressed: () => _chooseOption(opt, currentVerb, verbs),
                        child: Text(
                          opt,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
