import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController dipDirectionController = TextEditingController();
  final TextEditingController dipAngleController = TextEditingController();
  String result = '';
  String conversionResult = '';

  void calculate() {
    double dipDirection = double.tryParse(dipDirectionController.text) ?? 0;
    double dipAngle = double.tryParse(dipAngleController.text) ?? 0;

    double alpha = dipAngle * (pi / 180); // 转换为弧度
    double omega = (dipDirection + 270) * (pi / 180); // 转换为弧度

    double tanBeta = tan(alpha) * cos(omega);
    double beta = atan(tanBeta); // 结果为弧度

    // 将弧度转换为度
    double betaDegrees = beta * (180 / pi);
    int degrees = betaDegrees.floor();
    double minutesDecimal = (betaDegrees - degrees) * 60;
    int minutes = minutesDecimal.floor();
    double seconds = (minutesDecimal - minutes) * 60;

    setState(() {
      result = '$degrees° $minutes\' ${seconds.toStringAsFixed(2)}"';
    });
  }

  void clear() {
    dipDirectionController.clear();
    dipAngleController.clear();
    setState(() {
      result = '';
      conversionResult = '';
    });
  }

  void convertDegreesToRadians(double degrees) {
    double radians = degrees * (pi / 180);
    setState(() {
      conversionResult = '${radians.toStringAsFixed(2)} rad';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.currentTheme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('视倾角计算器'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(
                    dipDirectionController, '岩层走向与剖面方向间夹角 (°)', isDarkMode),
                const SizedBox(height: 16),
                _buildTextField(dipAngleController, '真倾角 (°)', isDarkMode),
                const SizedBox(height: 20),
                _buildElevatedButton('计算', calculate, isDarkMode),
                const SizedBox(height: 10),
                _buildElevatedButton('清除', clear, isDarkMode),
                const SizedBox(height: 20),
                Text(
                  result,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('常用转换',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _buildConversionButton('度转弧度', (double value) {
                  convertDegreesToRadians(value);
                }, isDarkMode),
                const SizedBox(height: 10),
                Text(
                  conversionResult,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDarkMode ? Colors.black : Colors.white,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        keyboardType: TextInputType.number,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildElevatedButton(
      String label, VoidCallback onPressed, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.white : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildConversionButton(
      String label, Function(double) onConvert, bool isDarkMode) {
    return ElevatedButton(
      onPressed: () {
        double inputValue =
            double.tryParse(dipAngleController.text) ?? 0; // 从输入框获取值并转换
        onConvert(inputValue);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.black : Colors.white),
      ),
    );
  }
}
