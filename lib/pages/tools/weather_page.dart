import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:html/parser.dart' show parse;

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission;

    // 检查权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 请求权限
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('定位权限被拒绝');
      }
    }

    // 获取当前位置
    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
  }

  Future<Map<String, dynamic>> _getLocationFromIP() async {
    final response = await http.get(Uri.parse('http://ip-api.com/json/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('无法获取位置信息');
    }
  }

  Future<Map<String, dynamic>> _fetchWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_mean&timezone=auto&forecast_days=4'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('无法获取天气信息');
    }
  }

  Future<Map<String, String>> _getMagneticDeclination(
      double latitude, double longitude) async {
    final url = Uri.parse(
        'https://www.magnetic-declination.com/srvact/?lat=$latitude&lng=$longitude&sec=uko2td8u&act=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      var document = parse(response.body);
      var documentBody = document.body?.text;

      final magneticDeclinationRegExp =
          RegExp(r'Magnetic Declination: ([^°]+° [^ ]+)');
      final declinationRegExp = RegExp(r'Declination is ([^ ]+ \([^)]+\))');
      final inclinationRegExp = RegExp(r'Inclination: ([^°]+° [^ ]+)');
      final magneticFieldRegExp =
          RegExp(r'Magnetic field strength:\s+([^\s]+)');

      final magneticDeclinationMatch =
          magneticDeclinationRegExp.firstMatch(documentBody ?? '');
      final declinationMatch = declinationRegExp.firstMatch(documentBody ?? '');
      final inclinationMatch = inclinationRegExp.firstMatch(documentBody ?? '');
      final magneticFieldMatch =
          magneticFieldRegExp.firstMatch(documentBody ?? '');

      final magneticDeclinationStr = magneticDeclinationMatch?.group(1) ?? '';
      final declinationStr = declinationMatch?.group(1) ?? '';
      final inclinationStr = inclinationMatch?.group(1) ?? '';
      final fieldStrengthValue = magneticFieldMatch?.group(1) ?? '';

      return {
        'magneticdeclination': magneticDeclinationStr,
        'declination': declinationStr,
        'inclination': inclinationStr,
        'magneticField': fieldStrengthValue
      };
    } else {
      throw Exception('Failed to load magnetic declination data');
    }
  }

  String getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return '晴朗';
      case 1:
      case 2:
      case 3:
        return '多云';
      case 45:
      case 48:
        return '有雾';
      case 51:
      case 53:
      case 55:
        return '小雨';
      case 56:
      case 57:
        return '冻雨';
      case 61:
      case 63:
      case 65:
        return '雨';
      case 66:
      case 67:
        return '冻雨';
      case 71:
      case 73:
      case 75:
        return '雪';
      case 77:
        return '雪粒';
      case 80:
      case 81:
      case 82:
        return '暴雨';
      case 85:
      case 86:
        return '大雪';
      case 95:
        return '雷暴';
      case 96:
      case 99:
        return '雷暴伴有冰雹';
      default:
        return '未知';
    }
  }

  IconData getWeatherIcon(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny;
      case 1:
      case 2:
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return Icons.grain;
      case 56:
      case 57:
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('天气查询'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: Platform.isWindows
              ? _getLocationFromIP()
              : _getCurrentLocation().then((position) => {
                    'lat': double.parse(position.latitude.toStringAsFixed(4)),
                    'lon': double.parse(position.longitude.toStringAsFixed(4)),
                    'city': '未知地点',
                    'regionName': ''
                  }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在获取定位信息...'),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('错误: ${snapshot.error}');
            } else {
              var locationData = snapshot.data!;
              double latitude = locationData['lat'];
              double longitude = locationData['lon'];
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchWeather(latitude, longitude),
                builder: (context, weatherSnapshot) {
                  if (weatherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在获取天气信息...'),
                      ],
                    );
                  } else if (weatherSnapshot.hasError) {
                    return Text('天气错误: ${weatherSnapshot.error}');
                  } else {
                    var weatherData = weatherSnapshot.data!;
                    return FutureBuilder<Map<String, String>>(
                      future: _getMagneticDeclination(latitude, longitude),
                      builder: (context, magneticSnapshot) {
                        if (magneticSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('正在获取磁偏角信息...'),
                            ],
                          );
                        } else if (magneticSnapshot.hasError) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '当前位置: ${locationData['city']}, ${locationData['regionName']}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '经纬度: ${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '无法获取磁偏角信息: ${magneticSnapshot.error}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '今天与后三天天气预报',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        for (int i = 0; i < 4; i++)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '日期: ${weatherData['daily']['time'][i]}',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(getWeatherIcon(
                                                        weatherData['daily']
                                                                ['weathercode']
                                                            [i])),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '天气: ${getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                Text(
                                                  '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                const Divider(),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          var magneticData = magneticSnapshot.data!;
                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '当前位置: ${locationData['city']}, ${locationData['regionName']}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '经纬度: ${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '磁偏角: ${magneticData['magneticdeclination']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '偏角方向: ${magneticData['declination']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '倾角: ${magneticData['inclination']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '磁场强度: ${magneticData['magneticField']}nT',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '未来四天天气预报',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 16),
                                          for (int i = 0; i < 4; i++)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '日期: ${weatherData['daily']['time'][i]}',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(getWeatherIcon(
                                                          weatherData['daily'][
                                                                  'weathercode']
                                                              [i])),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '天气: ${getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                        style: const TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  const Divider(),
                                                ],
                                              ),
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
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
