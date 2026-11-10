import 'package:flutter/material.dart';

import 'config.dart';
import 'telas/envia_foto.dart';
import 'telas/galeria.dart';
import 'telas/mostra_foto_id.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Fotos',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: const TelaMenu(),
    );
  }
}

/// Menu do app: tudo usa o meu site local (XAMPP).
class TelaMenu extends StatefulWidget {
  const TelaMenu({super.key});

  @override
  State<TelaMenu> createState() => _TelaMenuState();
}

class _TelaMenuState extends State<TelaMenu> {
  void _abrir(Widget tela) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => tela));
  }

  Future<void> _editarMeuSite() async {
    final controle = TextEditingController(text: Config.meuSite);
    final novo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Endereço do meu site'),
        content: TextField(
          controller: controle,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            helperText: 'Emulador: http://10.0.2.2/site_fotos/',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controle.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controle.dispose();
    if (novo != null && novo.isNotEmpty) {
      setState(() => Config.meuSite = novo.endsWith('/') ? novo : '$novo/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Fotos')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const _Secao('Meu site (XAMPP)'),
          _Item(
            icone: Icons.settings_ethernet,
            titulo: 'Endereço do meu site',
            subtitulo: Config.meuSite,
            onTap: _editarMeuSite,
          ),
          _Item(
            icone: Icons.add_a_photo,
            titulo: 'Enviar foto + descrição',
            subtitulo: 'Slide 8 — envia para o meu site',
            onTap: () => _abrir(TelaEnviaFoto(
              titulo: 'Enviar para meu site',
              baseUrl: Config.meuSite,
              comDescricao: true,
            )),
          ),
          _Item(
            icone: Icons.photo_library,
            titulo: 'Galeria de fotos',
            subtitulo: 'Slide 8 — galeria do meu site',
            onTap: () => _abrir(TelaGaleria(baseUrl: Config.meuSite)),
          ),
          _Item(
            icone: Icons.image_search,
            titulo: 'Buscar foto por id',
            subtitulo: '${Config.meuSite}mostra_json.php',
            onTap: () => _abrir(TelaMostraFotoId(baseUrl: Config.meuSite)),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
      child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  final IconData icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icone),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
