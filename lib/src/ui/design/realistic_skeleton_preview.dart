import 'package:flutter/material.dart';
import '../../domain/placement_data.dart';
import '../../theme/agentation_colors.dart';
import '../../theme/agentation_radii.dart';
import '../../theme/agentation_theme.dart';
import '../../theme/agentation_typography.dart';
import 'skeleton_templates.dart';

/// Renders a realistic visual representation of a wireframe skeleton component
/// for both the drag feedback and the canvas drop preview.
class RealisticSkeletonPreview extends StatelessWidget {
  const RealisticSkeletonPreview({
    super.key,
    this.template,
    this.placement,
    required this.accentColor,
    required this.isDark,
    this.elevation = 6.0,
    this.showBorder = true,
  }) : assert(template != null || placement != null, 'Either template or placement must be provided');

  final SkeletonTemplate? template;
  final PlacementData? placement;
  final Color accentColor;
  final bool isDark;
  final double elevation;
  final bool showBorder;

  String get componentType => placement?.componentType ?? template?.componentType ?? '';
  String get label => (placement?.text ?? placement?.label ?? template?.label ?? componentType).trim();
  double get width => placement?.width ?? template?.defaultWidth ?? 120.0;
  double get height => placement?.height ?? template?.defaultHeight ?? 44.0;
  Map<String, dynamic> get properties => placement?.properties ?? const {};

