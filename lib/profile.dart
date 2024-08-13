import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _email = '';
  String? _profileImageUrl; // Nullable yapıldı
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _name = doc['name'] ?? '';
            _email = user.email ?? '';
            _profileImageUrl = doc['profileImageUrl'];
          });
        } else {
          print("Kullanıcı verisi bulunamadı");
        }
      } catch (e) {
        print("Veri çekme hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profil bilgileri alınırken bir hata oluştu.')),
        );
      }
    } else {
      print("Kullanıcı oturumu açmamış.");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String profileImageUrl = await _uploadProfileImage(user.uid);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': profileImageUrl});
        setState(() {
          _profileImageUrl = profileImageUrl;
        });
      }
    }
  }

  Future<String> _uploadProfileImage(String uid) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$uid.jpg'); // Gerekirse dosya adı çeşitlendirilebilir
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    ).withOpacity(0.4);
  }

  Future<void> _editProfileField(String field) async {
    final TextEditingController controller = TextEditingController();

    if (field == 'name') {
      controller.text = _name;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Düzenle'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: field == 'name' ? 'Ad ve Soyad' : '',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({
                      'name': controller.text,
                    });
                    await user.updateDisplayName(controller
                        .text); // Firebase Auth display name güncellemesi
                    setState(() {
                      _name = controller.text; // Güncellenen adı göster
                    });
                    Navigator.of(context).pop(); // Dialogu kapat
                  } catch (e) {
                    print("Güncelleme hatası: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Güncelleme hatası: $e')),
                    );
                  }
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifre Güncelle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: const InputDecoration(
                    labelText: 'Eski Şifre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Eski şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yeni şifre boş olamaz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _confirmNewPasswordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: const InputDecoration(
                    labelText: 'Yeni Şifre (Tekrar)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yeni şifre (tekrar) boş olamaz';
                    } else if (value != _newPasswordController.text) {
                      return 'Şifreler uyuşmuyor';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    try {
                      String email = user.email ?? '';
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: email,
                        password: _oldPasswordController.text,
                      );

                      // Kullanıcıyı yeniden kimlik doğrulama
                      await user.reauthenticateWithCredential(credential);

                      // Yeni şifreyi güncelle
                      await user.updatePassword(_newPasswordController.text);

                      Navigator.of(context).pop(); // Dialogu kapat

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Şifre başarıyla güncellendi')),
                      );
                    } catch (e) {
                      print("Şifre güncelleme hatası: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Şifre güncelleme hatası: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Firestore'dan kullanıcı verilerini silme
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
      }

      // Profil resmi URL'sini kontrol et
      if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
        try {
          Reference storageRef =
              FirebaseStorage.instance.refFromURL(_profileImageUrl!);
          await storageRef.delete();
        } catch (e) {
          print("Profil resmi silme hatası: $e");
        }
      }

      // Kullanıcıyı Firebase Authentication'dan sil
      if (user != null) {
        await user.delete();
      }

      // Başarılı silme işlemi sonrası, kullanıcıyı giriş sayfasına yönlendir
      Navigator.of(context).pushReplacementNamed('/signin_screen');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hesap silme hatası: $e')),
      );
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text('Bu hesabı silmek istediğinizden emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () {
                Navigator.of(context).pop(); // Confirm dialog kapanır
                _deleteAccount(context); // BuildContext'i burada geçiriyoruz
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/bg2.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5), // Opaklık değeri
                BlendMode.dstATop, // Resmin üstüne renk ekleme
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // İçeriği üstten alta yerleştirir
          children: <Widget>[
            Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: _generateRandomColor(),
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(
                    height: 20), // Fotoğraf ve çizgi arasındaki boşluk
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  height: 1,
                  color: Colors.grey[
                      300], // Çizgi rengini istediğiniz gibi ayarlayabilirsiniz
                ),
                const SizedBox(
                    height: 20), // Çizgi ve yazılar arasındaki boşluk
                ListTile(
                  title: const Text('Ad ve Soyad'),
                  subtitle: Text(_name),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProfileField('name'),
                  ),
                ),
                ListTile(
                  title: const Text('E-posta'),
                  subtitle: Text(_email),
                ),
                ListTile(
                  title: const Text('Şifre'),
                  subtitle: const Text('*********'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _updatePassword,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showDeleteConfirmationDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Hesabı Sil',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
