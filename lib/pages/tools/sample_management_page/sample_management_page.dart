import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_sample_page.dart';
import '../../../theme_provider.dart';

class SampleManagementPage extends StatefulWidget {
  const SampleManagementPage({super.key});

  @override
  _SampleManagementPageState createState() => _SampleManagementPageState();
}

class _SampleManagementPageState extends State<SampleManagementPage> {
  final List<Map<String, dynamic>> _historyRoutes = [];

  void _addNewRoute() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController routeNameController = TextEditingController();
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isDarkMode =
                themeProvider.currentTheme.brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
              title: Text(
                '添加新路线',
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              content: TextField(
                controller: routeNameController,
                decoration: InputDecoration(
                  labelText: '路线名称',
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                style:
                    TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    if (routeNameController.text.isNotEmpty) {
                      setState(() {
                        _historyRoutes.add({
                          'routeName': routeNameController.text,
                          'samples': <Map<String, dynamic>>[]
                        });
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '请输入路线名称',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          backgroundColor:
                              isDarkMode ? Colors.black : Colors.white,
                        ),
                      );
                    }
                  },
                  child: Text('确定',
                      style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToAddSample(Map<String, dynamic> route) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddSamplePage(
          routeName: route['routeName'],
          samples: route['samples'] as List<Map<String, dynamic>>,
          onSampleAdded: (sampleInfo) {
            setState(() {
              route['samples'].add(sampleInfo);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('样品管理数据库'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '历史线路:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _historyRoutes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: isDarkMode ? Colors.black : Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.route,
                          color: isDarkMode ? Colors.white : Colors.black),
                      title: Text(
                        _historyRoutes[index]['routeName'],
                        style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () {
                        _navigateToAddSample(_historyRoutes[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRoute,
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
        child: Icon(Icons.add, color: isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}