  @override
  Widget build(BuildContext context) {
    final theme = AgentationThemeData.resolve(isDark: isDark);

    return Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle.merge(
        style: const TextStyle(decoration: TextDecoration.none),
        child: SizedBox(
          width: width,
          height: height,
          child: _buildComponent(theme),
        ),
      ),
    );
  }

  Widget _buildComponent(AgentationThemeData theme) {
    final type = componentType.toLowerCase();

    if (type == 'switch' || type == 'toggle') {
      return _buildSwitch(theme);
    } else if (type == 'checkbox') {
      return _buildCheckbox(theme);
    } else if (type == 'radio') {
      return _buildRadio(theme);
    } else if (type == 'button' || type.contains('button') && type != 'iconbutton') {
      return _buildButton(theme);
    } else if (type == 'iconbutton' || type == 'fab' || type == 'icon') {
      return _buildIconButton(theme);
    } else if (type == 'avatar' || type == 'useravatar') {
      return _buildAvatar(theme);
    } else if (type == 'image' || type == 'imagepreview') {
      return _buildImage(theme);
    } else if (type == 'input' || type == 'textfield' || type == 'searchbar' || type == 'passwordfield') {
      return _buildInput(theme);
    } else if (type == 'card' || type == 'container') {
      return _buildCard(theme);
    } else if (type == 'chip' || type == 'badge') {
      return _buildChip(theme);
    } else if (type == 'slider') {
      return _buildSlider(theme);
    } else if (type == 'text' || type == 'heading' || type == 'title') {
      return _buildText(theme);
    } else if (type == 'listtile') {
      return _buildListTile(theme);
    } else if (type == 'spinner' || type == 'circularprogressindicator') {
      return _buildSpinner(theme);
    } else if (type == 'progress' || type == 'progressbar') {
      return _buildProgress(theme);
    } else if (type == 'errorstate' || label.toLowerCase().contains('404') || label.toLowerCase().contains('error')) {
      return _buildErrorState(theme);
    } else if (type == 'emptystate' || label.toLowerCase().contains('empty')) {
      return _buildEmptyState(theme);
    } else if (type == 'pricing' || label.toLowerCase().contains('pricing')) {
      return _buildPricing(theme);
    } else if (type == 'product card' || type == 'productcard' || label.toLowerCase().contains('product')) {
      return _buildProductCard(theme);
    } else if (type == 'testimonial' || label.toLowerCase().contains('testimonial')) {
      return _buildTestimonial(theme);
    } else if (type == 'form' || label.toLowerCase().contains('login') || label.toLowerCase().contains('form')) {
      return _buildForm(theme);
    } else if (type == 'profile' || label.toLowerCase().contains('profile')) {
      return _buildProfile(theme);
    } else if (type == 'fileuploader' || label.toLowerCase().contains('upload')) {
      return _buildFileUploader(theme);
    } else if (type == 'breadcrumbs') {
      return _buildBreadcrumbs(theme);
    } else if (type == 'pagination') {
      return _buildPagination(theme);
    } else if (type == 'alertdialog' || type == 'modaldialog' || label.toLowerCase().contains('dialog')) {
      return _buildDialog(theme);
    } else if (type == 'timelinefeed' || type == 'timeline') {
      return _buildTimeline(theme);
    } else if (type == 'divider') {
      return _buildDivider(theme);
    }

    return _buildGeneric(theme);
  }

  // 1. Standalone Flutter Switch Toggle (NO outer dark box, NO overflow!)
  Widget _buildSwitch(AgentationThemeData theme) {
    final isChecked = properties['checked'] != false;
    final isListTile = width >= 120.0;

    if (!isListTile) {
      return Center(
        child: Container(
          width: 48.0,
          height: 28.0,
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            color: isChecked ? accentColor : (isDark ? Colors.white24 : Colors.black26),
            borderRadius: AgentationRadii.br14,
            boxShadow: [
              BoxShadow(
                color: (isChecked ? accentColor : Colors.black).withValues(alpha: 0.25),
                blurRadius: 4.0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Align(
            alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 23.0,
              height: 23.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3.0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Labeled Switch Tile
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br8,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 12.0, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            width: 38.0,
            height: 22.0,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: isChecked ? accentColor : (isDark ? Colors.white24 : Colors.black26),
              borderRadius: AgentationRadii.br11,
            ),
            child: Align(
              alignment: isChecked ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 18.0,
                height: 18.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Checkbox
  Widget _buildCheckbox(AgentationThemeData theme) {
    final isChecked = properties['checked'] != false;
    final isListTile = width >= 120.0;

    final box = Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: isChecked ? accentColor : Colors.transparent,
        borderRadius: AgentationRadii.br4,
        border: Border.all(
          color: isChecked ? accentColor : (isDark ? Colors.white54 : Colors.black54),
          width: 2.0,
        ),
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 14.0, color: Colors.white)
          : null,
    );

    if (!isListTile) {
      return Center(child: box);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br8,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
      ),
      child: Row(
        children: [
          box,
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 12.0, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Radio
  Widget _buildRadio(AgentationThemeData theme) {
    final isChecked = properties['checked'] != false;
    final isListTile = width >= 120.0;

    final circle = Container(
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? accentColor : (isDark ? Colors.white54 : Colors.black54),
          width: 2.0,
        ),
      ),
      child: isChecked
          ? Center(
              child: Container(
                width: 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );

    if (!isListTile) return Center(child: circle);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br8,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
      ),
      child: Row(
        children: [
          circle,
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 12.0, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 4. Realistic Button
  Widget _buildButton(AgentationThemeData theme) {
    final variant = properties['variant'] as String? ?? 'ElevatedButton';
    final isOutlined = variant == 'OutlinedButton';
    final isTextBtn = variant == 'TextButton';
    final hasIcon = properties['hasIcon'] == true;

    final Color bg = isOutlined || isTextBtn ? Colors.transparent : accentColor;
    final Color fg = isOutlined || isTextBtn ? accentColor : Colors.white;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AgentationRadii.br8,
          border: isOutlined ? Border.all(color: accentColor, width: 1.5) : null,
          boxShadow: (!isOutlined && !isTextBtn)
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasIcon) ...[
              Icon(Icons.touch_app, size: 14.0, color: fg),
              const SizedBox(width: 6.0),
            ],
            Flexible(
              child: Text(
                label.isNotEmpty ? label : 'Button',
                style: AgentationTypography.previewButton.copyWith(color: fg, fontSize: 12.5, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Realistic IconButton
  Widget _buildIconButton(AgentationThemeData theme) {
    return Center(
      child: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(Icons.touch_app, size: 18.0, color: accentColor),
      ),
    );
  }

  // 6. Realistic Avatar
  Widget _buildAvatar(AgentationThemeData theme) {
    final initials = (placement?.source ?? placement?.text ?? '').trim();
    final childContent = (initials.isNotEmpty && initials.length <= 4)
        ? Text(
            initials,
            style: AgentationTypography.previewHeading.copyWith(color: Colors.white, fontSize: 14.0),
          )
        : const Icon(Icons.person, size: 24.0, color: Colors.white);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: childContent,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: BoxDecoration(
                color: AgentationColors.onlineGreen,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AgentationColors.darkPreviewAvatarRing : Colors.white, width: 2.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 7. Realistic Image
  Widget _buildImage(AgentationThemeData theme) {
    final source = (placement?.source ?? placement?.text ?? '').trim();
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return ClipRRect(
        borderRadius: AgentationRadii.br10,
        child: Image.network(
          source,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackImage(theme),
        ),
      );
    }

    return _buildFallbackImage(theme);
  }

  Widget _buildFallbackImage(AgentationThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AgentationColors.darkPreviewContainer : AgentationColors.lightBorderSlate,
        borderRadius: AgentationRadii.br10,
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 28.0, color: accentColor),
            const SizedBox(height: 4.0),
            Text(
              'Image Preview',
              style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary, fontSize: 10.5, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // 8. Realistic Input Field
  Widget _buildInput(AgentationThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: AgentationRadii.br8,
          border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 16.0, color: accentColor),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                label.isNotEmpty && label != 'Input' ? label : 'Search or enter text...',
                style: AgentationTypography.previewBody.copyWith(color: theme.textSecondary, fontSize: 12.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 9. Realistic Card
  Widget _buildCard(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, size: 14.0, color: accentColor),
              const SizedBox(width: 6.0),
              Expanded(
                child: Text(
                  label.isNotEmpty ? label : 'Card Header',
                  style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 12.0, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 6.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.white12 : Colors.black12,
              borderRadius: AgentationRadii.br3,
            ),
          ),
          const SizedBox(height: 5.0),
          Container(
            height: 6.0,
            width: 80.0,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              borderRadius: AgentationRadii.br3,
            ),
          ),
        ],
      ),
    );
  }

  // 10. Realistic Chip
  Widget _buildChip(AgentationThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.15),
          borderRadius: AgentationRadii.br14,
          border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.0),
        ),
        child: Text(
          label.isNotEmpty ? label : 'Filter Chip',
          style: AgentationTypography.chip.copyWith(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 11. Realistic Slider
  Widget _buildSlider(AgentationThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: AgentationRadii.br8,
          border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.isNotEmpty ? label : 'Slider',
                  style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontWeight: FontWeight.w500),
                ),
                Text(
                  '50%',
                  style: AgentationTypography.previewCaption.copyWith(color: accentColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            ClipRRect(
              borderRadius: AgentationRadii.br2,
              child: LinearProgressIndicator(
                value: 0.5,
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation(accentColor),
                minHeight: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 12. Realistic Text Block
  Widget _buildText(AgentationThemeData theme) {
    return Center(
      child: Text(
        label.isNotEmpty ? label : 'Heading Title',
        style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 14.0, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // 13. Realistic ListTile
  Widget _buildListTile(AgentationThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: AgentationRadii.br8,
          border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 26.0,
              height: 26.0,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: AgentationRadii.br6,
              ),
              child: Icon(Icons.list_alt, size: 15.0, color: accentColor),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                label.isNotEmpty ? label : 'List Item Title',
                style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, size: 16.0, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }

  // 14. Spinner & Progress
  Widget _buildSpinner(AgentationThemeData theme) {
    return Center(
      child: SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(accentColor),
        ),
      ),
    );
  }

  Widget _buildProgress(AgentationThemeData theme) {
    return Center(
      child: ClipRRect(
        borderRadius: AgentationRadii.br3,
        child: LinearProgressIndicator(
          value: 0.65,
          backgroundColor: isDark ? Colors.white12 : Colors.black12,
          valueColor: AlwaysStoppedAnimation(accentColor),
          minHeight: 6.0,
        ),
      ),
    );
  }

  // 15. REALISTIC ERROR / 404 STATE BLOCK (The exact one from the user's screenshot!)
  Widget _buildErrorState(AgentationThemeData theme) {
    final errorRed = AgentationColors.destructive;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: errorRed.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: errorRed.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: errorRed.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, size: 22.0, color: errorRed),
          ),
          const SizedBox(height: 8.0),
          Text(
            label.isNotEmpty ? label : 'Something went wrong',
            style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 12.5),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3.0),
          Text(
            'Unable to load content or page not found',
            style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: errorRed,
              borderRadius: AgentationRadii.br6,
            ),
            child: Text(
              'Retry',
              style: AgentationTypography.previewButton.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // 16. Empty State Block
  Widget _buildEmptyState(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 22.0, color: accentColor),
          ),
          const SizedBox(height: 8.0),
          Text(
            'No items yet',
            style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 12.5),
          ),
          const SizedBox(height: 3.0),
          Text(
            'Get started by adding your first record',
            style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: AgentationRadii.br6,
            ),
            child: Text(
              'Create Item',
              style: AgentationTypography.previewButton.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // 17. Pricing Block
  Widget _buildPricing(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br14,
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: AgentationRadii.br4,
            ),
            child: Text(
              'PRO PLAN',
              style: AgentationTypography.previewSmall.copyWith(color: accentColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                r'$29',
                style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 24.0),
              ),
              Text(
                ' / month',
                style: AgentationTypography.previewBody.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
          const Divider(height: 18.0),
          _buildCheckItem(theme, 'Unlimited projects & members'),
          _buildCheckItem(theme, 'Advanced AI inspection tools'),
          _buildCheckItem(theme, 'Dedicated cloud storage'),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: AgentationRadii.br8,
            ),
            child: Center(
              child: Text(
                'Get Started',
                style: AgentationTypography.previewButton.copyWith(color: Colors.white, fontSize: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(AgentationThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 13.0, color: accentColor),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              text,
              style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary, fontSize: 10.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 18. Product Card Block
  Widget _buildProductCard(AgentationThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AgentationColors.darkPreviewContainer : AgentationColors.lightBorderSlate,
                borderRadius: AgentationRadii.brTop12,
              ),
              child: Center(
                child: Icon(Icons.shopping_bag_outlined, size: 36.0, color: accentColor),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Wireless Headphones',
                  style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      r'$79.99',
                      style: AgentationTypography.previewPrice.copyWith(color: accentColor),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AgentationRadii.br6,
                      ),
                      child: const Icon(Icons.add_shopping_cart, size: 14.0, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 19. Testimonial Block
  Widget _buildTestimonial(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star, size: 14.0, color: AgentationColors.starAmber),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: Text(
              '"This platform transformed our frontend engineering workflow. Truly extraordinary quality!"',
              style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontStyle: FontStyle.italic),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    'S',
                    style: AgentationTypography.previewCaption.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              Text(
                'Sarah Jenkins - Lead Designer',
                style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 20. Form / Login
  Widget _buildForm(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign In',
            style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: 8.0),
          _buildMiniInputField(theme, 'email@example.com', Icons.email_outlined),
          const SizedBox(height: 6.0),
          _buildMiniInputField(theme, '••••••••', Icons.lock_outline),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: AgentationRadii.br6,
            ),
            child: Center(
              child: Text(
                'Sign In',
                style: AgentationTypography.previewButton.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInputField(AgentationThemeData theme, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: isDark ? AgentationColors.darkPreviewSurface : AgentationColors.lightPreviewSlate,
        borderRadius: AgentationRadii.br6,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12.0, color: theme.textSecondary),
          const SizedBox(width: 6.0),
          Expanded(
            child: Text(
              hint,
              style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 21. Profile Block
  Widget _buildProfile(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42.0,
            height: 42.0,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 24.0, color: Colors.white),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Alex Robertson',
            style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 12.0),
          ),
          Text(
            'Frontend Architect',
            style: AgentationTypography.previewSmall.copyWith(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  // 22. File Uploader
  Widget _buildFileUploader(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isDark ? AgentationColors.darkPreviewUploader : AgentationColors.lightPreviewUploader,
        borderRadius: AgentationRadii.br10,
        border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_upload_outlined, size: 24.0, color: accentColor),
            const SizedBox(height: 4.0),
            Text(
              'Drag files or browse',
              style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 11.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // 23. Breadcrumbs
  Widget _buildBreadcrumbs(AgentationThemeData theme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Home', style: AgentationTypography.previewBody.copyWith(color: theme.textSecondary)),
          Icon(Icons.chevron_right, size: 14.0, color: theme.textSecondary),
          Text('Projects', style: AgentationTypography.previewBody.copyWith(color: theme.textSecondary)),
          Icon(Icons.chevron_right, size: 14.0, color: theme.textSecondary),
          Text('Details', style: AgentationTypography.previewBody.copyWith(color: accentColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 24. Pagination
  Widget _buildPagination(AgentationThemeData theme) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPageBtn(theme, '<', false),
          const SizedBox(width: 4.0),
          _buildPageBtn(theme, '1', true),
          const SizedBox(width: 4.0),
          _buildPageBtn(theme, '2', false),
          const SizedBox(width: 4.0),
          _buildPageBtn(theme, '3', false),
          const SizedBox(width: 4.0),
          _buildPageBtn(theme, '>', false),
        ],
      ),
    );
  }

  Widget _buildPageBtn(AgentationThemeData theme, String text, bool active) {
    return Container(
      width: 24.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: active ? accentColor : Colors.transparent,
        borderRadius: AgentationRadii.br4,
        border: Border.all(
          color: active ? accentColor : theme.borderTranslucentColor,
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: AgentationTypography.previewCaption.copyWith(color: active ? Colors.white : theme.textPrimary, fontSize: 10.5, fontWeight: active ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
  }

  // 25. Modal Dialog
  Widget _buildDialog(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br12,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Action', style: AgentationTypography.previewHeading.copyWith(color: theme.textPrimary, fontSize: 12.0)),
          const SizedBox(height: 4.0),
          Text('Are you sure you want to proceed?', style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Cancel', style: AgentationTypography.previewCaption.copyWith(color: theme.textSecondary, fontSize: 10.5)),
              const SizedBox(width: 12.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(color: accentColor, borderRadius: AgentationRadii.br4),
                child: Text('Confirm', style: AgentationTypography.previewButton.copyWith(color: Colors.white, fontSize: 10.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 26. Timeline Feed
  Widget _buildTimeline(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br10,
        border: Border.all(color: theme.borderTranslucentColor, width: 1.0),
      ),
      child: Column(
        children: [
          _buildTimelineNode(theme, 'Order Placed', '10:00 AM', true),
          _buildTimelineNode(theme, 'Processing', '11:30 AM', true),
          _buildTimelineNode(theme, 'Shipped', 'Pending', false),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(AgentationThemeData theme, String title, String time, bool done) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 14.0, color: done ? accentColor : theme.textSecondary),
          const SizedBox(width: 6.0),
          Expanded(child: Text(title, style: AgentationTypography.previewCaption.copyWith(color: theme.textPrimary, fontSize: 10.5))),
          Text(time, style: AgentationTypography.previewSmall.copyWith(color: theme.textSecondary)),
        ],
      ),
    );
  }

  // 27. Divider
  Widget _buildDivider(AgentationThemeData theme) {
    return Center(
      child: Container(height: 1.5, color: accentColor.withValues(alpha: 0.5)),
    );
  }

  // 28. Generic Fallback
  Widget _buildGeneric(AgentationThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: AgentationRadii.br8,
        border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.0),
        boxShadow: theme.cardShadows,
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(template?.icon ?? Icons.widgets_outlined, size: 16.0, color: accentColor),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                label,
                style: AgentationTypography.previewBody.copyWith(color: theme.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
