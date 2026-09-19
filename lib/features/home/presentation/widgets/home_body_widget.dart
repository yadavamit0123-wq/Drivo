import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as fmlt;

import '../../../../common/common.dart';
import '../../../../common/pickup_icon.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/home_bloc.dart';
import 'bottom_sheet_widget.dart';
import 'banner_widget.dart';

class HomeBodyWidget extends StatefulWidget {
  final HomeBloc home;

  const HomeBodyWidget({super.key, required this.home});

  @override
  State<HomeBodyWidget> createState() => _HomeBodyWidgetState();
}

class _HomeBodyWidgetState extends State<HomeBodyWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _markerAnimationController;
  final Map<String, fmlt.LatLng> _startMarkerPoints = {};
  final Map<String, fmlt.LatLng> _targetMarkerPoints = {};

  @override
  void initState() {
    super.initState();
    _markerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    super.dispose();
  }

  void _syncMarkerAnimation(List<dynamic> markers) {
    bool hasPositionUpdates = false;
    final activeIds = <String>{};

    for (final item in markers) {
      if (item is! Marker) continue;
      final marker = item;
      final id = marker.markerId.value;
      activeIds.add(id);
      final nextPoint = fmlt.LatLng(
        marker.position.latitude,
        marker.position.longitude,
      );
      final previousTarget = _targetMarkerPoints[id];

      if (previousTarget == null) {
        _startMarkerPoints[id] = nextPoint;
        _targetMarkerPoints[id] = nextPoint;
        continue;
      }

      final isSamePoint = previousTarget.latitude == nextPoint.latitude &&
          previousTarget.longitude == nextPoint.longitude;
      if (!isSamePoint) {
        _startMarkerPoints[id] = _interpolatedPoint(id) ?? previousTarget;
        _targetMarkerPoints[id] = nextPoint;
        hasPositionUpdates = true;
      }
    }

    _startMarkerPoints.removeWhere((id, _) => !activeIds.contains(id));
    _targetMarkerPoints.removeWhere((id, _) => !activeIds.contains(id));

    if (hasPositionUpdates) {
      _markerAnimationController.forward(from: 0);
    }
  }

  fmlt.LatLng? _interpolatedPoint(String markerId) {
    final from = _startMarkerPoints[markerId];
    final to = _targetMarkerPoints[markerId];
    if (from == null || to == null) return null;

    final t = Curves.linear.transform(_markerAnimationController.value);
    return fmlt.LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }
  // OSM Map update

  @override
  Widget build(BuildContext context) {
    final home = widget.home; // OSM Map update
    final size = MediaQuery.sizeOf(context);
    final screenWidth = size.width;
    return BlocProvider.value(
      value: home,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          _syncMarkerAnimation(homeBloc.markerList); //OSM Map Animate
          return Stack(
            children: [
              // The map and other widgets
              SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  children: [
                    (homeBloc.mapType == 'google_map')
                        // GOOGLE MAP
                        ? SizedBox(
                            height: size.height,
                            width: size.width,
                            child: GoogleMap(
                              mapType: homeBloc.selectedMapType,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (GoogleMapController controller) {
                                homeBloc.add(GoogleControllAssignEvent(
                                    controller: controller,
                                    isFromHomePage: true,
                                    isEditAddress: false,
                                    latlng: homeBloc.currentLatLng));
                              },
                              padding: EdgeInsets.only(
                                  bottom: screenWidth + size.width * 0.01),
                              initialCameraPosition: CameraPosition(
                                target: homeBloc.currentLatLng,
                                zoom: 15.0,
                              ),
                              onTap: (argument) {
                                homeBloc.currentLatLng = argument;
                                if (homeBloc.googleMapController != null) {
                                  homeBloc.googleMapController!.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: argument, zoom: 15)));
                                }
                              },
                              onCameraMoveStarted: () {
                                homeBloc.setDragging(true);

                                homeBloc.isCameraMoveComplete = true;
                              },
                              onCameraMove: (CameraPosition? position) {
                                if (position != null) {
                                  if (!context.mounted) return;
                                  homeBloc.currentLatLng = position.target;
                                }
                              },
                              onCameraIdle: () {
                                homeBloc.setDragging(false);
                                if (homeBloc.isCameraMoveComplete) {
                                  if (homeBloc.pickupAddressList.isEmpty) {
                                    homeBloc.add(UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: homeBloc.currentLatLng,
                                        mapType: homeBloc.mapType));
                                  } else {
                                    homeBloc.confirmPinAddress = true;
                                    homeBloc.add(UpdateEvent());
                                  }
                                }
                              },
                              markers: homeBloc.markerList.isNotEmpty
                                  ? Set.from(homeBloc.markerList)
                                  : {},
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(13, 20),
                              buildingsEnabled: false,
                              zoomControlsEnabled: false,
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                            ),
                          ) // OPEN STREET MAP
                        : SizedBox(
                            height: size.height * 0.55,
                            width: size.width,
                            child: fm.FlutterMap(
                              mapController: homeBloc.fmController,
                              options: fm.MapOptions(
                                onTap: (tapPosition, latLng) {
                                  homeBloc.currentLatLng =
                                      LatLng(latLng.latitude, latLng.longitude);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (homeBloc.fmController != null) {
                                      homeBloc.fmController!.move(latLng, 15);
                                    }
                                  });
                                  homeBloc.add(
                                    UpdateLocationEvent(
                                      isFromHomePage: true,
                                      latLng: homeBloc.currentLatLng,
                                      mapType: homeBloc.mapType,
                                    ),
                                  );
                                },
                                onMapEvent: (v) async {
                                  if (v.source ==
                                      fm.MapEventSource.nonRotatedSizeChange) {
                                    homeBloc.fmLatLng = fmlt.LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.currentLatLng = LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.add(
                                      UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: homeBloc.currentLatLng,
                                        mapType: homeBloc.mapType,
                                      ),
                                    );
                                  }
                                  if (v.source == fm.MapEventSource.onDrag) {
                                    homeBloc.currentLatLng = LatLng(
                                        v.camera.center.latitude,
                                        v.camera.center.longitude);
                                    homeBloc.add(UpdateEvent());
                                  }
                                  if (v.source == fm.MapEventSource.dragEnd) {
                                    homeBloc.add(
                                      UpdateLocationEvent(
                                        isFromHomePage: true,
                                        latLng: LatLng(v.camera.center.latitude,
                                            v.camera.center.longitude),
                                        mapType: homeBloc.mapType,
                                      ),
                                    );
                                  }
                                },
                                onPositionChanged: (p, l) async {
                                  if (l == false) {
                                    homeBloc.currentLatLng = LatLng(
                                        p.center.latitude, p.center.longitude);
                                    homeBloc.add(UpdateEvent());
                                  }
                                },
                                initialCenter: fmlt.LatLng(
                                    homeBloc.currentLatLng.latitude,
                                    homeBloc.currentLatLng.longitude),
                                initialZoom: 16,
                                minZoom: 13,
                                maxZoom: 20,
                              ),
                              children: [
                                fm.TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'app.example.com',
                                ),
                                fm.MarkerLayer(
                                  markers: homeBloc.markerList
                                      .asMap()
                                      .map(
                                        (k, value) {
                                          final marker =
                                              homeBloc.markerList.elementAt(k);
                                          return MapEntry(
                                            k,
                                            fm.Marker(
                                              alignment: Alignment.topCenter,
                                              // point: fmlt.LatLng(
                                              //     marker.position.latitude,
                                              //     marker.position.longitude),
                                              point: _interpolatedPoint(
                                                      marker.markerId.value) ??
                                                  fmlt.LatLng(
                                                    marker.position.latitude,
                                                    marker.position.longitude,
                                                  ),
                                              child: RotationTransition(
                                                turns: AlwaysStoppedAnimation(
                                                    marker.rotation / 360),
                                                child: Image.asset(
                                                  (marker.markerId.value
                                                          .toString()
                                                          .contains('truck'))
                                                      ? AppImages.truck
                                                      : marker.markerId.value
                                                              .toString()
                                                              .contains(
                                                                  'motor_bike')
                                                          ? AppImages.bike
                                                          : marker.markerId
                                                                  .value
                                                                  .toString()
                                                                  .contains(
                                                                      'auto')
                                                              ? AppImages.auto
                                                              : marker.markerId
                                                                      .value
                                                                      .toString()
                                                                      .contains(
                                                                          'lcv')
                                                                  ? AppImages
                                                                      .lcv
                                                                  : marker.markerId
                                                                          .value
                                                                          .toString()
                                                                          .contains(
                                                                              'ehcv')
                                                                      ? AppImages
                                                                          .ehcv
                                                                      : marker.markerId
                                                                              .value
                                                                              .toString()
                                                                              .contains('hatchback')
                                                                          ? AppImages.hatchBack
                                                                          : marker.markerId.value.toString().contains('hcv')
                                                                              ? AppImages.hcv
                                                                              : marker.markerId.value.toString().contains('mcv')
                                                                                  ? AppImages.mcv
                                                                                  : marker.markerId.value.toString().contains('luxury')
                                                                                      ? AppImages.luxury
                                                                                      : marker.markerId.value.toString().contains('premium')
                                                                                          ? AppImages.premium
                                                                                          : marker.markerId.value.toString().contains('suv')
                                                                                              ? AppImages.suv
                                                                                              : AppImages.car,
                                                  width: 16,
                                                  height: 25,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                      .values
                                      .toList(),
                                ),
                                const fm.RichAttributionWidget(
                                  attributions: [],
                                ),
                              ],
                            ),
                          ),

                    // Marker in the center of the screen
                    Positioned(
                      child: Container(
                        height: size.height * 0.8,
                        width: size.width * 1,
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: screenWidth * 0.6 + size.width * 0.06),
                          child: Image.asset(
                            AppImages.confirmationPin,
                            width: size.width * 0.12,
                            height: size.width * 0.12,
                          ),
                        ),
                      ),
                    ),

                    if (homeBloc.confirmPinAddress)
                      Positioned(
                        top: screenWidth * 0.09,
                        right: screenWidth * 0.38,
                        child: Container(
                          height: size.height * 0.8,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: screenWidth * 0.6 + size.width * 0.06),
                            child: Row(
                              children: [
                                BlocBuilder<HomeBloc, HomeState>(
                                  builder: (context, state) {
                                    return homeBloc.isDragging
                                        ? CustomButton(
                                            buttonColor: Theme.of(context)
                                                .disabledColor
                                                .withAlpha((0.5 * 255).toInt()),
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {},
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .pickMeHere,
                                          )
                                        : CustomButton(
                                            buttonColor:
                                                Theme.of(context).primaryColor,
                                            height: size.width * 0.08,
                                            width: size.width * 0.25,
                                            onTap: () {
                                              homeBloc.confirmPinAddress =
                                                  false;
                                              if (homeBloc
                                                      .nearByVechileSubscription ==
                                                  null) {
                                                homeBloc
                                                    .nearByVechileCheckStream(
                                                        context, this);
                                              }
                                              homeBloc.add(
                                                UpdateLocationEvent(
                                                  isFromHomePage: true,
                                                  latLng:
                                                      homeBloc.currentLatLng,
                                                  mapType: homeBloc.mapType,
                                                ),
                                              );
                                            },
                                            textSize: 12,
                                            buttonName:
                                                AppLocalizations.of(context)!
                                                    .confirm,
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Locate Me
              Positioned(
                bottom: size.height * 0.57,
                right: size.width * 0.03,
                child: Column(
                  children: [
                    if (homeBloc.mapType == 'google_map')
                      PopupMenuButton<MapType>(
                        color: AppColors.white,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: const Icon(Icons.layers, color: Colors.black),
                        ),
                        onSelected: (mapType) {
                          homeBloc.add(UpdateMapTypeEvent(mapType));
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                              value: MapType.normal,
                              child: MyText(
                                  text: AppLocalizations.of(context)!.normal,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.black))),
                          PopupMenuItem(
                              value: MapType.satellite,
                              child: MyText(
                                  text: AppLocalizations.of(context)!.satellite,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.black))),
                          PopupMenuItem(
                            value: MapType.terrain,
                            child: MyText(
                                text: AppLocalizations.of(context)!.terrain,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: AppColors.black)),
                          ),
                          PopupMenuItem(
                            value: MapType.hybrid,
                            child: MyText(
                                text: AppLocalizations.of(context)!.hybrid,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: AppColors.black)),
                          ),
                        ],
                      ),
                    SizedBox(height: size.width * 0.02),
                    InkWell(
                      onTap: () {
                        // Remove confirmPinAddress for envato code
                        homeBloc.confirmPinAddress = false;
                        if (homeBloc.nearByVechileSubscription == null) {
                          homeBloc.nearByVechileCheckStream(context, this);
                        }
                        homeBloc.add(LocateMeEvent(mapType: homeBloc.mapType));
                      },
                      child: Container(
                        height: size.width * 0.11,
                        width: size.width * 0.11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          border: Border.all(
                            width: 1.2,
                            color:
                                AppColors.black.withAlpha((0.8 * 255).toInt()),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.my_location,
                            size: size.width * 0.05,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Navigation and location bar
              SafeArea(
                bottom: false,
                top: true,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          homeBloc.add(DestinationSelectEvent(
                              isPickupChange: true,
                              transportType:
                                  homeBloc.selectedServiceType!.transportType));
                        },
                        child: Container(
                          // width: size.width * 0.78,
                          width: size.width * 0.9,
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 6),
                            child: Row(
                              children: [
                                const PickupIcon(),
                                SizedBox(width: size.width * 0.01),
                                SizedBox(
                                  // width: size.width * 0.63,
                                  width: size.width * 0.75,
                                  child: MyText(
                                      text: homeBloc.currentLocation,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Icon(Icons.edit_outlined,
                                    size: 18,
                                    color: Theme.of(context).disabledColor),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    double sheetSize = homeBloc.sheetSize;
                    double minChildSize = homeBloc.minChildSize; // Bottom
                    double maxChildSize = homeBloc.maxChildSize; // Top
                    double currentSize = sheetSize;
                    return Stack(
                      children: [
                        if (currentSize < 0.9 &&
                            homeBloc.userData != null &&
                            homeBloc.userData!.bannerImage != null &&
                            homeBloc.userData!.bannerImage.data.isNotEmpty)
                          Positioned(
                            bottom: MediaQuery.of(context).size.height *
                                    currentSize +
                                16,
                            left: 16,
                            right: 16,
                            child: BannerWidget(cont: context),
                          ),
                        GestureDetector(
                          onVerticalDragUpdate: (details) {
                            if (!homeBloc.isDraggingSheet) {
                              homeBloc
                                  .add(SetDraggingSheetEvent(isDragging: true));
                            }
                            final dragAmount = details.primaryDelta ?? 0;

                            currentSize = (currentSize -
                                    dragAmount / context.size!.height)
                                .clamp(minChildSize, maxChildSize);
                            homeBloc
                                .add(UpdateScrollPositionEvent(currentSize));
                          },
                          onVerticalDragEnd: (details) {
                            homeBloc
                                .add(SetDraggingSheetEvent(isDragging: false));
                            // Improved snapping logic: snap ONLY to top or bottom
                            final velocity = details.primaryVelocity ?? 0;

                            if (velocity < -300) {
                              // Swipe up
                              currentSize = maxChildSize;
                            } else if (velocity > 300) {
                              // Swipe down
                              currentSize = minChildSize;
                            } else {
                              // Slow drag - snap to nearest anchor (min or max)
                              if (currentSize >
                                  (minChildSize + maxChildSize) / 2) {
                                currentSize = maxChildSize;
                              } else {
                                currentSize = minChildSize;
                              }
                            }

                            homeBloc
                                .add(UpdateScrollPositionEvent(currentSize));
                          },
                          child: AnimatedContainer(
                            duration: homeBloc.isDraggingSheet
                                ? Duration.zero
                                : const Duration(milliseconds: 300),
                            height: MediaQuery.of(context).size.height *
                                currentSize,
                            curve: Curves.easeInOut,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(30)),
                              ),
                              child: homeBloc.serviceAvailable
                                  ? BottomSheetWidget(home: homeBloc)
                                  : Column(
                                      children: [
                                        SizedBox(height: size.width * 0.03),
                                        Image.asset(AppImages.noDataFound,
                                            height: size.width * 0.5,
                                            width: size.width),
                                        SizedBox(height: size.width * 0.02),
                                        MyText(
                                            text: AppLocalizations.of(context)!
                                                .serviceNotAvailable)
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
