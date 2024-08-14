import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/theme/theme.dart';
import 'my_home_page.dart';
import 'profile.dart';
import 'settings.dart';
import '../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth için

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Category> categories = [];
  final AuthService _auth = AuthService(); // AuthService örneği oluşturulması

  @override
  void initState() {
    super.initState();
    _fetchCategoriesFromFirestore();
  }

  Future<void> _fetchCategoriesFromFirestore() async {
    User? user = await _auth.getCurrentUser(); // Kullanıcıyı al
    if (user != null) {
      String userId = user.uid; // Kullanıcının uid'sini al
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        categories.clear();
        snapshot.docs.forEach((doc) {
          categories.add(Category(
            id: doc.id,
            title: doc['title'],
            todolist: [], // Notlar ayrı bir yerde tutuluyor, burada boş bırakıyoruz
          ));
        });
      });
    } else {
      // Eğer kullanıcı oturum açmamışsa ne yapılacağına karar verin
      print('Kullanıcı oturum açmamış');
    }
  }

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: const Text('Yeni Kategori Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kategori Adı',
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
                final String categoryName = controller.text;
                if (categoryName.isNotEmpty) {
                  User? user = await _auth.getCurrentUser();
                  if (user != null) {
                    // Firestore'a yeni kategori ekle
                    DocumentReference docRef = await FirebaseFirestore.instance
                        .collection('categories')
                        .add({
                      'title': categoryName,
                      'userId': user.uid,
                    });

                    setState(() {
                      categories.add(Category(
                        id: docRef.id,
                        title: categoryName,
                        todolist: [],
                      ));
                    });
                  }
                }
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    final TextEditingController controller =
        TextEditingController(text: category.title);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5),
          title: const Text('Kategori Düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Kategori Adı',
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
                final String categoryName = controller.text;
                if (categoryName.isNotEmpty) {
                  // Firestore'da kategoriyi güncelle
                  await FirebaseFirestore.instance
                      .collection('categories')
                      .doc(category.id)
                      .update({
                    'title': categoryName,
                  });

                  setState(() {
                    category.title = categoryName;
                  });
                }
                Navigator.of(context).pop(); // Dialogu kapat
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _removeTodoCategory(Category category) async {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(category.id)
        .delete();

    setState(() {
      categories.remove(category); // Seçilen kategoriyi listeden kaldır
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.title} kategorisi silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            // Geri alma işlemi için Firestore'a tekrar ekleme yapılmalı
            _undoDeleteCategory(category);
          },
        ),
      ),
    );
  }

  Future<void> _undoDeleteCategory(Category category) async {
    User? user = await _auth.getCurrentUser();
    if (user != null) {
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('categories').add({
        'title': category.title,
        'userId': user.uid,
      });

      setState(() {
        categories.add(Category(
          id: docRef.id,
          title: category.title,
          todolist: [],
        ));
      });
    }
  }

  Future<void> _navigateToCategory(Category category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(category: category),
      ),
    );
    setState(() {}); // Geri dönüldüğünde kategorileri yenile
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(
        context, '/signin'); // Giriş ekranına yönlendirme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Kategoriler'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/bg2.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(
                    0.5), // Burada opaklık değerini ayarlayabilirsiniz
                BlendMode
                    .dstATop, // Bu blend modu ile resmin üstüne renk eklenir
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF5F5F5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: const Text(
                'Menü',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Ayarlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Çıkış'),
              onTap: () {
                _signOut(); // Çıkış işlemi
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final previewText = category.todolist.isEmpty
              ? '>'
              : category.todolist.length <= 3
                  ? category.todolist.join(', ')
                  : '${category.todolist.sublist(0, 3).join(', ')}...';

          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 5,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(category.title, style: const TextStyle(fontSize: 18)),
              subtitle: Text(
                previewText,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditCategoryDialog(category); // Kategoriyi düzenle
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _removeTodoCategory(category); // Kategoriyi sil
                    },
                  ),
                ],
              ),
              onTap: () {
                _navigateToCategory(category); // Kategoriyi aç
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        tooltip: 'Yeni Kategori Ekle',
        backgroundColor: Color.fromARGB(255, 225, 234, 255),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Category {
  String id;
  String title;
  List<String> todolist;

  Category({required this.id, required this.title, required this.todolist});
}
