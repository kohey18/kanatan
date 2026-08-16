#!/bin/zsh
# macOS の say (Kyoko) で仮ナレーションを生成する
# 使い方: ./make-narration.sh
set -e
cd "$(dirname "$0")"
mkdir -p public/audio && cd public/audio

LINES=(
  "US配列は好き。でも、英数かなの切り替えだけが、ずっと面倒だった。"
  "Kanatanなら、左コマンドをタップで英数、右コマンドでかな。"
  "トグルじゃないから、今どっちのモードか、考えなくていい。"
  "コマンドキーのショートカットは、いつも通り。"
  "許可を1回ONにしたら、もう切り替え済み。"
  "考えるのは文章だけ。切り替えは、Kanatanに。無料・オープンソースです。"
)

i=1
for t in "${LINES[@]}"; do
  say -v Kyoko -o "line$i.aiff" "$t"
  afconvert -f WAVE -d LEI16@44100 "line$i.aiff" "line$i.wav"
  rm "line$i.aiff"
  i=$((i+1))
done
echo "✅ public/audio/line1..6.wav を生成しました"
