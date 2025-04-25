import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isProfileSelected = this.selectedIndex == 2;

    return Container(
      height: 80,
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.folder, "프로젝트", 0),
              _navItem(Icons.article, "게시물1", 1),
              const SizedBox(width: 70), // 중앙 공간 확보
              _navItem(Icons.article_outlined, "게시물2", 3),
              _navItem(Icons.article_outlined, "게시물3", 4),
            ],
          ),
          Positioned(
            top: -20, // 위로 띄움
            left: MediaQuery.of(context).size.width / 2 - 35,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 5.0,
                    percent: 0.25,
                    center: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                    ),
                    progressColor: isProfileSelected ? Colors.blue : Colors.grey,
                    backgroundColor: Colors.grey.shade300,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "프로필",
                    style: TextStyle(
                      fontSize: 12,
                      color: isProfileSelected ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0, // 선택 시 약간 확대
            duration: Duration(milliseconds: 200),
            child: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          ),
          SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
