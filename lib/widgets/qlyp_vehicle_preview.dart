import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qlyp_core/constants/qlyp_vehicle_category_assets.dart';
import 'package:qlyp_core/services/qlyp_vehicle_image_api.dart';

/// OEM or category vehicle preview with immediate bundled fallback (PRD M35.3).
class QlypVehiclePreview extends StatefulWidget {
  const QlypVehiclePreview({
    super.key,
    required this.apiBaseUrl,
    required this.idToken,
    required this.fallbackCategoryKey,
    this.makeId,
    this.modelId,
    this.colorId,
    this.year,
    this.height = 120,
    this.caption,
    this.borderRadius = 14,
    this.backgroundColor = const Color(0xFFF3F5F8),
  });

  final String apiBaseUrl;
  final Future<String?> Function() idToken;
  final String fallbackCategoryKey;
  final String? makeId;
  final String? modelId;
  final String? colorId;
  final String? year;
  final double height;
  final String? caption;
  final double borderRadius;
  final Color backgroundColor;

  @override
  State<QlypVehiclePreview> createState() => _QlypVehiclePreviewState();
}

class _QlypVehiclePreviewState extends State<QlypVehiclePreview> {
  String? _networkUrl;
  String? _resolution;
  late String _categoryKey;

  @override
  void initState() {
    super.initState();
    _categoryKey =
        QlypVehicleCategoryAssets.normalizeCategoryKey(widget.fallbackCategoryKey);
    _resolve();
  }

  @override
  void didUpdateWidget(covariant QlypVehiclePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    final inputsChanged = oldWidget.makeId != widget.makeId ||
        oldWidget.modelId != widget.modelId ||
        oldWidget.colorId != widget.colorId ||
        oldWidget.year != widget.year ||
        oldWidget.fallbackCategoryKey != widget.fallbackCategoryKey;
    if (inputsChanged) {
      _categoryKey = QlypVehicleCategoryAssets.normalizeCategoryKey(
        widget.fallbackCategoryKey,
      );
      _networkUrl = null;
      _resolution = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final result = await QlypVehicleImageApi.resolve(
      apiBaseUrl: widget.apiBaseUrl,
      idToken: widget.idToken,
      makeId: widget.makeId,
      modelId: widget.modelId,
      colorId: widget.colorId,
      year: widget.year,
    );
    if (!mounted) return;

    if (result.hasRemoteImage) {
      setState(() {
        _networkUrl = result.imageUrl;
        _resolution = result.resolution;
      });
      return;
    }

    final nextCategory = result.effectiveCategoryKey(_categoryKey);
    if (nextCategory != _categoryKey ||
        result.networkError ||
        result.resolution != _resolution) {
      setState(() {
        _categoryKey = nextCategory;
        _resolution = result.resolution;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: ColoredBox(
            color: widget.backgroundColor,
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: _buildImage(),
            ),
          ),
        ),
        if ((widget.caption ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.caption!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF697386),
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImage() {
    final assetPath =
        QlypVehicleCategoryAssets.assetPathForCategoryKey(_categoryKey);

    if ((_networkUrl ?? '').isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _networkUrl!,
        fit: BoxFit.contain,
        placeholder: (_, __) => _assetImage(assetPath),
        errorWidget: (_, __, ___) => _assetImage(assetPath),
      );
    }

    return _assetImage(assetPath);
  }

  Widget _assetImage(String assetPath) {
    return Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: widget.height * 0.45,
          color: const Color(0xFF9AA3B2),
        ),
      ),
    );
  }
}
