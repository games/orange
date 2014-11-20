import 'dart:html' as Html;
import 'package:orange/orange.dart';

Orange createOrange([bool fullScreen = true]) {
  var canvas = Html.querySelector("#container");
  if (fullScreen) {
    canvas.width = Html.window.innerWidth;
    canvas.height = Html.window.innerHeight;
  }
  return new Orange(canvas);
}
