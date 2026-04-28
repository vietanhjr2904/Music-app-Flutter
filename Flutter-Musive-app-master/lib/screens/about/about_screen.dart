import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:spotify_clone/screens/auth/login_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Hive.box('session');
    final username = session.get('username');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Menu'),
      ),
      body: ListView(
        children: [
          if (username != null)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(username,
                  style: const TextStyle(color: Colors.white)),
              subtitle: const Text('Đang đăng nhập',
                  style: TextStyle(color: Colors.grey)),
            ),
          const Divider(color: Colors.white12),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('Giới thiệu ứng dụng',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Musive Việt',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.music_note,
                    color: Colors.green, size: 40),
                children: const [
                  Text(
                    'Musive Việt là ứng dụng nghe nhạc Việt Nam '
                    'với giao diện lấy cảm hứng từ Spotify. '
                    'Hỗ trợ tìm kiếm, đăng nhập, thư viện cá nhân, '
                    'điều khiển tốc độ phát và chia sẻ bài hát.',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: Colors.white),
            title: const Text('Điều khoản & Chính sách',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: const Text('Trợ giúp',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined,
                color: Colors.white),
            title: const Text('Xóa cache nhạc',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text(
                'Dùng khi bài hát phát sai nội dung so với tiêu đề',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () async {
              await Hive.box('ytCache').clear();
              await Hive.box('RecentlyPlayed').clear();
              await Hive.box('Recentsearch').clear();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa cache. Khởi động lại app để áp dụng.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          const Divider(color: Colors.white12),
          if (username != null)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await session.clear();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
