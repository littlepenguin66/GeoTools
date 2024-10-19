import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart' show parse;

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  Future<Position> _getCurrentLocation() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('定位权限被拒绝');
      }
    }
    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high));
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
      final locationRegExp = RegExp(r'([A-Z\s]+)\nMagnetic Declination');

      final magneticDeclinationMatch =
          magneticDeclinationRegExp.firstMatch(documentBody ?? '');
      final declinationMatch = declinationRegExp.firstMatch(documentBody ?? '');
      final inclinationMatch = inclinationRegExp.firstMatch(documentBody ?? '');
      final magneticFieldMatch =
          magneticFieldRegExp.firstMatch(documentBody ?? '');
      final locationMatch = locationRegExp.firstMatch(documentBody ?? '');

      return {
        'magneticdeclination': magneticDeclinationMatch?.group(1) ?? '',
        'declination': declinationMatch?.group(1) ?? '',
        'inclination': inclinationMatch?.group(1) ?? '',
        'magneticField': magneticFieldMatch?.group(1) ?? '',
        'city': locationMatch?.group(1) ?? '未知地点',
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
      case 66:
      case 67:
        return '冻雨';
      case 61:
      case 63:
      case 65:
        return '雨';
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
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 56:
      case 57:
      case 66:
      case 67:
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.flash_on;
      default:
        return Icons.help;
    }
  }

  Widget _buildLoading(String message, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
        ),
        const SizedBox(height: 16),
        Text(message, style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildError(String message, ThemeData theme) {
    return Center(
      child: Text('错误: $message', style: theme.textTheme.bodyMedium),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 获取当前主题
    final appBarColor = theme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white; // 设置顶部栏颜色
    final appBarTextColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black; // 设置顶部栏字体和图标颜色

    return Scaffold(
      appBar: AppBar(
        title: Text('天气查询', style: TextStyle(color: appBarTextColor)),
        centerTitle: true,
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor), // 设置图标颜色
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getCurrentLocation().then((position) => {
                'lat': double.parse(position.latitude.toStringAsFixed(4)),
                'lon': double.parse(position.longitude.toStringAsFixed(4))
              }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading('正在获取定位信息...', theme);
            } else if (snapshot.hasError) {
              return _buildError(snapshot.error.toString(), theme);
            } else {
              var locationData = snapshot.data!;
              double latitude = locationData['lat'];
              double longitude = locationData['lon'];
              return FutureBuilder<Map<String, dynamic>>(
                future: _fetchWeather(latitude, longitude),
                builder: (context, weatherSnapshot) {
                  if (weatherSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoading('正在获取天气信息...', theme);
                  } else if (weatherSnapshot.hasError) {
                    return _buildError(weatherSnapshot.error.toString(), theme);
                  } else {
                    var weatherData = weatherSnapshot.data!;
                    return FutureBuilder<Map<String, String>>(
                      future: _getMagneticDeclination(latitude, longitude),
                      builder: (context, magneticSnapshot) {
                        if (magneticSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoading('正在获取磁偏角信息...', theme);
                        } else if (magneticSnapshot.hasError) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Card(
                                  elevation: 5,
                                  color: theme.cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '当前位置: ${magneticSnapshot.data?['city']}, ${magneticSnapshot.data?['regionName']}',
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '经纬度: ${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '无法获取磁偏角信息: ${magneticSnapshot.error}',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  elevation: 5,
                                  color: theme.cardColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '今天与后三天天气预报',
                                          style: theme.textTheme.bodyLarge,
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
                                                  style: theme
                                                      .textTheme.bodyMedium,
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                        getWeatherIcon(
                                                            weatherData['daily']
                                                                    [
                                                                    'weathercode']
                                                                [i]),
                                                        color: theme
                                                            .iconTheme.color),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '天气: ${getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                      style: theme
                                                          .textTheme.bodyMedium,
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                  style: theme
                                                      .textTheme.bodyMedium,
                                                ),
                                                Text(
                                                  '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                  style: theme
                                                      .textTheme.bodyMedium,
                                                ),
                                                Text(
                                                  '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                  style: theme
                                                      .textTheme.bodyMedium,
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
                                    color: theme.cardColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '当前位置: ${magneticData['city']}',
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '经纬度: ${latitude.toStringAsFixed(4)}° N, ${longitude.toStringAsFixed(4)}° E',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '磁偏角: ${magneticData['magneticdeclination']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            '偏角方向: ${magneticData['declination']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '倾角: ${magneticData['inclination']}',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '磁场强度: ${magneticData['magneticField']}nT',
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Card(
                                    elevation: 5,
                                    color: theme.cardColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '未来四天天气预报',
                                            style: theme.textTheme.bodyLarge,
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
                                                    style: theme
                                                        .textTheme.bodyMedium,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          getWeatherIcon(weatherData[
                                                                      'daily'][
                                                                  'weathercode']
                                                              [i]),
                                                          color: theme
                                                              .iconTheme.color),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '天气: ${getWeatherDescription(weatherData['daily']['weathercode'][i])}',
                                                        style: theme.textTheme
                                                            .bodyMedium,
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '降雨概率: ${weatherData['daily']['precipitation_probability_mean'][i]}%',
                                                    style: theme
                                                        .textTheme.bodyMedium,
                                                  ),
                                                  Text(
                                                    '最高温度: ${weatherData['daily']['temperature_2m_max'][i]}°C',
                                                    style: theme
                                                        .textTheme.bodyMedium,
                                                  ),
                                                  Text(
                                                    '最低温度: ${weatherData['daily']['temperature_2m_min'][i]}°C',
                                                    style: theme
                                                        .textTheme.bodyMedium,
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
