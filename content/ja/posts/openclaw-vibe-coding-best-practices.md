---
title: "OpenClaw：世界最大のバイブコーディングプロジェクトから学ぶ9つのベストプラクティス"
date: 2026-03-14T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - openclaw
  - best-practices
---

> 「かつてチームを率いていたことがある。私の下には多くのソフトウェアエンジニアがいた。あのときも、彼らが私の望むやり方とまったく同じコードを書くわけではないという点を受け入れなければならなかった」 – Peter Steinberger[^3]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

OpenClawはGitHubで最も多くのスターを集めたソフトウェアリポジトリ（31万以上のスター）であり、大規模なAI支援「バイブコーディング」の決定的なケーススタディです。[^1] オーストリアの開発者Peter Steinbergerが3〜8個の並列AIエージェントインスタンスを活用して構築したこのプロジェクトは[^2]、たった1人の開発者が30万LOC規模のTypeScriptモノレポ、20以上のメッセージング統合、3つのプラットフォーム向けネイティブアプリをオーケストレーションできることを示しています。しかも、コードのほとんどを自分では読まずに、です。[^3]

このプロジェクトの名前は、激動の過程を経てきました。2025年11月、AnthropicのClaudeをベースに1時間で作られたプロトタイプ **Clawdbot** が始まりでした。2026年1月にGitHubで公開されると1日で9,000スターを集めて爆発的に成長しましたが、Anthropicの商標権に関する警告を受けて **Moltbot** に改名せざるをえませんでした。続いて、なりすましアカウントや悪意あるnpmパッケージなどのセキュリティ事故が起きたことで、わずか3日後に再び **OpenClaw** へと名前を変えました。[^16] 2026年2月、SteinbergerはOpenAIに加わって「次世代のパーソナルエージェント」を率いることになり、OpenClawはOpenAIが支援する独立財団へ移管されました。[^17]

皮肉なことに、Steinberger本人は「vibe coding」という表現を蔑称だと呼び「agentic engineering」を好むのですが[^5]、OpenClawはこの潮流を代表するプロジェクトになりました。[^6] この記事では、OpenClawのリポジトリ構造、ワークフロー、コミュニティ運営のあり方を分析し、そこから抽出した実践可能なベストプラクティスを整理します。

## TL;DR

- OpenClawは、1人の開発者が複数のAIエージェントを調律して大規模なTypeScriptモノレポとネイティブアプリを運営した、代表的なバイブコーディングの事例です。
- 中核となるパターンは、生きている`AGENTS.md`、明確なPR規範、自動化された品質ゲート、並列エージェントの調整ルールです。
- バイブコーディングの熟練は、コードを自分で多く書く能力よりも、コードを書くシステムを設計し統制する能力へと移っていきます。

---

## 1. OpenClawは実際に何をするのか

OpenClawは**セルフホスト型のパーソナルAIアシスタント**であり、メッセージングプラットフォームを大規模言語モデルにつなぎます。ChatGPTやClaudeのWebインターフェースとは違い、OpenClawはユーザーのローカルマシンで動作し、ユーザーがすでに使っているチャネルと接続します。WhatsApp、Telegram、Discord、Slack、Signal、iMessage、Microsoft Teams、Matrix、LINEなど15以上のチャネルをサポートしています。READMEはこれを簡潔にこう説明します。*"あなたのデバイス上で直接動くパーソナルAIアシスタント。"*[^7]

アーキテクチャの中心にあるのは、ローカルの**Gatewayデーモン**です。これはポート18789で動作するWebSocketベースのコントロールプレーンで、入ってきたメッセージをそれぞれ独立したAIエージェントへルーティングします。各エージェントは自分だけのワークスペース、メモリ、そしてMarkdownファイル（`SOUL.md`、`MEMORY.md`、`USER.md`）で定義された個性を持ちます。[^8] エージェントは単に会話するだけではありません。シェルコマンドの実行、CDPを通じたブラウザ制御、スケジュール管理、cronジョブの実行、ハートビートシステムによる能動的な連絡まで行います。[^9] **ClawHub**というスキルマーケットプレイスには、1,700以上のコミュニティ製の拡張が登録されています。[^10]

技術スタックはTypeScriptベースの **pnpmモノレポ**（Node.js 22以上）で、Swift（macOS/iOS）とKotlin（Android）で書かれたネイティブのコンパニオンアプリを含みます。テストはVitestとV8カバレッジ70%以上を基準に運用されています。[^4]

---

## 2. リポジトリに表れるAI支援開発の痕跡

