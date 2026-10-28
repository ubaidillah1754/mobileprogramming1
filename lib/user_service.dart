import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class UserService {
  final String baseUrl = 'https://reqres.in/api';

  // Cache lokal agar perubahan (Create/Update/Delete) langsung terlihat di aplikasi
  static List<UserModel>? _cachedUsers;

  // Daftar nama orang Indonesia untuk melokalisasi data dari API ReqRes
  static final List<Map<String, String>> _indonesianNames = [
    {
      'first_name': 'Budi',
      'last_name': 'Santoso',
      'email': 'budi.santoso@mail.com',
    },
    {
      'first_name': 'Siti',
      'last_name': 'Rahmawati',
      'email': 'siti.rahmawati@mail.com',
    },
    {
      'first_name': 'Ahmad',
      'last_name': 'Fauzi',
      'email': 'ahmad.fauzi@mail.com',
    },
    {
      'first_name': 'Dewi',
      'last_name': 'Lestari',
      'email': 'dewi.lestari@mail.com',
    },
    {
      'first_name': 'Rizky',
      'last_name': 'Pratama',
      'email': 'rizky.pratama@mail.com',
    },
    {
      'first_name': 'Putri',
      'last_name': 'Ayu',
      'email': 'putri.ayu@mail.com',
    },
  ];

  // 1. GET: Mengambil daftar user
  Future<List<UserModel>> getUsers({bool forceRefresh = false}) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users?page=1'));

      if (response.statusCode == 200) {
        if (_cachedUsers == null || forceRefresh) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> listData = data['data'];

          // Mapping data dari API ReqRes menggunakan nama-nama orang Indonesia
          _cachedUsers = listData.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = Map<String, dynamic>.from(entry.value);

            if (index < _indonesianNames.length) {
              item['first_name'] = _indonesianNames[index]['first_name'];
              item['last_name'] = _indonesianNames[index]['last_name'];
              item['email'] = _indonesianNames[index]['email'];
            }
            return UserModel.fromJson(item);
          }).toList();
        }
        return List<UserModel>.from(_cachedUsers!);
      } else {
        throw Exception('Gagal memuat data (Error code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // 2. POST: Membuat user baru
  Future<UserModel> createUser(String firstName, String lastName, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'name': '$firstName $lastName',
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }),
      );

      // ReqRes mengembalikan status code 201 untuk operasi POST yang sukses
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        final newUser = UserModel(
          id: int.tryParse(data['id'].toString()) ?? DateTime.now().millisecondsSinceEpoch,
          email: email,
          firstName: firstName,
          lastName: lastName,
          avatar: 'https://reqres.in/img/faces/4-image.jpg',
        );

        // Tambahkan ke cache lokal agar langsung terlihat di daftar pengguna
        _cachedUsers ??= [];
        _cachedUsers!.insert(0, newUser);

        return newUser;
      } else {
        throw Exception('Gagal membuat user (Error code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // 3. PUT: Memperbarui data user
  Future<bool> updateUser(int id, String firstName, String lastName, String email) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({
          'name': '$firstName $lastName',
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        // Perbarui data di cache lokal
        if (_cachedUsers != null) {
          int index = _cachedUsers!.indexWhere((u) => u.id == id);
          if (index != -1) {
            _cachedUsers![index] = UserModel(
              id: id,
              email: email,
              firstName: firstName,
              lastName: lastName,
              avatar: _cachedUsers![index].avatar,
            );
          }
        }
        return true;
      } else {
        throw Exception('Gagal memperbarui user (Error code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // 4. DELETE: Menghapus user
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      // ReqRes umumnya mengembalikan status code 204 (No Content) saat delete berhasil
      if (response.statusCode == 204 || response.statusCode == 200) {
        // Hapus data dari cache lokal
        if (_cachedUsers != null) {
          _cachedUsers!.removeWhere((u) => u.id == id);
        }
        return true;
      } else {
        throw Exception('Gagal menghapus user (Error code: ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
