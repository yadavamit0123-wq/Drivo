// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/features/account/presentation/pages/coupon_list/page/coupon_list_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/help/help.dart';
import 'package:restart_tagxi/features/account/presentation/pages/outstation/page/outstation_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/profile/page/profile_info_page.dart';
import 'package:restart_tagxi/features/account/presentation/widgets/menu_options.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../common/common.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/domain/models/user_details_model.dart';
import '../../../home/application/home_bloc.dart';
import '../../application/acc_bloc.dart';
import 'fav_location/page/fav_location.dart';
import 'notification/page/notification_page.dart';
import 'refferal/page/referral_page.dart';
import 'settings/page/settings_page.dart';
import 'sos/page/sos_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(UserDataInitEvent(userDetails: arg.userData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is LogoutLoadingState) {
            Navigator.of(context).pop();
            CustomLoader.loader(context);
          } else if (state is LogoutFailureState) {
            CustomLoader.dismiss(context);
            if (context.mounted) {
              showToast(message: state.errorMessage);
            }
          } else if (state is LogoutSuccess) {
            CustomLoader.dismiss(context);
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginPage.routeName, (route) => false);
            }
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return (accBloc.userData != null)
              ? Directionality(
                  textDirection: context.read<AccBloc>().textDirection == 'rtl'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Scaffold(
                    body: SafeArea(
                      child: SizedBox(
                        width: size.width,
                        height: size.height,
                        child: Column(
                          children: [
                            SizedBox(
                              width: size.width,
                              child: Padding(
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          /// Name - Bold
                                          Expanded(
                                            child: MyText(
                                              text: accBloc.userData!.name,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium!
                                                  .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight
                                                        .w600, // ✅ Bold
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                  ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Help Button (unchanged)
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, HelpPage.routeName);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: size.width * 0.06,
                                            color: AppColors.green,
                                          ),
                                          SizedBox(width: size.width * 0.025),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .help,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 14,
                                                  color: AppColors.green,
                                                ),
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                            // Main content
                            Expanded(
                              child: Container(
                                width: size.width,
                                padding: EdgeInsets.all(size.width * 0.05),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .yourAccount,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.03),
                                      MenuSectionCard(children: [
                                        MenuOptions(
                                          icon: Icons.person_outline,
                                          iconColor: Colors.blue.shade600,
                                          iconbackground: Colors.blue.shade50,
                                          label: AppLocalizations.of(context)!
                                              .personalInformation,
                                          subtitle: accBloc.userData!.mobile,
                                          imagePath: AppImages.user,
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                    ProfileInfoPage.routeName,
                                                    arguments:
                                                        ProfileInfoPageArguments(
                                                            userData: context
                                                                .read<AccBloc>()
                                                                .userData!))
                                                .then((value) {
                                              if (!context.mounted) {
                                                return;
                                              }
                                              if (value != null) {
                                                context
                                                        .read<AccBloc>()
                                                        .userData =
                                                    value as UserDetail;
                                                context
                                                    .read<AccBloc>()
                                                    .add(AccUpdateEvent());
                                              } else {
                                                context.read<AccBloc>().add(
                                                    AccGetUserDetailsEvent());
                                              }
                                            });
                                          },
                                        ),
                                        customDivider(context),
                                        MenuOptions(
                                          icon: Icons.favorite_border,
                                          iconColor: Colors.pink.shade500,
                                          iconbackground: Colors.pink.shade50,
                                          label: AppLocalizations.of(context)!
                                              .favoriteLocation,
                                          onTap: () {
                                            Navigator.pushNamed(
                                                    context,
                                                    FavoriteLocationPage
                                                        .routeName,
                                                    arguments:
                                                        FavouriteLocationPageArguments(
                                                            userData: context
                                                                .read<AccBloc>()
                                                                .userData!))
                                                .then(
                                              (value) {
                                                if (!context.mounted) return;
                                                if (value != null) {
                                                  context
                                                          .read<AccBloc>()
                                                          .userData =
                                                      value as UserDetail;
                                                  context
                                                      .read<AccBloc>()
                                                      .add(AccUpdateEvent());
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ]),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .activity,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuSectionCard(children: [
                                        MenuOptions(
                                          icon: Icons.notifications_none,
                                          iconColor: Colors.amber.shade700,
                                          iconbackground: Colors.amber.shade50,
                                          label: AppLocalizations.of(context)!
                                              .notifications,
                                          imagePath: AppImages.notifications,
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                NotificationPage.routeName);
                                          },
                                        ),
                                        if (context
                                                .read<AccBloc>()
                                                .userData!
                                                .showOutstationRideFeature ==
                                            '1') ...[
                                          // SizedBox(height: size.width * 0.05),
                                          customDivider(context),
                                          MenuOptions(
                                            icon: Icons.route_outlined,
                                            iconColor: Colors.teal.shade600,
                                            iconbackground: Colors.teal.shade50,
                                            label: AppLocalizations.of(context)!
                                                .outStation,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context,
                                                  OutstationHistoryPage
                                                      .routeName,
                                                  arguments:
                                                      OutstationHistoryPageArguments(
                                                          isFromBooking:
                                                              false));
                                            },
                                          ),
                                        ],
                                      ]),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .benefits,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuSectionCard(children: [
                                        MenuOptions(
                                          icon: Icons.card_giftcard_outlined,
                                          iconColor: Colors.orange.shade600,
                                          iconbackground: Colors.orange.shade50,
                                          label: AppLocalizations.of(context)!
                                              .referEarn,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              ReferralPage.routeName,
                                              arguments: ReferralArguments(
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .referEarn,
                                                  userData: context
                                                      .read<AccBloc>()
                                                      .userData!),
                                            );
                                          },
                                        ),
                                        // SizedBox(height: size.width * 0.05),
                                        customDivider(context),
                                        MenuOptions(
                                          icon: Icons.local_offer_outlined,
                                          iconColor: Colors.indigo.shade600,
                                          iconbackground: Colors.indigo.shade50,
                                          label: AppLocalizations.of(context)!
                                              .coupon,
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                CouponsListPage.routeName,
                                                arguments:
                                                    CouponListPageArguments(
                                                        userData: context
                                                            .read<AccBloc>()
                                                            .userData!));
                                          },
                                        ),
                                        // SizedBox(
                                        //   height: size.width * 0.05,
                                        // ),
                                        customDivider(context),
                                        MenuOptions(
                                          icon: Icons.warning_amber_rounded,
                                          iconColor: Colors.red.shade600,
                                          iconbackground: Colors.red.shade50,
                                          label:
                                              AppLocalizations.of(context)!.sos,
                                          onTap: () {
                                            Navigator.pushNamed(
                                                    context, SosPage.routeName,
                                                    arguments: SOSPageArguments(
                                                        sosData: context
                                                            .read<AccBloc>()
                                                            .userData!
                                                            .sos
                                                            .data))
                                                .then(
                                              (value) {
                                                if (!context.mounted) return;
                                                if (value != null) {
                                                  final sos =
                                                      value as List<SOSDatum>;
                                                  context
                                                      .read<AccBloc>()
                                                      .sosdata = sos;
                                                  context
                                                          .read<AccBloc>()
                                                          .userData!
                                                          .sos
                                                          .data =
                                                      context
                                                          .read<AccBloc>()
                                                          .sosdata;
                                                  context
                                                      .read<AccBloc>()
                                                      .add(AccUpdateEvent());
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ]),
                                      SizedBox(height: size.width * 0.03),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .settings,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                            ),
                                      ),
                                      SizedBox(height: size.width * 0.05),
                                      MenuSectionCard(children: [
                                        MenuOptions(
                                          icon: Icons.language_outlined,
                                          iconColor: Colors.blue.shade600,
                                          iconbackground: Colors.blue.shade50,
                                          label: AppLocalizations.of(context)!
                                              .changeLanguage,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              ChooseLanguagePage.routeName,
                                              arguments:
                                                  ChooseLanguageArguments(
                                                      isInitialLanguageChange:
                                                          false),
                                            ).then(
                                              (value) {
                                                if (!context.mounted) return;
                                                context.read<AccBloc>().add(
                                                    AccGetDirectionEvent());
                                                context
                                                    .read<HomeBloc>()
                                                    .add(GetDirectionEvent());
                                              },
                                            );
                                          },
                                        ),
                                        customDivider(context),
                                        MenuOptions(
                                          icon: Icons.settings_outlined,
                                          iconColor: Colors.grey.shade800,
                                          iconbackground: Colors.grey.shade200,
                                          label: AppLocalizations.of(context)!
                                              .settings,
                                          imagePath: AppImages.settings,
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              SettingsPage.routeName,
                                              arguments: SettingsPageArguments(
                                                  userData: accBloc.userData!),
                                            );
                                          },
                                        ),
                                        customDivider(context),
                                        MenuOptions(
                                          icon: Icons.logout,
                                          iconColor: Colors.red.shade600,
                                          iconbackground: Colors.red.shade50,
                                          label: AppLocalizations.of(context)!
                                              .logout,
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              barrierColor:
                                                  Theme.of(context).shadowColor,
                                              builder: (BuildContext _) {
                                                return BlocProvider.value(
                                                  value:
                                                      BlocProvider.of<AccBloc>(
                                                          context),
                                                  child:
                                                      CustomDoubleButtonDialoge(
                                                    title: AppLocalizations.of(
                                                            context)!
                                                        .comeBackSoon,
                                                    content:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .logoutText,
                                                    noBtnName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .no,
                                                    yesBtnName:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .yes,
                                                    yesBtnFunc: () {
                                                      context
                                                          .read<AccBloc>()
                                                          .add(LogoutEvent());
                                                    },
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ]),
                                      SizedBox(height: size.width * 0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : const Scaffold(
                  body: Loader(),
                );
        }),
      ),
    );
  }
}

// Menu Group Card Widget ---------------------------------------------------
class MenuSectionCard extends StatelessWidget {
  final List<Widget> children;

  const MenuSectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8, // Increase blur
            spreadRadius: 1, // Spread evenly
            offset: const Offset(0, 0), // Center shadow (all sides)
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

Widget customDivider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Divider(
      height: 1,
      thickness: 0.4,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    ),
  );
}
