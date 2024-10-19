import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';
import '../main.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme == ThemeProvider.darkTheme;

    final appearanceTextColor = isDarkMode ? Colors.white : Colors.black;
    final aboutTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: appearanceTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDarkMode ? Colors.black : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: appearanceTextColor,
                        ),
                      ),
                      value: isDarkMode,
                      onChanged: (bool value) {
                        themeProvider.toggleTheme();
                      },
                      secondary: Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: appearanceTextColor,
                      ),
                      activeColor: Colors.white,
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: aboutTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDarkMode ? Colors.black : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.info, color: aboutTextColor),
                      title: Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: aboutTextColor,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: aboutTextColor),
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme == ThemeProvider.darkTheme;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Drawer(
      child: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CUGB-GeoTools',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tools for Geologists',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: textColor),
              title: Text('Toolbox', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'Toolbox')),
                );
              },
            ),
            Divider(
              color: textColor.withOpacity(0.5),
              height: 1,
            ),
            ListTile(
              leading: Icon(Icons.settings, color: textColor),
              title: Text('Settings', style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About'),
          content: const Text('This is a simple app for geologists.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}