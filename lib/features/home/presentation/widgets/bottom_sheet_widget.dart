// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/widgets/home_on_going_rides.dart';
import 'home_upcoming_rides.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';
import '../../domain/models/ride_modules_model.dart';
import 'bottom_sheet_shimmer.dart';
import 'banner_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final HomeBloc home;

  const BottomSheetWidget({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
        value: home,
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final homeBloc = context.read<HomeBloc>();
            if (homeBloc.userData == null) {
              return const SizedBox.shrink();
            }

            final uniqueTransportTypes = homeBloc.rideModules
                .map((m) => m.transportType)
                .toSet()
                .toList();

            final filteredModules = homeBloc.rideModules
                .where((m) => m.transportType == homeBloc.transportType)
                .toList();

            if (filteredModules.isEmpty) {
              if (homeBloc.isLoading) {
                return const BottomSheetShimmer();
              } else {
                return Column(
                  children: [
                    SizedBox(height: size.width * 0.03),
                    Image.asset(AppImages.noDataFound,
                        height: size.width * 0.5, width: size.width),
                    SizedBox(height: size.width * 0.02),
                    MyText(
                        text: AppLocalizations.of(context)!.serviceNotAvailable)
                  ],
                );
              }
            }

            return Container(
              height: size.height,
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SafeArea(
                bottom: false,
                top: homeBloc.isSheetAtTop ? true : false,
                child: Column(
                  children: [
                    SizedBox(height: size.width * 0.05),
                    Container(
                      width: size.width * 0.1,
                      height: size.width * 0.01,
                      decoration: BoxDecoration(
                        color: AppColors.borderColors,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    if (uniqueTransportTypes.length > 1) ...[
                      SizedBox(height: size.width * 0.05),
                      _buildCategorySelector(context, size, homeBloc),
                      SizedBox(height: size.width * 0.025),
                    ] else
                      SizedBox(height: size.width * 0.05),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: homeBloc.isSheetAtTop
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (filteredModules.isNotEmpty)
                              _buildAllServices(
                                  context,
                                  size,
                                  (homeBloc.sheetSize > 0.7)
                                      ? filteredModules
                                      : (filteredModules.length > 4
                                          ? filteredModules.sublist(0, 4)
                                          : filteredModules),
                                  homeBloc),
                            _buildSearchBar(context, size, homeBloc),
                            SizedBox(height: size.width * 0.025),
                            if (homeBloc.recentSearchPlaces.isNotEmpty &&
                                homeBloc.selectedServiceIndex != 2)
                              _buildRecentSearch(context, size, homeBloc),
                            if (homeBloc.sheetSize > 0.7 &&
                                homeBloc.userData != null &&
                                homeBloc.userData!.bannerImage != null &&
                                homeBloc.userData!.bannerImage.data.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: BannerWidget(cont: context),
                              ),
                            if (homeBloc.sheetSize > 0.7 &&
                                context
                                    .read<HomeBloc>()
                                    .upcomingRideList
                                    .isNotEmpty) ...[
                              SizedBox(height: size.width * 0.05),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.01),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.autorenew),
                                        SizedBox(width: size.width * 0.01),
                                        MyText(
                                            text: AppLocalizations.of(context)!
                                                .upcoming,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColorDark)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.0),
                                child: HomeUpcomingRidesWidget(cont: context),
                              ),
                            ],
                            if (homeBloc.isMultipleRide &&
                                homeBloc.sheetSize > 0.7 &&
                                context
                                    .read<HomeBloc>()
                                    .onGoingRideList
                                    .isNotEmpty) ...[
                              SizedBox(height: size.width * 0.05),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.01),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.autorenew),
                                        SizedBox(width: size.width * 0.01),
                                        MyText(
                                            text: AppLocalizations.of(context)!
                                                .onGoingRides,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColorDark)),
                                      ],
                                    ),
                                    if (context
                                        .read<HomeBloc>()
                                        .isMultipleRide) ...[
                                      if (context
                                              .read<HomeBloc>()
                                              .onGoingRideList
                                              .length >
                                          3)
                                        InkWell(
                                          onTap: () {
                                            context.read<HomeBloc>().add(
                                                NavigateToOnGoingRidesPageEvent());
                                          },
                                          child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .view,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
                                                          .primaryColorDark)),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: size.width * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.0),
                                child: HomeOnGoingRidesWidget(cont: context),
                              ),
                            ],
                            SizedBox(height: size.width * 0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget _buildCategorySelector(
      BuildContext context, Size size, HomeBloc homeBloc) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.borderColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(50),
      ),
      height: homeBloc.isSheetAtTop ? size.width * 0.12 : size.width * 0.10,
      padding: EdgeInsets.all(size.width * 0.01),
      child: Row(
        children: [
          _categoryButton(context, size, homeBloc, 'taxi',
              AppLocalizations.of(context)!.taxi, Icons.local_taxi_outlined),
          _categoryButton(
              context,
              size,
              homeBloc,
              'delivery',
              AppLocalizations.of(context)!.delivery,
              Icons.card_giftcard_outlined),
        ],
      ),
    );
  }

  Widget _categoryButton(BuildContext context, Size size, HomeBloc homeBloc,
      String type, String label, IconData icon) {
    bool isSelected = homeBloc.transportType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          homeBloc.add(ServiceTypeChangeEvent(
              transportType: type,
              serviceTypeIndex: type == 'taxi' ? 0 : 1,
              shouldNavigate: false));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: homeBloc.isSheetAtTop ? 18 : 16,
                  color: isSelected ? AppColors.white : AppColors.black),
              SizedBox(width: size.width * 0.02),
              MyText(
                text: label,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontSize: homeBloc.isSheetAtTop ? 16 : 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.white : AppColors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllServices(BuildContext context, Size size,
      List<ModulesData> modules, HomeBloc homeBloc) {
    if (modules.length < 2) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.services,
          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: homeBloc.isSheetAtTop ? 18 : 16,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: size.width * 0.025),
        if (modules.length == 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.44, height: size.width * 0.18),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.44, height: size.width * 0.18),
            ],
          ),
        if (modules.length == 3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.28,
                  height: size.width * 0.30,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.28,
                  height: size.width * 0.30,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.28,
                  height: size.width * 0.30,
                  isRow: false),
            ],
          ),
        if (modules.length == 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
        if (modules.length == 5)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.44,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(context, size, modules[0], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                        _buildServiceItem(context, size, modules[1], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                      ],
                    ),
                    SizedBox(height: size.width * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(context, size, modules[2], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                        _buildServiceItem(context, size, modules[3], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                      ],
                    )
                  ],
                ),
              ),
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.5,
                  isRow: false,
                  isLarge: true),
            ],
          ),
        if (modules.length == 6) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.18,
                  isLarge: true),
              _buildServiceItem(context, size, modules[5], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.18,
                  isLarge: true),
            ],
          ),
        ],
        if (modules.length == 7) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem(context, size, modules[4], homeBloc,
                        width: size.width * 0.21,
                        height: size.width * 0.25,
                        isMedium: true,
                        isRow: false),
                    _buildServiceItem(context, size, modules[5], homeBloc,
                        width: size.width * 0.21,
                        height: size.width * 0.25,
                        isMedium: true,
                        isRow: false),
                  ],
                ),
              ),
              _buildServiceItem(
                context,
                size,
                modules[6],
                homeBloc,
                width: size.width * 0.44,
                height: size.width * 0.25,
                isLarge: true,
              ),
            ],
          ),
        ],
        if (modules.length == 8) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[5], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[6], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[7], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
        ],
        if (modules.length == 9) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.44,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(context, size, modules[4], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                        _buildServiceItem(context, size, modules[5], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                      ],
                    ),
                    SizedBox(height: size.width * 0.0175),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildServiceItem(context, size, modules[6], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                        _buildServiceItem(context, size, modules[7], homeBloc,
                            width: size.width * 0.21,
                            height: size.width * 0.24,
                            isRow: false),
                      ],
                    )
                  ],
                ),
              ),
              _buildServiceItem(context, size, modules[8], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.5,
                  isRow: false,
                  isLarge: true),
            ],
          ),
        ],
        if (modules.length == 10) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[5], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[6], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[7], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[8], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.18,
                  isLarge: true),
              _buildServiceItem(context, size, modules[9], homeBloc,
                  width: size.width * 0.44,
                  height: size.width * 0.18,
                  isLarge: true),
            ],
          ),
        ],
        SizedBox(height: size.width * 0.0175),
        if (modules.length == 11) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[5], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[6], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
              _buildServiceItem(context, size, modules[7], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isMedium: true,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem(context, size, modules[8], homeBloc,
                        width: size.width * 0.21,
                        height: size.width * 0.25,
                        isMedium: true,
                        isRow: false),
                    _buildServiceItem(context, size, modules[9], homeBloc,
                        width: size.width * 0.21,
                        height: size.width * 0.25,
                        isMedium: true,
                        isRow: false),
                  ],
                ),
              ),
              _buildServiceItem(
                context,
                size,
                modules[10],
                homeBloc,
                width: size.width * 0.44,
                height: size.width * 0.25,
                isMedium: true,
              ),
            ],
          ),
        ],
        SizedBox(height: size.width * 0.0175),
        if (modules.length == 12) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[0], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[1], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[2], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[3], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[4], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[5], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[6], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[7], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
          SizedBox(height: size.width * 0.0175),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceItem(context, size, modules[8], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[9], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[10], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
              _buildServiceItem(context, size, modules[11], homeBloc,
                  width: size.width * 0.21,
                  height: size.width * 0.25,
                  isRow: false),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildServiceItem(
      BuildContext context, Size size, ModulesData module, HomeBloc homeBloc,
      {bool isRow = true,
      double? width,
      double? height,
      bool hasBadge = false,
      String? badgeText,
      bool isMedium = false,
      bool isLarge = false}) {
    int moduleIndex = homeBloc.getServiceIndex(module);

    bool isSelected = homeBloc.selectedServiceIndex == moduleIndex;

    return InkWell(
      onTap: () {
        homeBloc.add(ServiceTypeChangeEvent(
            transportType: module.transportType,
            serviceTypeIndex: moduleIndex,
            shouldNavigate: false));
      },
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(size.width * 0.01),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : AppColors.borderColor.withOpacity(0.5),
              width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (hasBadge && badgeText != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: MyText(
                    text: badgeText,
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 6,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            Center(
              child: isRow
                  ? Row(
                      children: [
                        _buildIconCircle(context, size, module,
                            isSmall: width != null && width < size.width * 0.3,
                            isMedium: isMedium,
                            isLarge: isLarge),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: MyText(
                            text: module.name,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildIconCircle(context, size, module,
                            isSmall: width != null && width < size.width * 0.3,
                            isMedium: isMedium,
                            isLarge: isLarge),
                        const SizedBox(height: 2),
                        Flexible(
                          child: MyText(
                            text: module.name,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: isLarge
                                        ? (module.name
                                                .split(' ')
                                                .any((word) => word.length > 9)
                                            ? 14
                                            : 16)
                                        : (module.name
                                                .split(' ')
                                                .any((word) => word.length > 9)
                                            ? 10
                                            : 12),
                                    fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle(BuildContext context, Size size, ModulesData module,
      {bool isSmall = false, bool isMedium = false, bool isLarge = false}) {
    double iconSize = isLarge ? 68 : (isMedium ? 48 : (isSmall ? 36 : 52));
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CachedNetworkImage(
        imageUrl: module.menuIcon,
        placeholder: (context, url) => const Loader(),
        errorWidget: (context, url, error) => Icon(
          Icons.directions_car,
          size: iconSize * 0.6,
          color: const Color(0xFF6C63FF),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, Size size, HomeBloc homeBloc) {
    return InkWell(
      onTap: () {
        if (homeBloc.pickupAddressList.isNotEmpty) {
          homeBloc.add(ServiceTypeChangeEvent(
              transportType: homeBloc.transportType,
              serviceTypeIndex: homeBloc.selectedServiceIndex,
              shouldNavigate: true));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.borderColor,
          borderRadius: homeBloc.isSheetAtTop
              ? BorderRadius.circular(16)
              : BorderRadius.circular(8),
        ),
        padding: homeBloc.isSheetAtTop
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.hintColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: MyText(
                text: homeBloc.selectedServiceIndex == 2
                    ? AppLocalizations.of(context)!.choosePickupLocation
                    : AppLocalizations.of(context)!.whereAreYouGoing,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.hintColor,
                      fontSize: 16,
                    ),
              ),
            ),
            if (homeBloc.selectedServiceIndex != 2) ...[
              if (homeBloc.userData?.showRideWithoutDestination == "1")
                InkWell(
                  onTap: () => homeBloc.add(RideWithoutDestinationEvent()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MyText(
                      text: AppLocalizations.of(context)!.skip,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearch(
      BuildContext context, Size size, HomeBloc homeBloc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.recentSearch,
          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              fontSize: homeBloc.isSheetAtTop ? 18 : 14,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(height: size.width * 0.02),
        ListView.builder(
          itemCount: (homeBloc.sheetSize <= 0.7)
              ? (homeBloc.recentSearchPlaces.isNotEmpty ? 1 : 0)
              : (homeBloc.recentSearchPlaces.length > 2
                  ? 2
                  : homeBloc.recentSearchPlaces.length),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final recentPlace =
                homeBloc.recentSearchPlaces.reversed.elementAt(index);
            return InkWell(
              onTap: () {
                if (homeBloc.pickupAddressList.isNotEmpty) {
                  homeBloc.add(RecentSearchPlaceSelectEvent(
                      address: recentPlace,
                      isPickupSelect: false,
                      transportType: homeBloc.transportType,
                      serviceTypeIndex: homeBloc.selectedServiceIndex));
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppColors.borderColor.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    homeBloc.isSheetAtTop
                        ? Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0EFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.access_time_filled,
                              size: 18,
                              color: Color(0xFF6C63FF),
                            ),
                          )
                        : Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF0EFFF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.access_time_filled,
                              size: 18,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                    SizedBox(width: size.width * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: recentPlace.address.split(',')[0],
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                          ),
                          MyText(
                            text: recentPlace.address,
                            textStyle:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: AppColors.hintColor,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.hintColor),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
