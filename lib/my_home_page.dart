import 'package:flutter/material.dart';
import 'category_page.dart';

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

  void _filterList(String query) {
    setState(() {
      filteredLists = todolist
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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

  void _showEditItemDialog(int index) {
    final String currentItem = filteredLists[index];
    final TextEditingController controller =
        TextEditingController(text: currentItem);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ögeyi Düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Öge',
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
                final String newItem = controller.text;
                if (newItem.isNotEmpty) {
                  setState(() {
                    final oldItem = filteredLists[index];
                    filteredLists[index] = newItem;
                    todolist[todolist.indexOf(oldItem)] = newItem;
                    widget.category.todolist[
                        widget.category.todolist.indexOf(oldItem)] = newItem;
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
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              filteredLists.add(itemName);
              filteredLists.sort(); // Sıralı hale getir
              todolist.add(itemName);
              widget.category.todolist.add(itemName);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterList,
              decoration: const InputDecoration(
                labelText: 'Ara',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLists.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(filteredLists[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditItemDialog(index); // Ögeyi düzenle
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeTodoItem(index); // Ögeyi sil
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        tooltip: 'Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
