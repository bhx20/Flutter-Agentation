/// A production-grade visual inspection and annotation engine for Flutter applications.
library;

// Core diagnostic logger
export 'src/core/agentation_logger.dart';

// Core Controller, Scope, and Wrapper Widget
export 'src/core/agentation_controller.dart';
export 'src/core/agentation_scope.dart';
export 'src/core/agentation_state.dart';
export 'src/core/flutter_agentation.dart';

// Overlay, Popup & Toolbar Components
export 'src/overlay/annotation_marker.dart' show AnnotationDetailCard, AnnotationMarker;
export 'src/overlay/annotation_popup.dart';
export 'src/overlay/highlight_style.dart';
export 'src/overlay/inspection_overlay.dart';
export 'src/overlay/widget_highlight.dart';
export 'src/toolbar/agentation_toolbar.dart';
export 'src/toolbar/toolbar_action_button.dart';

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
export 'src/models/hierarchical_inspection_result.dart';
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

