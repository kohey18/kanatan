# Kanatan の一般配布

Mac App Store 外で、Developer ID 署名と Apple の公証を付けた DMG を公開します。
対応 OS は macOS 13 以降、配布ビルドは Apple Silicon / Intel の Universal Binary です。

## 初回のみ必要な Apple の設定（両アプリで共用可能）

1. https://developer.apple.com/account/ で 新しい配布元として Apple Developer Program に加入します。
   未加入なら加入、期限切れなら更新します。本人確認・契約への同意・支払いはアカウント所有者が行います。
   個人名義で登録する前提です（2026-09-10 ユーザーの最新方針）。
2. Xcode → Settings → Accounts → 対象アカウント／チーム → Manage Certificates から
   **Developer ID Application** を作成します（ローカル証明書の発行には Account Holder 権限が必要）。
   既存証明書が別の Mac にある場合は、秘密鍵とセットで移行できます。
   `Apple Development` や `Apple Distribution` はこの配布方法の署名には使いません。
3. https://account.apple.com/ のサインインとセキュリティからアプリ用パスワードを発行し、
   次を**ご自身のターミナル**で実行します。パスワードは対話プロンプトに入力し、チャットや Git に保存しません。

```sh
xcrun notarytool store-credentials macos-notary \
  --apple-id 'YOUR_APPLE_ACCOUNT_EMAIL' \
  --team-id '3U5Y9G26T3'
```

ユーザー提供の Membership details 画面で、個人チーム `3U5Y9G26T3` を確認しました。
両アプリの release.sh はこの Team ID を既定値として使います（環境変数で上書き可能）。
以前この ID を別会社のチームと説明したのは誤りで、個人チームとして訂正しました。
ローカルビルドは ad-hoc 署名、配布ビルドはこのチームの Developer ID Application 署名を使用します。
このアプリ構成での DMG 配布には App Store Connect のアプリ登録や TestFlight 招待は不要です。

## 個人登録の準備

申請先: https://developer.apple.com/programs/enroll/

- ご自身が管理する Apple Account を使い、二要素認証を有効にします。
- Individual / 個人として、本名と正しい連絡先を入力します。法人情報・D-U-N-S番号は不要です。
- 本人確認、契約への同意、年会費の支払いを完了します。
  標準年会費は99米ドルで、実際の地域通貨での価格は申請時に確認します。
- このメンバーシップで Kanatan と Editan の両方を配布します。
- 将来 App Store に掲載する場合、個人登録では販売者として個人の正式氏名が表示されます。
- 別会社のメンバーシップには変更を加えません。既存アカウントで新規加入が進められない場合は、
  画面のエラーと既存チームでの役割を確認してから、使用するアカウントを決めます。

申請要件: https://developer.apple.com/help/account/membership/program-enrollment/

2026-09-10: ユーザー提供の注文完了画面で、Apple Developer Program の1年間メンバーシップ購入手続きを確認。
ユーザー提供のアカウント画面で、メンバーシップの有効化、登録タイプ「個人」、Team ID `3U5Y9G26T3` を確認しました。
現在は操作可能なブラウザが未接続のため、アカウント画面の確認にはユーザーの操作が必要です。

## ビルド・公証

```sh
# 有効な証明書名を確認（秘密鍵は表示しません）
security find-identity -v -p codesigning

export APPLE_TEAM_ID='3U5Y9G26T3'
export DEVELOPER_ID_APPLICATION='Developer ID Application: Kohei Kawai (3U5Y9G26T3)'
export NOTARY_PROFILE='macos-notary'
./scripts/release.sh --check
./scripts/release.sh 0.1.1 2
```

スクリプトは独立した出力ディレクトリに新規ビルドし、次を実施します。

1. Release / Universal ビルド、Developer ID 署名、Hardened Runtime とタイムスタンプを設定。
2. アプリを公証し、Accepted を確認してチケットを添付。
3. Applications へのリンクを含む DMG を作成・署名・公証してチケットを添付。
4. 署名、両 CPU アーキテクチャ、チケット、Gatekeeper の検証後に SHA-256 を出力。

出力先は `build/distribution/Kanatan-VERSION.XXXXXX/`。
署名や公証に失敗した出力物は公開しないでください。公証結果／失敗ログも同じディレクトリに保存されます。
公証の待機が中断された場合は、結果 JSON の submission ID を使って `xcrun notarytool info` / `log` で確認します。

証明書なしでコンパイルのみ検証する場合:

```sh
./scripts/release.sh --build-only 0.1.1 2
```

これはローカル用の ad-hoc 署名アプリだけを作り、配布用 DMG は作りません。
既存の install.sh と生成プロジェクトの出力先を分けており、/Applications の常用版を置き換えません。

## 公開前の確認

- 別の Mac／新規ユーザーで、ブラウザから DMG をダウンロードして Applications にコピーし起動。
- 開発元未確認の回避操作や `xattr` による隔離属性解除が不要なことを確認。
- アクセシビリティの許可、左右⌘による入力切替、ログイン時の起動を確認。アクセシビリティの許可は利用者ごとに必要です。
- DMG と `.dmg.sha256` を公開 GitHub Release にアップロード。
- ダウンロードリンクがログアウト状態でも使えることを確認。

## 現時点の残タスク（2026-09-10）

- [x] 最新方針を個人名義に変更（法人情報の収集は不要）。
- [x] Apple Developer Program の購入手続き完了を注文画面で確認。
- [x] メンバーシップ有効化完了（ユーザー報告）。
- [x] 個人チームの Team ID `3U5Y9G26T3` をアカウント画面で確認。
- [x] この Mac の有効な署名IDとして `Developer ID Application: Kohei Kawai (3U5Y9G26T3)` を確認。両アプリのスクリプトに既定値を設定。
- [x] `macos-notary` の公証用認証情報を Keychain に登録し、接続成功を確認。
- [x] Universal ビルド、Developer ID 署名、アプリと DMG の公証・チケット添付・Gatekeeper 検証が成功。
- [ ] 別環境で初回起動・機能確認。
- [x] [公証済み v0.1.1](https://github.com/kohey18/kanatan/releases/tag/v0.1.1) を公開。

- [x] 認証情報なしで公開 DMG を再ダウンロードし、検証済みファイルとの SHA-256 一致を確認。

## 今回の検証状況

- シェル構文、XcodeGen のプロジェクト生成、Release ビルドが成功。
- 以前の Xcode のコンパイラ情報取得の停止は再現せず、ビルド可能になりました。
- 独立したプロジェクト出力先からの Info.plist 参照を絶対パスに修正。
- `CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO` により、公証不可のデバッグ権限を除外。
- アプリと DMG の両方で Apple の公証結果 `Accepted` を確認。
- 公証チケットの添付と検証、署名検証、Gatekeeper の受け入れを確認。
- Apple Silicon / Intel の両アーキテクチャとバージョン情報を確認。
- DMG を読み取り専用でマウントし、内包アプリの署名・Gatekeeper・公証チケット・CPU 対応を確認。
- 常用中のアプリの終了や置換はしていません。別 Mac での初回起動と操作確認は残タスクです。

## Apple 公式資料

- [Developer Program 加入](https://developer.apple.com/programs/enroll/)
- [Developer ID 証明書](https://developer.apple.com/help/account/certificates/create-developer-id-certificates)
- [macOS の配布方法](https://developer.apple.com/macos/distribution/)
- [公証ワークフロー](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow)
