import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:faker/faker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:avatar_glow/avatar_glow.dart';

import 'user_model.dart';
import 'user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kontak & API Service',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
      home: const MainPage(),
    );
  }
}

// Model Lokal Dummy Kontak
class ContactModel {
  final String name;
  final String phone;
  final String email;
  final DateTime dateAdded;

  ContactModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.dateAdded,
  });
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final Faker _faker = Faker();
  late List<ContactModel> _contacts;

  // Integrasi UserService
  final UserService _userService = UserService();
  late Future<List<UserModel>> _futureApiUsers;

  @override
  void initState() {
    super.initState();
    // 1. Generate 15 Dummy Kontak dengan Faker (Praktikum Pertemuan 6)
    _contacts = List.generate(15, (index) {
      return ContactModel(
        name: _faker.person.name(),
        phone: _faker.phoneNumber.de(),
        email: _faker.internet.email(),
        dateAdded: _faker.date.dateTime(minYear: 2024, maxYear: 2026),
      );
    });

    // 2. Load API Users
    _loadApiUsers();
  }

  void _loadApiUsers() {
    setState(() {
      _futureApiUsers = _userService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildKontakPage(),
      _buildCariPage(),
      _buildProfilPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Daftar Kontak'
              : _currentIndex == 1
              ? 'Cari & Filter'
              : 'Profil Pengguna',
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _userService
                        .getUsers(forceRefresh: true)
                        .then((_) => _loadApiUsers());
                  },
                ),
              ]
            : null,
      ),
      body: pages[_currentIndex],
      // Bottom Bar Menggunakan ConvexAppBar
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.indigo,
        activeColor: Colors.white,
        color: Colors.white70,
        items: const [
          TabItem(icon: Icons.contacts, title: 'Kontak'),
          TabItem(icon: Icons.search, title: 'Cari'),
          TabItem(icon: Icons.person, title: 'Profil'),
        ],
        initialActiveIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // --- 1. HALAMAN KONTAK (Gabungan ListView + Faker + INTL + API ReqRes) ---
  Widget _buildKontakPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section A: Data Pengguna dari API ReqRes
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Data Pengguna (dari API ReqRes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          FutureBuilder<List<UserModel>>(
            future: _futureApiUsers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error API: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Tidak ada data API.'),
                );
              }

              final apiUsers = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: apiUsers.length,
                itemBuilder: (context, index) {
                  final user = apiUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatar),
                    ),
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        bool success = await _userService.deleteUser(user.id);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User API berhasil dihapus'),
                            ),
                          );
                          _loadApiUsers();
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
          const Divider(thickness: 2),

          // Section B: Data Dummy Kontak (Praktikum Pertemuan 6)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Daftar Kontak Dummy (Faker & INTL)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              // Format tanggal Bahasa Indonesia (INTL)
              final formattedDate = DateFormat(
                'dd MMMM yyyy',
                'id_ID',
              ).format(contact.dateAdded);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('📞 ${contact.phone}'),
                      Text('✉️ ${contact.email}'),
                      const SizedBox(height: 4),
                      Text(
                        'Ditambahkan pada: $formattedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 2. HALAMAN CARI (DropdownSearch) ---
  Widget _buildCariPage() {
    final List<String> categories = [
      'Keluarga',
      'Teman',
      'Kerja',
      'Komunitas',
      'Lainnya',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Kontak Berdasarkan Kategori',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownSearch<String>(
            items: (filter, loadProps) => categories,
            decoratorProps: const DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "Kategori Kontak",
                hintText: "Pilih kategori",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(hintText: "Cari kategori..."),
              ),
            ),
            onChanged: (String? value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kategori dipilih: $value')),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 3. HALAMAN PROFIL (AvatarGlow) ---
  Widget _buildProfilPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            startDelay: const Duration(milliseconds: 1000),
            glowColor: Colors.indigo,
            glowShape: BoxShape.circle,
            animate: true,
            curve: Curves.fastOutSlowIn,
            child: const Material(
              elevation: 8.0,
              shape: CircleBorder(),
              child: CircleAvatar(
                backgroundColor: Colors.indigo,
                radius: 60.0,
                child: Icon(Icons.person, size: 70, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mahasiswa Sistem Informasi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'NIM: 123456789 | Kelas: Mobile Programming',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
