import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../utils/barcode_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/card_viewmodel.dart';

class CategoryDetailView extends StatelessWidget {
  const CategoryDetailView({super.key, required this.category});

  final String category;

  void _showMoveCardSheet(
    BuildContext context,
    String username,
    CardViewModel vm,
    CardModel card,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final categories = vm.categories;
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Sposta in',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.clear_rounded),
                title: const Text('Senza categoria'),
                onTap: () {
                  vm.setCardCategory(username, card.id, null);
                  Navigator.of(context).pop();
                },
              ),
              for (final c in categories)
                ListTile(
                  leading: const Icon(Icons.folder_rounded),
                  title: Text(c),
                  trailing: c == card.category
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () {
                    vm.setCardCategory(username, card.id, c);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showBarcodeBottomSheet(BuildContext context, CardModel card) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Barcode tessera',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (barcodeFor(card.barcodeFormat, card.barcode)
                        case final barcode?)
                      BarcodeWidget(
                        barcode: barcode,
                        data: card.barcode,
                        width: double.infinity,
                        height: 140,
                        drawText: false,
                        color: Colors.black,
                      )
                    else ...[
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Codice non valido per il formato selezionato. Visualizzato solo come testo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SelectableText(
                      card.barcode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                card.barcodeFormat,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardTile(
    BuildContext context,
    String username,
    CardViewModel vm,
    CardModel card,
  ) {
    Color cardColor;
    try {
      cardColor = Color(int.parse(card.colorHex.replaceAll('#', '0xFF')));
    } catch (_) {
      cardColor = Colors.blueGrey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.card_membership, color: Colors.white, size: 20),
        ),
        title: Text(
          card.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          card.barcode,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                letterSpacing: 1.1,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Sposta',
              onPressed: () => _showMoveCardSheet(context, username, vm, card),
              icon: const Icon(Icons.drive_file_move_rtl),
            ),
            IconButton(
              tooltip: 'Mostra barcode',
              onPressed: () => _showBarcodeBottomSheet(context, card),
              icon: const Icon(Icons.qr_code_rounded),
            ),
            IconButton(
              tooltip: card.isFavorite ? 'Rimuovi preferito' : 'Aggiungi preferito',
              onPressed: () => vm.toggleFavorite(username, card.id),
              icon: Icon(
                card.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                color: card.isFavorite ? Colors.amber : null,
              ),
            ),
          ],
        ),
        onTap: () => _showBarcodeBottomSheet(context, card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final vm = context.watch<CardViewModel>();
    final username = authViewModel.currentUser?.username ?? '';

    final cards = vm.cardsByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: cards.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nessuna tessera in questa categoria',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: cards.length,
              onReorder: (oldIndex, newIndex) {
                vm.reorderCardsInCategory(username, category, oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final card = cards[index];
                return Container(
                  key: ValueKey('card_${card.id}'),
                  child: _buildCardTile(context, username, vm, card),
                );
              },
            ),
    );
  }
}

