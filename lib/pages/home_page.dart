import 'package:flutter/material.dart';
import '../models/tool.dart';
import '../widgets/tool_grid_item.dart';
import 'tools/calculator_page.dart';
import 'tools/weather_page.dart';
import 'tools/sample_management_page/sample_management_page.dart'; // Add this line

class HomePage extends StatelessWidget {
  final List<Tool> tools = [
    Tool(
      name: '视倾角计算器',
      icon: Icons.calculate,
    ),
    Tool(
      name: '地区天气磁偏角查询',
      icon: Icons.cloud,
    ),
    Tool(
      name: '样品管理',
      icon: Icons.library_books,
    ),
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // 设置左右间距
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // 设置每个单元格的最大宽度
            childAspectRatio: 1.0, // 宽高比
            crossAxisSpacing: 16, // 水平间距
            mainAxisSpacing: 16, // 垂直间距
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            return ToolGridItem(
              tool: tools[index],
              onTap: () {
                switch (tools[index].name) {
                  case '视倾角计算器':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalculatorPage(),
                      ),
                    );
                    break;
                  case '地区天气磁偏角查询':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WeatherPage(),
                      ),
                    );
                    break;
                  case '样品管理':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SampleManagementPage(),
                      ),
                    );
                    break;
                  default:
                    break;
                }
              },
            );
          },
        ),
      ),
    );
  }
}
