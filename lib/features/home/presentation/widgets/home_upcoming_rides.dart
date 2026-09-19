// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/app_arguments.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_images.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../account/presentation/pages/outstation/widget/outstation_offered_page.dart';
import '../../../account/presentation/pages/history/page/trip_summary_history.dart';
import '../../application/home_bloc.dart';

class HomeUpcomingRidesWidget extends StatelessWidget {
  final BuildContext cont;
  const HomeUpcomingRidesWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                items: List.generate(
                  (context.read<HomeBloc>().upcomingRideList.length > 3
                      ? 3
                      : context.read<HomeBloc>().upcomingRideList.length),
                  (index) {
                    final ride = context
                        .read<HomeBloc>()
                        .upcomingRideList
                        .elementAt(index);
                    return InkWell(
                      onTap: () {
                        if (ride.isOutStation == 1) {
                          if (ride.isBidRide == 1 &&
                              ride.acceptedRideFare == 0) {
                            Navigator.pushNamed(
                              context,
                              OutStationOfferedPage.routeName,
                              arguments: OutStationOfferedPageArguments(
                                requestId: ride.id,
                                currencySymbol: ride.requestedCurrencySymbol,
                                dropAddress: ride.dropAddress,
                                pickAddress: ride.pickAddress,
                                updatedAt: ride.tripStartTimeWithDate,
                                offeredFare: ride.offerredRideFare.toString(),
                              ),
                            ).then((value) {
                              if (!context.mounted) return;
                              context.read<HomeBloc>().add(GetDirectionEvent());
                            });
                          } else {
                            Navigator.pushNamed(
                              context,
                              HistoryTripSummaryPage.routeName,
                              arguments: TripHistoryPageArguments(
                                historyData: ride,
                                isSupportTicketEnabled: '0',
                                pageNumber: 1,
                              ),
                            ).then((value) {
                              if (!context.mounted) return;
                              context.read<HomeBloc>().add(GetDirectionEvent());
                            });
                          }
                        } else {
                          context.read<HomeBloc>().add(
                                ChangeBottomNavIndexEvent(
                                  index: 1, // History Tab
                                  pushTripSummary: true,
                                  historyData: ride,
                                  historyIndex: index,
                                ),
                              );
                        }
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
                            Padding(
                              padding: EdgeInsets.only(
                                  left: size.width * 0.01,
                                  right: size.width * 0.01),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: (ride.laterRide == true)
                                        ? ride.tripStartTimeWithDate
                                        : ride.convertedCreatedAt,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppColors.greyHintColor,
                                          fontSize: 12,
                                        ),
                                  ),
                                  Row(
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .pickupTime,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: AppColors.greyHintColor),
                                      ),
                                      MyText(
                                        text: ride.cvTripStartTime,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: AppColors.greyHintColor,
                                                fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const PickupIcon(),
                                    SizedBox(
                                      width: size.width * 0.02,
                                    ),
                                    Expanded(
                                      child: MyText(
                                        text: ride.pickAddress,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: size.height * 0.02),
                                if (ride.dropAddress.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const DropIcon(),
                                      SizedBox(
                                        width: size.width * 0.02,
                                      ),
                                      Expanded(
                                        child: MyText(
                                          text: ride.dropAddress,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
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
                                    child: Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: ride.vehicleTypeImage,
                                          height: 40,
                                          width: 40,
                                          placeholder: (_, __) =>
                                              const Loader(),
                                          errorWidget: (_, __, ___) =>
                                              Image.asset(AppImages.noImage),
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text: ride.driverDetail?.data
                                                      ?.carNumber ??
                                                  ride.carNumber,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            MyText(
                                              text: ride.driverDetail?.data
                                                      ?.vehicleTypeName
                                                      ?.toString() ??
                                                  ride.vehicleTypeName,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      MyText(
                                          text: (ride.isOutStation == 1 ||
                                                  ride.isBidRide == 1)
                                              ? '${ride.paymentTypeString.toString()} ${ride.requestedCurrencySymbol} ${ride.acceptedRideFare.toString()}'
                                              : '${ride.paymentTypeString.toString()} ${ride.requestedCurrencySymbol} ${ride.requestEtaAmount.toString()}',
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold)),
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
                  autoPlayAnimationDuration: const Duration(milliseconds: 300),
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
              if (context.read<HomeBloc>().upcomingRideList.length > 1) ...[
                SizedBox(height: size.width * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    (context.read<HomeBloc>().upcomingRideList.length > 3
                        ? 3
                        : context.read<HomeBloc>().upcomingRideList.length),
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
    );
  }
}
