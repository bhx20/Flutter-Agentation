/// A production-grade visual inspection and annotation engine for Flutter applications.
library;

// Core diagnostic logger
export 'src/core/agentation_logger.dart';

// Core Controller, Scope, and Wrapper Widget
export 'src/core/agentation_controller.dart';
export 'src/core/agentation_scope.dart';
export 'src/core/agentation_state.dart';
export 'src/core/flutter_agentation.dart';

// Overlay, Popup, Freeze & Toolbar Components
export 'src/overlay/annotation_marker.dart' show AnnotationDetailCard, AnnotationMarker;
export 'src/overlay/annotation_popup.dart';
export 'src/overlay/freeze_overlay.dart';
export 'src/overlay/highlight_style.dart';
export 'src/overlay/inspection_overlay.dart';
export 'src/overlay/widget_highlight.dart';
export 'src/toolbar/agentation_toolbar.dart';
export 'src/toolbar/output_detail_button.dart';
export 'src/toolbar/settings_panel.dart';
export 'src/toolbar/toolbar_action_button.dart';

// Interaction Modes & Handlers
export 'src/modes/area_selection_handler.dart';
export 'src/modes/draw_canvas_painter.dart';
export 'src/modes/multi_select_handler.dart';

// Visual Design Mode & Skeletons Palette
export 'src/design/component_palette.dart';
export 'src/design/rearrange_controller.dart';
export 'src/design/skeleton_templates.dart';
export 'src/design/spatial_guide_painter.dart';

// Networking & Model Context Protocol (MCP) Client
export 'src/networking/agent_sync_client.dart';

// Inspection Engine & Resolvers
export 'src/inspection/bounds_resolver.dart';
export 'src/inspection/element_inspector.dart';
export 'src/inspection/flutter_inspection_engine.dart';
export 'src/inspection/hit_test_engine.dart';
export 'src/inspection/route_resolver.dart';
export 'src/inspection/semantics_resolver.dart';
export 'src/inspection/text_resolver.dart';
export 'src/inspection/widget_identity_resolver.dart' show AgentationTarget, WidgetIdentityResolver;
export 'src/inspection/widget_path_resolver.dart';

// Immutable Data Models
export 'src/models/annotation.dart';
export 'src/models/annotation_intent.dart';
export 'src/models/annotation_severity.dart';
export 'src/models/annotation_status.dart';
export 'src/models/drawing_stroke.dart';
export 'src/models/hierarchical_inspection_result.dart';
export 'src/models/marker_color.dart';
export 'src/models/placement_data.dart';
export 'src/models/rearrange_data.dart';
export 'src/models/thread_message.dart';
export 'src/models/toolbar_settings.dart';
export 'src/models/widget_bounds.dart';
export 'src/models/widget_context.dart';
export 'src/models/widget_hierarchy_node.dart';
export 'src/models/widget_identity.dart';
export 'src/models/widget_inspection_result.dart';

// Storage Repositories
export 'src/storage/annotation_storage.dart';
export 'src/storage/memory_annotation_storage.dart';

// Output Encoders, Adapters & Clipboard Export
export 'src/output/agentation_format_adapter.dart';
export 'src/output/annotation_json_encoder.dart';
export 'src/output/annotation_markdown_encoder.dart';
export 'src/output/clipboard_exporter.dart';

// Exact Source Location & AI Feedback Context (Master Prompt Sections 5, 8, 11-13)
export 'src/source_location/feedback_context_builder.dart';
export 'src/source_location/feedback_target.dart';
export 'src/source_location/source_location_resolver.dart';
export 'src/source_location/source_path_normalizer.dart';
export 'src/source_location/widget_source_location.dart';
