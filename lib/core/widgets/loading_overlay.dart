import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:saviaqua/core/widgets/dots_loading_overlay.dart';
import 'package:saviaqua/core/widgets/drop_loading.dart';
import 'package:saviaqua/core/widgets/water_ripple_loader.dart';

enum LoadingStyle { defaultSpinner, drop, dots, waterRipple }

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? progressSize;
  final bool dismissible;
  final LoadingStyle style;
  final bool isBlurEnabled;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.progressColor,
    this.progressSize,
    this.dismissible = false,
    this.style = LoadingStyle.defaultSpinner,
    this.isBlurEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [child, if (isLoading) _buildOverlayContent(context)],
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return GestureDetector(
      onTap: dismissible ? () {} : null,
      child: Container(
        color: backgroundColor ?? Colors.black.withOpacity(0.6),
        child: BackdropFilter(
          filter: isBlurEnabled
              ? ImageFilter.blur(sigmaX: 3, sigmaY: 3)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Center(child: _buildLoaderByStyle(context)),
        ),
      ),
    );
  }

  Widget _buildLoaderByStyle(BuildContext context) {
    switch (style) {
      case LoadingStyle.waterRipple:
        return WaterRippleLoader(message: message);

      case LoadingStyle.drop:
        return DropLoadingWidget(message: message);

      case LoadingStyle.dots:
        return DotsLoadingOverlay(
          isLoading: true,
          child: const SizedBox(),
          message: message,
        );

      case LoadingStyle.defaultSpinner:
        return _buildDefaultSpinner(context);
    }
  }

  Widget _buildDefaultSpinner(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: progressSize ?? 60,
              height: progressSize ?? 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progressColor ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 20),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
