import 'package:flutter/material.dart';

import '../fotos_api.dart';

/// Slide 8 — Exercício: janela que mostra todas as fotos do seu site,
/// uma por vez.
class TelaGaleria extends StatefulWidget {
  const TelaGaleria({super.key, required this.baseUrl});

  final String baseUrl;

  @override
  State<TelaGaleria> createState() => _TelaGaleriaState();
}

class _TelaGaleriaState extends State<TelaGaleria> {
  List<Foto> _fotos = [];
  int _atual = 0;
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final fotos = await FotosApi(widget.baseUrl).listar();
      if (!mounted) return;
      setState(() {
        _fotos = fotos;
        _atual = 0;
      });
    } catch (e) {
      if (mounted) setState(() => _erro = '$e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria de fotos'),
        actions: [
          IconButton(
            onPressed: _carregando ? null : _carregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _corpo(),
    );
  }

  Widget _corpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Erro: $_erro', textAlign: TextAlign.center),
        ),
      );
    }
    if (_fotos.isEmpty) {
      return const Center(child: Text('Nenhuma foto enviada ainda'));
    }

    final foto = _fotos[_atual];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Foto ${_atual + 1} de ${_fotos.length}  (ID ${foto.id})'),
          const SizedBox(height: 8),
          Expanded(
            child: Image.network(
              foto.url(widget.baseUrl),
              key: ValueKey(foto.id),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progresso) => progresso == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
              errorBuilder: (context, erro, _) => const Center(
                  child: Text('Não foi possível carregar a imagem')),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            foto.texto.isEmpty ? '(sem descrição)' : foto.texto,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _atual > 0 ? () => setState(() => _atual--) : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Anterior'),
              ),
              ElevatedButton.icon(
                onPressed: _atual < _fotos.length - 1
                    ? () => setState(() => _atual++)
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Próxima'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
