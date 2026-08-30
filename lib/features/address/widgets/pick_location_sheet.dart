import 'package:flutter/material.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/widgets/loading_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

// ─────────────────────────────────────────────────────────────
//  Data model — unchanged public contract
// ─────────────────────────────────────────────────────────────

class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

// ─────────────────────────────────────────────────────────────
//  Public entry-point widget
// ─────────────────────────────────────────────────────────────

class PickLocationSheet extends StatefulWidget {
  const PickLocationSheet({super.key});

  @override
  State<PickLocationSheet> createState() => _PickLocationSheetState();
}

// ─────────────────────────────────────────────────────────────
//  State
// ─────────────────────────────────────────────────────────────

class _PickLocationSheetState extends State<PickLocationSheet> {
  // ── Constants ─────────────────────────────────────────────
  static const _fallback = LatLng(15.369445, 44.191007);
  static const _defaultZoom = 17.0;
  static const _defaultAddress = 'حدد موقعك ثم اضغط تأكيد الموقع';
  static const _fallbackAddress = 'موقع محدد على الخريطة';

  // ── State ──────────────────────────────────────────────────
  final MapController _mapController = MapController();

  /// Current map centre — updated only from onPositionChanged.
  /// No geocoding is triggered when this changes.
  LatLng _center = _fallback;

  /// Shown in the address card. Updated ONLY when the user
  /// taps "تأكيد الموقع".
  final String _address = _defaultAddress;

  /// True only while the confirm button is performing reverse-geocoding.
  bool _confirming = false;

  /// True after the map widget has been rendered at least once,
  /// so we can safely call _mapController.move().
  bool _mapReady = false;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ── Location helpers ───────────────────────────────────────

  /// Called once on open. Moves the map to the device location.
  /// No geocoding is performed here.
  Future<void> _initLocation() async {
    final position = await _getDevicePosition();
    if (!mounted) return;
    if (position != null) {
      _center = LatLng(position.latitude, position.longitude);
      if (_mapReady) {
        _mapController.move(_center, _defaultZoom);
      }
    }
  }

  /// "My location" button — moves the map only, NO geocoding.
  Future<void> _goToMyLocation() async {
    final position = await _getDevicePosition();
    if (!mounted) return;
    if (position == null) return;
    _center = LatLng(position.latitude, position.longitude);
    if (_mapReady) {
      _mapController.move(_center, _defaultZoom);
    }
  }

  /// Returns the device position, or null on any error / denied permission.
  Future<Position?> _getDevicePosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Confirm ────────────────────────────────────────────────

