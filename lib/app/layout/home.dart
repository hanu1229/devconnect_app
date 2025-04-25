// home.dart : 메인 페이지

import "package:devconnect_app/style/app_colors.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();

}

class _HomeState extends State<Home> {
  final ScrollController _scrollController = ScrollController();
  List<int> items = List.generate(20, (index) => index);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !isLoading) {
      _loadMoreData();
    }
  }

  Widget _buildLoader() {
    return isLoading
        ? Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(child: CircularProgressIndicator()),
    )
        : SizedBox.shrink();
  }

  void _loadMoreData() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 2)); // API 대기 시뮬레이션

    setState(() {
      items.addAll(List.generate(10, (index) => items.length + index));
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('무한 스크롤')),
      body: ListView.builder(
        scrollDirection : Axis.vertical,
        controller: _scrollController,
        itemCount: items.length + 1, // 로딩 인디케이터 때문에 +1
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildLoader();
          }
          return ListTile(title: Text('아이템 ${items[index]}'));
        },
      ),
    );
  }

}
