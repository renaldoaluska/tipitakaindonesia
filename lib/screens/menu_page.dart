import 'package:flutter/material.dart';
import '../services/sutta.dart';
import '../models/menu.dart';
import 'suttaplex.dart';

class MenuPage extends StatefulWidget {
  final String uid;
  const MenuPage({super.key, required this.uid});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<MenuItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    try {
      // pakai parameter language=id
      final data = await SuttaService.fetchMenu(widget.uid, language: "id");
      final root = (data is List && data.isNotEmpty) ? data[0] : null;
      final children = (root?["children"] as List? ?? []);

      List<MenuItem> items = [];
      for (var child in children) {
        final menuItem = MenuItem.fromJson(child);
        items.add(menuItem);
      }

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch menu: $e");
      setState(() => _loading = false);
    }
  }

  Widget buildMenuItem(MenuItem item) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple,
        child: Text(
          item.acronym.isNotEmpty ? item.acronym : "-",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        item.translatedTitle.isNotEmpty
            ? item.translatedTitle
            : item.originalTitle,
      ),
      subtitle: Text(item.blurb.isNotEmpty ? item.blurb : item.childRange),
      onTap: () {
        if (item.nodeType == "branch") {
          // kalau branch → buka halaman menu lagi
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MenuPage(uid: item.uid)),
          );
        } else {
          // kalau leaf → buka Suttaplex (detail + pilihan bahasa)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Suttaplex(uid: item.uid)),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.uid.toUpperCase())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const Center(child: Text("Data tidak tersedia (menu_page)"))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return buildMenuItem(item);
              },
            ),
    );
  }
}
