import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Основной класс приложения.
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
            builder: (iconData) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors
                      .primaries[iconData.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(iconData, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Виджет Dock для перемещения элементов.
class Dock<T extends Object> extends StatefulWidget {
  /// Создает экземпляр виджета Dock.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Список элементов типа [T], которые будут размещены в этом Dock.
  final List<T> items;

  /// Функция для построения виджета из предоставленного элемента типа [T].
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// Состояние виджета Dock.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// Элементы типа [T], которые будут изменяться.
  late List<T> _items = widget.items.toList();

  /// Индекс элемента, который перетаскивается.
  int? _draggedIndex;

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

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0),
                  end: const Offset(0.0, 0.0),
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Draggable<T>(
              key: ValueKey(item), // Ключ для анимации
              data: item,
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index;
                });
              },
              onDragCompleted: () {
                setState(() {
                  _draggedIndex = null;
                });
              },
              onDraggableCanceled: (velocity, offset) {
                setState(() {
                  _draggedIndex = null;
                });
              },
              feedback: Opacity(
                opacity: 0.7,
                child: widget.builder(item),
              ),
              childWhenDragging: const SizedBox.shrink(),
              child: DragTarget<T>(
                onAcceptWithDetails: (DragTargetDetails<T> details) {
                  setState(() {
                    final draggedItem = _items.removeAt(_draggedIndex!);
                    _items.insert(index, draggedItem);
                    _draggedIndex = null;
                  });
                },
                onWillAcceptWithDetails: (DragTargetDetails<T> details) =>
                    _draggedIndex != index,
                builder: (context, candidateData, rejectedData) {
                  return widget.builder(item);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
