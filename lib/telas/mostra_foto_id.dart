import 'package:flutter/material.dart';

import '../fotos_api.dart';

/// Mostra uma foto dado um id, usando o `mostra_json.php?id=...` do meu site
/// (mesma ideia do slide 7).
class TelaMostraFotoId extends StatefulWidget {
  const TelaMostraFotoId({super.key, required this.baseUrl});

  final String baseUrl;

  @override
  State<TelaMostraFotoId> createState() => _TelaMostraFotoIdState();
}

class _TelaMostraFotoIdState extends State<TelaMostraFotoId> {
  final _id = TextEditingController(text: '2');
  Future<Foto>? _foto;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  void _buscar() {
    final id = int.tryParse(_id.text.trim());
    if (id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Digite um id numérico')));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _foto = FotosApi(widget.baseUrl).buscarPorId(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar foto por id')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _id,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Id da foto',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _buscar(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _buscar, child: const Text('Mostrar')),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _foto == null
                  ? const Center(child: Text('Digite um id e toque em Mostrar'))
                  : FutureBuilder<Foto>(
                      future: _foto,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Erro: ${snapshot.error}',
                                  textAlign: TextAlign.center));
                        }
                        final foto = snapshot.data!;
                        return Column(
                          children: [
                            Text('ID: ${foto.id} — ${foto.nome}',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Image.network(
                                foto.url(widget.baseUrl),
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, progresso) =>
                                    progresso == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator()),
                                errorBuilder: (context, erro, _) => const Center(
                                    child: Text('Não foi possível carregar a imagem')),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
