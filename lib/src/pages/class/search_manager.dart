import 'package:flutter/widgets.dart';

class SearchManager {
  static final SearchManager _instance = SearchManager._internal();

  factory SearchManager() {
    return _instance;
  }

  SearchManager._internal();

  String _currentSearch = '';
  ScrollController? _scrollController; // Nuevo atributo para el controlador de desplazamiento

  String get currentSearch => _currentSearch;

  void setCurrentSearch(String search) {
    _currentSearch = search;
  }

  // Nuevo método para configurar el controlador de desplazamiento
  void setScrollController(ScrollController scrollController) {
    _scrollController = scrollController;
  }

  // Nuevo método para establecer la posición de desplazamiento
  void setScrollPosition(double position) {
    if (_scrollController != null) {
      _scrollController!.jumpTo(position);
    }
  }
}
