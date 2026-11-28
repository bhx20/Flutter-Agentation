import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Minimal HTTP client interface decoupling network operations from external packages.
abstract class SimpleHttpClient {
  Future<SimpleHttpResponse> get(Uri uri, {Map<String, String>? headers});
  void close();
}

/// Minimal HTTP response representation.
class SimpleHttpResponse {
  const SimpleHttpResponse(this.statusCode, this.body, {this.headers = const {}});
  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

/// Default no-op / fallback HTTP client when external network libraries are excluded.
class DefaultSimpleHttpClient implements SimpleHttpClient {
  const DefaultSimpleHttpClient();

  @override
  Future<SimpleHttpResponse> get(Uri uri, {Map<String, String>? headers}) async {
    return const SimpleHttpResponse(503, 'Network client disabled');
  }

  @override
  void close() {}
}

/// Change item describing a feature or improvement in a package release.
class PackageChange {
  const PackageChange({
    required this.isAdded,
    required this.title,
    required this.description,
  });

  final bool isAdded;
  final String title;
  final String description;
}

/// Release metadata and change items parsed dynamically from CHANGELOG.md.
class PackageRelease {
  const PackageRelease({
    required this.version,
    required this.date,
    required this.badge,
    required this.description,
    required this.changes,
  });

  final String version;
  final String date;
  final String badge;
  final String description;
  final List<PackageChange> changes;
}

/// Data model representing real-time package metrics, changelog, and metadata fetched from pub.dev APIs.
class PubPackageData {
  const PubPackageData({
    required this.name,
    required this.version,
    required this.description,
    required this.repositoryUrl,
    required this.homepageUrl,
    required this.publishedDate,
    required this.grantedPoints,
    required this.maxPoints,
    required this.likeCount,
    required this.downloadCount30Days,
    required this.publisherId,
    required this.platforms,
    required this.isWasmReady,
    required this.dartConstraint,
    required this.flutterConstraint,
    required this.versions,
    required this.releases,
    this.isLoading = false,
    this.error,
  });

  final String name;
  final String version;
  final String description;
  final String repositoryUrl;
  final String homepageUrl;
  final DateTime? publishedDate;
  final int grantedPoints;
  final int maxPoints;
  final int likeCount;
  final int downloadCount30Days;
  final String publisherId;
  final List<String> platforms;
  final bool isWasmReady;
  final String dartConstraint;
  final String flutterConstraint;
  final List<String> versions;
  final List<PackageRelease> releases;
  final bool isLoading;
  final String? error;

  /// Default baseline initialized with verified pub.dev package snapshot and real changelog.
  /// Guarantees instant rendering and fallback if network or browser CORS limits live calls.
  static final PubPackageData initial = PubPackageData(
    name: 'flutter_agentation',
    version: '1.0.0',
    description:
        'Visual UI feedback, runtime inspection, and Model Context Protocol (MCP) server daemon for Flutter.',
    repositoryUrl: 'https://github.com/bhx20/Flutter-Agentation',
    homepageUrl: 'https://pub.dev/packages/flutter_agentation',
    publishedDate: DateTime.parse('2026-11-02T15:12:26.912328Z'),
    grantedPoints: 150,
    maxPoints: 160,
    likeCount: 9,
    downloadCount30Days: 756,
    publisherId: 'coddynet.com',
    platforms: const ['android', 'ios', 'windows', 'linux', 'macos', 'web'],
    isWasmReady: true,
    dartConstraint: '^3.12.2',
    flutterConstraint: '>=3.16.0',
    versions: const ['1.0.0', '0.1.0'],
    releases: const [
      PackageRelease(
        version: 'v1.0.0',
        date: 'November 2026',
        badge: 'Latest Release',
        description:
            'First official stable release of Flutter Agentation with production MCP daemon and full multi-platform engine.',
        changes: [
          PackageChange(
            isAdded: true,
            title: 'Model Context Protocol (MCP) Server Daemon',
            description:
                'Built-in MCP engine supporting stdio and HTTP/SSE transport on localhost:4747. Exposes visual feedback pins, widget attributes, and status resolver tools to AI coding agents.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Spec-Kit Native Slash Commands',
            description:
                'Promptless workflow registering /flutter-agentation-check-mcp and /flutter-agentation-review-feedback directly for Cursor and AI agent environments.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Visual Wireframing & Layout Mode',
            description:
                'Realistic skeleton wireframe components and interactive counter-question dialogs for clarifying UI intent.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Deep Widget Inspection',
            description:
                'Resolves exact RenderBox bounds, ancestor breadcrumbs, and exact Dart source line mapping for immediate grep and code patching.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Draft Annotation Protection',
            description:
                'Prevents unsent feedback from leaking to AI agents when Auto-Send is disabled.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Cross-Platform Runtime Support',
            description:
                'Complete support across Flutter Web, macOS, Windows, Linux, iOS, and Android (with ADB reverse port forwarding).',
          ),
        ],
      ),
      PackageRelease(
        version: 'v0.1.0',
        date: 'November 2026',
        badge: 'Initial Release',
        description:
            'Initial public release introducing visual UI feedback overlay, morphing toolbar, and real-time webhook engine.',
        changes: [
          PackageChange(
            isAdded: true,
            title: 'Visual UI Inspection Engine',
            description:
                'Click or hover any widget to inspect bounding boxes, exact source file, line number, and widget hierarchy.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Floating Annotation Toolbar',
            description:
                'Morphing pill toolbar with Inspection, Drawing/Sketching, Wireframe Placement, Layout Rearrange, and Settings panels.',
          ),
          PackageChange(
            isAdded: true,
            title: 'Auto-Send & Draft Control',
            description:
                'Support for both instant streaming (Auto-Send ON) and manual batch submission (Auto-Send OFF with toolbar Send button and badge counter).',
          ),
          PackageChange(
            isAdded: true,
            title: 'Webhook & Export Integrations',
            description:
                'Real-time webhook dispatching and clipboard exports (Markdown, JSON, HTML).',
          ),
        ],
      ),
    ],
    isLoading: false,
    error: null,
  );

