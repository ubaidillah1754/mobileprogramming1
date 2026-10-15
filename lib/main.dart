import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Palet warna
const Color navy = Color(0xFF14213D);
const Color blue = Color(0xFF1F3A5F);
const Color mustard = Color(0xFFE9B949);
const Color background = Color(0xFFFFFDF5);
const Color surface = Color(0xFFE8EDF3);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kartu Profil Sayyid',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kartu Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: navy,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 850),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: navy.withValues(alpha: 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: profilePhoto()),
                      const SizedBox(width: 32),
                      const Expanded(flex: 3, child: ProfileInformation()),
                    ],
                  )
                : Column(
                    children: [
                      profilePhoto(),
                      const SizedBox(height: 28),
                      const ProfileInformation(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget profilePhoto() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: mustard,
              ),
              child: const CircleAvatar(
                radius: 75,
                backgroundColor: blue,
                backgroundImage: AssetImage('assets/foto_profil.jpg'),
              ),
            ),
            Positioned(
              right: -8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Text(
                  'Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'BACKEND DEVELOPER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blue,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class ProfileInformation extends StatelessWidget {
  const ProfileInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, saya',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sayyid Ahmed Ubaidilah',
          style: TextStyle(
            color: navy,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Backend Developer',
          style: TextStyle(
            color: blue,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '23 Tahun | Mahasiswa Sistem Informasi',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 18),
        const Text(
          'Saya adalah mahasiswa Sistem Informasi yang '
          'tertarik pada pengembangan backend, perancangan '
          'database, dan pembangunan REST API. Saya berfokus '
          'mengembangkan sistem yang terstruktur, aman, '
          'dan efisien menggunakan teknologi web.',
          style: TextStyle(fontSize: 14, height: 1.7, color: Color(0xFF555555)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Keahlian',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SkillChip(label: 'Laravel'),
            SkillChip(label: 'PHP'),
            SkillChip(label: 'MySQL'),
            SkillChip(label: 'REST API'),
            SkillChip(label: 'Database Design'),
            SkillChip(label: 'Git & GitHub'),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Kontak & Sosial Media',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            contactIcon(Icons.email_outlined),
            const SizedBox(width: 12),
            contactIcon(Icons.phone_outlined),
            const SizedBox(width: 12),
            contactIcon(Icons.code),
          ],
        ),
      ],
    );
  }

  Widget contactIcon(IconData icon) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: navy, size: 24),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: surface,
      side: BorderSide.none,
      labelStyle: const TextStyle(
        color: navy,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }
}
