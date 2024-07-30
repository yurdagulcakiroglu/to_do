import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do/theme/theme.dart';
import 'my_home_page.dart';
import 'profile.dart';
import 'settings.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Category> categories = [];

  void _showAddCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              onPressed: () {
                final String categoryName = controller.text;
                if (categoryName.isNotEmpty) {
                  setState(() {
                    final String categoryId =
                        DateTime.now().toString(); // Benzersiz id oluşturma
                    categories.add(Category(
                        id: categoryId, name: categoryName, todolist: []));
                  });
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
        TextEditingController(text: category.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              onPressed: () {
                final String categoryName = controller.text;
                if (categoryName.isNotEmpty) {
                  setState(() {
                    category.name = categoryName; // Kategori adını güncelle
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

  void _removeTodoCategory(Category category) {
    setState(() {
      categories.remove(category); // Seçilen kategoriyi listeden kaldır
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} kategorisi silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              categories.add(category); // Silinen kategoriyi geri al
            });
          },
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
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
                // Çıkış işlemi
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
              title: Text(category.name, style: const TextStyle(fontSize: 18)),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Category {
  String id;
  String name;
  List<String> todolist;

  Category({required this.id, required this.name, required this.todolist});
}
