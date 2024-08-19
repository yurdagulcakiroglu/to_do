import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/theme/theme.dart';
import 'my_home_page.dart';
import 'profile.dart';
import 'settings.dart';
import '../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth için
import 'package:flutter/services.dart';

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
      QuerySnapshot categoriesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      setState(() {
        categories.clear();
        categoriesSnapshot.docs.forEach((doc) {
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
                        .collection('users')
                        .doc(user.uid)
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
                  User? user = await _auth.getCurrentUser();
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('categories')
                        .doc(category.id)
                        .update({
                      'title': categoryName,
                    });

                    setState(() {
                      category.title = categoryName;
                    });
                  }
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
    User? user = await _auth.getCurrentUser();
    if (user != null) {
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Kategori belgesini al
          DocumentSnapshot categoryDoc = await transaction.get(
            FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('categories')
                .doc(category.id),
          );

          if (categoryDoc.exists) {
            // Kategoriye ait notları al
            QuerySnapshot notesSnapshot =
                await categoryDoc.reference.collection('notes').get();
            for (var noteDoc in notesSnapshot.docs) {
              transaction.delete(noteDoc.reference);
            }

            // Kategori belgesini sil
            transaction.delete(categoryDoc.reference);
          }
        });

        setState(() {
          categories.remove(category); // Seçilen kategoriyi listeden kaldır
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.title} kategorisi silindi'),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () {
                _undoDeleteCategory(category);
              },
            ),
          ),
        );
      } catch (e) {
        print("Kategori silme hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori silme hatası: $e')),
        );
      }
    }
  }

  Future<void> _undoDeleteCategory(Category category) async {
    User? user = await _auth.getCurrentUser();
    if (user != null) {
      try {
        // Geri al işlemi sırasında kategoriyi yeniden ekleyin
        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .add({
          'title': category.title,
          'userId': user.uid,
        });

        setState(() {
          categories.add(Category(
            id: docRef.id,
            title: category.title,
            todolist: [], // Geri alırken notları yeniden eklemeyi düşünmelisiniz
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${category.title} kategorisi geri alındı')),
        );
      } catch (e) {
        print("Kategori geri alma hatası: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori geri alma hatası: $e')),
        );
      }
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

  Future<void> _onBackPressed() async {
    if (Platform.isAndroid) {
      // Android cihazlarda uygulamanın kapanmasını sağla
      SystemNavigator.pop();
    } else {
      // Diğer platformlarda (iOS gibi) kapatma işlemini gerçekleştir
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false, //Geri tuşuna basıldığında önceki ekrana dönülmesini engeller ve uygulamanın kapanmasını sağlar.
      onPopInvoked: (didPop) async {
        return await _onBackPressed();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Kategoriler'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/images/bg2.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.dstATop,
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
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ayarlar'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Çıkış'),
                onTap: () {
                  _signOut();
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
                title: Text(category.title),
                subtitle: Text(previewText),
                onTap: () => _navigateToCategory(category),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCategoryDialog(category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeTodoCategory(category),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCategoryDialog,
          tooltip: 'Kategori Ekle',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class Category {
  String id;
  String title;
  List<String> todolist;

  Category({
    required this.id,
    required this.title,
    required this.todolist,
  });
}
