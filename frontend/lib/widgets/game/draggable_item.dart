import 'package:flutter/material.dart';

class DraggableItem extends StatefulWidget {
  final String itemId;
  final String imagePath;
  final Offset initialPosition;
  final Size size;
  final void Function(Offset newPosition) onPositionChanged;

  const DraggableItem({
    super.key,
    required this.itemId,
    required this.imagePath,
    required this.initialPosition,
    required this.size,
    required this.onPositionChanged,
  });

  @override
  State<DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<DraggableItem> {
  late Offset _position;
  bool _isDragging = false;
  late Offset _dragStartPosition;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        
        onLongPressStart: (details) {
          debugPrint('🔴 Long press start on ${widget.itemId}');
          _dragStartPosition = _position;
          setState(() {
            _isDragging = true;
          });
        },
        
        onLongPressMoveUpdate: (details) {
          setState(() {
            // Новая позиция = начальная + смещение от точки нажатия
            _position = _dragStartPosition + details.offsetFromOrigin;
          });
          debugPrint('🔄 Moving ${widget.itemId} to: (${_position.dx}, ${_position.dy})');
        },
        
        onLongPressEnd: (_) {
          debugPrint('✅ Long press end for ${widget.itemId}');
          setState(() {
            _isDragging = false;
          });
          widget.onPositionChanged(_position);
        },
        
        child: Opacity(
          opacity: _isDragging ? 0.9 : 1.0,
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            color: Colors.transparent,
            child: Image.asset(
              widget.imagePath,
              width: widget.size.width,
              height: widget.size.height,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}