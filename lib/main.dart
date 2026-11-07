
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

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
        hint: 'ဖုန်းထဲက Video ရွေးပါ၊ သို့မဟုတ် Video Link ထည့်ပါ။'),
    ToolPage(title: 'Title + Hashtag', action: 'title',
        hint: 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။'),
    ToolPage(title: 'Thumbnail စာသား', action: 'thumbnail',
        hint: 'Thumbnail အတွက် မြန်မာ + English စာသား ရယူပါ။'),
    ToolPage(title: 'SRT အကူအညီ', action: 'srt',
        hint: 'Subtitle စာသား သို့မဟုတ် transcript ကို ထည့်ပါ။'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MYANMAR AI',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.auto_awesome, color: Color(0xFF38D996)),
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          NavigationDestination(
              icon: Icon(Icons.translate), label: 'Tools'),
          NavigationDestination(
              icon: Icon(Icons.movie_outlined), label: 'Recap'),
          NavigationDestination(
              icon: Icon(Icons.subtitles_outlined), label: 'SRT'),
        ],
      ),
    );
  }
}

class ToolPage extends StatefulWidget {
  final String title;
  final String action;
  final String hint;

  const ToolPage({
    super.key,
    required this.title,
    required this.action,
    required this.hint,
  });

  @override
  State<ToolPage> createState() => _ToolPageState();
}

class _ToolPageState extends State<ToolPage> {
  final controller = TextEditingController();

  String result = '';
  bool busy = false;
  PlatformFile? selectedVideo;
int? selectedVideoSize;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  
Future<void> pickVideo() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.video,
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final size = await file.length();

      setState(() {
        selectedVideo = file;
        selectedVideoSize = size;
        result = '';
      });
    }
  } catch (e) {
    setState(() => result = 'Video ရွေးမရပါ: $e');
  }
}


  Future<void> runAI() async {
    final input = controller.text.trim();

    if (selectedVideo != null) {
      setState(() {
        result =
            'Video ဖိုင်ကို ရွေးချယ်ပြီးပါပြီ။ '
            'Video ကို AI နဲ့ အမှန်တကယ် စစ်ဆေးနိုင်ဖို့ '
            'Media Upload စနစ်ကို နောက်တစ်ဆင့်မှာ ချိတ်ဆက်ရပါမယ်။';
      });
      return;
    }

    if (input.isEmpty || busy) return;

    if (workerUrl.contains('YOUR-WORKER-NAME')) {
      setState(() {
        result = 'Worker URL မသတ်မှတ်ရသေးပါ။';
      });
      return;
    }

    setState(() {
      busy = true;
      result = '';
    });

    try {
      final response = await http.post(
        Uri.parse(workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': widget.action,
          'input': input,
        }),
      ).timeout(const Duration(seconds: 90));

      final data = jsonDecode(response.body)
          as Map<String, dynamic>;

      if (response.statusCode == 200) {
        setState(() {
          result = (data['text'] ??
              data['reply'] ??
              'အဖြေမရရှိပါ။').toString();
        });
      } else {
        setState(() {
          result = (data['error'] ??
              'Server error (${response.statusCode})').toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => result = 'အသေးစိတ် Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecap = widget.action == 'recap';

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          widget.title,
          style: Theme.of(context)
              .textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          widget.hint,
          style: const TextStyle(color: Colors.white70),
        ),

        if (isRecap) ...[
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: busy ? null : pickVideo,
            icon: const Icon(Icons.video_library),
            label: const Text('ဖုန်းထဲက Video ရွေးမယ်'),
          ),
          if (selectedVideo != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10251B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file, color: Color(0xFF38D996)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${selectedVideo!.name}\n'
                      '${((selectedVideoSize ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB',
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
  selectedVideo = null;
  selectedVideoSize = null;
});
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'သို့မဟုတ် Video Link ထည့်ပါ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],

        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: isRecap
                ? 'YouTube / TikTok / Facebook / Instagram Link သို့မဟုတ် စာသားထည့်ပါ...'
                : 'ဒီနေရာမှာ စာရေးပါ...',
            filled: true,
            fillColor: const Color(0xFF10251B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height: 14),

        FilledButton.icon(
          onPressed: busy ? null : runAI,
          icon: busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(busy ? 'လုပ်ဆောင်နေသည်...' : 'ဖန်တီးမယ်'),
        ),

        if (result.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'ရလဒ်',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SelectableText(
            result,
            style: const TextStyle(height: 1.5),
          ),
        ],

        const SizedBox(height: 24),
        const Text(
          'မှတ်ချက် — ယခုအဆင့်တွင် Video ရွေးချယ်နိုင်ပြီး Link ထည့်နိုင်ပါပြီ။ '
          'Video Upload၊ Link မှ Video အကြောင်းအရာဖတ်ခြင်း၊ '
          'အသံထုတ်ယူခြင်းနှင့် အချိန်ညှိ SRT တို့ကို '
          'နောက်ထပ် Backend စနစ်ဖြင့် ချိတ်ဆက်ရပါမည်။',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
