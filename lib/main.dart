import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isDragging, isHovered) {
              return AnimatedScale(
                scale: isDragging || isHovered ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors
                        .primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;

  final Widget Function(T, bool isDragging, bool isHovered) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late final List<T> _items = widget.items.toList();

  int? _draggedIndex;

  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isDragging = index == _draggedIndex;
          final isHovered = index == _hoveredIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(
              left: index > 0 && index == _hoveredIndex ? 48 : 0,
            ),
            child: Draggable<T>(
              data: item,
              feedback: widget.builder(item, true, false),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index;
                });
              },
              onDragEnd: (_) {
                setState(() {
                  _draggedIndex = null;
                  _hoveredIndex = null;
                });
              },
              child: DragTarget<T>(
                onWillAcceptWithDetails: (details) {
                  setState(() {
                    _hoveredIndex = index;
                  });
                  return true;
                },
                onLeave: (_) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                onAcceptWithDetails: (details) {
                  setState(() {
                    final oldIndex = _draggedIndex!;
                    final draggedItem = details.data;
                    _items.removeAt(oldIndex);
                    _items.insert(index, draggedItem);
                    _draggedIndex = null;
                    _hoveredIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return widget.builder(item, isDragging, isHovered);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
