import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String workerUrl = String.fromEnvironment(
  'WORKER_URL',
  defaultValue: 'https://YOUR-WORKER-NAME.YOUR-SUBDOMAIN.workers.dev',
);

void main() => runApp(const MyanmarAIApp());

class MyanmarAIApp extends StatelessWidget {
  const MyanmarAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A36A);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MYANMAR AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081510),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [
    ToolPage(title: 'AI Chat', action: 'chat',
      hint: 'မြန်မာလို မေးခွန်းရေးပါ။'),
    ToolPage(title: 'ဘာသာပြန်', action: 'translate',
      hint: 'ဘာသာပြန်လိုသော စာသားနှင့် ဘယ်ဘာသာသို့ ပြန်လိုသည်ကို ရေးပါ။'),
    ToolPage(title: 'Video Recap', action: 'recap',
      hint: 'ဇာတ်လမ်းအကြောင်းအရာ သို့မဟုတ် ကိုယ်ပိုင်မှတ်စုကို ထည့်ပါ။ မူရင်းအစဉ်အတိုင်း အကျဉ်းချုပ်ရေးပေးမည်။'),
    ToolPage(title: 'Title + Hashtag', action: 'title',
      hint: 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။ မြန်မာ/English ခေါင်းစဉ်၊ Description နှင့် Hashtag ရယူပါ။'),
    ToolPage(title: 'Thumbnail စာသား', action: 'thumbnail',
      hint: 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။ Thumbnail အတွက် မြန်မာ + English စာသားနှင့် ဒီဇိုင်းအကြံပြုချက် ရယူပါ။'),
    ToolPage(title: 'SRT အကူအညီ', action: 'srt',
      hint: 'Subtitle စာသား သို့မဟုတ် transcript ကို ထည့်ပါ။ SRT ပုံစံပြောင်းရန် ကူညီပေးမည်။'),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = pages[index];
    return Scaffold(
      appBar: AppBar(
        title: const Text('MYANMAR AI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: const [Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.auto_awesome, color: Color(0xFF38D996)),
        )],
      ),
      body: selected,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.translate), label: 'Tools'),
          NavigationDestination(icon: Icon(Icons.movie_outlined), label: 'Recap'),
          NavigationDestination(icon: Icon(Icons.subtitles_outlined), label: 'SRT'),
        ],
      ),
    );
  }
}

class ToolPage extends StatefulWidget {
  final String title;
  final String action;
  final String hint;
  const ToolPage({super.key, required this.title, required this.action, required this.hint});

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final controller = TextEditingController();
  String result = '';
  bool busy = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> runAI() async {
    final input = controller.text.trim();
    if (input.isEmpty || busy) return;
    if (workerUrl.contains('YOUR-WORKER-NAME')) {
      setState(() => result = 'Worker URL မသတ်မှတ်ရသေးပါ။ README.md ကိုကြည့်ပါ။');
      return;
    }
    setState(() { busy = true; result = ''; });
    try {
      final response = await http.post(
        Uri.parse(workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': widget.action, 'input': input}),
      ).timeout(const Duration(seconds: 90));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) {
        setState(() => result = (data['text'] ?? data['reply'] ?? 'အဖြေမရရှိပါ။').toString());
      } else {
        setState(() => result = (data['error'] ?? 'Server error (${response.statusCode})').toString());
      }
    } catch (e) {
      setState(() => result = 'ချိတ်ဆက်မှု မအောင်မြင်ပါ။ အင်တာနက်နှင့် Worker URL ကို စစ်ဆေးပါ။');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(widget.hint, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 18),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'ဒီနေရာမှာ စာရေးပါ...',
            filled: true,
            fillColor: const Color(0xFF10251B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: busy ? null : runAI,
          icon: busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome),
          label: Text(busy ? 'လုပ်ဆောင်နေသည်...' : 'ဖန်တီးမယ်'),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text('ရလဒ်', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText(result, style: const TextStyle(height: 1.5)),
        ],
        const SizedBox(height: 24),
        const Text(
          'မှတ်ချက် — ဤဗားရှင်းသည် အခြေခံ AI စာသားလုပ်ဆောင်ချက်များအတွက် စတင်ပုံစံဖြစ်သည်။ '
          'ဗီဒီယိုဖိုင်မှ အသံထုတ်ယူခြင်း၊ အလိုအလျောက်အချိန်ညှိ SRT၊ အသံဖန်တီးခြင်း၊ '
          'ပုံဖိုင်ထုတ်လုပ်ခြင်းနှင့် Video Editing တို့ကို သီးခြား Media Pipeline များဖြင့် ထပ်မံတည်ဆောက်ရမည်။',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
