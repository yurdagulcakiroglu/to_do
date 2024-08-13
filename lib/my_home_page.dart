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
  Map<String, bool> checkedItems = {};
  Map<String, String> descriptions = {};

  @override
  void initState() {
    super.initState();
    todolist = List.from(widget.category.todolist);
    filteredLists = List.from(todolist);
    filteredLists.sort();
    for (var item in todolist) {
      checkedItems[item] = false;
      descriptions[item] = '';
    }
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
          backgroundColor: const Color(0xFFF5F5F5),
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
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                final String itemName = controller.text;
                if (itemName.isNotEmpty) {
                  setState(() {
                    todolist.add(itemName);
                    filteredLists = List.from(todolist);
                    checkedItems[itemName] = false;
                    descriptions[itemName] = '';
                  });
                  widget.category.todolist.add(itemName);
                }
                Navigator.of(context).pop();
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
                Navigator.of(context).pop();
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
                    checkedItems.remove(oldItem);
                    checkedItems[newItem] = false;
                    descriptions[newItem] = descriptions[oldItem] ?? '';
                    descriptions.remove(oldItem);
                  });
                }
                Navigator.of(context).pop();
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
      checkedItems.remove(itemName);
      descriptions.remove(itemName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () {
            setState(() {
              filteredLists.add(itemName);
              filteredLists.sort();
              todolist.add(itemName);
              widget.category.todolist.add(itemName);
              checkedItems[itemName] = false;
              descriptions[itemName] = '';
            });
          },
        ),
      ),
    );
  }

  void _showAddDescriptionDialog(String item) {
    final TextEditingController controller =
        TextEditingController(text: descriptions[item]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Açıklama Ekle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  descriptions[item] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.category.name),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg2.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40.0,
              child: TextField(
                onChanged: _filterList,
                decoration: const InputDecoration(
                  hintText: 'Ara',
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLists.length,
              itemBuilder: (context, index) {
                final item = filteredLists[index];
                return Card(
                  child: ExpansionTile(
                    leading: Checkbox(
                      value: checkedItems[item],
                      onChanged: (bool? value) {
                        setState(() {
                          checkedItems[item] = value ?? false;
                        });
                      },
                    ),
                    title: Text(
                      item,
                      style: TextStyle(
                        decoration: checkedItems[item]!
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditItemDialog(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _removeTodoItem(index);
                          },
                        ),
                      ],
                    ),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (descriptions[item]!.isNotEmpty)
                              Text(
                                descriptions[item]!,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14.0),
                              ),
                            ElevatedButton(
                              onPressed: () {
                                _showAddDescriptionDialog(item);
                              },
                              child: const Text('Açıklama Ekle'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Resim ekleme işlevi
                              },
                              child: const Text('Resim Ekle'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Ses ekleme işlevi
                              },
                              child: const Text('Ses Ekle'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Cihaz verileri ekleme işlevi
                              },
                              child: const Text('Cihaz Verisi Ekle'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF5F5F5),
        onPressed: _showAddItemDialog,
        tooltip: 'Ekle',
        child: const Icon(Icons.add),
      ),
    );
  }
}
