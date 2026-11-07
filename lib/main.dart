
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

const String workerUrl = String.fromEnvironment(
  'WORKER_URL',
  defaultValue: 'https://myanmar-ai-api.nay577770.workers.dev',
);

const purple = Color(0xFFAD79FF);
const bg = Color(0xFF0B0813);
const card = Color(0xFF191326);

void main() => runApp(const MyanmarAIApp());

class MyanmarAIApp extends StatelessWidget {
  const MyanmarAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MYANMAR AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 42});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/myanmar_ai_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFF39205C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: purple,
              size: size * 0.65,
            ),
          );
        },
      ),
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

  void openTool(String title, String action, String hint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ToolPage(
          title: title,
          action: action,
          hint: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        onOpen: (i) => setState(() => index = i),
        onTool: openTool,
      ),
      ToolPage(
        title: 'Video Recap',
        action: 'recap',
        hint: 'ဇာတ်လမ်းအကြောင်းအရာ သို့မဟုတ် ခွင့်ပြုထားသော Video Link ထည့်ပါ။',
      ),
      ToolPage(
        title: 'ဘာသာပြန်',
        action: 'translate',
        hint: 'မြန်မာ၊ English၊ Thai၊ Chinese၊ Japanese၊ Korean ဘာသာများအတွက် စာသားထည့်ပါ။',
      ),
      const VoicePage(),
      MorePage(onTool: openTool),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            BrandLogo(size: 40),
            SizedBox(width: 10),
            Text(
              'MYANMAR AI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.workspace_premium, color: purple),
          ),
        ],
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF15101F),
        indicatorColor: purple.withOpacity(0.2),
        selectedIndex: index,
        onDestinationSelected: (v) {
          setState(() => index = v);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: purple),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie, color: purple),
            label: 'Recap',
          ),
          NavigationDestination(
            icon: Icon(Icons.translate),
            selectedIcon: Icon(Icons.translate, color: purple),
            label: 'Translate',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq),
            selectedIcon: Icon(Icons.graphic_eq, color: purple),
            label: 'Voice',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            selectedIcon: Icon(Icons.grid_view, color: purple),
            label: 'More',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final Function(int) onOpen;
  final Function(String, String, String) onTool;

  const DashboardPage({
    super.key,
    required this.onOpen,
    required this.onTool,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF552B91),
                Color(0xFF24143F),
                Color(0xFF171024),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandLogo(size: 76),
              const SizedBox(height: 16),
              const Text(
                'MYANMAR AI STUDIO',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'သင့်ရဲ့ AI Video Creation Studio',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => onOpen(1),
                style: FilledButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.black,
                ),
                child: const Text('စတင်အသုံးပြုမယ်'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          'AI FEATURES',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            FeatureCard(
              icon: Icons.movie_creation_outlined,
              title: 'Video Recap',
              subtitle: 'ဇာတ်လမ်းအကျဉ်းချုပ်',
              onTap: () => onOpen(1),
            ),
            FeatureCard(
              icon: Icons.translate,
              title: 'ဘာသာပြန်',
              subtitle: 'Multi Language',
              onTap: () => onOpen(2),
            ),
            FeatureCard(
              icon: Icons.graphic_eq,
              title: 'Voice Studio',
              subtitle: 'အသံထုတ်လုပ်မှု',
              onTap: () => onOpen(3),
            ),
            FeatureCard(
              icon: Icons.subtitles_outlined,
              title: 'SRT Subtitle',
              subtitle: 'စာတန်းထိုး',
              onTap: () => onTool(
                'SRT Subtitle',
                'srt',
                'Subtitle စာသား သို့မဟုတ် Transcript ထည့်ပါ။',
              ),
            ),
            FeatureCard(
              icon: Icons.image_outlined,
              title: 'Thumbnail',
              subtitle: 'Thumbnail စာသား',
              onTap: () => onTool(
                'Thumbnail',
                'thumbnail',
                'Thumbnail အတွက် စာသားရေးပါ။',
              ),
            ),
            FeatureCard(
              icon: Icons.title,
              title: 'Title & Hashtag',
              subtitle: 'Video အတွက် စာသား',
              onTap: () => onTool(
                'Title + Hashtag',
                'title',
                'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'MYANMAR AI • PREMIUM EDITION',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: purple.withOpacity(0.18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: purple, size: 30),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
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

        if (!mounted) return;

        setState(() {
          selectedVideo = file;
          selectedVideoSize = size;
          result = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => result = 'Video ရွေးမရပါ: $e');
      }
    }
  }

  Future<void> runAI() async {
    final input = controller.text.trim();

    if (selectedVideo != null) {
      setState(() {
        result =
            'Video ရွေးချယ်ပြီးပါပြီ။ '
            'အမှန်တကယ် AI Recap လုပ်ရန် Video Upload Backend လိုအပ်ပါသေးသည်။';
      });
      return;
    }

    if (input.isEmpty || busy) return;

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
              'Server Error (${response.statusCode})').toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => result = 'Error: $e');
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.hint,
          style: const TextStyle(color: Colors.white60),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file, color: purple),
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
        ],
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'ဒီနေရာမှာ စာရေးပါ...',
            filled: true,
            fillColor: card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
          ),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'ရလဒ်',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              result,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ],
    );
  }
}

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 90),
            const SizedBox(height: 20),
            const Text(
              'VOICE STUDIO',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Narrator နှင့် Character Voice '
              'ထုတ်လုပ်နိုင်မည့်နေရာပါ။',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            const Text(
              'Voice Generation Backend ကို '
              'နောက်တစ်ဆင့်မှာ ချိတ်ဆက်ရပါမယ်။',
              textAlign: TextAlign.center,
              style: TextStyle(color: purple),
            ),
          ],
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final Function(String, String, String) onTool;

  const MorePage({
    super.key,
    required this.onTool,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      ['SRT Subtitle', 'srt', 'Subtitle စာသား သို့မဟုတ် Transcript ထည့်ပါ။', Icons.subtitles],
      ['Thumbnail', 'thumbnail', 'Thumbnail အတွက် စာသားရေးပါ။', Icons.image],
      ['Title + Hashtag', 'title', 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။', Icons.title],
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'MORE TOOLS',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        for (final tool in tools)
          Card(
            color: card,
            child: ListTile(
              leading: Icon(tool[3] as IconData, color: purple),
              title: Text(tool[0] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTool(
                tool[0] as String,
                tool[1] as String,
                tool[2] as String,
              ),
            ),
          ),
        const SizedBox(height: 25),
        const Center(
          child: Text(
            'MYANMAR AI PREMIUM\nVersion 2.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
int;

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
      final files = await FilePicker.pickFiles(type: FileType.video);
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
        result = 'Video ရွေးချယ်ပြီးပါပြီ။ အမှန်တကယ် AI Recap လုပ်ရန် Video Upload Backend လိုအပ်ပါသေးသည်။';
      });
      return;
    }

    if (input.isEmpty || busy) return;

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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        setState(() {
          result = (data['text'] ?? data['reply'] ?? 'အဖြေမရရှိပါ။').toString();
        });
      } else {
        setState(() {
          result = (data['error'] ?? 'Server Error (${response.statusCode})').toString();
        });
      }
    } catch (e) {
      if (mounted) setState(() => result = 'Error: $e');
    } finally {
      if (mounted) setState(() => busy = false);
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(widget.hint, style: const TextStyle(color: Colors.white60)),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file, color: purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${selectedVideo!.name}\n${((selectedVideoSize ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB',
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
        ],
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'ဒီနေရာမှာ စာရေးပါ...',
            filled: true,
            fillColor: card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
          ),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text('ရလဒ်', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(result, style: const TextStyle(height: 1.6)),
          ),
        ],
      ],
    );
  }
}

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 90),
            const SizedBox(height: 20),
            const Text(
              'VOICE STUDIO',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Narrator နှင့် Character Voice ထုတ်လုပ်နိုင်မည့်နေရာပါ။',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            const Text(
              'Voice Generation Backend ကို နောက်တစ်ဆင့်မှာ ချိတ်ဆက်ရပါမယ်။',
              textAlign: TextAlign.center,
              style: TextStyle(color: purple),
            ),
          ],
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final Function(String, String, String) onTool;

  const MorePage({super.key, required this.onTool});

  @override
  Widget build(BuildContext context) {
    final tools = [
      ['SRT Subtitle', 'srt', 'Subtitle စာသား သို့မဟုတ် Transcript ထည့်ပါ။', Icons.subtitles],
      ['Thumbnail', 'thumbnail', 'Thumbnail အတွက် စာသားရေးပါ။', Icons.image],
      ['Title + Hashtag', 'title', 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။', Icons.title],
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'MORE TOOLS',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 18),
        for (final tool in tools)
          Card(
            color: card,
            child: ListTile(
              leading: Icon(tool[3] as IconData, color: purple),
              title: Text(tool[0] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTool(
                tool[0] as String,
                tool[1] as String,
                tool[2] as String,
              ),
            ),
          ),
        const SizedBox(height: 25),
        const Center(
          child: Text(
            'MYANMAR AI PREMIUM\nVersion 2.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
er.dispose();
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
            'Video ရွေးချယ်ပြီးပါပြီ။ '
            'အမှန်တကယ် AI Recap လုပ်ရန် Video Upload Backend လိုအပ်ပါသေးသည်။';
      });
      return;
    }

    if (input.isEmpty || busy) return;

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
              'Server Error (${response.statusCode})').toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => result = 'Error: $e');
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.hint,
          style: const TextStyle(color: Colors.white60),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.video_file, color: purple),
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
        ],
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'ဒီနေရာမှာ စာရေးပါ...',
            filled: true,
            fillColor: card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
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
          style: FilledButton.styleFrom(
            backgroundColor: purple,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(16),
          ),
        ),
        if (result.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'ရလဒ်',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              result,
              style: const TextStyle(height: 1.6),
            ),
          ),
        ],
      ],
    );
  }
}

