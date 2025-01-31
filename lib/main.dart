import 'package:app_image_load/context_menu.dart';
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;
import 'dart:js' as js;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///Контроллер ввода текста
  TextEditingController inputController = TextEditingController();

  ///Переменная содержащая ссылку на картинку
  String? imageUrl;

  ///Переменная содержит уникальный Id html элемента
  final String viewId = "main-image-view";

  ///Html элемент image который отображает заданную картинку
  late html.ImageElement imageElement;

  ///Переменная содержит статус контекстного меню [StateMenu.Hide] - закрыто, [StateMenu.Show] - открыто
  StateMenu isOpenMenu = StateMenu.Hide;

  ///OverlayEntry, класс который поможет нам отрисовать FloatingActionButton поверх всех элементов.
  ///Необходим, чтобы кнопка FloatingActionButton не затемнялась при открытии конетекстного меню
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    imageElement = html.ImageElement();

    ///Регистрация и встраивание нативного элемента html
    ui.platformViewRegistry
        .registerViewFactory(viewId, (int viewId) => imageElement);

    overlayEntry = createOverlayFloatingActionButton((stateMenu) {
      setState(() {
        isOpenMenu = stateMenu;
      });
    });

    ///Отображаем FloatingActionButton поверх всех виджетов.
    ///
    ///[WidgetsBinding.instance.addPostFrameCallback] используется для выполнения кода
    ///сразу после построения (рендеринга) текущего кадра, но до следующего кадра в Flutter.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(overlayEntry!);
    });
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }

  ///Метод загружает картинку в элементе html, url которой указан в поле ввода
  void updateImage() {
    imageUrl = inputController.text.trim();
    if (imageUrl?.isNotEmpty ?? false) {
      setState(() {
        imageElement.src = imageUrl;
      });
    }
  }

  ///Метод вызывает переключение fullscreen из JS-функций
  void switchFullScreen() => js.context.callMethod('switchFullScreen');

  /// Scaffold обернут в виджет Stack, что позволяет накладывать дополнительные слои поверх основного интерфейса.
  /// Это позволит затемнить весь экран, включая AppBar, если он используется.
  ///
  /// FloatingActionButton добавлен в оверлей, что позволяет его рисовать поверх всех остальных элементов интерфейса.
  ///
  /// Текущая реализация обеспечивает равномерное затемнение всего экрана, включая все части приложения,
  /// при этом FloatingActionButton и контекстное меню всегда остаются поверх остальных элементов, согласно требованиям ТЗ.
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imageUrl == null
                        ? null
                        : GestureDetector(
                            onDoubleTap: switchFullScreen,
                            child: HtmlElementView(viewType: viewId)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputController,
                      decoration: InputDecoration(hintText: 'Image URL'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: updateImage,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
      if (isOpenMenu == StateMenu.Show)
        Container(
          color: Colors.black.withAlpha(150),
        ),
    ]);
  }
}
