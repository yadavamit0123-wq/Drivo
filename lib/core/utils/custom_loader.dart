import 'package:flutter/material.dart';

import '../../common/common.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class CustomLoader {
  static int _openDialogCount = 0;

  static Future loader(BuildContext context) async {
    if (!context.mounted) {
      return Future.value();
    }
    _openDialogCount++;
    try {
      await showDialog<dynamic>(
        context: context,
        barrierColor: Colors.white.withAlpha((0.8 * 255).toInt()),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const AlertDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            titlePadding: EdgeInsets.zero,
            contentPadding: EdgeInsets.zero,
            content: Loader(),
          );
        },
      );
    } finally {
      if (_openDialogCount > 0) {
        _openDialogCount--;
      }
    }
  }

  static void dismiss(BuildContext context) {
    if (_openDialogCount <= 0) {
      return;
    }
    final rootContext = navigatorKey.currentContext;
    if (rootContext == null || !rootContext.mounted) {
      _openDialogCount = 0;
      return;
    }
    final navigator = Navigator.of(rootContext, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
      _openDialogCount--;
    }
  }
}

class Loader extends StatefulWidget {
  final Color? color;
  const Loader({super.key, this.color});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: widget.color ?? AppColors.primary,
      ),
    );
  }
}
