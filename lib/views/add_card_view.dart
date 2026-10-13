import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/card_model.dart';
import '../utils/barcode_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/card_viewmodel.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _titleController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedColorHex = '#3F51B5'; // Indigo default
  String? _selectedCategory;

  // Valore e formato letti dalla fotocamera: il formato vale solo finché
  // l'utente non modifica a mano il codice.
  String? _scannedCode;
  String? _scannedFormat;

  bool _isScanning = false;

  final List<Map<String, String>> _predefinedColors = [
    {'name': 'Rosso', 'hex': '#E53935'},
    {'name': 'Verde', 'hex': '#43A047'},
    {'name': 'Blu', 'hex': '#1E88E5'},
    {'name': 'Arancione', 'hex': '#F4511E'},
    {'name': 'Viola', 'hex': '#8E24AA'},
    {'name': 'Indigo', 'hex': '#3F51B5'},
    {'name': 'Teal', 'hex': '#00897B'},
    {'name': 'Nero', 'hex': '#212121'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _simulateScan() async {
    setState(() {
      _isScanning = true;
    });

    // Simulate camera scan delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final random = Random();
    final List<Map<String, String>> mockCards = [
      {
        'title': 'Coop',
        'barcode': '2012345678901',
        'format': 'EAN13',
        'color': '#E53935',
      },
      {
        'title': 'Esselunga',
        'barcode': '04123456',
        'format': 'EAN8',
        'color': '#F4511E',
      },
      {
        'title': 'Decathlon',
        'barcode': '3589624512586',
        'format': 'CODE128',
        'color': '#1E88E5',
      },
      {
        'title': 'Conad',
        'barcode': '8001234567890',
        'format': 'EAN13',
        'color': '#43A047',
      },
      {
        'title': 'Ikea Family',
        'barcode': '990123456789',
        'format': 'CODE128',
        'color': '#F4511E',
      },
    ];

    final chosen = mockCards[random.nextInt(mockCards.length)];

    setState(() {
      _isScanning = false;
      _titleController.text = chosen['title']!;
      _barcodeController.text = chosen['barcode']!;
      _scannedCode = chosen['barcode']!;
      _scannedFormat = chosen['format']!;
      _selectedColorHex = chosen['color']!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scansionata carta: ${chosen['title']}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startRealScan() {
    // onDetect scatta più volte per lo stesso codice: senza questo flag il
    // secondo pop chiuderebbe anche la pagina sottostante.
    var handled = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (sheetContext) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Scansiona Codice',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Stack(
            children: [
              MobileScanner(
                onDetect: (capture) {
                  if (handled) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final scannedCode = barcodes.first.rawValue;
                    final scannedFormat = barcodes.first.format;
                    if (scannedCode != null) {
                      handled = true;
                      final formatStr = formatFromScanner(scannedFormat);

                      setState(() {
                        _barcodeController.text = scannedCode;
                        _scannedCode = scannedCode;
                        _scannedFormat = formatStr;
                      });

                      Navigator.pop(sheetContext); // Close scanner sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Codice scansionato: $scannedCode (${scannedFormat.name})',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
              ),
              Center(
                child: Container(
                  width: 280,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Inquadra il codice a barre o QR',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final cardViewModel = context.watch<CardViewModel>();
    final username = authViewModel.currentUser?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aggiungi Tessera',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          // 68 navbar + 24 margin + system safe area (e.g. home gesture bar)
          24 + 68 + 24 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner Simulator Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 180,
                  color: Colors.black87,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_isScanning) ...[
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.redAccent),
                            SizedBox(height: 16),
                            Text(
                              'Inquadra il codice a barre...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Scanner red line simulation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          builder: (context, value, child) {
                            return Positioned(
                              top: 20 + (140 * value),
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 2,
                                color: Colors.redAccent,
                              ),
                            );
                          },
                          onEnd: () {
                            if (_isScanning) {
                              setState(() {}); // loop animation
                            }
                          },
                        ),
                      ] else ...[
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.network(
                              'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?auto=format&fit=crop&q=80&w=400',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.qr_code_scanner,
                              size: 40,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _startRealScan,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Scansiona'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dettagli Tessera',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Nome Negozio / Tessera',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Codice a Barre / Numero',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoria (opzionale)',
                prefixIcon: const Icon(Icons.folder_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nessuna categoria'),
                ),
                ...cardViewModel.categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c,
                    child: Text(c),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedCategory = val;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Scegli il Colore della Carta',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _predefinedColors.length,
                itemBuilder: (context, index) {
                  final colorItem = _predefinedColors[index];
                  final hex = colorItem['hex']!;
                  final isSelected = _selectedColorHex == hex;
                  final color = Color(int.parse(hex.replaceAll('#', '0xFF')));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorHex = hex;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 4,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note Aggiuntive (opzionale)',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                final title = _titleController.text.trim();
                final barcode = _barcodeController.text.trim();

                if (title.isEmpty || barcode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compila tutti i campi obbligatori!'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final newCard = CardModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  barcode: barcode,
                  barcodeFormat: barcode == _scannedCode
                      ? _scannedFormat!
                      : inferFormat(barcode),
                  colorHex: _selectedColorHex,
                  notes: _notesController.text.trim(),
                  category: _selectedCategory,
                );

                cardViewModel.addCard(username, newCard);

                // Reset inputs
                _titleController.clear();
                _barcodeController.clear();
                _notesController.clear();
                setState(() {
                  _selectedColorHex = '#3F51B5';
                  _scannedCode = null;
                  _scannedFormat = null;
                  _selectedCategory = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tessera aggiunta con successo!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text(
                'Salva Tessera',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
