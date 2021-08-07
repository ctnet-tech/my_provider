import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef ChildWidgetFetchBuilder<TValue> = Widget Function(
    BuildContext context, TValue value);

class FetchList<TValue> extends StatefulWidget {
  const FetchList(
      {required this.buildChild,
      required this.listValue,
      required this.itemsPerPage,
      required this.itemsLoadFist,
      required this.builderLoading});

  final int itemsLoadFist;
  final ChildWidgetFetchBuilder<TValue> buildChild;
  final ChildWidgetFetchBuilder<String> builderLoading;
  final List<TValue> listValue;
  final int itemsPerPage;

  @override
  _FetchListState<TValue> createState() => _FetchListState<TValue>();
}

class _FetchListState<TValue> extends State<FetchList<TValue>> {
  List<TValue> _pairList = [];
  List<TValue> _listChild = [];
  ScrollController _scrollController = new ScrollController(

  );
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _listChild = widget.listValue;
    _loadMore(fistItems: widget.itemsLoadFist,isReload: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  void _loadMore({isReload = true, fistItems}) {
    if (_listChild.length == 0) {
    } else {
      var getList = _listChild.take(fistItems ?? widget.itemsPerPage);
      _pairList.addAll(getList);
      _listChild.removeRange(0, fistItems ?? widget.itemsPerPage);

    }
    setState(() {

    });

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: Key('ListViewKey'),
      controller: _scrollController,
      child: Column(
        children: List.generate(_pairList.length + 1, (index) {
          if (index == _pairList.length) {
            return _listChild.length == 0
                ? Container()
                : widget.builderLoading(context, "Loading");
          }
          var w = widget.buildChild(context, _pairList[index]);
          return w;
        }),
      ),
    );
  }
}
