import 'package:flutter/material.dart';
import 'package:flutter_coding/profile.dart';
import './camembert.dart';
import './bdd/session_manager.dart';


class Header extends StatefulWidget implements PreferredSizeWidget {
  final String nom;
  final bool isAdmin;
  final Object id;
  final VoidCallback onLogout;

  const Header({
    Key? key,
    required this.nom,
    required this.isAdmin,
    required this.id,
    required this.onLogout,
  }) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.nom),
      actions: [
        if (widget.isAdmin)
          IconButton(
            icon: Icon(Icons.pie_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PieChartPage()),
              );
            },
          ),
        if (widget.isAdmin)
          IconButton(
            icon: Icon(Icons.admin_panel_settings),
            onPressed: () {},
          ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(id: widget.id.toString()),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: widget.onLogout,
        ),
      ],
    );
  }
}
