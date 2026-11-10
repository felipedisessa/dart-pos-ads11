import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../fotos_api.dart';

class TelaEnviaFoto extends StatefulWidget {
  const TelaEnviaFoto({
    super.key,
    required this.titulo,
    required this.baseUrl,
    this.comDescricao = false,
  });

  final String titulo;
  final String baseUrl;
  final bool comDescricao;

  @override
  State<TelaEnviaFoto> createState() => _TelaEnviaFotoState();
}

class _TelaEnviaFotoState extends State<TelaEnviaFoto> {
  final _descricao = TextEditingController();
  File? _imagem;
  bool _enviando = false;
  String _mensagem = '';

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _tirarFoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() {
        _imagem = File(pickedFile.path);
        _mensagem = '';
      });
    }
  }

  Future<void> _enviar() async {
    final imagem = _imagem;
    if (imagem == null) return;

    setState(() {
      _enviando = true;
      _mensagem = 'Enviando...';
    });

    try {
      final resposta = await FotosApi(widget.baseUrl).enviarFoto(
        imagem,
        texto: widget.comDescricao ? _descricao.text.trim() : null,
      );
      if (!mounted) return;
      setState(() {
        _mensagem = resposta;
        _imagem = null;
        _descricao.clear();
      });
    } catch (e) {
      if (mounted) setState(() => _mensagem = 'Falha: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Destino: ${widget.baseUrl}salva.php',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.grey[200],
              ),
              child: _imagem != null
                  ? Image.file(_imagem!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Nenhuma foto tirada ainda'),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (widget.comDescricao) ...[
              TextField(
                controller: _descricao,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _enviando ? null : _tirarFoto,
              icon: const Icon(Icons.camera),
              label: const Text('Tirar Foto com a Câmera'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_imagem == null || _enviando) ? null : _enviar,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Enviar Foto'),
            ),
            const SizedBox(height: 16),
            if (_enviando) const Center(child: CircularProgressIndicator()),
            Text(_mensagem, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
