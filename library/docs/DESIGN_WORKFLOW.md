# Nano Banana Design Workflow

Nano Banana（Gemini 3.0ベース）を使用したデザインワークフローガイド。

---

## 1. ワークフロー概要

```
PRP作成 → Designer → Nano Banana → モックアップ生成 → resources/mockups/ に保存
```

---

## 2. Designer エージェントへの指示例

```
あなたは Designer です。
PRPを読み、Nano Banana を使ってUIモックアップを生成してください。

# TASK
docs/PRP.md のデザイン要件を分析し、以下を生成：
1. ホームページのモックアップ
2. 主要ページのワイヤーフレーム
3. カラーパレットとタイポグラフィ

# OUTPUT
- resources/mockups/ に画像を保存
- docs/design_system.md にデザインシステムを記載

# DESIGN GUIDELINES
- モバイルファースト
- カラー: [要件に基づく]
- トーン: [信頼感 / モダン / 温かみ など]
```

---

## 3. Nano Banana プロンプト例

### ホームページモックアップ

```
Create a modern, clean homepage mockup for an education website about 
studying abroad in Malaysia. 

Design requirements:
- Color scheme: Blue and green, conveying trust and tropical openness
- Mobile-first responsive design
- Hero section with compelling headline
- Navigation: Home, Why Malaysia, Education, Areas, Visa, Finance
- Modern typography, clean layout
- Include call-to-action button

Style: Professional, welcoming, Japanese/Korean target audience
```

### カラーパレット生成

```
Generate a cohesive color palette for an education abroad website:
- Primary: Trust-inspiring blue
- Secondary: Fresh tropical green  
- Accent: Warm coral for CTAs
- Neutral: Clean grays for text

Show color swatches with hex codes, suitable for web design.
```

---

## 4. 画像の保存方法

生成された画像は以下の構造で保存：

```
resources/
└── mockups/
    ├── homepage.png
    ├── about.png
    ├── color_palette.png
    └── components/
        ├── header.png
        ├── footer.png
        └── cards.png
```

---

## 5. Design System ドキュメント

`docs/design_system.md` に記載する内容：

```markdown
# Design System

## Colors
- Primary: #2563EB (Blue)
- Secondary: #10B981 (Green)
- Accent: #F59E0B (Amber)

## Typography
- Headings: Inter, Bold
- Body: Inter, Regular
- Size Scale: 14px, 16px, 18px, 24px, 32px, 48px

## Spacing
- Base unit: 4px
- Scale: 4, 8, 12, 16, 24, 32, 48, 64

## Components
- [See resources/mockups/components/]
```

---

*See: [agents.json](../config/agents.json) - Designer エージェント定義*
