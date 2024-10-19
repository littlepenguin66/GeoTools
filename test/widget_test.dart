import 'package:http/http.dart' as http;

Future<void> fetchMagneticDeclination(double latitude, double longitude) async {
  final url = Uri.parse(
      'https://www.magnetic-declination.com/srvact/?lat=$latitude&lon=$longitude&sec=uko2td8u&act=1');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
    // 解析响应内容
  } else {
    print('Failed to fetch data. Status code: ${response.statusCode}');
  }
}
