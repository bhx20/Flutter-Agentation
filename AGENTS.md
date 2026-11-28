# Agent Memory & Development Rules

## User Workflow & Feedback Preferences
- **Do not run or create test cases on UI feedback**: When the user provides feedback or requests changes, do not run test suites (`flutter test`) or write/update test cases unless explicitly asked.
- **Direct implementation**: Immediately implement the requested feedback/changes directly in the target files.
- **Fast response time**: Prioritize quick turnarounds and rapid edits without executing unnecessary test flows.
- **Visual feedback verification**: Apply the code change cleanly and hot reload/restart the running app for visual inspection.
- **ValueNotifier over setState**: ALWAYS use `ValueNotifier` and `ValueListenableBuilder` (or other reactive notifiers) instead of `setState`. Do not use `setState` anywhere across this project.
