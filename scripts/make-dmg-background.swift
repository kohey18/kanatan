#!/usr/bin/env swift
// DMG の背景画像 scripts/dmg-background.png を生成する
// 使い方: swift scripts/make-dmg-background.swift
//
// make-dmg.sh のレイアウトと座標を合わせている:
//   ウィンドウ 660x420 / アイコンサイズ 128
//   Kanatan.app 中心 (165, 190) / Applications 中心 (495, 190)
// 矢印は 2 つのアイコンの隙間 (x: 229〜431) に収まるように描く。
// Retina で滲まないよう 2x (1320x840px, 144dpi) で出力する。

import AppKit

let pointSize = NSSize(width: 660, height: 420)
let scale = 2

let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(pointSize.width) * scale,
    pixelsHigh: Int(pointSize.height) * scale,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
)!
rep.size = pointSize  // 144dpi として保存され、Finder が 660x420pt で表示する

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

NSColor.white.setFill()
NSRect(origin: .zero, size: pointSize).fill()

// AppKit は左下原点なので、アイコン中心の y=190(上から)は 420-190=230
let centerY: CGFloat = 230
let arrowColor = NSColor(calibratedWhite: 0.78, alpha: 1)

// シャフト: 隙間の中央 (x=330) を挟んで左右対称に
let shaft = NSBezierPath()
shaft.move(to: NSPoint(x: 272, y: centerY))
shaft.line(to: NSPoint(x: 376, y: centerY))
shaft.lineWidth = 13
shaft.lineCapStyle = .round
arrowColor.setStroke()
shaft.stroke()

// 矢頭: 開いたシェブロン
let head = NSBezierPath()
head.move(to: NSPoint(x: 352, y: centerY + 26))
head.line(to: NSPoint(x: 388, y: centerY))
head.line(to: NSPoint(x: 352, y: centerY - 26))
head.lineWidth = 13
head.lineCapStyle = .round
head.lineJoinStyle = .round
head.stroke()

NSGraphicsContext.restoreGraphicsState()

let png = rep.representation(using: .png, properties: [:])!
let out = URL(fileURLWithPath: "scripts/dmg-background.png")
try! png.write(to: out)
print("✅ \(out.path) を生成しました (\(rep.pixelsWide)x\(rep.pixelsHigh)px, 144dpi)")
