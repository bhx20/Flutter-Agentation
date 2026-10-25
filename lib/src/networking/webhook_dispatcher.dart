import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../core/agentation_logger.dart';

/// Configuration for webhook deliveries matching official Agentation behavior.
class WebhookConfig {
  const WebhookConfig({
    this.maxRetries = 3,
    this.baseDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.timeoutMs = 10000,
  });

  final int maxRetries;
  final int baseDelayMs;
  final int maxDelayMs;
  final int timeoutMs;
}

/// Result of a webhook delivery attempt.
class WebhookDeliveryResult {
  const WebhookDeliveryResult({
    required this.ok,
    required this.attempts,
    this.status,
    this.cancelled = false,
    this.error,
  });

  final bool ok;
  final int attempts;
  final int? status;
  final bool cancelled;
  final String? error;
}

/// Robust webhook dispatcher with exponential backoff, jitter, and Retry-After support.
/// Mirrors `agentation-main/mcp/src/server/webhooks.ts`.
class WebhookDispatcher {
  WebhookDispatcher({
    this.config = const WebhookConfig(),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final WebhookConfig config;
  final http.Client _client;
  final math.Random _random = math.Random();
  bool _closed = false;

  bool get isClosed => _closed;

  /// Parses standard HTTP Retry-After header (either seconds integer or RFC HTTP-date).
  int _parseRetryAfter(String? value) {
    if (value == null || value.trim().isEmpty) return 0;
    final trimmed = value.trim();
    final seconds = int.tryParse(trimmed);
    if (seconds != null) {
      return seconds * 1000;
    }
    final date = DateTime.tryParse(trimmed);
    if (date != null) {
      final diff = date.difference(DateTime.now()).inMilliseconds;
      return math.max(0, diff);
    }
    return 0;
  }

  /// Sends a webhook payload to the given URL with bounded retries and exponential backoff.
  Future<WebhookDeliveryResult> send(
    String url,
    String payload, {
    String? eventType,
  }) async {
    if (_closed) {
      return const WebhookDeliveryResult(ok: false, attempts: 0, cancelled: true);
    }

    final Uri target;
    try {
      target = Uri.parse(url);
      if (target.scheme != 'http' && target.scheme != 'https') {
        return const WebhookDeliveryResult(ok: false, attempts: 0, error: 'Invalid URL scheme');
      }
    } catch (e) {
      return WebhookDeliveryResult(ok: false, attempts: 0, error: 'Malformed URL: $e');
    }

    final deliveryId = 'del_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(100000)}';
    int attempts = 0;
    int? lastStatus;
    String? lastError;

    for (int attempt = 0; attempt <= config.maxRetries; attempt++) {
      if (_closed) {
        return WebhookDeliveryResult(ok: false, attempts: attempts, status: lastStatus, cancelled: true);
      }
      attempts++;
      lastStatus = null;
      lastError = null;
      int retryAfterMs = 0;

      try {
        final headers = <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'User-Agent': 'Agentation-Webhook/1.0',
          'X-Agentation-Delivery-Id': deliveryId,
        };
        if (eventType != null) {
          headers['X-Agentation-Event'] = eventType;
        }

        final response = await _client
            .post(
              target,
              headers: headers,
              body: payload,
            )
            .timeout(Duration(milliseconds: config.timeoutMs));

        lastStatus = response.statusCode;

        if (response.statusCode >= 200 && response.statusCode < 300) {
          AgentationLogger.debug(
            '[Webhook] Delivered $eventType to $url in $attempts attempt(s) (HTTP ${response.statusCode})',
          );
          return WebhookDeliveryResult(ok: true, attempts: attempts, status: response.statusCode);
        }

        // Only retry on rate limit (429) or transient server errors (500-599)
        if (lastStatus != 429 && (lastStatus < 500 || lastStatus >= 600)) {
          return WebhookDeliveryResult(
            ok: false,
            attempts: attempts,
            status: lastStatus,
            error: 'Server responded with HTTP $lastStatus',
          );
        }

        retryAfterMs = _parseRetryAfter(response.headers['retry-after']);
      } catch (e) {
        lastError = e.toString();
        if (_closed) {
          return WebhookDeliveryResult(ok: false, attempts: attempts, status: lastStatus, cancelled: true);
        }
      }

      if (attempt == config.maxRetries) break;
      if (retryAfterMs > config.maxDelayMs) break;

      // Exponential backoff with 25% jitter
      final jitter = 1.0 + (_random.nextDouble() * 0.25);
      final computedBackoff = (config.baseDelayMs * math.pow(2, attempt) * jitter).toInt();
      final backoff = math.min(config.maxDelayMs, computedBackoff);
      final waitDurationMs = math.max(backoff, retryAfterMs);

      try {
        await Future.delayed(Duration(milliseconds: waitDurationMs));
      } catch (_) {
        break;
      }
    }

    AgentationLogger.warning(
      '[Webhook] Failed to deliver $eventType to $url after $attempts attempt(s) ${lastStatus != null ? '(HTTP $lastStatus)' : ''}: $lastError',
    );
    return WebhookDeliveryResult(
      ok: false,
      attempts: attempts,
      status: lastStatus,
      error: lastError ?? (lastStatus != null ? 'HTTP $lastStatus' : 'Unknown delivery failure'),
    );
  }

  /// Closes the dispatcher and cancels active resources.
  void close() {
    _closed = true;
    _client.close();
  }
}
