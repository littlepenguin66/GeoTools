import 'package:flutter/material.dart';
import 'add_sample_page.dart'; // 新的页面

class SampleManagementPage extends StatefulWidget {
  const SampleManagementPage({super.key});

  @override
  _SampleManagementPageState createState() => _SampleManagementPageState();
}

class _SampleManagementPageState extends State<SampleManagementPage> {
  // 模拟的历史线路数据
  final List<Map<String, dynamic>> _historyRoutes = [];

  void _addNewRoute() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController routeNameController = TextEditingController();
        return AlertDialog(
          title: const Text('添加新路线'),
          content: TextField(
            controller: routeNameController,
            decoration: const InputDecoration(
              labelText: '路线名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
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
                    const SnackBar(content: Text('请输入路线名称')),
                  );
                }
              },
              child: const Text('确定'),
            ),
          ],
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
              route['samples'].add(sampleInfo); // 添加到对应路线的样品列表
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('样品管理数据库'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('历史线路:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _historyRoutes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4, // 阴影效果
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // 圆角
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: const Icon(Icons.route,
                          color: Color.fromARGB(255, 255, 255, 255)), // 线路图标
                      title: Text(
                        _historyRoutes[index]['routeName'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      contentPadding: const EdgeInsets.all(16), // 内边距
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
        child: const Icon(Icons.add),
      ),
    );
  }
}