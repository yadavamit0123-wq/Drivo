import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/domain/models/user_details_model.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';

class BottomNavigationbarWidget extends StatefulWidget {
  final int index;
  final UserDetail userData;
  final Function(int) onTap;
  const BottomNavigationbarWidget(
      {super.key,
      required this.index,
      required this.userData,
      required this.onTap});

  @override
  State<BottomNavigationbarWidget> createState() =>
      _BottomNavigationbarWidgetState();
}

class _BottomNavigationbarWidgetState extends State<BottomNavigationbarWidget> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.index;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationbarWidget oldWidget) {
    if (oldWidget.index != widget.index) {
      setState(() {
        _selectedIndex = widget.index;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final availableWidth = size.width - (size.width * 0.1) - 24;

    final bgColor = isDark
        ? AppColors.bottomNavigationBarColorDark
        : AppColors.bottomNavigationBarColor;
    final shadowColor = isDark
        ? AppColors.bottomNavigationBarShadowColorDark
        : AppColors.bottomNavigationBarShadowColor;

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: 12),
      color: Colors.transparent,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 1,
              blurRadius: 15,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              index: 0,
              iconPath: AppImages.home,
              label: AppLocalizations.of(context)!.home,
              availableWidth: availableWidth,
              isDark: isDark,
            ),
            _buildNavItem(
              index: 1,
              iconData: Icons.history,
              label: AppLocalizations.of(context)!.history,
              availableWidth: availableWidth,
              isDark: isDark,
            ),
            if (widget.userData.showWalletFeatureOnMobileApp == '1')
              _buildNavItem(
                index: 2,
                iconPath: AppImages.walletMenu,
                label: AppLocalizations.of(context)!.wallet,
                availableWidth: availableWidth,
                isDark: isDark,
              ),
            _buildNavItem(
              index: 3,
              iconPath: AppImages.user,
              label: AppLocalizations.of(context)!.myAccount,
              availableWidth: availableWidth,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    String? iconPath,
    IconData? iconData,
    required String label,
    required double availableWidth,
    required bool isDark,
  }) {
    final bool isWalletEnabled =
        widget.userData.showWalletFeatureOnMobileApp == '1';
    final isSelected = _selectedIndex == index;
    final double itemWidth = isSelected
        ? (availableWidth * (isWalletEnabled ? 0.45 : 0.55))
        : (availableWidth * (isWalletEnabled ? 0.15 : 0.20));

    final selectedColor = isDark
        ? AppColors.bottomNavigationBarSelectedColorDark
        : AppColors.bottomNavigationBarSelectedColor;
    final unselectedColor = isDark
        ? AppColors.bottomNavigationBarUnSelectedColorDark
        : AppColors.bottomNavigationBarUnSelectedColor;
    final iconTextActiveColor = isDark
        ? AppColors.bottomNavigationBarColorDark
        : AppColors.bottomNavigationBarColor;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex == index) return;
        widget.onTap(index);
        if (index == 0) {
          context.read<HomeBloc>().add(GetDirectionEvent());
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: itemWidth,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath,
                height: 20,
                width: 20,
                color: isSelected ? iconTextActiveColor : unselectedColor,
              )
            else if (iconData != null)
              Icon(
                iconData,
                size: 20,
                color: isSelected ? iconTextActiveColor : unselectedColor,
              ),
            if (isSelected) const SizedBox(width: 8),
            if (isSelected)
              Flexible(
                child: MyText(
                  text: label,
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: iconTextActiveColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
