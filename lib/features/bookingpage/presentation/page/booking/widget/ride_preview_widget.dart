import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/common.dart';
//import '../../../../../../common/pickup_icon.dart';
import '../../../../../../core/utils/custom_divider.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/booking_bloc.dart';
import 'eta_list_view_widget.dart';
import 'rental_ride/rental_eta_list_view.dart';

class RidePreviewWidget extends StatelessWidget {
  final BuildContext cont;
  final BookingPageArguments arg;

  const RidePreviewWidget({super.key, required this.cont, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<BookingBloc>(),
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: !context.read<BookingBloc>().showBiddingVehicles
                      ? size.width * 0.05
                      : size.width * 0.05,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: CustomDivider()),
                  ],
                ),
                SizedBox(height: size.width * 0.04),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.08 * 255).toInt()),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.borderColor
                            .withAlpha((0.5 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.only(
                        top: size.width * 0.03, bottom: size.width * 0.025),
                    child: Column(
                      children: [
                        // Pickup location with enhanced UI
                        ListView.builder(
                          itemCount: arg.pickupAddressList.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final address =
                                arg.pickupAddressList.elementAt(index);
                            return _buildLocationTile(
                              context: context,
                              icon: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: AppColors.green
                                      .withAlpha((0.15 * 255).toInt()),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.trip_origin,
                                  color: AppColors.green,
                                  size: 18,
                                ),
                              ),
                              address: address.address,
                              label: AppLocalizations.of(context)!.pickup,
                              labelColor: AppColors.green,
                              size: size,
                            );
                          },
                        ),
                        SizedBox(height: size.width * 0.03),
                        if (arg.stopAddressList.isNotEmpty) ...[
                          // Stop locations with connecting line
                          ListView.separated(
                            itemCount: arg.stopAddressList.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemBuilder: (context, index) {
                              final address =
                                  arg.stopAddressList.elementAt(index);
                              return _buildLocationTile(
                                context: context,
                                icon: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: AppColors.red
                                        .withAlpha((0.15 * 255).toInt()),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    (index == arg.stopAddressList.length - 1)
                                        ? Icons.location_on
                                        : Icons.add_location_alt,
                                    color: AppColors.red,
                                    size: 18,
                                  ),
                                ),
                                address: address.address,
                                label: (index == arg.stopAddressList.length - 1)
                                    ? AppLocalizations.of(context)!.dropLocation
                                    : AppLocalizations.of(context)!
                                        .stop
                                        .replaceAll('111', '${index + 1}'),
                                labelColor: AppColors.red,
                                size: size,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: size.width * 0.043),
                                    height: 1,
                                    width: 2,
                                    color: Theme.of(context).dividerColor),
                              );
                            },
                          ),
                          SizedBox(height: size.width * 0.02),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!context.read<BookingBloc>().isRentalRide &&
                    context.read<BookingBloc>().etaDetailsList.isNotEmpty) ...[
                  EtaListViewWidget(cont: context, arg: arg, thisValue: this),
                ],
                if (context.read<BookingBloc>().isRentalRide &&
                    context
                        .read<BookingBloc>()
                        .rentalEtaDetailsList
                        .isNotEmpty) ...[
                  SizedBox(height: size.width * 0.02),
                  RentalEtaListViewWidget(
                      cont: context, arg: arg, thisValue: this),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build location tile with modern UI
  Widget _buildLocationTile({
    required BuildContext context,
    required Widget icon,
    required String address,
    required String label,
    required Color labelColor,
    required Size size,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.width * 0.008),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: size.width * 0.003),
                MyText(
                  text: address,
                  maxLines: 1,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((0.9 * 255).toInt()),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