バイブコーディングの最も明確な証拠は、コミット履歴にあります。初期にはAnthropicのClaude Codeで開発されていたため、コミットに **「claude」が共同作成者（co-author）** として頻繁に登場します。しかしSteinbergerが2026年2月にOpenAIに加わって以降は、`codex/issue-issue-41258-20260312044119`のような **OpenAI Codexエージェントが自律的に生成したブランチ** が目立って増えました。1つのリポジトリにClaudeとCodex、2つのAIコーディングエージェントの痕跡が共存しているわけです。READMEはむしろこう明記しています。**"AI/vibe-coded PRs welcome!"**[^7]

Steinberger個人のワークフローはとくに印象的です。彼は **Codex CLIのインスタンスを3〜8個、3x3のターミナルグリッドで同時に実行**しており、そのほとんどは別々のワークツリーではなく同じフォルダで作業しています。[^2] 各エージェントは`AGENTS.md`のルールに導かれてアトミックなコミットを作ります。彼は **2026年1月の1か月だけで6,600以上のコミット**を残しましたが、見かけ上は20人規模のチームの速度でも、実際には1人とAIエージェントたちの組み合わせです。[^3] プロンプトは時が経つほど短くなっており、いまでは通常1〜2文とスクリーンショット1枚で十分で、スクリーンショットが入力の約50%を占めています。[^11]

`CONTRIBUTING.md`は、コミュニティがAI支援のPRをどう扱うべきかを規範化しています。[^12]

- PRのタイトルまたは説明にAIの使用有無を明示すること
- テストの水準を明記すること（未テスト／軽くテスト済み／十分にテスト済み）
- 可能ならプロンプトまたはセッションログを含めること
- 生成されたコードが何をするのかを理解していることを確認すること

文書はこう締めくくられます。*"ここではAIのPRを一級市民として扱う。ただ、レビュアーがどこを重点的に見るべきかわかるように透明性がほしいだけだ。"*[^12]

---

## 3. AGENTS.mdとCLAUDE.mdの設定パターン

OpenClawのリポジトリで最も再現可能性の高いイノベーションは、**`AGENTS.md`ファイル**です。[^4] これはコードベースで作業するすべてのAIコーディングエージェントのための包括的な指示文書です。`CLAUDE.md`は同じファイルを指すシンボリックリンクで、Claude CodeとCodex系のエージェントが同一の指示を読むことを保証します。ルールも明確です。*"リポジトリのどこであれ新しい`AGENTS.md`を追加するときは、必ずそれを指す`CLAUDE.md`のシンボリックリンクも一緒に追加すること。"*[^4]

このファイルは、AIエージェントのための組織的記憶装置として機能します。Steinbergerはこれを **「組織の傷跡が蓄積された痕跡（organizational scar tissue）の集まり」** と表現しますが、それは何かがうまくいかないたびにCodex自身が段階的に内容を追加してきたからです。[^11] 中核となるセクションは次のとおりです。

- **ビルドおよびテストのコマンド**：`pnpm build`、`pnpm check`、`pnpm test`、高速な型チェック用の`pnpm tsgo`のように正確に明示
- **Gitの規約**：`fix(telegram):`、`feat(skills):`のようなサブシステムスコープを含むConventional Commitsの強制、push前の`git pull --rebase`の要求
- **マルチエージェントの安全ルール**：git stashを作成／適用／削除しないこと、要求されない限りブランチを変えないこと、認識していない変更を見つけたら別のエージェントが作業中だと仮定して作業を続けること
- **チェンジログのルール**：ユーザーにとって意味のある項目だけをセクションの末尾に追加、外部コントリビューターの表記は`Thanks @author`パターン
- **セキュリティ境界**：実際の電話番号、本番環境の設定値、動画ファイルのコミット禁止

より広いコミュニティの次元では、**自動コードレビューが必須**です。GitHub Codexのレビューが自動的に実行されない場合、コントリビューターはローカルで`codex review --base origin/main`を実行し、その結果を必須のレビュー作業として扱わなければなりません。[^12]

---

## 4. 大規模運用におけるPRパターンと自動化

OpenClawはおよそ **1日14件の新規PR** を処理しており、任意の時点で5,500件以上のオープンPRと19,000件以上のクローズ済みPRが存在します。[^13] この規模のボリュームは強力な自動化を要求します。リポジトリには合計 **58個のラベル** があり、コンポーネント（`agents`、`cli`、`gateway`、`docker`）、チャネル（`channel: telegram`、`channel: discord`、`channel: whatsapp-web`）、種類（`docs`、`enhancement`、`bug`）別に分かれています。[^8]

