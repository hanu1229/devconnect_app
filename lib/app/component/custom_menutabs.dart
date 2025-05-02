import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomMenuTabs extends StatelessWidget {
  final Function(int) changePage;
  final int selectedIndex;

  const CustomMenuTabs({
    super.key,
    required this.changePage,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildTab("기본 정보", 2),
            _buildTab("프로젝트", 9),
            _buildTab("평가", 10),
          ],
        ),
        SizedBox(height: 5),
        Divider(thickness: 0.5, color: Colors.black45),
      ],
    );
  }

  Widget _buildTab(String title, int pageIndex) {
    final isSelected = selectedIndex == pageIndex;
    return TextButton(
      onPressed: () => changePage(pageIndex),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        minimumSize: Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: isSelected ? Colors.blueAccent : Colors.black,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
