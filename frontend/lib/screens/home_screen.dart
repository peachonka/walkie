import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import '../../theme/app_theme.dart';
import '../widgets/profile/stats_modal.dart';
import '../widgets/profile/achievements_modal.dart';
import '../widgets/collection/collection_modal.dart';
import '../services/items_service.dart';
import '../services/pet_service.dart';
import '../services/walk_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/walk/start_walk_dialog.dart';
import '../screens/walk_screen.dart';
import '../widgets/walk/walk_result_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _petName = 'Загрузка...';
  String? _petAvatar;

  final ItemsService _itemsService = ItemsService();
  final PetService _petService = PetService();
  final WalkService _walkService = WalkService();
  final AuthService _authService = AuthService();

  Map<String, dynamic>? _selectedItem;
  Offset? _tempPosition;
  bool _isPlacingItem = false;
  bool _isMovingItem = false;
  Map<String, dynamic>? _movingItem;
  bool _itemSelectedFromCollection = false;
  List<Map<String, dynamic>> _placedItems = [];

  static const String baseUrl = 'http://157.22.192.92:3000';

  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
    _loadPetData();
    _loadPlacedItems();
    _checkAndRestoreActiveWalk();
  }

  Future<void> _loadPetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petName = prefs.getString('pet_name');

      final petData = await _petService.getPet();

      setState(() {
        _petName = petName ?? 'Питомец';
        _petAvatar = petData?['avatar'];
      });

      print('Загружены данные питомца: имя=$_petName, аватар=$_petAvatar');
    } catch (e) {
      print('Ошибка загрузки данных питомца: $e');
      setState(() {
        _petName = 'Питомец';
        _petAvatar = null;
      });
    }
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _loadPlacedItems() async {
    final items = await _itemsService.getPlacedItems();
    setState(() {
      _placedItems = items;
    });
  }

  void _showEditPetNameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _petName);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text(
          'Изменить имя питомца',
          style: TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите новое имя для вашего питомца',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFFF1D5),
                border: Border.all(color: const Color(0xFF827454), width: 1),
              ),
              child: TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Имя питомца',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != _petName) {
                await _updatePetName(newName);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            child: const Text(
              'Сохранить',
              style: TextStyle(
                fontFamily: 'Sigmar Cyrillic',
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Восстановление активной прогулки при старте HomeScreen.
  ///
  /// Логика:
  /// 1. Берём сохранённый walkId из SharedPreferences.
  /// 2. Если он есть — показываем диалог с 3 кнопками:
  ///    «Продолжить» — открываем WalkScreen.
  ///    «Завершить сейчас» — принудительно завершаем через POST /walks/:id/end.
  ///    «Отмена» — оставляем как есть (можно будет восстановить позже).
  Future<void> _checkAndRestoreActiveWalk() async {
    final savedId = await _walkService.getSavedActiveWalkId();
    if (savedId == null || !mounted) return;

    print('Восстановление: найдена сохранённая прогулка ID=$savedId');

    // Даём кадру отрисоваться, чтобы диалог показался поверх UI
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Незавершённая прогулка',
          style: TextStyle(
            fontFamily: 'Sigmar Cyrillic',
            fontSize: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        content: const Text(
          'У вас есть незавершённая прогулка. Продолжить её или завершить?',
          style: TextStyle(
            fontFamily: 'Pangolin',
            fontSize: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text(
              'Позже',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'finish'),
            child: const Text(
              'Завершить сейчас',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'continue'),
            child: const Text(
              'Продолжить',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (action == 'continue') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalkScreen(
            walkId: savedId,
            onWalkEnd: _showWalkResult,
          ),
        ),
      );
    } else if (action == 'finish') {
      // Принудительно завершаем прогулку
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );

      final result = await _walkService.endWalk(savedId, 0, 0);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Прогулка завершена')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось завершить прогулку')),
          );
          // Не удалилось — попробуем очистить локально, чтобы разблокировать старт
          await _walkService.clearSavedActiveWalk();
        }
      }
    }
    // action == 'cancel' или null — ничего не делаем
  }

  Future<void> _updatePetName(String newName) async {
    final success = await _petService.updatePetName(newName);

    if (success && mounted) {
      setState(() {
        _petName = newName;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pet_name', newName);

      print('Имя питомца обновлено: $newName');
    } else {
      print('Ошибка при обновлении имени питомца');
    }

    _loadPetData();
  }

  void _showStatsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const StatsModal(),
    );
  }

  void _showAchievementsModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => const AchievementsModal(),
    );
  }

  void _showCollectionModal() {
    _itemSelectedFromCollection = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => CollectionModal(
        onItemSelected: (item) {
          _itemSelectedFromCollection = true;

          Map<String, dynamic>? existingItem;
          for (var placed in _placedItems) {
            if (placed['item_name'] == _getItemName(item)) {
              existingItem = placed;
              break;
            }
          }

          if (existingItem != null) {
            _startMovingItem(existingItem, fromCollection: true);
          } else {
            _startPlacingItem(item);
          }
        },
      ),
    );
  }

  void _startPlacingItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _isPlacingItem = true;
      _isMovingItem = false;
      _movingItem = null;
      _tempPosition = const Offset(300, 300);
    });
  }

  void _startMovingItem(Map<String, dynamic> item,
      {bool fromCollection = false}) {
    setState(() {
      _movingItem = item;
      _isMovingItem = true;
      _isPlacingItem = false;
      _selectedItem = null;
      _tempPosition = Offset(item['x'], item['y']);
      _itemSelectedFromCollection = fromCollection;
    });
  }

  void _removeItemFromScreen() async {
    if (_movingItem == null) return;

    final itemToRemove = _movingItem!;
    final itemName = itemToRemove['item_name'];
    final positionId = itemToRemove['id'];

    print('Убираем предмет с экрана: $itemName, positionId: $positionId');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    try {
      final success = await _itemsService.removePlacedItem(positionId);

      if (mounted) {
        Navigator.pop(context);
      }

      if (success && mounted) {
        setState(() {
          _placedItems.removeWhere((p) => p['id'] == positionId);
          _isMovingItem = false;
          _movingItem = null;
          _tempPosition = null;
        });

        print('Предмет $itemName успешно убран с экрана и из базы данных');
      } else {
        print('Ошибка при удалении предмета с сервера');
      }
    } catch (e) {
      print('Ошибка при удалении предмета: $e');
    }
  }

  String _getItemName(Map<String, dynamic> item) {
    return item['name'] ?? item['item_name'] ?? 'Предмет';
  }

  int? _getItemId(Map<String, dynamic> item) {
    if (item['item_id'] != null) {
      return item['item_id'] is int
          ? item['item_id']
          : int.tryParse(item['item_id'].toString());
    }
    if (item['id'] != null) {
      return item['id'] is int
          ? item['id']
          : int.tryParse(item['id'].toString());
    }
    return null;
  }

  void _onScreenTap(TapDownDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    if (details.localPosition.dy > screenHeight - 100) {
      return;
    }

    if ((_isPlacingItem || _isMovingItem) && _tempPosition != null) {
      setState(() {
        _tempPosition = details.localPosition;
      });
    }
  }

  Future<void> _confirmPlacement() async {
    if (_tempPosition == null) return;

    int? itemId;
    String itemName;

    if (_isMovingItem && _movingItem != null) {
      itemId = _movingItem!['item_id'];
      itemName = _movingItem!['item_name'];
    } else if (_isPlacingItem && _selectedItem != null) {
      itemId = _getItemId(_selectedItem!);
      itemName = _getItemName(_selectedItem!);
    } else {
      _resetPlacingMode();
      return;
    }

    if (itemId == null) {
      _resetPlacingMode();
      return;
    }

    final success = await _itemsService.placeItem(
      itemId,
      _tempPosition!.dx,
      _tempPosition!.dy,
    );

    if (success && mounted) {
      if (_isMovingItem && _movingItem != null) {
        setState(() {
          final index = _placedItems.indexWhere((p) => p['item_id'] == itemId);
          if (index != -1) {
            _placedItems[index] = {
              ..._placedItems[index],
              'x': _tempPosition!.dx,
              'y': _tempPosition!.dy,
            };
          }
        });
      } else {
        setState(() {
          _placedItems.add({
            'item_id': itemId,
            'item_name': itemName,
            'x': _tempPosition!.dx,
            'y': _tempPosition!.dy,
          });
        });
      }
      _resetPlacingMode();
    } else {
      _resetPlacingMode();
    }
  }

  void _cancelPlacing() {
    _resetPlacingMode();

    if (_itemSelectedFromCollection) {
      _showCollectionModal();
    }
    _itemSelectedFromCollection = false;
  }

  void _resetPlacingMode() {
    setState(() {
      _isPlacingItem = false;
      _isMovingItem = false;
      _selectedItem = null;
      _movingItem = null;
      _tempPosition = null;
    });
  }

  void _showStartWalkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => StartWalkDialog(
        onConfirm: _startWalk,
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _startWalk() async {
    if (!mounted) return;

    print('=== НАЧАЛО ПРОЦЕССА СТАРТА ПРОГУЛКИ ===');

    if (mounted) {
      Navigator.pop(context);
      print('Диалог подтверждения закрыт');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    try {
      final result = await _walkService.startWalk();
      print('Результат startWalk: $result');

      if (mounted) {
        Navigator.pop(context);
        print('Индикатор загрузки закрыт');
      }

      if (result != null && mounted) {
        final walkId = result['walk_id'].toString();
        print('=== ПРОГУЛКА УСПЕШНО НАЧАТА ===');
        print('ID прогулки: $walkId');

        await Future.delayed(const Duration(milliseconds: 200));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalkScreen(
                walkId: walkId,
                onWalkEnd: _showWalkResult,
              ),
            ),
          ).then((_) {
            print('WalkScreen закрыт');
          }).catchError((e) {
            print('Ошибка при открытии WalkScreen: $e');
          });
        }
      } else {
        print('Ошибка: результат начала прогулки пустой');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось начать прогулку')),
          );
        }
      }
    } catch (e) {
      print('Ошибка при начале прогулки: $e');
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showWalkResult(Map<String, dynamic> result) {
    print('=== ПОКАЗ РЕЗУЛЬТАТОВ ПРОГУЛКИ ===');

    if (mounted) {
      Navigator.pop(context);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black54,
          builder: (context) => WalkResultDialog(
            result: result,
            onCollect: () {
              print('Нажата кнопка "Собрать награды"');
              _refreshAfterWalk();
            },
          ),
        );
      }
    });
  }

  Future<void> _refreshAfterWalk() async {
    print('=== ОБНОВЛЕНИЕ ПОСЛЕ ПРОГУЛКИ ===');

    if (!mounted) {
      print('HomeScreen не смонтирован, пропускаем обновление');
      return;
    }

    try {
      await _loadPlacedItems();
    } catch (e) {
      print('Ошибка при обновлении: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Выход из аккаунта',
          style: TextStyle(fontFamily: 'Sigmar Cyrillic', fontSize: 20),
        ),
        content: const Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(fontFamily: 'Pangolin', fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Отмена',
              style: TextStyle(fontFamily: 'Pangolin', fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Выйти',
              style: TextStyle(
                fontFamily: 'Pangolin',
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );

      // Если есть активная прогулка — принудительно завершим её,
      // чтобы пользователь не «застрял» на бэке
      try {
        final savedId = await _walkService.getSavedActiveWalkId();
        if (savedId != null) {
          print('При логауте найдена активная прогулка ID=$savedId, завершаем');
          await _walkService.endWalk(savedId, 0, 0);
        }
      } catch (e) {
        print('Не удалось завершить прогулку при логауте: $e');
      }

      await _authService.logout();

      if (context.mounted) {
        Navigator.pop(context);
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  String _getItemIconFromName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('очк')) return 'assets/images/items/sunglasses.png';
    if (lowerName.contains('миск')) return 'assets/images/items/bowl.png';
    if (lowerName.contains('ков')) return 'assets/images/items/carpet.png';
    return 'assets/images/items/sunglasses.png';
  }

  String _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onScreenTap,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/game_background.png',
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: _petAvatar != null && _petAvatar!.isNotEmpty
                  ? Image.network(
                      _resolveImageUrl(_petAvatar),
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/pet_0.png',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/pet_0.png',
                      width: 300,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
            ),

            ..._placedItems.where((item) =>
                !(_isMovingItem &&
                    _movingItem != null &&
                    item['item_id'] == _movingItem!['item_id'])).map((item) =>
                Positioned(
                  left: item['x'],
                  top: item['y'],
                  child: GestureDetector(
                    onLongPress: () {
                      _startMovingItem(item);
                    },
                    child: Image.asset(
                      _getItemIconFromName(item['item_name']),
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image,
                              size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                )),

            if (_isMovingItem && _movingItem != null && _tempPosition != null)
              Positioned(
                left: _tempPosition!.dx,
                top: _tempPosition!.dy,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    _getItemIconFromName(_movingItem!['item_name']),
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            if (_isPlacingItem &&
                _selectedItem != null &&
                _tempPosition != null)
              Positioned(
                left: _tempPosition!.dx,
                top: _tempPosition!.dy,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    _getItemIconFromName(_getItemName(_selectedItem!)),
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image,
                            size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),

            Positioned(
              top: 20,
              left: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuButton(
                    iconPath: 'assets/icons/chart-spline.svg',
                    onPressed: _showStatsModal,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    iconPath: 'assets/icons/shelving-unit.svg',
                    onPressed: _showCollectionModal,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuIconButton(
                    icon: Icons.emoji_events,
                    onPressed: _showAchievementsModal,
                  ),
                  const SizedBox(height: 12),
                  _buildLogoutButton(context),
                ],
              ),
            ),

            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: _showEditPetNameDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppTheme.primaryColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _petName,
                        style: const TextStyle(
                          fontFamily: 'Pangolin',
                          fontSize: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: AppTheme.primaryColor.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              child: CustomButton(
                text: 'Гулять',
                onPressed: _showStartWalkDialog,
                width: 120,
              ),
            ),

            if (_isPlacingItem || _isMovingItem)
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  children: [
                    if (_isMovingItem && _movingItem != null)
                      CustomButton(
                        text: 'Убрать',
                        onPressed: _removeItemFromScreen,
                        width: 100,
                      ),
                    if (_isMovingItem && _movingItem != null)
                      const SizedBox(width: 12),
                    CustomButton(
                      text: 'Отмена',
                      onPressed: _cancelPlacing,
                      width: 100,
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: 'OK',
                      onPressed: _confirmPlacement,
                      width: 100,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String iconPath,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              AppTheme.primaryColor,
              BlendMode.srcIn,
            ),
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image,
                  size: 32, color: AppTheme.primaryColor);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.secondaryColor,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.logout, size: 32, color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}