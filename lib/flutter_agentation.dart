/// A production-grade visual inspection and annotation engine for Flutter applications.
library;

// ── Core: Lifecycle & State Orchestration ──
export 'src/core/agentation_controller.dart';
export 'src/core/agentation_keymap.dart';
export 'src/core/agentation_logger.dart';
export 'src/core/agentation_scope.dart';
export 'src/core/agentation_state.dart';
export 'src/core/flutter_agentation.dart';
export 'src/core/package_version.dart';

// ── Theme: Centralized Design Tokens & Theming ──
export 'src/theme/agentation_colors.dart';
export 'src/theme/agentation_radii.dart';
export 'src/theme/agentation_theme.dart';
export 'src/theme/agentation_typography.dart';

// ── Domain: Domain Entities & Value Objects ──
export 'src/domain/annotation.dart';
export 'src/domain/annotation_intent.dart';
export 'src/domain/annotation_severity.dart';
export 'src/domain/annotation_status.dart';
export 'src/domain/drawing_stroke.dart';
export 'src/domain/hierarchical_inspection_result.dart';
export 'src/domain/hierarchical_result.dart';
export 'src/domain/marker_color.dart';
export 'src/domain/placement_data.dart';
export 'src/domain/rearrange_data.dart';
export 'src/domain/thread_message.dart';
export 'src/domain/toolbar_settings.dart';
export 'src/domain/widget_bounds.dart';
export 'src/domain/widget_context.dart';
export 'src/domain/widget_hierarchy_node.dart';
export 'src/domain/widget_identity.dart';
export 'src/domain/widget_inspection_result.dart';

// ── Inspection: Inspection & Resolution Engine ──
export 'src/inspection/bounds_resolver.dart';
export 'src/inspection/element_inspector.dart';
export 'src/inspection/flutter_inspection_engine.dart';
export 'src/inspection/hit_test_engine.dart';
export 'src/inspection/route_resolver.dart';
export 'src/inspection/semantics_resolver.dart';
export 'src/inspection/text_resolver.dart';
export 'src/inspection/widget_identity_resolver.dart' show AgentationTarget, WidgetIdentityResolver;
export 'src/inspection/widget_path_resolver.dart';

// ── Source Location: AST, Source Mapping & Code Extraction ──
export 'src/source_location/feedback_context_builder.dart';
export 'src/source_location/feedback_target.dart';
export 'src/source_location/source_code_extractor.dart';
export 'src/source_location/source_location_resolver.dart';
export 'src/source_location/source_path_normalizer.dart';
export 'src/source_location/widget_code_resolver.dart';
export 'src/source_location/widget_source_location.dart';

// ── UI: Presentation Layer (Toolbar, Overlay, Modes, Design) ──
export 'src/ui/design/component_palette.dart';
export 'src/ui/design/rearrange_controller.dart';
export 'src/ui/design/skeleton_templates.dart';
export 'src/ui/design/spatial_guide_painter.dart';
export 'src/ui/modes/area_selection_handler.dart';
export 'src/ui/modes/draw_canvas_painter.dart';
export 'src/ui/modes/multi_select_handler.dart';
export 'src/ui/overlay/annotation_marker.dart' show AnnotationDetailCard, AnnotationHoverPreviewCard, AnnotationMarker;
export 'src/ui/overlay/annotation_popup.dart';
export 'src/ui/overlay/freeze_overlay.dart';
export 'src/ui/overlay/highlight_style.dart';
export 'src/ui/overlay/inspection_overlay.dart';
export 'src/ui/overlay/widget_highlight.dart';
export 'src/ui/toolbar/agentation_icons.dart';
export 'src/ui/toolbar/agentation_toolbar.dart';
export 'src/ui/toolbar/output_detail_button.dart';
export 'src/ui/toolbar/settings_panel.dart';
export 'src/ui/toolbar/toolbar_action_button.dart';
export 'src/ui/toolbar/toolbar_icon_button.dart';

// ── Storage: Persistence Layer ──
export 'src/storage/annotation_storage.dart';
export 'src/storage/memory_annotation_storage.dart';

// ── Networking: Remote Collaboration & Sync ──
export 'src/networking/agent_sync_client.dart';

// ── Output: Encoders & Export ──
export 'src/output/agentation_format_adapter.dart';
export 'src/output/annotation_json_encoder.dart';
export 'src/output/annotation_markdown_encoder.dart';
export 'src/output/clipboard_exporter.dart';
