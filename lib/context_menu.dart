import 'package:flutter/material.dart';
import 'dart:js' as js;

enum StateMenu { Show, Hide }

///Метод открывает браузер в полноэкранном режиме
void enterFullScreen() => js.context.callMethod('enterFullScreen');

///Метод позволяет выйти из полноэкранного режима браузера
void exitFullScreen() => js.context.callMethod('exitFullScreen');

///Переменная содержит состояние контекстного меню открыто/закрыто
StateMenu _stateMenu = StateMenu.Hide;

///Метод добавляет кнопку в Overlay для отрисовки виджета поверх остальных.
///Метод добавляет кнопку FloatingActionButton в нижнем углу экрана, которая открывает контекстное меню
///для входа и выхода в полноэкранный режим браузера путем вызова JS-функций.
///На входе принимает callback функцию которая возвращает состояние контекстного меню
///[StateMenu.Hide] - закрыто, [StateMenu.Show] - открыто
OverlayEntry createOverlayFloatingActionButton(
    Function(StateMenu) callbackState) {
  return OverlayEntry(
    builder: (context) => Positioned(
      bottom: 15,
      right: 15,
      child: FloatingActionButton(
        onPressed: () {
          if (_stateMenu == StateMenu.Show) {
            Navigator.pop(context);
            _stateMenu = StateMenu.Hide;
          } else {
            openMenu(
              context,
              onTapFullScreen: enterFullScreen,
              onTapExitFullScreen: exitFullScreen,
            ).then((data) {
              _stateMenu = StateMenu.Hide;
              callbackState(_stateMenu);
            });
            _stateMenu = StateMenu.Show;
          }
          callbackState(_stateMenu);
        },
        child: Icon(Icons.add),
      ),
    ),
  );
}

///Метод openMenu открывает контекстное меню состоящее из двух items 'Enter FullScreen' и 'Exit FullScreen',
///использует context кнопки FloatingActionButton для определения позиции и отображения сверху над кнопкой FloatingActionButton
Future openMenu(
  BuildContext context, {
  Function()? onTapFullScreen,
  Function()? onTapExitFullScreen,
}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final Offset buttonPosition = button.localToGlobal(Offset.zero);

  return showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy - 120,
      buttonPosition.dx + button.size.width,
      buttonPosition.dy,
    ),
    items: [
      PopupMenuItem(
        onTap: onTapFullScreen,
        child: Text('Enter FullScreen'),
      ),
      PopupMenuItem(
        onTap: onTapExitFullScreen,
        child: Text('Exit FullScreen'),
      ),
    ],
  );
}