  /// The ONLY place where reverse-geocoding is called.
  Future<void> _confirmLocation() async {
    if (_confirming) return;

    HapticFeedback.lightImpact();
    setState(() => _confirming = true);

    String resolvedAddress = _fallbackAddress;

    try {
      final places = await placemarkFromCoordinates(
        _center.latitude,
        _center.longitude,
      );

      if (places.isNotEmpty) {
        final p = places.first;
        final parts = [
          p.name,
          p.street,
          p.subLocality,
          p.locality,
          p.subAdministrativeArea,
          p.administrativeArea,
          p.country,
        ].where((e) => e != null && e.trim().isNotEmpty).toList();

        if (parts.isNotEmpty) {
          resolvedAddress = parts.join('، ');
        }
      }
    } catch (_) {
      resolvedAddress = _fallbackAddress;
    }

    if (!mounted) return;

    Navigator.of(context).pop(
      PickedLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: resolvedAddress,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: screenHeight * 0.88,
        child: Column(
          children: [
            _SheetHandle(colorScheme: colorScheme),
            _SheetHeader(
              onClose: _confirming ? null : () => Navigator.of(context).pop(),
              colorScheme: colorScheme,
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _MapSection(
                mapController: _mapController,
                center: _center,
                confirming: _confirming,
                colorScheme: colorScheme,
                onMapReady: () {
                  _mapReady = true;
                  _mapController.move(_center, _defaultZoom);
                },
                onPositionChanged: (pos) => _center = pos,
                onZoomIn: () {
                  if (_mapReady) {
                    _mapController.move(
                      _center,
                      _mapController.camera.zoom + 1,
                    );
                  }
                },
                onZoomOut: () {
                  if (_mapReady) {
                    _mapController.move(
                      _center,
                      _mapController.camera.zoom - 1,
                    );
                  }
                },
                onMyLocation: _confirming ? null : _goToMyLocation,
              ),
            ),
            _BottomCard(
              address: _address,
              confirming: _confirming,
              colorScheme: colorScheme,
              onConfirm: _confirmLocation,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Sub-widgets (private, stateless)
// ─────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SheetHandle({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final VoidCallback? onClose;
  final ColorScheme colorScheme;

  const _SheetHeader({required this.onClose, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Close button
          _IconCircleButton(
            icon: Icons.close_rounded,
            onPressed: onClose,
            colorScheme: colorScheme,
          ),
          // Title
          Expanded(
            child: Text(
              'اختيار الموقع',
              textAlign: TextAlign.center,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Spacer to balance the close button
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Circular icon button used for close, zoom, and my-location.
class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final ColorScheme colorScheme;

  const _IconCircleButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
    this.size = 40, // INTENTIONAL COMPONENT DIMENSION
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: colorScheme.surface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12), // INTENTIONAL VISUAL EXCEPTION (Elevation mapping)
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onPressed,
          child: AppIcon(icon, size: AppIconSize.small, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  final MapController mapController;
  final LatLng center;
  final bool confirming;
  final ColorScheme colorScheme;
  final VoidCallback onMapReady;
  final ValueChanged<LatLng> onPositionChanged;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback? onMyLocation;

  const _MapSection({
    required this.mapController,
    required this.center,
    required this.confirming,
    required this.colorScheme,
    required this.onMapReady,
    required this.onPositionChanged,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onMyLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Tile map ─────────────────────────────────────
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 17,
                onMapReady: onMapReady,
                onPositionChanged: (position, _) =>
                    onPositionChanged(position.center),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.bhm_supermarket',
                ),
              ],
            ),

            // ── Centre pin (always mid-screen) ────────────────
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LocationPin(colorScheme: colorScheme),
                  // Stem shadow offset
                  const SizedBox(height: 32), // INTENTIONAL COMPONENT DIMENSION
                ],
              ),
            ),

            // ── Zoom column (top-left for RTL comfort) ─────────
            PositionedDirectional(
              start: 12,
              top: 16,
              child: Column(
                children: [
                  _IconCircleButton(
                    icon: Icons.add_rounded,
                    onPressed: onZoomIn,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _IconCircleButton(
                    icon: Icons.remove_rounded,
                    onPressed: onZoomOut,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),

            // ── My-location button (bottom-left) ───────────────
            PositionedDirectional(
              start: 12,
              bottom: 16,
              child: _IconCircleButton(
                icon: Icons.my_location_rounded,
                onPressed: onMyLocation,
                size: 44, // INTENTIONAL COMPONENT DIMENSION
                colorScheme: colorScheme,
              ),
            ),

            // ── Confirm loading overlay ────────────────────────
            if (confirming)
              Container(
                color: Colors.black.withValues(alpha: 0.25),
                child: Center(
                  child: Container(
                    width: 56, // INTENTIONAL COMPONENT DIMENSION
                    height: 56, // INTENTIONAL COMPONENT DIMENSION
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: AppLoading(size: 24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  final ColorScheme colorScheme;

  const _LocationPin({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        Container(
          width: 52, // INTENTIONAL COMPONENT DIMENSION
          height: 52, // INTENTIONAL COMPONENT DIMENSION
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
        // Pin icon
        Container(
          width: 38, // INTENTIONAL COMPONENT DIMENSION
          height: 38, // INTENTIONAL COMPONENT DIMENSION
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26, // INTENTIONAL VISUAL EXCEPTION
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: AppIcon(
            Icons.location_on_rounded,
            color: colorScheme.primary,
            size: AppIconSize.medium,
          ),
        ),
      ],
    );
  }
}

class _BottomCard extends StatelessWidget {
  final String address;
  final bool confirming;
  final ColorScheme colorScheme;
  final VoidCallback onConfirm;

  const _BottomCard({
    required this.address,
    required this.confirming,
    required this.colorScheme,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06), // INTENTIONAL VISUAL EXCEPTION
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Address row ────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40, // INTENTIONAL COMPONENT DIMENSION
                height: 40, // INTENTIONAL COMPONENT DIMENSION
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppIcon(
                  Icons.location_on_rounded,
                  color: colorScheme.primary,
                  size: AppIconSize.small,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Confirm button ─────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52, // INTENTIONAL COMPONENT DIMENSION FOR ACCESSIBILITY
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                elevation: 0,
              ),
              onPressed: confirming ? null : onConfirm,
              icon: confirming
                  ? AppLoading(
                      type: AppLoadingType.bars,
                      size: 18,
                      color: colorScheme.onPrimary,
                    )
                  : const AppIcon(Icons.check_rounded, size: AppIconSize.small),
              label: Text(
                confirming ? 'جارٍ تحديد العنوان...' : 'تأكيد الموقع',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
