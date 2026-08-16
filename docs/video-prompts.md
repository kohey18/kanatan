# Kanatan サービス説明動画 生成プロンプト集（Gemini Omni Flash用）

30秒のサービス紹介動画を **8秒×4クリップ** で生成して繋ぐ構成。
ナレーション・構成はLP（docs/index.html）の最新文言に準拠。

このファイルの読み方:
- **✂️ コードブロック（```で囲まれた部分）だけを、そのままGemini Omni Flashに貼り付けてください。**
- コードブロックの外の文章は人間用の説明です。貼り付けないでください。
- 各クリップは 16:9 / 8秒 で生成してください。
- 動画モデルは日本語の文字描画が崩れやすいため、プロンプトは「画面内テキストなし」で統一しています。ロゴやキャッチコピーは編集時に後乗せします。

---

## 全体構成（貼り付け不要・編集時の設計図）

| クリップ | 秒数 | 役割 | 対応するLP文言 |
|---|---|---|---|
| 1 | 0–8 | 共感 | 「US配列のまま、英数／かなだけ欲しい。」 |
| 2 | 8–16 | 解決 | 「左⌘で英数、右⌘でかな。」 |
| 3 | 16–24 | 体験 | 「押すキーで、行き先が決まる。」「もう、切り替え済み。」 |
| 4 | 24–30 | ブランド | 「考えるのは文章だけ。切り替えはKanatanに。」 |

---

## クリップ1: 共感（0–8秒）

「間違ったモードで打ってしまい、消して打ち直す」を文字なしで表現。タイプされた文章は抽象的なグレーのバーで描かせ、モードの不確かさは青⇄赤に揺れる小さなインジケータで見せる（クリップ2で「タップで確定して光る」と対比になる）。

✂️ 下のブロックをそのまま貼り付け:

```
Create an 8-second 16:9 video. A person in a blue shirt types on a laptop at a clean white desk. The laptop screen shows an abstract document: typed text is represented only as plain rounded gray horizontal bars — absolutely no letters, no words, no characters, no readable or pseudo-readable text anywhere in the video. Seconds 0-3: the person types and gray bars appear on the screen, while a small rounded indicator above the laptop flickers uncertainly between blue #0017C1 and red #D64550. Seconds 3-6: the person notices a mistake, taps the delete key repeatedly, and the gray bars shrink and disappear one by one; a small sweat drop appears by their head. Seconds 6-8: the person sighs and starts typing again from the beginning, shoulders slightly slumped. Slow gentle zoom in.

Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text of any kind.
```

## クリップ2: 解決（8–16秒）

✂️ 下のブロックをそのまま貼り付け:

```
Create an 8-second 16:9 video. Top-down view of a minimal US-layout keyboard with blank white keys. At second 2, a finger taps the key immediately left of the spacebar: the key lights up blue #0017C1 with a soft pulse and stays lit. At second 5, a finger taps the key immediately right of the spacebar: the key lights up red #D64550 with a soft pulse and stays lit. The rest of the keyboard stays white and light gray. Crisp, satisfying tap motion with a subtle ripple radiating from each tapped key.

Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## クリップ3: 体験（16–24秒）

✂️ 下のブロックをそのまま貼り付け:

```
Create an 8-second 16:9 video. The same person from before now types fluidly and confidently on the laptop, posture relaxed, with a slight smile. Above the laptop, two clean rounded squares — one blue #0017C1, one red #D64550 — pulse gently in alternation, in rhythm with the typing, like a smooth metronome. Nothing interrupts the typing flow. Gentle lateral camera drift.

Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

## クリップ4: ブランド（24–30秒）

✂️ 下のブロックをそのまま貼り付け:

```
Create an 8-second 16:9 video. A rounded-square app icon, split vertically into a blue #0017C1 half and a red #D64550 half, floats to the center of a pure white screen and settles with a soft, satisfying bounce. A subtle radial glow expands behind it. The icon gently pulses once — blue side first, then red side — then holds still. Calm, confident ending shot with generous white space around the icon.

Style: clean flat vector illustration, Japanese government design system aesthetic, white background, primary blue #0017C1 and accent red #D64550, minimal color palette, smooth subtle motion, no camera shake, no photorealism, no on-screen text.
```

---

## ナレーション原稿（30秒・日本語TTS/収録用）

✂️ TTSに貼り付ける場合は下のブロックをそのまま:

```
US配列は好き。でも、英数かなの切り替えだけが、ずっと面倒だった。
Kanatanなら、左コマンドをタップで英数、右コマンドでかな。
トグルじゃないから、今どっちのモードか、考えなくていい。
コマンドキーのショートカットは、いつも通り。
許可を1回ONにしたら、もう切り替え済み。
考えるのは文章だけ。切り替えは、Kanatanに。無料・オープンソースです。
```

クリップとの対応（貼り付け不要）: 1〜2文目=クリップ1、3文目=クリップ2、4〜5文目=クリップ3、6文目=クリップ4。

---

## BGM生成プロンプト（Suno / Udio / Lyria など音楽生成AI用）

動画の構成（0-8s 戸惑い → 8-16s 解決 → 16-24s 快適 → 24-30s ブランド）に合わせた30秒のインスト曲。
ナレーションの下に敷くので、主張しすぎないミニマルなものを指定している。

✂️ 下のブロックをそのまま貼り付け:

```
30-second instrumental background music for a Mac app intro video. Minimal, clean, modern Japanese tech aesthetic. Warm marimba and soft felt piano over a light electronic pulse, around 105 BPM. Structure: sparse and slightly hesitant for the first 8 seconds; from 8s a confident, steady groove begins with two subtle percussive "tap" accents; stays light and pleasant through 24s; ends calm and resolved with a soft final chord that lands exactly at 30 seconds. No vocals, no heavy drums, no dramatic risers, no cinematic epicness. Mood: tidy, friendly, trustworthy.
```

日本語で指定できるサービスの場合:

```
Macアプリ紹介動画用の30秒のインストゥルメンタルBGM。ミニマルで清潔な、現代的な日本のテックプロダクトの雰囲気。温かいマリンバと柔らかいフェルトピアノ、軽い電子的なパルス、テンポは105BPM前後。構成: 最初の8秒はまばらで少し戸惑うような雰囲気 → 8秒から自信のある一定のグルーヴが始まり、控えめなタップ音のアクセントを2回 → 24秒まで軽快さを維持 → 最後は落ち着いたコードで30秒ちょうどに静かに着地。ボーカルなし、重いドラムなし、映画的な盛り上げなし。印象: 端正、親しみやすい、信頼できる。
```

生成できたら `video/public/audio/bgm.mp3` として保存すれば、ナレーションの音量を邪魔しないダッキング付きで組み込む（実装はすぐできるので声かけを）。

---

## 仕上げチェックリスト（貼り付け不要・編集作業用）

1. クリップ4の終盤に、実物のアプリアイコン（`docs/assets/app-icon.png`）・ロゴタイプ「Kanatan」・キャッチコピー「もう、入力モードで迷わない。」をテロップで後乗せする（文字は生成に任せない）
2. クリップ2と3の間に実機のスクリーン録画（メニューバー+実際の切り替え）を2〜3秒挟むと信頼感が上がる
3. BGMはミニマルなもの。クリップ2の2つのタップに効果音を合わせると「押したら切り替わる」が音でも伝わる
4. 末尾に「無料・オープンソース / macOS 13+」とLPのURLをテロップ表示
