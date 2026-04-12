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
      } else {
        final List<Map<String, dynamic>> formattedItems = [];
        for (var userItem in items) {
          final itemData = userItem['item'];
          formattedItems.add({
            'user_item_id': userItem['id'],
            'id': itemData['id'],
            'name': itemData['name'],
            'icon': itemData['icon'],
          });
        }
        setState(() {
          _items = formattedItems;
          _isLoading = false;
        });
      }
    } catch (e) {
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
              
              _buildContent(),
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

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: _items.map((item) => _buildItemCard(item)).toList(),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final itemName = item['name'] ?? 'Предмет';
    final iconPath = _getIconPath(item);
    
    return GestureDetector(
      onTap: () => _onItemTap(item),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.secondaryColor.withOpacity(0.3),
          border: Border.all(color: AppTheme.primaryColor, width: 1),
        ),
        child: Column(
          children: [
            Image.asset(
              iconPath,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory,
                    size: 30,
                    color: Colors.grey,
                  ),
                );
              },
            ),
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
      ),
    );
  }

  String _getIconPath(Map<String, dynamic> item) {
    final name = (item['name'] ?? '').toLowerCase();
    
    if (name.contains('очк')) return 'assets/images/items/sunglasses.png';
    if (name.contains('миск')) return 'assets/images/items/bowl.png';
    if (name.contains('ков')) return 'assets/images/items/carpet.png';
    
    if (item['icon'] != null && item['icon'].toString().isNotEmpty) {
      return 'assets/images/items/${item['icon']}';
    }
    
    return 'assets/images/items/sunglasses.png';
  }
}