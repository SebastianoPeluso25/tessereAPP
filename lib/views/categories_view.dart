import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/card_viewmodel.dart';
import 'category_detail_view.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    String username,
    CardViewModel vm,
  ) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nuova categoria'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nome categoria',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
    if (name == null) return;
    await vm.addCategory(username, name);
  }

  void _showReorderCategoriesSheet(BuildContext context, String username) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Consumer<CardViewModel>(
            builder: (context, vm, _) {
              return ReorderableListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: vm.categories.length,
                itemBuilder: (context, index) {
                  final name = vm.categories[index];
                  return ListTile(
                    key: ValueKey('category_$name'),
                    title: Text(name),
                    leading: const Icon(Icons.drag_handle_rounded),
                  );
                },
                onReorder: (oldIndex, newIndex) {
                  vm.reorderCategories(username, oldIndex, newIndex);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    String username,
    CardViewModel vm,
    String category,
  ) async {
    final controller = TextEditingController(text: category);
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rinomina categoria'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nuovo nome',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) return;
    await vm.renameCategory(username, category, name);
  }

  Future<void> _showDeleteCategoryDialog(
    BuildContext context,
    String username,
    CardViewModel vm,
    String category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Elimina categoria'),
          content: Text(
            'Eliminando la categoria le tessere associate perderanno la categoria. Vuoi continuare?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    await vm.removeCategory(username, category);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final vm = context.watch<CardViewModel>();
    final username = authViewModel.currentUser?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Categorie',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Ordina',
            onPressed: () => _showReorderCategoriesSheet(context, username),
            icon: const Icon(Icons.reorder_rounded),
          ),
          IconButton(
            tooltip: 'Aggiungi',
            onPressed: () => _showAddCategoryDialog(context, username, vm),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: vm.categories.length,
        itemBuilder: (context, index) {
          final category = vm.categories[index];
          final count = vm.cardsByCategory(category).length;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryDetailView(category: category),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.18),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.10),
                  ],
                ),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditCategoryDialog(context, username, vm, category);
                          } else if (value == 'delete') {
                            _showDeleteCategoryDialog(context, username, vm, category);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Rinomina'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Elimina'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count tessere',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }
}

