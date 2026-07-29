---
title: "Oh My Claude Code - Claude Codeを「チーム」として使うプラグイン"
date: 2026-01-21T22:03:59+09:00
draft: false
toc: false
images:
tags:
  - claude-code
  - agentic-dev
  - vibe-coding
  - plugins
  - oh-my-claudecode
---

> “Don’t learn Claude Code. Just use OMC.”（Claude Codeを学ぶな。OMCを使え。）– *oh-my-claudecode* README[^github]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

oh-my-claudecode（OMC）は、Claude Codeに「マルチエージェント・オーケストレーション」を載せるプラグインです。[^github] ユーザーがサブエージェント、スキル、フックといった概念を一つずつ学習しなくても、**自然言語のリクエストを手がかりに必要な振る舞い（計画／並列化／継続実行／リサーチ／デザイン感覚）を自動で有効化する** ことを目指しています。

本稿は、OMCについて「何を解決しようとするプラグインなのか」「なぜClaude Codeでこの方式が合理的なのか」「どのようなワークフローで特に強いのか」を一度に読み通せる形にまとめた技術レポートです。

**[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)**

---

## TL;DR

- OMCは、Claude Codeのサブエージェント、スキル、フックを束ね、自然言語のリクエストだけで必要な作業モードを自動的に組み合わせるプラグインです。
- 中核的な価値は、コマンド学習の負担を減らし、計画・並列化・リサーチ・デザイン感覚といったワークフローをClaude Codeの中で自然に有効化する点にあります。
- 特に、複雑な開発作業を役割ごとに分割し、最後までやり切る必要がある場面で生産性を高めてくれます。

## 1. プロジェクト概要

OMCが掲げる一行の要約は「Multi-agent orchestration for Claude Code. Zero learning curve.」です。[^github] 要点は二つあります。

1. **自動委任（delegation-first）**：「複雑な作業だ」と言えば、設計／リサーチ／実行／QAといった専門的な役割に分割して並列に走らせます。
2. **自動モード切り替え**：「plan this」「don't stop until done」といった表現を検知し、計画インタビューや継続実行（完了保証）の性向をオンにします。

リポジトリが公開している「Under the hood」構成図は、OMCが単なるプロンプト集ではなく、Claude Codeの拡張ポイント（agents／skills／hooks／statusline）を束ねて **実運用のワークフロー** に仕立てたパッケージであることを示しています。[^github]

---

## 2. インストールと利用の流れ（本当に30秒）

READMEに基づく利用の流れはシンプルです。[^github]

```text
/plugin marketplace add https://github.com/Yeachan-Heo/oh-my-claudecode
/plugin install oh-my-claudecode
/oh-my-claudecode:omc-setup
```

インストール後は「コマンドを覚える」のではなく、普段どおりに仕事を任せるだけです。OMCが文中のヒントを読み取り、内部で適切なスキルやサブエージェントを組み合わせます。[^github]

---

## 3. なぜ「スキル合成」が核心なのか

OMCが興味深いのは、「Claude Codeの制約」を正面から受け入れているからです。Claude Codeは、会話の「マスター」を別のエージェントに差し替える方式ではなく、**固定されたマスターにスキルを注入（inject）する方式で振る舞いを変えます**。[^arch]

OMCはこの構造を「レイヤー」として整理します。[^arch]

```text
[Execution Skill] + [0-N Enhancement Skills] + [Optional Guarantee]
```

たとえば「UI作業＋複数ファイルの修正＋コミットまで」が必要な場合は、実行（基本）レイヤーの上に`frontend-ui-ux`や`git-master`といった補強レイヤーを重ねる、という具合です。[^arch] つまり、モードを「乗り換える」のではなく **振る舞いを「重ね着する」方式** なので、文脈が途切れません。

---

## 4. パワーユーザーのための「マジックキーワード」

ほとんどは自動ですが、必要ならキーワードで強制することもできます。[^github]

| キーワード | 効果 |
| --- | --- |
| `ralph` | 完了するまで止まらない継続実行 |
| `ralplan` | 合意を形成しながら反復的に計画 |
| `ulw` | 最大限の並列実行（ultrawork） |
| `plan` | 計画インタビューの開始 |
| `autopilot` / `ap` | 自律実行フロー |

そして止めたいときは「stop/cancel/abort」のように言えば、文脈に合わせて中断します。[^github]

---

## 5. OMCが提供する「パッケージ」の構成

公式ドキュメントによれば、OMCは大きく次のものを一度に提供します。[^github][^full]

- **特化エージェントのセット（27個）**：architect、researcher、designer、writer、critic、planner、qa-testerなどの役割群（ティア別のバリエーションを含む）[^github]
- **スキルのセット（28個）**：orchestrate、ultrawork、ralph、planner、git-master、frontend-ui-ux、learnerなど[^github]
- **HUD Statusline**：オーケストレーションの進行状況をClaude Codeのステータスバーに要約表示[^github]
- **メモリ／ノートシステム**：コンテキストのコンパクション後も重要な情報を残そうとする3階層メモリの構想（優先度／作業メモリ／手動ノート）[^full]

具体的な内部動作とルーティングの哲学は、`docs/ARCHITECTURE.md`で「スキルベースのルーティングをいかにオペレーティングシステムのように作るか」という観点から説明されています。[^arch]

---

## 6. どんなときに特に有用か／トレードオフは何か

OMCは特に次のような状況で光ります。

1. **マルチファイル・マルチ役割の作業**：設計・実装・検証を同時に進める必要がある機能開発
2. **コンテキストが頻繁に崩れる長期セッション**：ノートやメモリで「忘れてはならないこと」を残すパターン
3. **計画は必要だが時間はかけたくないとき**：「plan」の一言で計画インタビューを強制する流れ

逆に、明確なコストもあります。

1. **トークン・時間・コストの増加**：並列化と補強スキルは、基本的により多くの呼び出しと思考を誘発します。
2. **自動化の不透明さ**：「なぜ今この行動をしたのか」がすぐには理解できないことがあります。
3. **プラグイン運用のリスク**：自律実行が強力であるほど、権限やガードレール（コマンドの中断、範囲の制限）により敏感になります。

---

## 7. おわりに

oh-my-claudecodeは「Claude Codeをうまく使うコツ」を超えて、**Claude Codeをチームのように使うためのデフォルト値のセット** を提供します。[^github] スキル合成というClaude Codeの構造を正面から活用し、ユーザーは自然言語で指示し、システムは自ら計画・並列・完了保証を組み立てます。Claude Codeを「ツール」ではなく「運用環境」として捉える人であれば、OMCはかなり説得力のある出発点になるでしょう。

---

## 参考資料

- [Yeachan Heo, *oh-my-claudecode* (GitHub)](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [oh-my-claudecode, *ARCHITECTURE*](https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/ARCHITECTURE.md)
- [oh-my-claudecode, *Full Reference Documentation*](https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/FULL-README.md)
- [Anthropic, *Claude Code Docs*](https://docs.anthropic.com/claude-code)

[^github]: https://github.com/Yeachan-Heo/oh-my-claudecode
[^arch]: https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/ARCHITECTURE.md
[^full]: https://github.com/Yeachan-Heo/oh-my-claudecode/blob/main/docs/FULL-README.md
