import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.112:8000";

  static Future<Map<String, dynamic>> login(String user, String pass) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: { "Content-Type": "application/json" },
      body: jsonEncode({
        "username": user,
        "password": pass,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Error en login: ${res.body}");
    }

    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<List<dynamic>> obtenerPaquetes(int usuarioId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/paquetes/$usuarioId"),
    );

    if (res.statusCode != 200) {
      throw Exception("Error al obtener paquetes");
    }

    return jsonDecode(utf8.decode(res.bodyBytes));
  }

  static Future<bool> enviarEntrega({
    required int paqueteId,
    required double lat,
    required double lng,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    final uri = Uri.parse("$baseUrl/entregar-paquete");
    final request = http.MultipartRequest("POST", uri);

    request.fields["paquete_id"] = paqueteId.toString();
    request.fields["latitud"] = lat.toString();
    request.fields["longitud"] = lng.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        "foto",
        Uint8List.fromList(fileBytes),
        filename: fileName,
      ),
    );

    final response = await request.send();
    return response.statusCode == 200;
  }
}
