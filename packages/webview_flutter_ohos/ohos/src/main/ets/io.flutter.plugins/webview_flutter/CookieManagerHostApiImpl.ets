// Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE_ODID file.
// Based on CookieManagerHostApiImpl.java originally written by
// Copyright 2013 The Flutter Authors.

import { Result } from './GeneratedOhosWebView'
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import { InstanceManager } from './InstanceManager'
import { CookieManagerHostApi } from './GeneratedOhosWebView';
import web_webview from '@ohos.web.webview'
import { url } from '@kit.ArkTS';
export class CookieManagerHostApiImpl extends CookieManagerHostApi {
  static getCookieHeader(url: string): string {
    return web_webview.WebCookieManager.fetchCookieSync(url);
  }

  static setCookieHeaders(url: string, cookies: string[]): void {
    for (const cookie of cookies) web_webview.WebCookieManager.configCookieSync(url, cookie, false, true);
    web_webview.WebCookieManager.saveCookieSync();
  }

  static clearCookies(): void {
    web_webview.WebCookieManager.clearAllCookiesSync();
    web_webview.WebCookieManager.saveCookieSync();
  }

  static clearCookiesForUrl(address: string): void {
    const target = new url.URL(address);
    const header = CookieManagerHostApiImpl.getCookieHeader(address);
    const names = new Set<string>();
    for (const pair of header.split(';')) {
      const separator = pair.indexOf('=');
      if (separator > 0) names.add(pair.substring(0, separator).trim());
    }
    // ArkWeb exposes the Cookie header, not cookie attributes. Enumerate the
    // domain/path scopes that can match this URL, then verify the result.
    const domains: string[] = [''];
    const labels = target.hostname.split('.');
    for (let index = 0; index < labels.length; index++) domains.push(labels.slice(index).join('.'));
    const paths = new Set<string>(['/']);
    let path = '';
    for (const segment of target.pathname.split('/')) {
      if (segment.length === 0) continue;
      path += '/' + segment;
      paths.add(path);
      paths.add(path + '/');
    }
    for (const name of names) {
      for (const domain of domains) {
        for (const scope of paths) {
          const secure = target.protocol === 'https:' ? '; Secure' : '';
          const domainAttribute = domain.length > 0 ? '; Domain=' + domain : '';
          const expired = name + '=; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=' + scope +
            domainAttribute + secure + '; HttpOnly';
          try {
            web_webview.WebCookieManager.configCookieSync(address, expired, false, true);
          } catch (_) {
            // Public-suffix and cookie-prefix rules reject invalid scopes.
            // Completion is based on the observed postcondition below.
          }
        }
      }
    }
    web_webview.WebCookieManager.saveCookieSync();
    if (CookieManagerHostApiImpl.getCookieHeader(address).trim().length > 0) {
      throw new Error('Unable to clear all cookies visible at this URL');
    }
  }
  private binaryMessenger: BinaryMessenger;
  private instanceManager: InstanceManager;

  constructor(binaryMessenger: BinaryMessenger , instanceManager: InstanceManager ) {
    super()
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  private getCookieManagerInstance(identifier: number): ESObject {
    const cookieManagerInstance: ESObject = this.instanceManager.getInstance(identifier)
    if (cookieManagerInstance) {
      return cookieManagerInstance
    }
    else {
      throw new Error("getCookieManagerInstance, no such instance")
    }
  }
  attachInstance(instanceIdentifier: number) {

  }

  setCookie(identifier: number, url: string, value: string) {
    const origin = url.includes('://') ? url : 'https://' + url.replace(/^\./, '');
    CookieManagerHostApiImpl.setCookieHeaders(origin, [value]);
  }

  setAcceptThirdPartyCookies(identifier: number, accept: boolean) {
    web_webview.WebCookieManager.putAcceptThirdPartyCookieEnabled(accept);
  }

  removeAllCookies(identifier: number, result: Result<boolean> ) {
    CookieManagerHostApiImpl.clearCookies();
    result.success(true)
  }

}

export interface cookieManager {
  removeAllCookies(identifier: number, result: Result<boolean> | null): void

  putAcceptThirdPartyCookieEnabled(accept: boolean): void

  setCookie(url: string, value: string): void
}
