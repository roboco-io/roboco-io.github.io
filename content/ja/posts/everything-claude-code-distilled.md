---
title: "Everything Claude Code — ハッカソン優勝者のAI開発チームレシピ"
date: 2026-01-20T09:30:07+09:00
draft: false
toc: false
images:
tags:
  - claude-code
  - vibe-coding
  - agentic-dev
---

> 「AIをチームとして迎え入れるには、ツールよりもプロセスを先に設計しなければならない。」– Anthropic x Forum Venturesハッカソン優勝者 Affaan Mustafa

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

Everything Claude Codeは、Claude Code CLIを**仮想的な開発チーム環境**へと変貌させる設定集です。ハッカソン優勝者が10か月にわたって実際のスタートアップ製品を作りながら磨き上げたレシピが1つの公開リポジトリに集約されており、これを適用するとClaudeを「シニアエンジニア＋QA＋アーキテクト」として呼び出せます。[^tilnote] リポジトリはGitHubで誰でも確認できます。

**[Everything Claude Code](https://github.com/affaan-m/everything-claude-code)**

本稿は、リポジトリの構造、Claude APIの活用方式、技術スタック、そしてハッカソン優勝につながった差別化要素を一望できるようにまとめた技術レポートです。最後には現時点での限界と改善のアイデアも添えました。

---

## TL;DR

- Everything Claude Codeは、Claude Code CLIを役割分担された仮想的な開発チームのように運用するための設定集です。
- エージェント、スキル、スラッシュコマンド、ルール、フックを組み合わせて、計画・TDD・レビュー・ドキュメント化を反復可能なフローに仕立てます。
- 核心は、ツールをたくさん付け足すことではなく、必要な文脈とガードレールだけを有効にしてClaudeが安定して働けるようにすることです。

---

## 1. プロジェクト概要

Everything Claude Codeは、「Claudeを多役割のエージェントチームとして運用せよ」という明確な哲学のもとで設計されています。[^tilnote] メインセッションがプロジェクトマネージャーの役割を担い、細かな作業はさまざまなサブエージェントが並列で遂行します。作者はこの構成で2025年9月のAnthropic x Forum Venturesハッカソンにおいて、**zenith.chat**を完全にClaude Codeだけで開発して優勝したという実践事例も共有しています。[^github]

中核となる価値提案は3つです。

1. **役割分離**: 役割ごとにプロンプト、ツール権限、トーンを分離してLLMの集中度を高めます。
2. **プロセスの標準化**: `/plan`、`/tdd`、`/code-review`といったスラッシュコマンドで開発ルーティンを自動化します。
3. **品質のガードレール**: ルール・スキル・フックを組み合わせてセキュリティ、テスト、スタイルを強制します。

この哲学を土台に、リポジトリ全体が「AIがプロジェクトの履歴を学習し、ツールを自ら実行する」完成形の開発パイプラインを構成しています。

---

## 2. リポジトリの構造とアーキテクチャ

リポジトリは、Claude Codeに必要な文脈を役割ごとのフォルダに分けて管理しています。実際の利用者は、必要なファイルを自分の`~/.claude`、あるいはプロジェクトルートの`.claude`にコピーして有効化します。

### 2.1 Agents

`agents/`は役割特化型プロンプトの集まりです。`planner`、`architect`、`code-reviewer`、`security-reviewer`、`tdd-guide`、`build-error-resolver`、`e2e-runner`、`refactor-cleaner`、`doc-updater`などが代表的です。[^github] 各ファイルはYAMLフロントマターでモデル（`opus`）、許可ツール（`Read`、`Grep`、`Bash`など）、説明を定義し、本文には役割ごとの指針を収めています。**ツールを最小化**して集中度を高め、エージェント間の役割衝突を防ぐことが設計の中心的な視点です。

### 2.2 Skills

`skills/`はチームで共有する業務マニュアルです。`coding-standards.md`、`backend-patterns.md`、`frontend-patterns.md`、`security-review/`、`tdd-workflow/`などが含まれます。[^github] 特に`tdd-workflow`はRED→GREEN→REFACTORのループとカバレッジ80%という要件を詳細に明示しており、Claudeがテスト駆動開発を自動的に思い出すようにしています。スキルは全社共通（`~/.claude/skills`）とプロジェクト専用（`.claude/skills`）に分けて運用できます。

### 2.3 Commands

`commands/`には`/plan`、`/tdd`、`/e2e`、`/code-review`、`/build-fix`、`/refactor-clean`、`/test-coverage`、`/update-docs`などのスラッシュコマンド用プロンプトがあります。[^github] ユーザーがチャット欄でコマンドを入力するだけで、その手順に沿ったプロンプトが読み込まれ、必要なスキルやエージェントが呼び出されます。おかげで「機能の計画 → TDDの実行 → コードレビュー → ドキュメント同期」といった一連の開発フローをボタンのように実行できます。

### 2.4 Rules

`rules/`は常に適用されるガードレールです。`security.md`、`coding-style.md`、`testing.md`、`git-workflow.md`、`agents.md`、`performance.md`、`patterns.md`、`hooks.md`などにモジュール化されており、Claude Codeはこのフォルダのすべてのルールをシステムプロンプトへ自動的に挿入します。たとえば`testing.md`は「カバレッジ80%未満のPRは禁止」というルールを明示し、モデルがテストの省略を許さないようにしています。

### 2.5 Hooks

`hooks/hooks.json`は、Pre/Post ToolUseのタイミングで実行する自動化スクリプトを定義します。例としては、TypeScriptファイルの編集後に`console.log`が残っていれば警告するフックや、セッション終了前にフォーマッターを走らせるフックなどがあります。[^github] フックマッチャーでツール名やファイルパターンを指定し、Bashコマンドや追加コマンドを実行するように構成します。反復的なミス（デバッグコードの放置、テストの漏れなど）を自動で監視するセーフティネットの役割を果たします。

### 2.6 MCP設定

`mcp-configs/`は、GitHub、Supabase、Vercel、Railway、ClickHouseなど多数のMCPサーバー設定テンプレートを提供します。[^tilnote] ユーザーは必要な項目を`~/.claude/settings.json`に貼り付けてAPIキーを埋めれば、Claudeが直接それらのサービスAPIを呼び出せるようになります。READMEは「有効なMCPはプロジェクトあたり10個以下、ツール全体は80個以下」というガイドも示しています。過剰なMCPの有効化はコンテキストウィンドウを侵食し、モデルの性能を落とすためです。

### 2.7 Plugins & Examples

`plugins/`は、Claude Skills Marketplaceと外部プラグインのインストール方法を案内する文書群です。`examples/`フォルダにはプロジェクトレベル（`CLAUDE.md`）とユーザーレベル（`user-CLAUDE.md`）の設定例、カスタム`statusline.json`などが含まれており、新規ユーザーはそのままコピーして始められます。結果としてリポジトリ全体が「リファレンス実装＋テンプレート」の役割を兼ねています。

---

## 3. Claude API活用の原則

Everything Claude Codeが強調するAI活用の原則は、次の4つに要約できます。

1. **マルチエージェントの並列化**  
   メインセッションが大きな方向性を定め、細部の作業はサブエージェントが委譲を受けて遂行します。各エージェントは自分のドメイン文脈だけを扱うため、応答の品質と速度が安定して保たれます。[^tilnote]

2. **TDD・テストファースト**  
   `/tdd`コマンドと`tdd-workflow`スキルによってRED→GREEN→REFACTORのサイクルを強制し、`testing.md`ルールでカバレッジ80%以上を要求します。Claudeは機能リクエストを受け取ると、常にテスト追加の必要性を想起させます。

3. **セキュリティ・品質のガードレール**  
   `security.md`は秘密鍵のハードコーディング禁止、入力検証、エラー処理、脆弱なライブラリの検査などを明文化しています。`/code-review`コマンドと`code-reviewer`エージェントは、AIが書いたコードを再びAIがレビューするようにして自己精製ループを形成します。

4. **コンテキスト予算の管理**  
   MCP・ルール・スキル・ツールが増えるほどシステムプロンプトは肥大化するため、READMEは「必要な設定だけを有効化すること」を繰り返し強調しています。[^github] プロジェクトごとに最小構成として集中力を保つことが、Claude活用の効率を決めます。

これらの原則があるからこそ、Claude Codeは単なるコード自動補完ツールではなく、**プロンプトエンジニアリング＋ワークフローエンジン**として機能します。

---

## 4. 使用技術スタックとツールチェーン

Everything Claude Code自体はMarkdown・JSONベースの設定集ですが、その背景には次のようなスタックが敷かれています。

- **Anthropic Claude Code CLI**: システムプロンプトを組み立て、LLMとツール呼び出しを仲介するランタイムです。最新のOpus/Sonnetモデルをサポートします。
- **MCPサーバー群**: GitHub、Supabase、Vercel、Railway、ClickHouseなど主要SaaS向けのMCPテンプレートを提供し、Claudeが直接APIを呼び出せるようにします。[^tilnote]
- **テスト＆品質ツール**: `/e2e`コマンドはPlaywrightの実行を前提に設計されており、`testing.md`はJest/VitestなどのJSテスティングスタックを内包しています。`/build-fix`はNode/Viteのビルドエラーを扱えるように書かれています。
- **フロントエンド/バックエンドのパターン**: `frontend-patterns.md`にはReact/Next.jsの指針、`backend-patterns.md`にはAPI・DB・キャッシュのベストプラクティスが整理されています。`clickhouse-io.md`のように特定のデータ技術に関するスキルも存在します。

つまり、リポジトリは「言語/フレームワーク中立」を標榜しつつも、第一のターゲットは**TypeScriptベースのフルスタックWeb製品**です。他の言語やドメインで使うには、追加のスキルを書く必要があります。

---

## 5. ハッカソン優勝につながった差別化要素

ハッカソンでEverything Claude Codeが発揮した競争力は、5つに整理できます。

1. **役割の並列化**: 設計・実装・テストを異なるエージェントが同時に処理し、開発のボトルネックを減らしました。
2. **標準化された開発ルーティン**: `/plan → /tdd → /code-review → /update-docs`の順序が自動化され、機能ごとのサイクルが短く一定でした。
3. **フルスタックの自動化**: MCPのおかげでClaudeがGitHubのIssue、Supabaseのクエリ、Vercelのデプロイなどを直接実行し、人間は製品ロジックだけに集中できました。[^medium]
4. **フックによる安全装置**: console.logの除去やテスト漏れの警告といったフックがミスを早期に捕まえ、品質を維持しました。
5. **実戦で検証されたノウハウ**: 作者が実務で繰り返し検証したプロンプトやルールを収めているため、「一度使ってみた程度の洞察」ではなく「磨き上げられたフレームワーク」でした。

この組み合わせのおかげで、短時間でも高い品質を保つ「AI主導のチーム」が実現し、それがハッカソンでの差別化要素として機能しました。

---

## 6. 技術的な限界と改善の方向性

いかに完成度が高くとも、解決すべき課題は依然として存在します。

1. **コンテキストウィンドウの限界**  
   MCP・ルール・スキルを過度に有効化すると、Claudeが使えるトークンが減り、長時間セッションで文脈の欠落が生じます。動的なコンテキスト読み込みや、必要な時点ごとに設定を差し替える機能が今後の補完ポイントです。

2. **モデルのコストと可用性**  
   Opusモデルは遅く、コストも高くなります。利用量が増えるほど負担が大きくなるため、Sonnetや他モデルへの自動フォールバック戦略が必要です。Anthropic以外のモデルを差し込める抽象化レイヤーも検討に値します。

3. **オンボーディングの難度**  
   エージェント・スキル・フックの概念をすべて理解する必要があるため、初期の学習曲線が急です。対話型の設定ウィザードやGUIベースの設定管理があれば、導入の障壁を下げられます。

4. **ドメインの偏り**  
   現在のスキルはJS/TSのWebサービスに最適化されています。組み込み、データサイエンス、モバイルなど他ドメイン向けのスキル/コマンドをコミュニティが追加し続けてこそ、汎用フレームワークになります。

5. **実行の安全性**  
   Bash権限を与えられたエージェントが誤ったコマンドを実行するリスクは依然として残ります。コマンドの2段階承認、サンドボックスモード、`/dry-run`コマンドといった保護装置が今後必要になる理由です。

6. **パフォーマンスの最適化**  
   すべての作業をAIが説明しながら実行すると、速度が遅くなり得ます。応答のキャッシュやエージェント間の結果共有といった最適化がなければ、「速くコーディングする」体験からは遠ざかります。

---

## 7. おわりに

Everything Claude Codeは単なる設定ファイルの寄せ集めではなく、**AIと共に働く方法を設計したオペレーティングシステム**に近い存在です。役割単位のプロンプト、テスト中心のルール、フックによる自動化、MCP連携が組み合わさることで、「AIをどうチームメンバーとして使うか」という問いに具体的な答えを示しています。同時に、コンテキスト管理・オンボーディング・ドメイン拡張といった課題も明確です。このリポジトリを自分のプロジェクトへ移植し、組織のプロセスとドメイン知識を上乗せした瞬間、AIはもはや補助ツールではなく**持続可能な開発パートナー**になります。

---

## 参考資料

- [Affaan Mustafa, *Everything Claude Code Repository* (GitHub)](https://github.com/affaan-m/everything-claude-code)
- [Tilnote, *Everything Claude Code まとめ*](https://tilnote.io/en/pages/696db2d265a2e4dd63f35cc7)
- [JP Caparas, *The Claude Code setup that won a hackathon*](https://jpcaparas.medium.com/the-claude-code-setup-that-won-a-hackathon-a75a161cd41c)
- [MCP Servers Catalog](https://mcpservers.org/servers/asifdotpy/github-mcp-server-asifdotpy)
- [Tatsuya Takasaka, *Zenn: Anthropicハッカソン優勝者のClaude Code設定解説*](https://zenn.dev/ttks/articles/a54c7520f827be)

[^tilnote]: https://tilnote.io/en/pages/696db2d265a2e4dd63f35cc7
[^github]: https://github.com/affaan-m/everything-claude-code
[^medium]: https://jpcaparas.medium.com/the-claude-code-setup-that-won-a-hackathon-a75a161cd41c
