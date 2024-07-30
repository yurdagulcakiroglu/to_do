import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '';
      _email = prefs.getString('email') ?? '';
      _phone = prefs.getString('phone') ?? '';
      _address = prefs.getString('address') ?? '';
    });
  }

  Future<void> _editProfile() async {
    final TextEditingController nameController =
        TextEditingController(text: _name);
    final TextEditingController emailController =
        TextEditingController(text: _email);
    final TextEditingController phoneController =
        TextEditingController(text: _phone);
    final TextEditingController addressController =
        TextEditingController(text: _address);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profili Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildTextField(nameController, 'Ad'),
                _buildTextField(emailController, 'Email'),
                _buildTextField(phoneController, 'Telefon'),
                _buildTextField(addressController, 'Adres'),
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
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setString('name', nameController.text);
                await prefs.setString('email', emailController.text);
                await prefs.setString('phone', phoneController.text);
                await prefs.setString('address', addressController.text);

                setState(() {
                  _name = nameController.text;
                  _email = emailController.text;
                  _phone = phoneController.text;
                  _address = addressController.text;
                });

                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    AssetImage('assets/profile_picture.png'), // Profil resmi
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Bilgilerim',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildProfileInfoRow('Ad:', _name),
            _buildProfileInfoRow('Email:', _email),
            _buildProfileInfoRow('Telefon:', _phone),
            _buildProfileInfoRow('Adres:', _address),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _editProfile,
                child: const Text('Düzenle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Text(info),
        ],
      ),
    );
  }
}
