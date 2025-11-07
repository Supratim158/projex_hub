import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_showcase/pages/all_projects.dart';
import '../../config/size_config.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 47,
        left: SizeConfig.defaultWidth,
        right: SizeConfig.defaultWidth,
      ),
      child: Row(
        children: [
          // Menu Button
          // CircleAvatar(
          //   backgroundColor: Colors.white70,
          //   child: IconButton(
          //     onPressed: () {
          //       Scaffold.of(context).openDrawer();
          //     },
          //     icon: const Icon(
          //       Icons.menu,
          //       color: Colors.black,
          //     ),
          //   ),
          // ),
          //
          // const SizedBox(width: 10),

          // Search Bar (acts like a button)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProjectsPage(), // 👈 Your search page
                  ),
                );
              },
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      "Search...",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


