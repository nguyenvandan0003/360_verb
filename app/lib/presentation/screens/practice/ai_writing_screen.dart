import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/ai_feedback.dart';
import '../../../data/models/verb.dart';
import '../../../logic/ai_providers.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/gamification_providers.dart';
import '../../../logic/iap_provider.dart';
import '../../../logic/tts_provider.dart';
import '../../../logic/verb_providers.dart';
import '../../widgets/auth_modal.dart';
import '../../widgets/paywall_modal.dart';

enum ChatSender { ai, user }

class ChatMessage {
  final String id;
  final ChatSender sender;
  final String text;
  final DateTime timestamp;
  final Verb? verb;
  final String? targetForm;
  final AiEvaluation? evaluation;
  final bool isPrompt;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.verb,
    this.targetForm,
    this.evaluation,
    this.isPrompt = false,
  });
}

class AiWritingScreen extends ConsumerStatefulWidget {
  final Verb? initialVerb;

  const AiWritingScreen({super.key, this.initialVerb});

  @override
  ConsumerState<AiWritingScreen> createState() => _AiWritingScreenState();
}

class _AiWritingScreenState extends ConsumerState<AiWritingScreen> {
  late Verb? _selectedVerb;
  String _targetForm = 'V2';
  final _sentenceController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _hasInitializedChat = false;
  bool _isAiTyping = false;

