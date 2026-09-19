import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/custom_header.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/features/account/presentation/pages/coupon_list/widget/coupon_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/coupon_list_widget.dart';

class CouponsListPage extends StatelessWidget {
  final CouponListPageArguments args;
  static const String routeName = '/couponsListPage';

  const CouponsListPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(GetPromoCodeListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is PromoClearLoadingState) {
          } else if (state is PromoClearFailureState) {
          } else if (state is PromoClearSuccessState) {
          } else if (state is PromoApplyLoadingState) {
            CustomLoader.loader(context);
          } else if (state is PromoApplyFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is PromoApplySuccessState) {
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Theme.of(context).shadowColor,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<AccBloc>(context),
                  child: AlertDialog(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: MyText(
                      text: AppLocalizations.of(context)!.promoApplied.replaceAll(
                          '111',
                          "'${context.read<AccBloc>().selectedPromoCodeValue}'"),
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontSize: 16, color: AppColors.hintColor),
                      textAlign: TextAlign.center,
                    ),
                    content: MyText(
                      text: AppLocalizations.of(context)!
                          .appliedPromoText
                          .replaceAll('111',
                              '${args.userData.currencySymbol}${context.read<AccBloc>().selectedPromoPrice.toString()}'),
                      textStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontSize: 20,
                              ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                    ),
                    actions: [
                      CustomButton(
                        buttonName: AppLocalizations.of(context)!.okText,
                        borderRadius: 5,
                        width: size.width,
                        height: size.width * 0.12,
                        onTap: () {
                          context.read<AccBloc>().add(GetPromoCodeListEvent());
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          return SafeArea(
            child: Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                appBar: CustomHeader(
                  title: AppLocalizations.of(context)!.coupon,
                  automaticallyImplyLeading: true,
                  titleFontSize: 18,
                ),
                body: Padding(
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (_) {
                            if (context.read<AccBloc>().isLoading) {
                              return CouponShimmer(size: size);
                            }

                            if (context
                                .read<AccBloc>()
                                .promoCodeDataList
                                .isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(AppImages.notificationsNoData),
                                    SizedBox(height: size.width * 0.05),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .noDataAvailable,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return CouponsListWidget(
                              cont: context,
                              promoCodeDataList:
                                  context.read<AccBloc>().promoCodeDataList,
                              currencySymbol: args.userData.currencySymbol,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
