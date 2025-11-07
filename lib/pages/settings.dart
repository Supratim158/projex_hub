import 'package:flutter/material.dart';
import 'package:project_showcase/pages/login/onboarding_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🌈 Gradient Header
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7F7FD5),
                    Color(0xFF86A8E7),
                    Color(0xFF91EAE4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  "Settings ⚙",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            // ⚪ White Body Container
            Container(
              transform: Matrix4.translationValues(0, -25, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧩 Preferences
                  const Text(
                    "Preferences",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildSwitchTile(
                    title: "Dark Mode",
                    subtitle: "Enable dark theme",
                    value: isDarkMode,
                    onChanged: (v) => setState(() => isDarkMode = v),
                  ),
                  _buildSwitchTile(
                    title: "Notifications",
                    subtitle: "Allow push notifications",
                    value: notificationsEnabled,
                    onChanged: (v) => setState(() => notificationsEnabled = v),
                  ),

                  const SizedBox(height: 25),

                  // 👤 Account Section
                  const Text(
                    "Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildOptionTile(
                    icon: Icons.person,
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                  ),
                  _buildOptionTile(
                    icon: Icons.lock,
                    title: "Change Password",
                    subtitle: "Update your account password",
                  ),

                  const SizedBox(height: 25),

                  // ℹ About Section
                  const Text(
                    "About",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.deepPurple,
                      ),
                      title: const Text("About This App"),
                      subtitle: const Text(
                        "Version 1.0.0\nDeveloped by .......",
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🚪 Logout Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (contex)=>OnboardingScreen()));
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Custom Widgets
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(subtitle),
        value: value,
        activeColor: Colors.deepPurple,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.deepPurple,
        ),
        onTap: () {},
      ),
    );
  }
}