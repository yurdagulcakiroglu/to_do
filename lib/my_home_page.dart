import 'package:flutter/material.dart';
import 'category_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.category});

  final Category category;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<String> todolist = []; // Boş bir liste ile başlat
  List<String> filteredLists = [];
  Map<String, bool> checkedItems = {};
  Map<String, String> descriptions = {};
  Map<String, String> itemImageUrls = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser; // Mevcut kullanıcıyı al
    _loadNotes(); // Firestore'dan notları yükle
  }

  void _loadNotes() async {
    User? user = _auth.currentUser; // Kullanıcıyı al
    if (user != null) {
      final notesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(widget.category.id)
          .collection('notes')
          .get();

      final notes = notesSnapshot.docs.map((doc) => doc.data()).toList();
      setState(() {
        todolist = notes.map((note) => note['title'] as String).toList();
        filteredLists = List.from(todolist);
        filteredLists.sort();
        for (var note in notes) {
          String item = note['title'] as String;

          checkedItems[item] = false;
          descriptions[item] = note['description'] as String? ?? '';
          itemImageUrls[item] = note['image'] as String? ?? '';
        }
      });
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
              labelText: 'Yazınız..',
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
              onPressed: () async {
                final String itemName = controller.text;
                if (itemName.isNotEmpty) {
                  try {
                    if (_currentUser != null) {
                      final newNote = {
                        'title': itemName,
                        'createdAt': Timestamp.now(),
                        'description': '',
                      };

                      await _firestore
                          .collection('users')
                          .doc(_currentUser!.uid)
                          .collection('categories')
                          .doc(widget.category.id)
                          .collection('notes')
                          .doc(itemName)
                          .set(newNote);

                      setState(() {
                        todolist.add(itemName);
                        filteredLists = List.from(todolist);
                        filteredLists.sort();
                        checkedItems[itemName] = false;
                        descriptions[itemName] = '';
                      });
                      Navigator.of(context).pop(); // Dialogu kapat
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kullanıcı oturum açmamış.'),
                        ),
                      );
                    }
                  } catch (e) {
                    print("Error adding note: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not eklenirken bir hata oluştu.'),
                      ),
                    );
                  }
                }
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
              onPressed: () async {
                final String newItem = controller.text;
                if (newItem.isNotEmpty) {
                  final oldItem = filteredLists[index];
                  await _firestore
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('categories')
                      .doc(widget.category.id)
                      .collection('notes')
                      .doc(oldItem)
                      .update({
                    'title': newItem,
                    'updatedAt': Timestamp.now(),
                  });

                  setState(() {
                    filteredLists[index] = newItem;
                    todolist[todolist.indexOf(oldItem)] = newItem;
                    checkedItems.remove(oldItem);
                    checkedItems[newItem] = false;
                    descriptions[newItem] = descriptions[oldItem] ?? '';
                    descriptions.remove(oldItem);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            )
          ],
        );
      },
    );
  }

  void _removeTodoItem(int index) async {
    final itemName = filteredLists[index];
    await _firestore
        .collection('users')
        .doc(_currentUser!.uid)
        .collection('categories')
        .doc(widget.category.id)
        .collection('notes')
        .doc(itemName)
        .delete();

    setState(() {
      filteredLists.removeAt(index);
      todolist.remove(itemName);
      checkedItems.remove(itemName);
      descriptions.remove(itemName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$itemName silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () async {
            // Geri al işlemi için opsiyonel bir yapı ekleyebilirsiniz.
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
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = controller.text;
                if (description.isNotEmpty) {
                  try {
                    await _firestore
                        .collection('users')
                        .doc(_currentUser!.uid)
                        .collection('categories')
                        .doc(widget.category.id)
                        .collection('notes')
                        .doc(item)
                        .update({
                      'description': description,
                      'updatedAt': Timestamp.now(),
                    });

                    setState(() {
                      descriptions[item] = description;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    print("Error updating description: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Açıklama eklenirken bir hata oluştu.'),
                      ),
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

  void _showAddAttachmentDialog(String item, String type) async {
    final ImagePicker _picker = ImagePicker();
    XFile? image;

    if (type == 'image') {
      image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        try {
          final ref = FirebaseStorage.instance
              .ref()
              .child('notes')
              .child(item)
              .child(DateTime.now().toString() + '.png');
          await ref.putFile(File(image.path));
          final imageUrl = await ref.getDownloadURL();

          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('categories')
              .doc(widget.category.id)
              .collection('notes')
              .doc(item)
              .update({
            'image': imageUrl,
            'updatedAt': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görsel başarıyla eklendi.'),
            ),
          );
        } catch (e) {
          print("Error adding image: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görsel eklenirken bir hata oluştu.'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.category.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage('assets/images/bg2.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), BlendMode.dstATop),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    descriptions[item]!,
                                    style: const TextStyle(
                                      color: Color(0xFF7A7A7A),
                                      fontSize: 14.0,
                                    ),
                                  ),
                                  if (itemImageUrls[item] != null &&
                                      itemImageUrls[item]!
                                          .isNotEmpty) // Görsel URL'si varsa göster
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(
                                        itemImageUrls[item]!,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ],
                              ),

                            // Ekler için bir sıra düğme ekleyebilirsiniz
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.photo),
                                  onPressed: () {
                                    _showAddAttachmentDialog(item, 'image');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.description),
                                  onPressed: () {
                                    _showAddDescriptionDialog(item);
                                  },
                                ),
                              ],
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
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
