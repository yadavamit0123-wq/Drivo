// ignore_for_file: deprecated_member_use

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/app_colors.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';

class HomeOnGoingRidesWidget extends StatelessWidget {
  final BuildContext cont;
  const HomeOnGoingRidesWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  items: List.generate(
                    (context.read<HomeBloc>().onGoingRideList.length > 3
                        ? 3
                        : context.read<HomeBloc>().onGoingRideList.length),
                    (index) {
                      final ride = context
                          .read<HomeBloc>()
                          .onGoingRideList
                          .elementAt(index);
                      return InkWell(
                        onTap: () {
                          context
                              .read<HomeBloc>()
                              .add(OnGoingRideOnTapEvent(selectedIndex: index));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 3),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 3, // Increase blur
                                spreadRadius: 0.1, // Spread evenly
                                offset: const Offset(
                                    0, 0), // Center shadow (all sides)
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Route Indicator
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 6),
                                          Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.lightGreen
                                                  .withOpacity(0.85),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.lightGreen
                                                      .withOpacity(0.25),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                          if (ride.dropAddress.isNotEmpty) ...[
                                            SizedBox(
                                                height: size.height * 0.035),
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: AppColors.errorLight
                                                  .withOpacity(0.9),
                                              size: 20,
                                            ),
                                          ]
                                        ],
                                      ),

                                      const SizedBox(width: 14),

                                      /// Address
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: size.height * 0.005),
                                            MyText(
                                              text: ride.pickAddress,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                            ),
                                            if (ride
                                                .dropAddress.isNotEmpty) ...[
                                              SizedBox(
                                                  height: size.height * 0.005),
                                              MyText(
                                                text: ride.dropAddress,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.width * 0.02,
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                              ),
                              Container(
                                padding: EdgeInsets.all(size.width * 0.02),
                                width: size.width,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: ride
                                                .driverDetail.data.carNumber,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          MyText(
                                            text: ride.driverDetail.data
                                                .vehicleTypeName
                                                .toString(),
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        MyText(
                                            text: (ride.acceptedAt != "" &&
                                                    ride.isDriverArrived == 0)
                                                ? AppLocalizations.of(context)!
                                                    .accepted
                                                : (ride.isDriverArrived == 1 &&
                                                        ride.isTripStart == 0)
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .arrived
                                                    : (ride.isCompleted == 1)
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .completed
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .tripStarted,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: (ride.acceptedAt !=
                                                              "" &&
                                                          ride.isDriverArrived ==
                                                              0)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : (ride.isDriverArrived ==
                                                                  1 &&
                                                              ride.isTripStart ==
                                                                  0)
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : AppColors.green,
                                                )),
                                        MyText(
                                            text: (ride.isOutStation == 1 ||
                                                    ride.isBidRide == 1)
                                                ? '${ride.paymentTypeString.toString()} ${ride.requestedCurrencySymbol} ${ride.acceptedRideFare.toString()}'
                                                : '${ride.paymentTypeString.toString()} ${ride.requestedCurrencySymbol} ${ride.requestEtaAmount.toString()}',
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  options: CarouselOptions(
                    height: size.width * 0.5,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.95,
                    initialPage: 0,
                    enableInfiniteScroll: false,
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 2),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 300),
                    autoPlayCurve: Curves.ease,
                    enlargeCenterPage: false,
                    enlargeFactor: 0.3,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      context.read<HomeBloc>().onGoingRideIndex = index;
                      context.read<HomeBloc>().add(UpdateEvent());
                    },
                  ),
                ),
                SizedBox(height: size.width * 0.025),
                if (context.read<HomeBloc>().onGoingRideList.length > 1) ...[
                  SizedBox(height: size.width * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      // context.read<HomeBloc>().onGoingRideList.length,
                      (context.read<HomeBloc>().onGoingRideList.length > 3
                          ? 3
                          : context.read<HomeBloc>().onGoingRideList.length),
                      (index) {
                        final isSelected =
                            context.read<HomeBloc>().onGoingRideIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 6,
                          width: isSelected ? 20 : 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : AppColors.greyHeader.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
