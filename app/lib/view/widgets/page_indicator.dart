import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class PageIndicator extends StatefulWidget {
  final PageController pageController;
  final int pageCount;

  const PageIndicator({
    super.key,
    required this.pageController,
    required this.pageCount,
  });

  @override
  State<PageIndicator> createState() => _PageIndicatorState();
}

class _PageIndicatorState extends State<PageIndicator> {
  int currentPage = 0;

  @override
  void initState() {
    widget.pageController.addListener(() {
      currentPage = widget.pageController.page?.toInt() ?? currentPage;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DotsIndicator(
      dotsCount: widget.pageCount,
      position: currentPage,
      decorator: DotsDecorator(
        color: Colors.white.withOpacity(0.5),
        activeColor: Colors.white,
      ),
    );
  }
}
