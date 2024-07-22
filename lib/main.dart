import 'package:flutter/material.dart';

void main() {
  runApp(Deneme());
}

class Deneme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uygulama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoryPage(),
    );
  }
}

class CategoryPage extends StatefulWidget {
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

  void _removeTodoCategory(Category category) {
    setState(() {
      categories.remove(category); // Seçilen kategoriyi listeden kaldır
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category.name} kategorisi silindi'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriler'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _removeTodoCategory(categories[index]); // Kategoriyi sil
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyHomePage(category: categories[index]),
                ),
              );
            },
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.category});

  final Category category;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> todolist;
  List<String> filteredLists = [];

  @override
  void initState() {
    super.initState();
    todolist = List.from(widget.category.todolist); // Listeyi kopyala
    filteredLists = List.from(todolist); // Filtreli listeyi kopyala
    filteredLists.sort(); // Başlangıçta sıralı
  }

  void _showAddItemDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'yazınız..',
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
                final String itemName = controller.text;
                if (itemName.isNotEmpty) {
                  setState(() {
                    todolist.add(itemName);
                    filteredLists = List.from(todolist); // Listeyi güncelle
                  });
                  widget.category.todolist.add(itemName);
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

  void _removeTodoItem(int index) {
    final itemName = filteredLists[index];
    setState(() {
      filteredLists.removeAt(index);
      todolist.remove(itemName);
      widget.category.todolist.remove(itemName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName silindi'), // Silinen öğe burada gösteriliyor
      ),
    );
  }

  void _filterList(String query) {
    final filtered = todolist.where((toDoItem) {
      return toDoItem.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredLists = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 191, 162, 249),
        title: Text(widget.category.name),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: _filterList,
              decoration: const InputDecoration(
                hintText: 'Ara',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search), // Büyüteç ikonu ekleme
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredLists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredLists[index]),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _removeTodoItem(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Yeni Öge Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Category {
  final String
      id; // Kategoriyi benzersiz şekilde tanımlamak için eklenen özellik
  final String name;
  final List<String> todolist;

  Category({required this.id, required this.name, required this.todolist});
}
