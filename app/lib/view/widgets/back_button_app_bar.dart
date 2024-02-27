import "package:flutter/material.dart";

/// An [AppBar] with invisible background, only showing the back button
class BackButtonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;

  const BackButtonAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      leadingWidth: 72,
      title: title,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: Navigator.of(context).pop,
        ),
      ),
    );
  }

  /// This should be default for [AppBar]
  @override
  Size get preferredSize => const Size(0, 56.0);
}
