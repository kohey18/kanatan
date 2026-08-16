# Kanatan サービス説明動画 生成プロンプト集（Gemini Omni Flash用）

30秒のサービス紹介動画を、8秒×4クリップで生成して繋ぐ構成。
各クリップのプロンプトは英語（映像モデルは英語の方が指示追従が安定するため）。ナレーションは日本語で後述。

**共通の注意**:
- アスペクト比 **16:9**、各クリップ **8秒** で生成
- 動画生成モデルは**日本語の文字描画が崩れやすい**ので、画面内テキスト（ロゴ・キャッチコピー）はプロンプトで最小限にし、最終的には動画編集で後乗せするのが安全
- 全クリップ共通のスタイル指定（各プロンプト末尾に付与）:

> Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.

---

## 構成（30秒）

| クリップ | 秒数 | 役割 | ナレーション |
|---|---|---|---|
| 1 | 0–8 | 共感（打ち間違いの苛立ち） | 「konnnichiha って、打ったことありませんか」 |
| 2 | 8–16 | 解決（左⌘=英数、右⌘=かな） | 「Kanatanなら、左コマンドで英数、右コマンドでかな」 |
| 3 | 16–24 | 体験（迷いなく打てる） | 「押すキーで行き先が決まるから、もう迷わない」 |
| 4 | 24–30 | ブランド（ロゴ+CTA） | 「Kanatan。無料・オープンソースで、今日から」 |

## クリップ1: 共感

```
An 8-second 16:9 animation. A person in a blue shirt types on a laptop at a clean white desk. A speech bubble above the laptop fills with garbled zigzag symbols and "?!" marks. The person stops typing, shoulders slump slightly, a small sweat drop appears by their head. Slow gentle zoom toward the confused speech bubble. Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## クリップ2: 解決

```
An 8-second 16:9 animation. Top-down view of a minimal US-layout keyboard. At second 2, a finger taps the key left of the spacebar: the key lights up blue #0017C1 with a soft pulse. At second 5, a finger taps the key right of the spacebar: the key lights up red #D64550 with a soft pulse. The rest of the keyboard stays white and light gray. Crisp, satisfying tap motion with a subtle ripple from each key. Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## クリップ3: 体験

```
An 8-second 16:9 animation. The same person from before now types fluidly and happily on the laptop. Above the laptop, two clean squares alternate glowing in rhythm with the typing: a blue square and a red square, pulsing alternately like a smooth metronome. The person's posture is relaxed and confident, with a slight smile. Gentle lateral camera drift. Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## クリップ4: ブランド

```
An 8-second 16:9 animation. A rounded-square app icon, split vertically into a blue half and a red half, floats to the center of a pure white screen and settles with a soft bounce. A subtle radial glow expands behind it. The icon gently pulses once, blue side first, then red side. Calm, confident ending shot with plenty of white space around the icon. Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## ナレーション原稿（30秒・日本語TTS/収録用）

> こんにちは、のつもりが「konnnichiha」。
> USキーボードの日本語切り替え、地味にストレスですよね。
> Kanatanなら、左コマンドをタップで英数、右コマンドでかな。
> 押すキーで行き先が決まるから、今どっちのモードか、考えなくていい。
> コマンドキーのショートカットはそのまま。設定も、ほぼゼロ。
> Kanatan。無料・オープンソースで、今日から手に入ります。

## 仕上げ（編集時）

1. クリップ4の終盤に、実物のアプリアイコン（`docs/assets/app-icon.png`）とロゴタイプ「Kanatan」、キャッチコピー「もう、入力モードで迷わない。」をテロップで後乗せ（生成任せにしない）
2. クリップ2と3の間に、実機のスクリーン録画（メニューバー+実際の切り替え）を2〜3秒挟むと信頼感が上がる
3. BGMは打鍵音と相性のいいミニマルなもの。クリップ2のタップに合わせて効果音を置くと「押したら切り替わる」が音でも伝わる
