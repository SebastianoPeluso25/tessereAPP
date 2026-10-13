import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../models/card_model.dart';
import '../utils/barcode_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/card_viewmodel.dart';
import 'categories_view.dart';
import 'category_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88)
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final cardViewModel = context.watch<CardViewModel>();
    final username = authViewModel.currentUser?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Le mie Tessere',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: cardViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cardViewModel.cards.isEmpty
          ? _buildEmptyState()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: cardViewModel.cards.length,
                    itemBuilder: (context, index) {
                      final card = cardViewModel.cards[index];
                      double scale = (1 - (_currentPage - index).abs() * 0.1)
                          .clamp(0.88, 1.0);
                      return Transform.scale(
                        scale: scale,
                        child: _buildCarouselCard(
                          card,
                          username,
                          cardViewModel,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                _buildPageIndicator(cardViewModel.cards.length),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categorie',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CategoriesView(),
                            ),
                          );
                        },
                        child: const Text('Vedi tutte'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 116,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: cardViewModel.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = cardViewModel.categories[index];
                      final count = cardViewModel
                          .cardsByCategory(category)
                          .length;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryDetailView(category: category),
                            ),
                          );
                        },
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.18),
                                Theme.of(
                                  context,
                                ).colorScheme.secondary.withOpacity(0.10),
                              ],
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.folder_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$count tessere',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withOpacity(0.7),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                if (cardViewModel.favoriteCards.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Preferite',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: cardViewModel.favoriteCards.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          itemCount: cardViewModel.favoriteCards.length,
                          itemBuilder: (context, index) {
                            final card = cardViewModel.favoriteCards[index];
                            return _buildFavoriteListItem(
                              card,
                              username,
                              cardViewModel,
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Carousel card (rectangular)
  // ═══════════════════════════════════════════════════════════
  Widget _buildCarouselCard(CardModel card, String username, CardViewModel vm) {
    final cardColor = _parseColor(card.colorHex);

    return GestureDetector(
      onTap: () => _showCardDetails(card, username),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor,
              cardColor.withValues(
                red: (cardColor.r - 30 / 255).clamp(0.0, 1.0),
                blue: (cardColor.b + 30 / 255).clamp(0.0, 1.0),
              ),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative icon
            Positioned(
              right: -24,
              bottom: -24,
              child: Opacity(
                opacity: 0.12,
                child: Icon(Icons.payment, size: 160, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card title
                      Expanded(
                        child: Text(
                          card.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // ★ Favorite button
                      GestureDetector(
                        onTap: () => vm.toggleFavorite(username, card.id),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            card.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            key: ValueKey(card.isFavorite),
                            color: card.isFavorite
                                ? Colors.amber
                                : Colors.white70,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (card.notes != null && card.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      card.notes!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  // Barcode preview row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code,
                          color: Colors.black87,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            card.barcode,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Favorites section list item
  // ═══════════════════════════════════════════════════════════
  Widget _buildFavoriteListItem(
    CardModel card,
    String username,
    CardViewModel vm,
  ) {
    final cardColor = _parseColor(card.colorHex);

    return GestureDetector(
      onTap: () => _showCardDetails(card, username),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        child: Row(
          children: [
            // Color dot
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_membership,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Card info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    card.barcode,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      letterSpacing: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unstar button
            IconButton(
              icon: const Icon(
                Icons.star_rounded,
                color: Colors.amber,
                size: 24,
              ),
              onPressed: () => vm.toggleFavorite(username, card.id),
              tooltip: 'Rimuovi dai preferiti',
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Page indicator dots
  // ═══════════════════════════════════════════════════════════
  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final diff = (_currentPage - index).abs();
        final size = (10 - diff * 4).clamp(5.0, 10.0);
        final opacity = (1.0 - diff * 0.5).clamp(0.3, 1.0);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: index == _currentPage.round() ? 22 : size,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Theme.of(context).colorScheme.primary.withOpacity(opacity),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Empty state
  // ═══════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Nessuna tessera aggiunta',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Aggiungi la tua prima tessera fedeltà premendo il pulsante "+" nella barra di navigazione.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Card detail bottom sheet
  // ═══════════════════════════════════════════════════════════
  void _showCardDetails(CardModel card, String username) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
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
                    card.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Elimina Tessera'),
                          content: Text(
                            'Sei sicuro di voler eliminare "${card.title}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annulla'),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                context.read<CardViewModel>().removeCard(
                                  username,
                                  card.id,
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Elimina'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Barcode widget
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
                        'Codice non valido per il formato selezionato.\nVisualizzato solo come testo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      card.barcode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (card.notes != null && card.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Note',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    card.notes!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
