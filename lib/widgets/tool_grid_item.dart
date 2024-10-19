import 'package:flutter/material.dart';
import '../models/tool.dart';

class ToolGridItem extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;

  const ToolGridItem({super.key, required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: isDarkMode ? Colors.black : Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              size: 48.0,
              color: textColor,
            ),
            const SizedBox(height: 8.0),
            Text(
              tool.name,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}