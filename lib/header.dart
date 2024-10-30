import 'package:flutter/material.dart';
import './bdd/session_manager.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String nom;
  final bool isAdmin;
  final VoidCallback onLogout;

  const Header({
    Key? key,
    required this.nom,
    required this.isAdmin,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Bienvenue, $nom"),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              // Action pour le bouton Admin (vide pour l'instant)
            },
          ),
        if (isAdmin)
        IconButton(
          icon: const Icon(Icons.telegram),
          onPressed: () {
            // Action pour le bouton Admin (vide pour l'instant)
          },
        ),
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.umbrella_sharp),
            onPressed: () {
              // Action pour le bouton Admin (vide pour l'instant)
            },
          ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
