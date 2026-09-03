# flutter_webview_ohos

HarmonyOS webview stack for [Luotopia](https://github.com/ClosedWHU/Luotopia-app): the OpenHarmony-SIG port of the flutter/packages `webview_flutter` family, mirrored as a monorepo so every package can be pinned with a single git ref.

## Packages

| Path | Version | Role |
|------|---------|------|
| `packages/webview_flutter` | 4.6.0 | App-facing API |
| `packages/webview_flutter_android` | 3.15.0 | Android implementation |
| `packages/webview_flutter_wkwebview` | 3.12.0 | iOS/macOS implementation |
| `packages/webview_flutter_platform_interface` | 2.10.0 | Platform interface |
| `packages/webview_flutter_ohos` | 3.15.0 | HarmonyOS implementation (ArkWeb) |

## Usage

Wired via `dependency_overrides` in Luotopia's OHOS build graph, one ref for the whole family:

```yaml
webview_flutter:
  git:
    url: https://github.com/TsinbeiLabs/flutter_webview_ohos.git
    path: packages/webview_flutter
    ref: main
# ... same for the other four packages
```

The HAP build additionally copies `packages/webview_flutter_ohos/ohos` into the hvigor module tree (the native side is not consumed through pub).
