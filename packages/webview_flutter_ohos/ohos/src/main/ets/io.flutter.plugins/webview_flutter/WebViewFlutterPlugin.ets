// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on WebViewFlutterPlugin.java originally written by
// Copyright 2013 The Flutter Authors.

import { FlutterPluginBinding, FlutterPlugin } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import PluginRegistry from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/PluginRegistry';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import PlatformViewRegistry from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformViewRegistry';
import { OhosObjectHostApiImpl } from './OhosObjectHostApiImpl';
import { CookieManagerHostApiImpl } from './CookieManagerHostApiImpl';
import { CustomViewCallbackHostApiImpl } from './CustomViewCallbackHostApiImpl';
import { DownloadListenerFlutterApiImpl } from './DownloadListenerFlutterApiImpl';
import { DownloadListenerCreator, DownloadListenerHostApiImpl } from './DownloadListenerHostApiImpl';
import { FlutterAssetManager, PluginBindingFlutterAssetManager } from './FlutterAssetManager';
import { FlutterAssetManagerHostApiImpl } from './FlutterAssetManagerHostApiImpl';
import GeneratedOhosWebView, {
  CookieManagerHostApi,
  CustomViewCallbackHostApi,
  DownloadListenerHostApi,
  FlutterAssetManagerHostApi,
  GeolocationPermissionsCallbackHostApi,
  HttpAuthHandlerHostApi,
  InstanceManagerHostApi,
  JavaScriptChannelHostApi,
  PermissionRequestHostApi,
  OhosObjectFlutterApi,
  OhosObjectHostApi,
  WebViewHostApi,
  InstanceManagerApi,
  WebViewClientHostApi,
  WebChromeClientHostApi,
  WebSettingsHostApi,
  WebStorageHostApi
} from './GeneratedOhosWebView';
import { GeolocationPermissionsCallbackHostApiImpl } from './GeolocationPermissionsCallbackHostApiImpl';
import { HttpAuthHandlerHostApiImpl } from './HttpAuthHandlerHostApiImpl';
import { InstanceManager } from './InstanceManager';
import { JavaScriptChannelCreator, JavaScriptChannelHostApiImpl } from './JavaScriptChannelHostApiImpl';
import { PermissionRequestHostApiImpl } from './PermissionRequestHostApiImpl';
import { WebViewHostApiImpl, WebViewProxy } from './WebViewHostApiImpl';
import { WebViewPlatformView } from './WebViewHostApiImpl';
import MethodChannel, { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
import { FlutterWebViewFactory } from './FlutterWebViewFactory';
import { JavaScriptChannelFlutterApiImpl } from './JavaScriptChannelFlutterApiImpl';
import { WebViewClientCreator, WebViewClientHostApiImpl } from './WebViewClientHostApiImpl';
import { WebViewClientFlutterApiImpl } from './WebViewClientFlutterApiImpl';
import { WebChromeClientCreator, WebChromeClientHostApiImpl } from './WebChromeClientHostApiImpl';
import { WebChromeClientFlutterApiImpl } from './WebChromeClientFlutterApiImpl';
import { WebSettingsCreator, WebSettingsHostApiImpl } from './WebSettingsHostApiImpl';
import { WebStorageHostApiImpl } from './WebStorageHostApiImpl';

const TAG:string = "WebViewFlutterPlugin";
export class WebViewFlutterPlugin implements FlutterPlugin, MethodCallHandler {
  private configurationChannel: MethodChannel | null = null;

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      const args = call.args as Map<string, Object>;
      switch (call.method) {
        case 'getCookieHeader':
          result.success(CookieManagerHostApiImpl.getCookieHeader(args.get('url') as string));
          break;
        case 'setCookieHeaders':
          CookieManagerHostApiImpl.setCookieHeaders(args.get('url') as string, args.get('cookies') as string[]);
          result.success(null);
          break;
        case 'clearCookies':
          CookieManagerHostApiImpl.clearCookies();
          result.success(null);
          break;
        case 'clearCookiesForUrl':
          CookieManagerHostApiImpl.clearCookiesForUrl(args.get('url') as string);
          result.success(null);
          break;
        case 'addDocumentStartJavaScript':
          await this.viewFor(args.get('instanceId') as number)
            .addDocumentStartJavaScript(args.get('source') as string);
          result.success(null);
          break;
        case 'setDarkMode':
          await this.viewFor(args.get('instanceId') as number).setDarkMode(args.get('enabled') as boolean);
          result.success(null);
          break;
        case 'configureLayout':
          await this.viewFor(args.get('instanceId') as number).configureLayout(
            args.get('useWideViewPort') as boolean,
            args.get('textZoom') as number,
            args.get('allowMixedContent') as boolean);
          result.success(null);
          break;
        case 'getPermissionRequestOrigin': {
          const request = this.instanceManager?.getInstance(args.get('instanceId') as number) as PermissionRequest;
          result.success(request.getOrigin());
          break;
        }
        default:
          result.notImplemented();
      }
    } catch (error) {
      result.error('WEBVIEW_CONFIGURATION_ERROR', (error as Error).message, null);
    }
  }

  private viewFor(identifier: number): WebViewPlatformView {
    const view: Object | undefined = this.instanceManager?.getInstance(identifier);
    if (!(view instanceof WebViewPlatformView)) throw new Error('Unknown WebView instance');
    return view;
  }
  getUniqueClassName(): string {
    return TAG;
  }

  private instanceManager: InstanceManager|null = null;

  setUp(
    binaryMessenger: BinaryMessenger, viewRegistry: PlatformViewRegistry, context: Context,
    flutterAssetManager: FlutterAssetManager
  ) {
    this.instanceManager = new InstanceManager({
      onFinalize: (identifier: number) => {
        new OhosObjectFlutterApi(binaryMessenger).dispose(
          identifier, { reply: () => {
        } }
        )
      }
    })

    InstanceManagerHostApi.setup(
      binaryMessenger,
      {
        clear: () => {
          if(this.instanceManager)
            this.instanceManager.clear();
        }
      }
    );
    viewRegistry.registerViewFactory(
      "plugins.flutter.io/webview", new FlutterWebViewFactory(this.instanceManager)
    );

    let webViewHostApi: WebViewHostApi =
      new WebViewHostApiImpl(
        this.instanceManager, new WebViewProxy(), binaryMessenger, context);
    let javaScriptChannelHostApi: JavaScriptChannelHostApi =
      new JavaScriptChannelHostApiImpl(
        this.instanceManager,
        new JavaScriptChannelCreator(),
        new JavaScriptChannelFlutterApiImpl(binaryMessenger, this.instanceManager),
      );

    OhosObjectHostApi.setup(binaryMessenger, new OhosObjectHostApiImpl(this.instanceManager));

    WebViewHostApi.setup(binaryMessenger, webViewHostApi);

    JavaScriptChannelHostApi.setup(binaryMessenger, javaScriptChannelHostApi);

    WebViewClientHostApi.setup(
      binaryMessenger,
      new WebViewClientHostApiImpl(
        this.instanceManager,
        new WebViewClientCreator(),
        new WebViewClientFlutterApiImpl(binaryMessenger, this.instanceManager))
    );

    WebChromeClientHostApi.setup(
      binaryMessenger,
      new WebChromeClientHostApiImpl(
        this.instanceManager,
        new WebChromeClientCreator(),
        new WebChromeClientFlutterApiImpl(binaryMessenger, this.instanceManager))
    );

    DownloadListenerHostApi.setup(
      binaryMessenger,
      new DownloadListenerHostApiImpl(
        this.instanceManager,
        new DownloadListenerCreator(),
        new DownloadListenerFlutterApiImpl(binaryMessenger, this.instanceManager))
    );

    WebSettingsHostApi.setup(
      binaryMessenger,
      new WebSettingsHostApiImpl(
        this.instanceManager, new WebSettingsCreator())
    );

    FlutterAssetManagerHostApi.setup(
      binaryMessenger, new FlutterAssetManagerHostApiImpl(flutterAssetManager)
    );

    CookieManagerHostApi.setup(
      binaryMessenger, new CookieManagerHostApiImpl(binaryMessenger, this.instanceManager)
    );

    WebStorageHostApi.setup(
      binaryMessenger,
      new WebStorageHostApiImpl()
    );

    PermissionRequestHostApi.setup(
      binaryMessenger, new PermissionRequestHostApiImpl(binaryMessenger, this.instanceManager)
    );

    GeolocationPermissionsCallbackHostApi.setup(
      binaryMessenger,
      new GeolocationPermissionsCallbackHostApiImpl(binaryMessenger, this.instanceManager)
    );
    CustomViewCallbackHostApi.setup(
      binaryMessenger, new CustomViewCallbackHostApiImpl(binaryMessenger, this.instanceManager));
    HttpAuthHandlerHostApi.setup(
      binaryMessenger, new HttpAuthHandlerHostApiImpl(binaryMessenger, this.instanceManager));
  }

  onAttachedToEngine(binding: FlutterPluginBinding) {
    this.setUp(
      binding.getBinaryMessenger(),
      binding.getPlatformViewRegistry(),
      binding.getApplicationContext(),
      new PluginBindingFlutterAssetManager(
        binding.getApplicationContext().resourceManager, binding.getFlutterAssets())
    );
    this.configurationChannel = new MethodChannel(binding.getBinaryMessenger(),
      'plugins.flutter.io/webview_ohos/configuration');
    this.configurationChannel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding) {
    this.configurationChannel?.setMethodCallHandler(null);
    this.configurationChannel = null;
    if (this.instanceManager != null) {
      this.instanceManager.stopFinalizationListener();
      this.instanceManager = null;
    }
  }

  getInstanceManager() {
    return this.instanceManager;
  }
}
