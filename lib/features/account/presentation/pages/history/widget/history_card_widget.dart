// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/history_model.dart';

class HistoryCardWidget extends StatelessWidget {
  final BuildContext cont;
  final HistoryData history;

  const HistoryCardWidget({
    super.key,
    required this.cont,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            // margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 2, // Increase blur
                  spreadRadius: 0.5, // Spread evenly
                  offset: const Offset(0, 0), // Center shadow (all sides)
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        MyText(
                          text: (history.laterRide == true)
                              ? history.tripStartTimeWithDate
                              : history.isCompleted == 1
                                  ? history.convertedCompletedAt
                                  : history.isCancelled == 1
                                      ? history.convertedCancelledAt
                                      : history.convertedCreatedAt,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.greyHintColor,
                                    fontSize: 12,
                                  ),
                        ),
                        if (history.returnTime.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: MyText(
                              text: history.returnTime,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    MyText(
                      text: (history.isBidRide == 1)
                          ? '${history.requestedCurrencySymbol} ${history.acceptedRideFare}'
                          : (history.isCompleted == 1)
                              ? '${history.requestBill.data.requestedCurrencySymbol} ${history.requestBill.data.totalAmount}'
                              : '${history.requestedCurrencySymbol} ${history.requestEtaAmount}',
                      textStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 24,
                              ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: AppColors.lightGreen.withOpacity(0.85),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightGreen.withOpacity(0.25),
                                blurRadius: 6,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 1.8,
                          height: size.width * 0.13,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.lightGreen.withOpacity(0.8),
                                Colors.grey.shade300.withOpacity(0.6),
                                AppColors.errorLight.withOpacity(0.8),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.errorLight.withOpacity(0.9),
                          size: 20,
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),

                    /// Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.pickup,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: AppColors.greyHintColor),
                              ),
                              MyText(
                                text: history.cvTripStartTime,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: AppColors.greyHintColor,
                                        fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            text: history.pickAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.drop,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: AppColors.greyHintColor),
                              ),
                              MyText(
                                text: history.cvCompletedAt,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        color: AppColors.greyHintColor,
                                        fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            text:
                                (history.requestStops?.data.isNotEmpty == true)
                                    ? history.requestStops!.data.last.address
                                    : history.dropAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).dividerColor.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // === Bottom Section ===
                (history.isOutStation != 1)
                    ? _buildRegularTripDetails(context)
                    : _buildOutstationTripDetails(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // Regular City Ride
  Widget _buildRegularTripDetails(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Vehicle Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: history.vehicleTypeImage,
                    height: 48,
                    width: 48,
                    placeholder: (_, __) => const Loader(),
                    errorWidget: (_, __, ___) => Image.asset(AppImages.noImage),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: history.vehicleTypeName,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: history.carColor,
                          textStyle:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: AppColors.greyHintColor,
                                    fontSize: 13,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right: Status + Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (history.isCompleted == 1 ||
                history.isCancelled == 1 ||
                history.isLater == true)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: history.isCompleted == 1
                      ? AppColors.green
                      : history.isCancelled == 1
                          ? AppColors.red
                          : AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: MyText(
                  text: history.isCompleted == 1
                      ? AppLocalizations.of(context)!.completed
                      : history.isCancelled == 1
                          ? AppLocalizations.of(context)!.cancelled
                          : (history.isRental == false)
                              ? AppLocalizations.of(context)!.upcoming
                              // : 'Rental ${history.rentalPackageName}',
                              : AppLocalizations.of(context)!
                                  .rental
                                  .replaceAll('111', history.rentalPackageName),
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Outstation Ride
  Widget _buildOutstationTripDetails(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText(
                  text: (history.isRoundTrip == 1)
                      ? AppLocalizations.of(context)!.roundTrip
                      : AppLocalizations.of(context)!.oneWayTrip,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        // color: AppColors.yellowColor,
                      ),
                ),
                if (history.isRoundTrip == 1)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.import_export,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Vehicle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: history.vehicleTypeImage,
                        height: 48,
                        width: 48,
                        placeholder: (_, __) => const Loader(),
                        errorWidget: (_, __, ___) =>
                            Image.asset(AppImages.noImage),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: history.vehicleTypeName,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: history.carColor,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: AppColors.greyHintColor,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right: Status + Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (history.isCompleted == 1 ||
                    history.isCancelled == 1 ||
                    history.isLater == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: history.isCompleted == 1
                          ? AppColors.green
                          : history.isCancelled == 1
                              ? AppColors.red
                              : AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: MyText(
                      text: history.isCompleted == 1
                          ? AppLocalizations.of(context)!.completed
                          : history.isCancelled == 1
                              ? AppLocalizations.of(context)!.cancelled
                              : (history.isRental == false)
                                  ? AppLocalizations.of(context)!.upcoming
                                  : 'Rental ${history.rentalPackageName}',
                      textStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Colors.black,
                              ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