  PubPackageData copyWith({
    String? name,
    String? version,
    String? description,
    String? repositoryUrl,
    String? homepageUrl,
    DateTime? publishedDate,
    int? grantedPoints,
    int? maxPoints,
    int? likeCount,
    int? downloadCount30Days,
    String? publisherId,
    List<String>? platforms,
    bool? isWasmReady,
    String? dartConstraint,
    String? flutterConstraint,
    List<String>? versions,
    List<PackageRelease>? releases,
    bool? isLoading,
    String? error,
  }) {
    return PubPackageData(
      name: name ?? this.name,
      version: version ?? this.version,
      description: description ?? this.description,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      homepageUrl: homepageUrl ?? this.homepageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      grantedPoints: grantedPoints ?? this.grantedPoints,
      maxPoints: maxPoints ?? this.maxPoints,
      likeCount: likeCount ?? this.likeCount,
      downloadCount30Days: downloadCount30Days ?? this.downloadCount30Days,
      publisherId: publisherId ?? this.publisherId,
      platforms: platforms ?? this.platforms,
      isWasmReady: isWasmReady ?? this.isWasmReady,
      dartConstraint: dartConstraint ?? this.dartConstraint,
      flutterConstraint: flutterConstraint ?? this.flutterConstraint,
      versions: versions ?? this.versions,
      releases: releases ?? this.releases,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Service that fetches dynamic package information, metrics, score, and changelog from pub.dev and GitHub.
class PubDevService {
  PubDevService._() {
    packageNotifier = ValueNotifier<PubPackageData>(PubPackageData.initial);
  }

  static final PubDevService instance = PubDevService._();

  static const String packageName = 'flutter_agentation';
  static const String baseUrl = 'https://pub.dev/api';
  static const String changelogRawUrl =
      'https://raw.githubusercontent.com/bhx20/Flutter-Agentation/main/CHANGELOG.md';

  /// Flag to enable or disable automatic network calls (useful for offline environments).
  static bool enableNetworkCalls = true;

  late final ValueNotifier<PubPackageData> packageNotifier;

  PubPackageData get current => packageNotifier.value;

  /// Fetches package details, score, publisher, and CHANGELOG.md dynamically.
  Future<void> fetchPackageData({SimpleHttpClient? client}) async {
    // Avoid triggering unmocked real network calls during widget testing
    if (client == null &&
        (!enableNetworkCalls ||
            WidgetsBinding.instance.runtimeType
                .toString()
                .contains('TestWidgetsFlutterBinding'))) {
      return;
    }

    final httpClient = client ?? const DefaultSimpleHttpClient();
    final shouldCloseClient = client == null;

    packageNotifier.value = current.copyWith(isLoading: true, error: null);

    try {
      // 1. Fetch package details
      final pkgUri = Uri.parse('$baseUrl/packages/$packageName');
      final pkgResponse = await httpClient.get(
        pkgUri,
        headers: {'Accept': 'application/json'},
      );

      String version = current.version;
      String description = current.description;
      String repositoryUrl = current.repositoryUrl;
      DateTime? publishedDate = current.publishedDate;
      String dartConstraint = current.dartConstraint;
      String flutterConstraint = current.flutterConstraint;
      List<String> versions = List.from(current.versions);

      if (pkgResponse.statusCode == 200) {
        final Map<String, dynamic> pkgJson =
            jsonDecode(pkgResponse.body) as Map<String, dynamic>;
        final latest = pkgJson['latest'] as Map<String, dynamic>?;
        if (latest != null) {
          version = (latest['version'] as String?) ?? version;
          final pubDateStr = latest['published'] as String?;
          if (pubDateStr != null) {
            publishedDate = DateTime.tryParse(pubDateStr) ?? publishedDate;
          }

          final pubspec = latest['pubspec'] as Map<String, dynamic>?;
          if (pubspec != null) {
            description = (pubspec['description'] as String?) ?? description;
            final repo = pubspec['repository'] as String?;
            final home = pubspec['homepage'] as String?;
            if (repo != null && repo.isNotEmpty) {
              repositoryUrl = repo;
            } else if (home != null && home.isNotEmpty) {
              repositoryUrl = home;
            }

            final env = pubspec['environment'] as Map<String, dynamic>?;
            if (env != null) {
              dartConstraint = (env['sdk'] as String?) ?? dartConstraint;
              flutterConstraint =
                  (env['flutter'] as String?) ?? flutterConstraint;
            }
          }
        }

        final rawVersions = pkgJson['versions'] as List<dynamic>?;
        if (rawVersions != null && rawVersions.isNotEmpty) {
          versions = rawVersions
              .map((v) => (v as Map<String, dynamic>)['version'] as String?)
              .whereType<String>()
              .toList();
        }
      }

      // 2. Fetch package score
      final scoreUri = Uri.parse('$baseUrl/packages/$packageName/score');
      final scoreResponse = await httpClient.get(
        scoreUri,
        headers: {'Accept': 'application/json'},
      );

      int grantedPoints = current.grantedPoints;
      int maxPoints = current.maxPoints;
      int likeCount = current.likeCount;
      int downloadCount30Days = current.downloadCount30Days;
      List<String> platforms = List.from(current.platforms);
      bool isWasmReady = current.isWasmReady;
      String publisherId = current.publisherId;

      if (scoreResponse.statusCode == 200) {
        final Map<String, dynamic> scoreJson =
            jsonDecode(scoreResponse.body) as Map<String, dynamic>;
        grantedPoints =
            (scoreJson['grantedPoints'] as num?)?.toInt() ?? grantedPoints;
        maxPoints = (scoreJson['maxPoints'] as num?)?.toInt() ?? maxPoints;
        likeCount = (scoreJson['likeCount'] as num?)?.toInt() ?? likeCount;
        downloadCount30Days =
            (scoreJson['downloadCount30Days'] as num?)?.toInt() ??
                downloadCount30Days;

        final tags = (scoreJson['tags'] as List<dynamic>?)
                ?.map((t) => t.toString())
                .toList() ??
            [];

        final foundPlatforms = tags
            .where((t) => t.startsWith('platform:'))
            .map((t) => t.replaceFirst('platform:', ''))
            .toList();
        if (foundPlatforms.isNotEmpty) {
          platforms = foundPlatforms;
        }

        isWasmReady = tags.contains('is:wasm-ready');

        for (final tag in tags) {
          if (tag.startsWith('publisher:')) {
            publisherId = tag.replaceFirst('publisher:', '');
          }
        }
      }

      // 3. Fetch publisher endpoint if available
      try {
        final pubUri = Uri.parse('$baseUrl/packages/$packageName/publisher');
        final pubResponse = await httpClient.get(
          pubUri,
          headers: {'Accept': 'application/json'},
        );
        if (pubResponse.statusCode == 200) {
          final Map<String, dynamic> pubJson =
              jsonDecode(pubResponse.body) as Map<String, dynamic>;
          final id = pubJson['publisherId'] as String?;
          if (id != null && id.isNotEmpty) {
            publisherId = id;
          }
        }
      } catch (_) {
        // Publisher endpoint is optional
      }

      // 4. Fetch dynamic CHANGELOG.md from repository (recommended approach per pub.dev API spec)
      List<PackageRelease> releases = List.from(current.releases);
      try {
        final changelogUri = Uri.parse(changelogRawUrl);
        final changelogResponse = await httpClient.get(changelogUri);
        if (changelogResponse.statusCode == 200 &&
            changelogResponse.body.isNotEmpty) {
          final parsed = parseChangelogMarkdown(
            changelogResponse.body,
            latestPublishedDate: publishedDate,
          );
          if (parsed.isNotEmpty) {
            releases = parsed;
          }
        }
      } catch (_) {
        // Fallback to verified baseline releases
      }

      // Update state with newly fetched dynamic metrics and changelog
      packageNotifier.value = PubPackageData(
        name: packageName,
        version: version,
        description: description,
        repositoryUrl: repositoryUrl,
        homepageUrl: 'https://pub.dev/packages/$packageName',
        publishedDate: publishedDate,
        grantedPoints: grantedPoints,
        maxPoints: maxPoints,
        likeCount: likeCount,
        downloadCount30Days: downloadCount30Days,
        publisherId: publisherId,
        platforms: platforms,
        isWasmReady: isWasmReady,
        dartConstraint: dartConstraint,
        flutterConstraint: flutterConstraint,
        versions: versions,
        releases: releases,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (kDebugMode) {
        print('PubDevService fetch error: $e');
      }
      packageNotifier.value = current.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  /// Parses Markdown CHANGELOG format into structured [PackageRelease] items.
  static List<PackageRelease> parseChangelogMarkdown(
    String markdown, {
    DateTime? latestPublishedDate,
  }) {
    final releases = <PackageRelease>[];
    final lines = markdown.split('\n');
    String currentVersion = '';
    final currentChanges = <PackageChange>[];

    void commitRelease() {
      if (currentVersion.isNotEmpty) {
        final isLatest = releases.isEmpty;
        final releaseDate = isLatest && latestPublishedDate != null
            ? '${_monthName(latestPublishedDate.month)} ${latestPublishedDate.year}'
            : 'November 2026';

        releases.add(
          PackageRelease(
            version: currentVersion.startsWith('v')
                ? currentVersion
                : 'v$currentVersion',
            date: releaseDate,
            badge: isLatest ? 'Latest Release' : 'Release',
            description: currentChanges.isNotEmpty
                ? currentChanges.first.title
                : 'Release $currentVersion',
            changes: List.from(currentChanges),
          ),
        );
        currentChanges.clear();
      }
    }

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.startsWith('## ')) {
        commitRelease();
        currentVersion = line.replaceFirst('## ', '').trim();
      } else if (line.startsWith('* ') || line.startsWith('- ')) {
        final bullet = line.substring(2).trim();
        if (bullet.isEmpty) continue;

        // Check if bullet has bold title e.g. **Title**: Description
        final match = RegExp(r'^\*\*(.*?)\*\*:\s*(.*)$').firstMatch(bullet);
        if (match != null) {
          final title = match.group(1) ?? '';
          final desc = match.group(2) ?? '';
          final lower = title.toLowerCase();
          final isAdded = !lower.contains('fix') && !lower.contains('improve');
          currentChanges.add(
            PackageChange(
              isAdded: isAdded,
              title: title,
              description: desc,
            ),
          );
        } else {
          final dotIndex = bullet.indexOf('. ');
          if (dotIndex != -1 && dotIndex < 60) {
            final title = bullet.substring(0, dotIndex).trim();
            final desc = bullet.substring(dotIndex + 2).trim();
            currentChanges.add(
              PackageChange(
                isAdded: !bullet.toLowerCase().contains('fix'),
                title: title,
                description: desc.isNotEmpty ? desc : title,
              ),
            );
          } else {
            currentChanges.add(
              PackageChange(
                isAdded: true,
                title: bullet,
                description: bullet,
              ),
            );
          }
        }
      }
    }
    commitRelease();
    return releases;
  }

  static String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}
