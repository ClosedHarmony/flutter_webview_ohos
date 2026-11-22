// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.

import web_webview from '@ohos.web.webview'
import  PlatformView from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import { WebViewPlatformView, WebSettingsImpl } from './WebViewHostApiImpl';
import { Any } from '@ohos/flutter_ohos';
import { deviceInfo } from '@kit.BasicServicesKit';

@Observed
export declare class Params {
  direction: Direction
  platformView: PlatformView
}
@Component
export struct OhosWebView {
  @ObjectLink params: Params;
  @ObjectLink settings: WebSettingsImpl;
  webView: WebViewPlatformView = this.params.platformView as WebViewPlatformView;
  controller: web_webview.WebviewController = this.webView.getController();

  @State disposed: boolean = false;

  aboutToAppear() {
    this.webView.aboutToAppear();
    this.webView.setOnDisposeCallback(() => {
      this.disposed = true;
    });
  }

  aboutToDisappear() {
    this.webView.aboutToDisappear();
  }

  onDidBuild() {
    this.webView.completeConfigurationUpdate();
  }

  build() {
    Column() {
      if (!this.disposed) {
        Web(
          {
            src: this.webView.getUrl(),
            controller: this.controller
          })
          .keyboardAvoidMode(WebKeyboardAvoidMode.RESIZE_VISUAL)
          .backgroundColor(this.settings.backgroundColor)
          .onDownloadStart(this.webView.onDownloadStart)
          .onPageBegin(this.webView.onPageBegin)
          .onPageEnd(this.webView.onPageEnd)
          .onErrorReceive(this.webView.onErrorReceive)
          .onRefreshAccessedHistory(this.webView.onRefreshAccessedHistory)
          .onProgressChange(this.webView.onProgressChange)
          .onGeolocationShow(this.webView.onGeolocationShow)
          .onGeolocationHide(this.webView.onGeolocationHide)
          .onShowFileSelector(this.webView.onShowFileSelector)
          .onPermissionRequest(this.webView.onPermissionRequest)
          .onConsole(this.webView.onConsoleMessage)
          .onWindowExit(this.webView.onWindowExit)
          .domStorageAccess(this.settings.domStorageAccess)
          .allowWindowOpenMethod(this.settings.allowWindowOpenMethod)
          .multiWindowAccess(false)
          .javaScriptAccess(this.settings.javaScriptAccess)
          .mediaPlayGestureAccess(this.settings.mediaPlayGestureAccess)
          .zoomAccess(this.settings.zoomAccess)
          .overviewModeAccess(this.settings.overviewModeAccess)
          .wideViewModeAccess(this.settings.wideViewModeAccess)
          .metaViewport(this.settings.wideViewModeAccess)
          .fileAccess(this.settings.fileAccess)
          .darkMode(this.settings.darkMode)
          .forceDarkAccess(this.settings.darkMode === WebDarkMode.On)
          .runJavaScriptOnDocumentStart(this.settings.documentStartScripts)
          .textZoomRatio(this.settings.textZoomRatio)
          .onScroll(this.webView.onScroll)
          .onControllerAttached(this.webView.onControllerAttached)
          .onWindowNew((event: Any) => {
            let newWebViewController: web_webview.WebviewController = new web_webview.WebviewController();
            let dialogController: CustomDialogController = new CustomDialogController({
              builder: NewWebView({ webViewController: newWebViewController })
            })
            dialogController.open();
            event.handler.setWebController(newWebViewController);
          })
          .onSslErrorEventReceive((event) => {
            let handler: ESObject = event.handler as ESObject;
            if (deviceInfo.sdkApiVersion >= 20) {
              handler.handleCancel(true);
            } else {
              handler.handleCancel();
            }
          })
          .onHttpAuthRequest(this.webView.onHttpAuthRequest)
          .onAlert(this.webView.onJsAlert)
          .onConfirm(this.webView.onJsConfirm)
          .onPrompt(this.webView.onJsPrompt)
          .mixedMode(this.settings.mixedMode)
          .onOverrideUrlLoading(this.webView.onOverrideUrlLoading)
          .onFullScreenEnter(this.webView.onFullScreenEnter)
          .onFullScreenExit(this.webView.onFullScreenExit)
      }
    }
  }
}

@Builder
export function WebBuilder(params: Params) {
  OhosWebView({
    params: params,
    settings: (params.platformView as WebViewPlatformView).getWebSettings(),
    webView: params.platformView as WebViewPlatformView,
    controller: (params.platformView as WebViewPlatformView).getController()
  }).backgroundColor(Color.Transparent)
}

@CustomDialog
struct NewWebView {
  controller?: CustomDialogController
  webViewController: web_webview.WebviewController = new web_webview.WebviewController();

  build() {
    Web({ src: "", controller: this.webViewController })
      .javaScriptAccess(true)
      .multiWindowAccess(false)
      .onWindowExit(
        () => {
          if (this.controller) {
            this.controller.close();
          }
        }
      )
  }
}