レビュープロセスには複数のボットが参加します。**openclaw-barnacle** ボットは自動ラベリングと自動応答を担当し、**Greptile-apps** は自動コード分析を、**aisle-research-bot** はレビューコメントを残します。`.github/workflows/auto-response.yml`ワークフローは、特定のパターンに一致するイシュー（TestFlightの要請、サードパーティ拡張の提案、スパムなど）を自動的にクローズしてロックします。[^13]

`VISION.md`は強い制限を課します。**1つのPRは1つのイシュー／トピックだけを扱うこと**、関連のない修正を束ねないこと、そしておよそ5,000行以上変わるPRは例外的な場合にのみレビューする、というものです。[^14] CIパイプラインにはメインのテストスイート、インストールのスモークテスト、ワークフローの健全性検査、自動ラベラーが含まれ、カバレッジ基準は **行、ブランチ、関数、ステートメントのすべてで70%以上** を要求します。[^4]

---

## 5. バイブコーディングのワークフローから抽出した9つのベストプラクティス

OpenClawの公式 **Vibe Codingスキル**（ClawHubで1,700以上のスター）は、この方法論をルール化された形で整理しています。[^15] ここにSteinbergerの公開されたワークフローとリポジトリの実際の慣行を組み合わせると、最も実践的なパターンは次のようになります。

### 5.1 生きている`AGENTS.md`ファイルを維持する

最も影響力の大きい実践です。段階的に書きましょう。AIエージェントがミスをするたびにルールを追加すればよいのです。ツールの互換性のために`CLAUDE.md`へシンボリックリンクを張りましょう。Steinbergerのファイルは約300行の長さで、gitの規約、テストコマンド、アーキテクチャパターン、ファイル長の制限（約500 LOC）、マルチエージェントの調整ルールまで含んでいます。これは口伝の知識を、機械が読める制度的記憶へと変えます。[^4][^11]

### 5.2 Research → Plan → Implement のワークフローを使う

実装の前に、AIにまず既存のコードを探索させましょう。たとえば「authモジュールを読んで、セッションがどう動くのか説明して」と指示します。次に計画を提案させます。「修正するファイルと、各ファイルで変わる内容を書き出して」と指示するのです。計画を検討したうえで、はじめて実装へ進みます。*"計画段階で誤解を捕まえるコストは、連鎖したエラーをデバッグするより10倍安い。"*[^15]

### 5.3 サブシステムスコープを含むConventional Commitsを強制する

`type(scope): description`というパターン、たとえば`fix(telegram): resolve TypeError in status command`のような形式は、AIエージェントが理解でき、自動チェンジログ生成も可能な、機械解釈可能な履歴をつくります。コミッターのヘルパースクリプトを使い、ステージングが意図したファイルだけに限定されるようにしましょう。[^4]

### 5.4 AIエージェントを、管理対象のジュニアエンジニアのように扱う

Steinbergerの中核となる比喩です。人間の努力は**システムアーキテクチャ**と**趣味（taste）**、すなわち動く解法と優雅な解法を見分ける能力に集中すべきです。実装、ボイラープレート、リファクタリングはエージェントに任せましょう。[^3]

### 5.5 明示的な調整ルールとともに並列エージェントを運用する

複数のエージェントは同じフォルダでも同時に作業できます。ただし、`AGENTS.md`に次のことが明確に書かれている必要があります。修正の前に`git status`と`git diff`を確認すること、アトミックなコミットを作ること、stashに触れたりブランチを変えたりしないこと、理解できない変更を見ても別のエージェントの作業とみなして進めること。こうしてはじめて「バイブコーディング」は1人プレイではなく、マルチプレイのオーケストレーション問題へと変わります。[^4][^2]

### 5.6 AIのPRを、透明性が保証された一級市民として扱う

コントリビューターに、AIツールの使用有無の開示、テスト水準の明記、プロンプトやセッションログの添付、生成されたコードへの理解の確認を求めましょう。これは参入障壁を立てる行為ではありません。微妙なAI生成のバグが潜んでいる可能性が高い箇所にレビュアーが集中できるよう、必要な文脈を提供する仕事です。[^12]

### 5.7 趣味（taste）を必要としないものは、すべて自動化する

OpenClawは自動ラベリング、自動応答ワークフロー、自動コードレビューのボット、staleイシューの管理、シークレット検出、デッドコード分析、重複検査まで使っています。人間の役割はアーキテクチャと品質の判断です。それ以外は自動化するか、エージェントに委譲すべきです。[^13]

### 5.8 いつ介入し、いつ流れに任せるかを見分ける

