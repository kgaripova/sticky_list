import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sticky_list/models/item.dart';
import 'package:sticky_list/services/item_service.dart';
import 'dart:math';

class StickyList extends StatefulWidget {
  const StickyList({super.key});

  @override
  _StickyListState createState() => _StickyListState();
}

class _StickyListState extends State<StickyList> {
  static const double itemHeight = 80.0;
  static const int _batchSize = 30;
  List<Item> _dataItems = [];
  final List<Widget> _sliverAppBars = [];
  int _currentMaxIndex = 0;
  bool _isLoading = false;

  final ScrollController _scrollController = ScrollController();
  final List<int> _stickyItems = [];
  int _lastStickyIndex = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchInitialItems();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void fetchInitialItems() async {
    // Load useless data to test performance but it's better not to do so
    _dataItems = await ItemService.shared.fetchItems(includeUselessData: true);

    _renderNextBatch();
  }

  void _renderNextBatch() {
    if (_currentMaxIndex >= _dataItems.length) return;

    setState(() {
      _isLoading = true;

      int nextMaxIndex = min(_currentMaxIndex + _batchSize, _dataItems.length);

      for (int i = _currentMaxIndex; i < nextMaxIndex; i++) {
        _sliverAppBars.add(
          _getSliverAppBar(i),
        );
      }

      _currentMaxIndex = nextMaxIndex;
      _isLoading = false;
    });
  }

  SliverAppBar _getSliverAppBar(int index) {
    final isPinned = _stickyItems.contains(index) && index >= _lastStickyIndex;
    return SliverAppBar(
      key: ValueKey('header:$index'),
      backgroundColor: isPinned ? Colors.cyan : Colors.transparent,
      pinned: isPinned,
      collapsedHeight: itemHeight,
      expandedHeight: itemHeight,
      flexibleSpace: GestureDetector(
        onTap: () {
          _onItemTap(index);
        },
        child: Center(
          child: Text(
            _dataItems[index].header,
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 10), _handleScroll);
  }

  void _handleScroll() {
    final previousLastStickyIndex = _lastStickyIndex;
    final currentOffset = max(_scrollController.offset, 0);
    for (int i = _stickyItems.length - 1; i >= 0; i--) {
      if (currentOffset >= _stickyItems[i] * itemHeight) {
        if (_stickyItems[i] != _lastStickyIndex) {
          setState(() {
            _lastStickyIndex = _stickyItems[i];
          });
        }
        break;
      }
    }

    if (_stickyItems.isNotEmpty) {
      for (int j = 0; j < _stickyItems.length; j++) {
        final refreshUpTo = max(previousLastStickyIndex, _lastStickyIndex);
        if (_stickyItems[j] > refreshUpTo) {
          break;
        }
        setState(() {
          _sliverAppBars[_stickyItems[j]] = _getSliverAppBar(_stickyItems[j]);
        });
      }
    }
  }

  void _onItemTap(int index) {
    bool scroll = false;
    setState(() {
      if (_stickyItems.contains(index)) {
        _stickyItems.remove(index);
      } else {
        _stickyItems.add(index);
        scroll = true;
        if (_lastStickyIndex > index) {
          _lastStickyIndex = index;
        }

        _stickyItems.sort();
      }

      _sliverAppBars[index] = _getSliverAppBar(index);

      if (scroll) {
        _scrollToItem(index);
      }
    });
  }

  void _scrollToItem(int itemIndex) {
    _scrollController.animateTo(
      itemIndex * itemHeight,
      duration: const Duration(milliseconds: 600),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _renderNextBatch();
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            ..._sliverAppBars,
            if (_currentMaxIndex < _dataItems.length)
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: itemHeight,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
          ],
        ),
      ),
    );
  }
}