class VoicePage extends StatelessWidget {
  const VoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.graphic_eq,
              color: purple,
              size: 70,
            ),
            const SizedBox(height: 20),
            const Text(
              'VOICE STUDIO',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Narrator နှင့် Character Voice '
              'ထုတ်လုပ်နိုင်မည့်နေရာပါ။',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 18),
            const Text(
              'Voice Generation Backend ကို '
              'နောက်တစ်ဆင့်မှာ ချိတ်ဆက်ရပါမယ်။',
              textAlign: TextAlign.center,
              style: TextStyle(color: purple),
            ),
          ],
        ),
      ),
    );
  }
}

class MorePage extends StatelessWidget {
  final Function(String, String, String) onTool;

  const MorePage({
    super.key,
    required this.onTool,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      ['SRT Subtitle', 'srt', 'Subtitle စာသား သို့မဟုတ် Transcript ထည့်ပါ။', Icons.subtitles],
      ['Thumbnail', 'thumbnail', 'Thumbnail အတွက် စာသားရေးပါ။', Icons.image],
      ['Title + Hashtag', 'title', 'ဗီဒီယိုအကြောင်းအရာကို ရေးပါ။', Icons.title],
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'MORE TOOLS',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 18),
        for (final tool in tools)
          Card(
            color: card,
            child: ListTile(
              leading: Icon(tool[3] as IconData, color: purple),
              title: Text(tool[0] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTool(
                tool[0] as String,
                tool[1] as String,
                tool[2] as String,
              ),
            ),
          ),
        const SizedBox(height: 25),
        const Center(
          child: Text(
            'MYANMAR AI PREMIUM\nVersion 2.0',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
        ),
      ],
    );
  }
}
