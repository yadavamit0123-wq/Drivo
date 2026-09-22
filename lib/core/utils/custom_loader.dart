import 'package:flutter/material.dart';

import '../../common/common.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class CustomLoader {
  static bool _isShowing = false;

  static Future<void> loader(BuildContext context) async {
    if (!context.mounted || _isShowing) {
      return;
    }
    _isShowing = true;
    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
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
      _isShowing = false;
    }
  }

  static void dismiss(BuildContext context) {
    if (!_isShowing) {
      return;
    }

    var popped = false;

    void attemptPop(BuildContext? ctx) {
      if (popped || ctx == null || !ctx.mounted) {
        return;
      }
      final navigator = Navigator.of(ctx, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
        popped = true;
      }
    }

    attemptPop(context.mounted ? context : null);
    if (!popped) {
      attemptPop(navigatorKey.currentContext);
    }

    _isShowing = false;
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
