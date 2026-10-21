/// Standard Model Context Protocol (MCP) JSON-RPC 2.0 constants and schema definitions.
class McpProtocol {
  McpProtocol._();

  static const String protocolVersion = '2024-11-05';
  static const String serverName = 'flutter-agentation';
  static const String serverVersion = '0.0.1';

  /// Standard MCP tool definitions matching both official Agentation MCP
  /// (`agentation_*`) and core generic tool aliases.
  static final List<Map<String, dynamic>> tools = [
    // ── Official Agentation Tool Names ──
    {
      'name': 'agentation_get_all_pending',
      'description':
          'Get all pending annotations across all sessions. Includes feedback, design placements, and rearrange annotations.',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
    {
      'name': 'agentation_get_pending',
      'description':
          'Get all pending (unresolved) annotations for a session. Includes kind: "feedback", "placement", or "rearrange".',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'sessionId': {
            'type': 'string',
            'description': 'The session ID to get pending annotations for.',
          },
        },
      },
    },
    {
      'name': 'agentation_get_session',
      'description': 'Get active session annotations and metadata.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'sessionId': {
            'type': 'string',
            'description': 'The session ID to get.',
          },
        },
      },
    },
    {
      'name': 'agentation_list_sessions',
      'description': 'List all annotation sessions in the running Flutter app.',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
    {
      'name': 'agentation_acknowledge',
      'description':
          'Mark an annotation as acknowledged to let the user know the agent has seen their feedback.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'annotationId': {
            'type': 'string',
            'description': 'The annotation ID to acknowledge.',
          },
        },
        'required': ['annotationId'],
      },
    },
    {
      'name': 'agentation_resolve',
      'description':
          'Mark an annotation as resolved once you have addressed the feedback, with an optional summary.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'annotationId': {
            'type': 'string',
            'description': 'The annotation ID to resolve.',
          },
          'summary': {
            'type': 'string',
            'description': 'Optional summary of how it was resolved.',
          },
        },
        'required': ['annotationId'],
      },
    },
    {
      'name': 'agentation_dismiss',
      'description':
          'Dismiss an annotation with a reason why it will not be addressed.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'annotationId': {
            'type': 'string',
            'description': 'The annotation ID to dismiss.',
          },
          'reason': {
            'type': 'string',
            'description': 'Reason for dismissing this annotation.',
          },
        },
        'required': ['annotationId', 'reason'],
      },
    },
    {
      'name': 'agentation_reply',
      'description':
          'Add a reply message to an annotation thread to ask clarifying questions or provide updates.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'annotationId': {
            'type': 'string',
            'description': 'The annotation ID to reply to.',
          },
          'message': {
            'type': 'string',
            'description': 'The reply message.',
          },
        },
        'required': ['annotationId', 'message'],
      },
    },

    // ── Direct / Generic Tool Aliases ──
    {
      'name': 'get_annotations',
      'description':
          'Returns all active UI feedback annotations, placed components, and inspected widget context from the running Flutter app.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'format': {
            'type': 'string',
            'enum': ['json', 'markdown', 'summary'],
            'description': 'Desired output format (defaults to json).',
          },
        },
      },
    },
    {
      'name': 'get_latest_annotation',
      'description':
          'Returns the most recently created or updated UI annotation requiring agent action.',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
    {
      'name': 'resolve_annotation',
      'description':
          'Marks a feedback annotation as resolved in the Flutter app once the code change is implemented.',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'annotationId': {
            'type': 'string',
            'description': 'Unique identifier of the annotation to resolve.',
          },
        },
        'required': ['annotationId'],
      },
    },
    {
      'name': 'clear_annotations',
      'description': 'Clears all annotations from the running Flutter application.',
      'inputSchema': {
        'type': 'object',
        'properties': {},
      },
    },
  ];

  /// Standard MCP resource definitions.
  static final List<Map<String, dynamic>> resources = [
    {
      'uri': 'agentation://annotations',
      'name': 'Active Flutter UI Annotations',
      'description': 'Current live list of UI feedback pins, comments, and placed skeletons.',
      'mimeType': 'application/json',
    },
  ];

  /// Generates the standard JSON-RPC 2.0 success response.
  static Map<String, dynamic> success(dynamic id, dynamic result) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'result': result,
    };
  }

  /// Generates the standard JSON-RPC 2.0 error response.
  static Map<String, dynamic> error(dynamic id, int code, String message, [dynamic data]) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'error': {
        'code': code,
        'message': message,
        'data': ?data,
      },
    };
  }

  /// Generates the standard initialize result payload.
  static Map<String, dynamic> initializeResult() {
    return {
      'protocolVersion': protocolVersion,
      'capabilities': {
        'tools': {
          'listChanged': true,
        },
        'resources': {
          'subscribe': false,
          'listChanged': true,
        },
      },
      'serverInfo': {
        'name': serverName,
        'version': serverVersion,
      },
    };
  }
}
