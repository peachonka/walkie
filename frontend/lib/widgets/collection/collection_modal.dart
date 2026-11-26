import 'package:flutter/material.dart';
import '../../services/items_service.dart';
import '../../theme/app_theme.dart';

class CollectionModal extends StatefulWidget {
  final Function(Map<String, dynamic> item) onItemSelected;

  const CollectionModal({
    super.key,
    required this.onItemSelected,
  });

  @override
  State<CollectionModal> createState() => _CollectionModalState();
}

class _CollectionModalState extends State<CollectionModal> {
  final ItemsService _itemsService = ItemsService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];
  String? _error;

  static const String baseUrl = 'http://157.22.192.92:3000';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _itemsService.getUserItems();

      if (items.isEmpty) {
        setState(() {
          _items = [];
          _isLoading = false;
        });
        return;
      }

      // Группируем по item_id (или по name+icon, если item_id нет)
      // Один item_id → одна карточка, в которой хранится count экземпляров.
      final Map<String, Map<String, dynamic>> grouped = {};

      for (var userItem in items) {
        final itemData = userItem['item'];
        final itemId = itemData['id']?.toString() ?? '';
        final itemName = itemData['name'] ?? 'Предмет';
        final itemIcon = itemData['icon'];

        final key = itemId.isNotEmpty ? itemId : '$itemName|$itemIcon';

        if (grouped.containsKey(key)) {
          grouped[key]!['count'] = (grouped[key]!['count'] as int) + 1;
        } else {
          grouped[key] = {
            'id': itemId,
            'name': itemName,
            'icon': itemIcon,
            'count': 1,
          };
        }
      }

      final List<Map<String, dynamic>> formattedItems = grouped.values.toList();

      print('=== CollectionModal: загружено ${items.length} записей, '
          'уникальных предметов: ${formattedItems.length}');
      for (var it in formattedItems) {
        print('=== item: name=${it['name']}, id=${it['id']}, count=${it['count']}, icon=${it['icon']}');
      }

      setState(() {
        _items = formattedItems;
        _isLoading = false;
      });
    } catch (e) {
      print('=== Ошибка CollectionModal._loadItems: $e');
      setState(() {
        _error = 'Не удалось загрузить данные';
        _isLoading = false;
      });
    }
  }

  void _onItemTap(Map<String, dynamic> item) {
    Navigator.of(context).pop();
    Future.microtask(() {
      widget.onItemSelected(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppTheme.backgroundColor,
            border: Border.all(color: AppTheme.primaryColor, width: 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Коллекция',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontFamily: 'Sigmar Cyrillic',
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.warning_amber, size: 48, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'У вас пока нет предметов\nСовершайте прогулки, чтобы их найти!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pangolin',
              fontSize: 16,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(_items[index]);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final itemName = item['name'] ?? 'Предмет';
    final count = item['count'] as int? ?? 1;

    return GestureDetector(
      onTap: () => _onItemTap(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.secondaryColor.withOpacity(0.3),
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildItemImage(item, size: 50),
                const SizedBox(height: 8),
                Text(
                  itemName,
                  style: const TextStyle(
                    fontFamily: 'Pangolin',
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            // Бейдж количества
            if (count > 1)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'x$count',
                    style: const TextStyle(
                      fontFamily: 'Pangolin',
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // КАРТИНКИ ПРЕДМЕТОВ
  // ============================================================

  String _resolveItemIcon(Map<String, dynamic> item) {
    final iconPath = item['icon'];

    if (iconPath != null && iconPath.toString().isNotEmpty) {
      final path = iconPath.toString();
      if (path.startsWith('http')) return path;
      if (path.startsWith('/')) return '$baseUrl$path';
      return '$baseUrl/$path';
    }

    return _getItemIconFromName(item['name'] ?? '');
  }

  String _getItemIconFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('очк')) return 'assets/images/items/sunglasses.png';
    if (lower.contains('миск')) return 'assets/images/items/bowl.png';
    if (lower.contains('ков')) return 'assets/images/items/carpet.png';
    return 'assets/images/items/sunglasses.png';
  }

  Widget _buildItemImage(Map<String, dynamic> item, {double size = 50}) {
    final iconPath = item['icon'];
    final hasRemoteIcon = iconPath != null && iconPath.toString().isNotEmpty;

    if (hasRemoteIcon) {
      return Image.network(
        _resolveItemIcon(item),
        height: size,
        width: size,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            height: size,
            width: size,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            _getItemIconFromName(item['name'] ?? ''),
            height: size,
            width: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error2, stackTrace2) {
              return Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory,
                  size: size * 0.6,
                  color: Colors.grey,
                ),
              );
            },
          );
        },
      );
    }

    return Image.asset(
      _getItemIconFromName(item['name'] ?? ''),
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.inventory,
            size: size * 0.6,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}