  final List<String> _promptScenarios = [
    'kể về việc bạn đã làm vào ngày hôm qua',
    'kể về một chuyến du lịch đáng nhớ trong quá khứ',
    'nói về một kỷ niệm thời thơ ấu của bạn',
    'kể về một trải nghiệm bạn vừa hoàn thành gần đây',
    'miêu tả một tình huống xảy ra vào cuối tuần trước',
    'nói về một bài học hay quyết định quan trọng của bạn',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVerb = widget.initialVerb;
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _initChatWithVerb(Verb verb, List<Verb> allVerbs) {
    if (_hasInitializedChat) return;
    _hasInitializedChat = true;

    _addAiPrompt(verb, isFirst: true);
  }

  void _addAiPrompt(Verb verb, {bool isFirst = false}) {
    final rand = Random();
    final form = rand.nextBool() ? 'V2' : 'V3';
    _targetForm = form;
    _selectedVerb = verb;

    final formName = form == 'V2' ? 'quá khứ (V2: "${verb.v2}")' : 'phân từ hai (V3: "${verb.v3}")';
    final scenario = _promptScenarios[rand.nextInt(_promptScenarios.length)];

    String text;
    if (isFirst) {
      text = 'Xin chào! Mình là Gia sư AI đồng hành cùng bạn làm chủ 360 động từ bất quy tắc. 🚀\n\n'
          '👉 **Thử thách hôm nay**: Động từ **"${verb.v1.toUpperCase()}"**\n'
          '• V1: ${verb.v1} • V2: ${verb.v2} • V3: ${verb.v3}\n'
          '• Nghĩa: ${verb.meaningVi}\n\n'
          'Bạn hãy đặt 1 câu tiếng Anh sử dụng dạng $formName để $scenario nhé!';
    } else {
      text = 'Tuyệt vời! Chúng ta cùng sang thử thách tiếp theo nhé:\n\n'
          '👉 Động từ mới: **"${verb.v1.toUpperCase()}"**\n'
          '• V1: ${verb.v1} • V2: ${verb.v2} • V3: ${verb.v3}\n'
          '• Nghĩa: ${verb.meaningVi}\n\n'
          'Hãy đặt 1 câu tiếng Anh có chứa dạng $formName để $scenario nhé!';
    }

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: text,
        timestamp: DateTime.now(),
        verb: verb,
        targetForm: form,
        isPrompt: true,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _submitSentence(List<Verb> allVerbs) async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      AuthModal.show(context);
      return;
    }

    final verb = _selectedVerb;
    final text = _sentenceController.text.trim();
    if (verb == null || text.isEmpty) return;

    _sentenceController.clear();

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: ChatSender.user,
        text: text,
        timestamp: DateTime.now(),
        verb: verb,
        targetForm: _targetForm,
      ));
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      final eval = await ref.read(aiEvaluationProvider.notifier).evaluate(
            verbV1: verb.v1,
            targetForm: _targetForm,
            userSentence: text,
            token: authState.token,
          );

      ref.read(gamificationProvider.notifier).addXp(25);

      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add(ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            sender: ChatSender.ai,
            text: eval.feedback,
            timestamp: DateTime.now(),
            verb: verb,
            targetForm: _targetForm,
            evaluation: eval,
          ));
        });
        _scrollToBottom();

        // After evaluation, automatically ask the next question with a new verb
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          final rand = Random();
          final nextVerb = allVerbs[rand.nextInt(allVerbs.length)];
          _addAiPrompt(nextVerb);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add(ChatMessage(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            sender: ChatSender.ai,
            text: 'Có lỗi khi phân tích câu: $e. Hãy thử lại hoặc đặt câu mới nhé!',
            timestamp: DateTime.now(),
            verb: verb,
          ));
        });
        _scrollToBottom();
      }
    }
  }

  void _pickNextRandomVerb(List<Verb> allVerbs) {
    if (allVerbs.isEmpty) return;
    final rand = Random();
    final nextVerb = allVerbs[rand.nextInt(allVerbs.length)];
    _addAiPrompt(nextVerb);
  }

  void _giveHint(Verb verb) {
    final form = _targetForm == 'V2' ? verb.v2 : verb.v3;
    final hint = '💡 Gợi ý cấu trúc cho dạng $form (${verb.meaningVi}):\n'
        '• Khẳng định: S + $form + O + thời gian (ví dụ: yesterday, last week, already...)\n'
        '• Thử bắt đầu bằng: "I $form..." hoặc "She $form..."';

    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        sender: ChatSender.ai,
        text: hint,
        timestamp: DateTime.now(),
        verb: verb,
        targetForm: _targetForm,
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final allVerbsAsync = ref.watch(allVerbsProvider);
    final evalAsync = ref.watch(aiEvaluationProvider);
    final authState = ref.watch(authProvider);
    final iapState = ref.watch(iapProvider);
    final tts = ref.watch(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gia Sư AI Viết Câu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm lại câu mới',
            onPressed: () {
              _sentenceController.clear();
              ref.read(aiEvaluationProvider.notifier).reset();
              setState(() {
                _messages.clear();
                _hasInitializedChat = false;
              });
              allVerbsAsync.whenData((verbs) {
                if (verbs.isNotEmpty) {
                  _initChatWithVerb(verbs.first, verbs);
                }
              });
            },
          ),
        ],
      ),
      body: allVerbsAsync.when(
        data: (verbs) {
          if (verbs.isEmpty) return const Center(child: Text('Không có dữ liệu'));
          _selectedVerb ??= verbs.first;
          final verb = _selectedVerb!;

          if (!_hasInitializedChat) {
            _initChatWithVerb(verb, verbs);
          }

          // If evaluation comes from provider override (e.g. In automated tests)
          final activeOverrideEval = evalAsync.value;

          return SafeArea(
            child: Column(
              children: [
                // Header Status Bar (Compact & Responsive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: iapState.isPro
                        ? Colors.amber.shade50
                        : const Color(0xFF10B981).withValues(alpha: 0.08),
                    border: Border(
                      bottom: BorderSide(
                        color: iapState.isPro
                            ? Colors.amber.shade200
                            : const Color(0xFF10B981).withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iapState.isPro ? Icons.workspace_premium_rounded : Icons.verified_user_rounded,
                        color: iapState.isPro ? Colors.amber.shade800 : const Color(0xFF059669),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          iapState.isPro
                              ? 'VIP PRO: Gia sư AI không giới hạn (${authState.user?.name ?? 'Tài khoản'})'
                              : 'Đã kết nối Gia sư AI (${authState.user?.name ?? 'Tài khoản'})',
                          style: TextStyle(
                            color: iapState.isPro ? Colors.amber.shade900 : const Color(0xFF065F46),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!iapState.isPro)
                        TextButton(
                          onPressed: () => PaywallModal.show(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Nâng cấp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),

                // Chat Messages Thread
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    itemCount: (activeOverrideEval != null ? 1 : 0) + _messages.length + (_isAiTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (activeOverrideEval != null) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildEvaluationCard(activeOverrideEval, tts),
                          );
                        }
                        index--;
                      }
                      if (index == _messages.length && _isAiTyping) {
                        return _buildAiTypingIndicator();
                      }
                      final msg = _messages[index];
                      return _buildMessageItem(msg, tts);
                    },
                  ),
                ),

                // Quick Action Suggestion Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  color: Colors.grey.shade50,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.lightbulb_outline_rounded, size: 16, color: Colors.amber),
                          label: const Text('Gợi ý câu mẫu', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () => _giveHint(_selectedVerb ?? verb),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.shuffle_rounded, size: 16, color: AppTheme.primary),
                          label: const Text('Đổi từ khác', style: TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () => _pickNextRandomVerb(verbs),
                        ),
                        const SizedBox(width: 8),
                        ActionChip(
                          avatar: const Icon(Icons.volume_up_rounded, size: 16, color: Color(0xFF10B981)),
                          label: Text(
                            'Phát âm "${_selectedVerb?.v1 ?? verb.v1}"',
                            style: const TextStyle(fontSize: 11),
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () => tts.speak(
                            '${_selectedVerb?.v1}, ${_selectedVerb?.v2}, ${_selectedVerb?.v3}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Input Bar (Modern Chat Bubble Input)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sentenceController,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _submitSentence(verbs),
                              decoration: InputDecoration(
                                hintText: 'Nhập câu trả lời bằng tiếng Anh...',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: evalAsync.isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.send_rounded, size: 16),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Kiểm tra câu với Gia sư AI',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onPressed: () => _submitSentence(verbs),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi tải dữ liệu: $err')),
      ),
    );
  }

  Widget _buildAiTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF059669)),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gia sư AI đang chấm...',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg, dynamic tts) {
    if (msg.sender == ChatSender.user) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI message or Evaluation
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: msg.evaluation != null
                    ? (msg.evaluation!.isCorrect
                        ? const [Color(0xFF10B981), Color(0xFF059669)]
                        : const [Color(0xFFF59E0B), Color(0xFFD97706)])
                    : const [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              msg.evaluation != null ? Icons.fact_check_rounded : Icons.smart_toy_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.evaluation != null)
                  _buildEvaluationCard(msg.evaluation!, tts)
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF1E293B)),
                        ),
                        if (msg.verb != null) ...[
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.primary),
                              tooltip: 'Nghe phát âm',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => tts.speak(msg.verb!.v1),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(AiEvaluation eval, dynamic tts) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: eval.isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: eval.isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      eval.isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                      color: eval.isCorrect ? const Color(0xFF16A34A) : Colors.amber.shade800,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        eval.isCorrect ? 'Đạt chuẩn ngữ pháp' : 'Cần lưu ý ngữ pháp',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: eval.isCorrect ? const Color(0xFF15803D) : Colors.amber.shade900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: eval.isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Text(
                      'Điểm: ${eval.score}/10',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: eval.isCorrect ? const Color(0xFF15803D) : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            eval.feedback,
            style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
          ),
          if (eval.grammarExplanation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              eval.grammarExplanation,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.35),
            ),
          ],
          if (eval.improvedSentence.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Câu gợi ý viết lại tự nhiên:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.primary),
                  tooltip: 'Phát âm mẫu',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => tts.speak(eval.improvedSentence),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                  tooltip: 'Sao chép',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: eval.improvedSentence));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép câu gợi ý.')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                eval.improvedSentence,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
