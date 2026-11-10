import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Uma foto cadastrada no site (tabela `fotos`).
class Foto {
  Foto({required this.id, required this.nome, this.texto = ''});

  final int id;
  final String nome;
  final String texto;

  factory Foto.fromJson(Map<String, dynamic> json) => Foto(
        id: int.parse(json['id'].toString()),
        nome: json['nome'].toString(),
        texto: (json['texto'] ?? '').toString(),
      );

  /// Endereço completo da imagem no site.
  String url(String baseUrl) => Uri.parse(baseUrl).resolve(nome).toString();
}

/// Comunicação com os scripts PHP (salva.php, mostra_json.php, lista_json.php).
class FotosApi {
  FotosApi(this.baseUrl);

  final String baseUrl;

  Uri _uri(String caminho) => Uri.parse(baseUrl).resolve(caminho);

  /// Hospedagens gratuitas como a InfinityFree (free.nf) respondem com uma
  /// página de verificação em JavaScript a clientes que não são navegadores.
  static void _verificaBloqueio(String corpo) {
    if (corpo.contains('/aes.js') || corpo.contains('__test=')) {
      throw const HttpException(
        'O servidor respondeu com uma verificação anti-robô (JavaScript) em '
        'vez dos dados. Essa hospedagem só aceita navegadores.',
      );
    }
  }

  /// Envia a foto para `salva.php` no campo `foto` (igual ao envia.php),
  /// e opcionalmente uma descrição no campo `texto`.
  Future<String> enviarFoto(File foto, {String? texto}) async {
    final requisicao = http.MultipartRequest('POST', _uri('salva.php'));
    requisicao.files.add(await http.MultipartFile.fromPath('foto', foto.path));
    if (texto != null) {
      requisicao.fields['texto'] = texto;
    }

    final resposta = await http.Response.fromStream(await requisicao.send());
    _verificaBloqueio(resposta.body);

    if (resposta.statusCode != 200) {
      throw HttpException('Erro HTTP ${resposta.statusCode}');
    }

    // salva.php devolve HTML: retira as tags e fica só com as mensagens.
    final texto2 = resposta.body
        .replaceAll(RegExp(r'<title>.*?</title>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (!texto2.contains('Imagem recebida')) {
      throw HttpException(texto2.isEmpty ? 'Erro no envio!' : texto2);
    }
    return texto2;
  }

  /// Busca uma foto pelo id em `mostra_json.php?id=...`.
  Future<Foto> buscarPorId(int id) async {
    final resposta = await http.get(_uri('mostra_json.php?id=$id'));
    _verificaBloqueio(resposta.body);
    if (resposta.statusCode != 200) {
      throw HttpException('Erro HTTP ${resposta.statusCode}');
    }

    final json = jsonDecode(resposta.body) as Map<String, dynamic>;
    if (json.containsKey('erro')) {
      throw HttpException(json['erro'].toString());
    }
    return Foto.fromJson(json);
  }

  /// Lista todas as fotos em `lista_json.php`.
  Future<List<Foto>> listar() async {
    final resposta = await http.get(_uri('lista_json.php'));
    _verificaBloqueio(resposta.body);
    if (resposta.statusCode != 200) {
      throw HttpException('Erro HTTP ${resposta.statusCode}');
    }

    final lista = jsonDecode(resposta.body) as List<dynamic>;
    return lista
        .map((item) => Foto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