スキャフォールディング、UIコンポーネント、ボイラープレート、探索的な作業はAIに任せましょう。一方、**認証、決済、データ処理、データベーススキーマ、APIの権限、そしてセキュリティに接するすべて**は手動の介入が必要です。そして、あらゆる変更のあとには必ずテストしましょう。AIは「見かけは完璧だが微妙なバグがある」コードを作り出します。[^15]

### 5.9 プロンプトに制約条件をアンカー（固定）する

明示的な境界を与えましょう。行数の制限（「50行以下」）、出力形式の制限（「ファイル全体ではなく、修正した関数だけ」）、範囲の固定（「決済フローだけ、authには触れないこと」）、スタイルの指示（「`UserService.ts`の既存パターンに従うこと」）といった制約です。曖昧なプロンプトは曖昧な結果を生みます。[^15]

---

## 結論

OpenClawのリポジトリは、本番規模のバイブコーディングがエンジニアリングの規律を捨てることではなく、それを**再配置すること**だと示しています。このプロジェクトの1,200人以上のコントリビューター、19,000件以上のマージ済みPR、18,000件以上のコミットは、大規模なソフトウェアプロジェクトを可能にするまさにその原則で運営されています。明確な規約、自動化された強制、構造化されたコミュニケーション、明示的な境界がそれです。

イノベーションは *誰が実行するか* にあります。AIエージェントが実装を担い、人間はアーキテクチャ、趣味（taste）、調整を担います。**「組織の傷跡が蓄積された痕跡」** を積み上げていく、生きた段階的な指示ファイルという`AGENTS.md`（`CLAUDE.md`）のパターンは[^11]、最も移植しやすい実践方法です。

Steinbergerが詳細な仕様書（2025年6月）から、スクリーンショット中心の短いプロンプト（2025年後半）へ、さらに最小限の監督で3〜8個の並列エージェントを回す段階（2026年）へと移っていった軌跡は、すべてのバイブコーダーがたどることになる学習曲線を示しています。[^2] 教訓は、コードが重要でないということではありません。ソフトウェアエンジニアリングの重心が移動したということです。コードを自分で書く熟練から、コードを書くシステムを設計する熟練へ。300行の`AGENTS.md`を蓄積し、70%のカバレッジ基準線を立て、マルチエージェントの衝突ルールを設計する仕事は、レンガを積む仕事ではなく建築をする仕事です。そしてその建築もまた、簡単には得られない熟練を要求します。

---

[^1]: GitHub Repository — openclaw/openclaw: https://github.com/openclaw/openclaw
[^2]: Peter Steinberger, "Shipping at Inference-Speed": https://steipete.me/posts/2025/shipping-at-inference-speed
[^3]: The Pragmatic Engineer, "The creator of Clawd: I ship code I don't read": https://newsletter.pragmaticengineer.com/p/the-creator-of-clawd-i-ship-code
[^4]: AGENTS.md (AI agent guide): https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^5]: TechSpot, "OpenClaw creator says vibe coding is a slur against AI-assisted development": https://www.techspot.com/news/111468-openclaw-creator-vibe-coding-slur-against-ai-assisted.html
[^6]: Fortune, "Who is OpenClaw creator Peter Steinberger?": https://fortune.com/2026/02/19/openclaw-who-is-peter-steinberger-openai-sam-altman-anthropic-moltbook/
[^7]: README.md: https://github.com/openclaw/openclaw/blob/main/README.md
[^8]: DeepWiki architecture analysis — openclaw/openclaw: https://deepwiki.com/openclaw/openclaw/8-channels
[^9]: OpenClaw official documentation: https://docs.openclaw.ai
[^10]: Milvus Blog, "What Is OpenClaw? Complete Guide to the Open-Source AI Agent": https://milvus.io/blog/openclaw-formerly-clawdbot-moltbot-explained-a-complete-guide-to-the-autonomous-ai-agent.md
[^11]: Peter Steinberger, "Just Talk To It — the no-bs Way of Agentic Engineering": https://steipete.me/posts/just-talk-to-it
[^12]: CONTRIBUTING.md: https://github.com/openclaw/openclaw/blob/main/CONTRIBUTING.md
[^13]: Pull Requests — openclaw/openclaw: https://github.com/openclaw/openclaw/pulls
[^14]: VISION.md: https://github.com/openclaw/openclaw/blob/main/VISION.md
[^15]: OpenClaw official Vibe Coding skill (ClawHub): https://playbooks.com/skills/openclaw/skills/vibe-coding
[^16]: TechCrunch, "OpenClaw creator Peter Steinberger joins OpenAI": https://techcrunch.com/2026/02/15/openclaw-creator-peter-steinberger-joins-openai/
[^17]: Peter Steinberger, "OpenClaw, OpenAI and the future": https://steipete.me/posts/2026/openclaw
