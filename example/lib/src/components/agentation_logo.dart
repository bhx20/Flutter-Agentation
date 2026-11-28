import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders the official Flutter Agentation brand logo using high-resolution PNG asset.
class AgentationLogo extends StatelessWidget {
  const AgentationLogo({
    super.key,
    this.height = 18.0,
  });

  /// Height of the logo in logical pixels.
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'logo.png',
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          height: height,
          child: const FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Flutter ',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                      fontFamily: 'system-ui',
                    ),
                  ),
                  TextSpan(
                    text: 'Agentation',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentBlue,
                      letterSpacing: -0.5,
                      fontFamily: 'system-ui',
                    ),
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
        );
      },
    );
  }
}
