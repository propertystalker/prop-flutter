import 'package:flutter/material.dart';

class PropertyFilterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PropertyFilterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: const Icon(Icons.business),
        ),
      ),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('98375', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 16),
          Text('British Land', style: TextStyle(fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://picsum.photos/seed/picsum/200/300'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
