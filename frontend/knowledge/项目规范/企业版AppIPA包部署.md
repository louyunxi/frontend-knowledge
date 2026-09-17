---
title: 企业版 App IPA 包部署自有服务器
platform: uniapp
compatibility: uniapp-only
domain: 项目规范
source: 综合实践
tags: [ipa, ios, 企业证书, OTA, manifest.plist, 部署]
---

> ⚠️ 本知识仅适用于 **uni-app 自定义组件 / uni-app 打包 App** 场景。
> 普通 H5 / 小程序没有「ipa 包」概念，**不能**复用。

# 企业版 App IPA 包部署到自有服务器

## 背景

苹果企业开发者账号（$299/年）签名的 ipa 可不经过 App Store 分发给员工 / 内部用户。
需要把 ipa 与 manifest.plist 放在可 HTTPS 访问的服务器上，通过 Safari 一键安装。

## 文件结构

```
https://your-domain.com/app/
├── YourApp.ipa          # 打包后的 ipa
├── manifest.plist       # 安装清单
└── index.html           # 引导下载页（可选）
```

## manifest.plist 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>items</key>
    <array>
        <dict>
            <key>assets</key>
            <array>
                <dict>
                    <key>kind</key><string>software-package</string>
                    <key>url</key>
                    <string>https://your-domain.com/app/YourApp.ipa</string>
                </dict>
            </array>
            <key>metadata</key>
            <dict>
                <key>bundle-identifier</key>
                <string>com.yourcompany.yourapp</string>
                <key>bundle-version</key><string>1.0.0</string>
                <key>kind</key><string>software</string>
                <key>title</key><string>YourApp</string>
            </dict>
        </dict>
    </array>
</dict>
</plist>
```

## 一键安装链接

```html
<a href="itms-services://?action=download-manifest&url=https://your-domain.com/app/manifest.plist">
  安装 App
</a>
```

> Safari 打开该链接即可触发企业证书安装流程。

## 服务器 HTTPS 要求

苹果强制要求 manifest.plist 与 ipa 都通过 **HTTPS** 提供，可信证书即可（自签证书无效）。

## manifest.json 配置要点

```json
{
  "app-plus": {
    "distribute": {
      "ios": {
        "certificateType": "enterprise",
        "appid": "com.yourcompany.yourapp",
        "profile": "your-enterprise.mobileprovision"
      }
    }
  }
}
```

## 实践提示

1. 企业证书违规滥用会被苹果封号，**仅供内部员工使用**。
2. 推荐配合「版本号 + manifest 缓存策略」实现 OTA 升级。
3. ipa 体积较大，建议开启 Nginx gzip + 分片断点续传。
4. 微信 H5 / 小程序分发不受此约束，按常规流程发布即可。