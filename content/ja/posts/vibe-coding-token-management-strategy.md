---
title: "バイブコーディングのトークン管理戦略"
date: 2026-03-19T09:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - claude-code
  - codex
  - gemini
  - context-engineering
---

> トークン不足はモデル性能の問題ではなく、たいていはコンテキストの運用方法の問題です。

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

Claude Code、Codex、Geminiのようなバイブコーディングツールを長く使っていると、ある時点から似たような症状が現れます。応答が遅くなり、すでに合意した制約を忘れ、関係のないファイルにまで手を出し始めるのです。これをよく「トークンが足りない」と表現しますが、実際に起きている現象は、より正確に言えば**コンテキスト汚染**、あるいはContext Rotに近いものです。

Perplexityを通じてまとめたideationメモを読み返してみると、要点ははっきりしています。実際の利用環境では、トークン使用量の大部分は出力ではなく**入力コンテキスト**で発生します。したがって問題を解く最良の方法も「より大きなモデル」ではなく「よりきれいなコンテキスト」なのです。本稿ではその内容をもとに、ツール別の機能紹介ではなく**実務の運用戦略**を中心に、トークン管理の原則を整理してみます。

## TL;DR

- トークン不足は単なる上限の問題ではなく、会話・ログ・文書が入り混じって生じるコンテキスト汚染の問題として捉えるべきです。
- `.claudeignore`、作業文書の分割、`/clear`と`/compact`、handoff文書のように、範囲を絞る習慣がまず先です。
- 良いバイブコーディングとは、長いプロンプトよりも、いま必要な情報だけをモデルに見せるコンテキスト設計に近いものです。

## なぜトークンが先に尽きるのか

長いセッションが積み重なり続けると、問題は二つの層で現れます。一つは純粋なトークン上限への到達であり、もう一つはそれより先に訪れる品質の低下です。会話ログ、失敗した試み、暫定的な仮説、長いビルドログ、すでに終わった作業の文脈が残り続けると、モデルはいま重要な情報とすでに破棄された情報を区別しにくくなります。

この現象は、単にコンテキストウィンドウの大きさでは解決しません。長いコンテキストはより多くの情報を収められるようにしてくれますが、その中の情報がきちんと整理されている保証まではしてくれないからです。だからこそトークン管理の核心は、節約そのものよりも**選別**にあります。

## 戦略1: `.claudeignore`で、そもそも読ませてはいけないものを遮断する

実測ベースで最もROIが高い単一の施策は、`.claudeignore`の設定です。ideation文書に引用された事例では、`node_modules`、ビルド成果物、ログ、バイナリ、大容量画像、lockファイルを除外するだけでも**30〜40%程度の削減効果**が報告されています。[^6][^7]

たとえば、こういった具合です。

```text
node_modules/
.next/
dist/
build/
coverage/
.cache/
*.log
*.db
*.sqlite
.env*
*.png
*.jpg
*.gif
*.mp4
```

この戦略の本質は節約ではありません。モデルが、そもそも見ても役に立たない情報を見ないようにすることです。とくにlockファイルやビルド成果物は、トークンを多く消費するわりに推論上の価値がほとんどありません。

## 戦略2: `tasks.md`を一つに詰め込まず、インデックス構造に分割する

ideation文書で最も印象的な事例の一つが、単一の大きな`tasks.md`をドメイン別文書と`INDEX.md`の構造に分けて**76.1%の削減**を達成したケースです。[^8]

```text
tasks/
├── INDEX.md
├── backend.md
├── frontend.md
├── infra.md
├── security.md
└── archive/
```

この構造が良い理由は単純です。すべての作業ですべてのタスクを読む必要はないからです。全体の状況は`INDEX.md`だけ見ればよく、特定の作業では該当ドメインのファイルだけを読めば済みます。完了した履歴は`archive/`に片付けておけば、現在のセッションの作業台から消えます。

トークン管理とは、結局のところ文書の情報アーキテクチャの問題でもあるのです。

## 戦略3: セッションを長く引きずらず、`/clear`と`/compact`を意識的に使う

Claude Codeを基準に見ると、最も即効性が高い方法は`/clear`と`/compact`を戦略的に使うことです。[^1][^2]

- `/clear`は作業の文脈を完全に初期化するときに使います。
- `/compact`は重要な内容だけを残して会話履歴を要約するときに使います。
- 長いデバッグセッションの直後、機能を一つ終えたとき、あるいはコンテキスト使用量が70%程度に達したときにcompactをかける習慣が効果的です。[^2]

肝心なのは、長い会話をずっと維持するほうが生産的だという錯覚から抜け出すことです。セッションは長く続けるよりも、**短く切って再開できる**べきなのです。

## 戦略4: handoff文書を残して新しいセッションに移る

セッションを頻繁に切るには、再開のコストが低くなければなりません。このとき最も単純で強力な方法が、`HANDOFF.md`のような短い引き継ぎ文書を置くことです。[^3]

たとえば、以下の程度で十分です。

```text
目標: ログインフローのrace condition解消
修正したファイル: auth_service.ts, login_controller.ts
確認した事実: DBの問題ではなく、APIの重複呼び出しが原因
失敗した試み: mutexの適用は副作用が出たためロールバック
次の作業: idempotency key方式の検討
完了条件: 重複ログインの再現テストが通ること
```

この文書の目的は、長文の記録を残すことではありません。次のセッションが**すぐに働き出せる程度の方向性**だけを残すことです。

## 戦略5: まずPlan modeを通し、実装は後にする

大きな作業をいきなり実行モードに放り込むと、モデルは探索と設計と実装を同じコストセンターの中で一度に処理してしまいます。この進め方は試行錯誤が多く、トークンも多く消費します。ideationでは、まずPlan modeを通して範囲を絞ってから実装に入る習慣が**20〜30%の削減**に寄与すると整理しています。[^7]

この原則はごく単純です。

1. まず関連ファイルと影響範囲を洗い出す。
2. 修正候補のファイルとアプローチを短く計画する。
3. 計画から不要な範囲を削ぎ落とす。
4. そのあとで初めて実装する。

つまりトークンの節約は、プロンプトを短く書く技術よりも、**不要な試行錯誤を事前に取り除く設計の習慣**に近いのです。

## 戦略6: 繰り返す説明は`CLAUDE.md`に逃がし、階層的に管理する

セッションのたびにプロジェクト構造やスタイルガイド、禁止ルール、テスト方式まで説明し直しているチームは少なくありません。これは長期的に最も高くつくトークンの浪費です。ideation文書でも、`CLAUDE.md`をグローバル・プロジェクト・モジュールの単位でレイヤー化するパターンを推奨しています。[^4]

```text
~/
└── CLAUDE.md
project/
├── CLAUDE.md
├── backend/CLAUDE.md
└── frontend/CLAUDE.md
```

この構造の利点は明快です。常に必要なルールは上位に置き、特定ドメインにだけ必要な情報は下位のモジュールファイルに置きます。そうすれば、すべてのセッションが同じ重いルールファイルを丸ごと抱えて回る必要がなくなります。

とくに`CLAUDE.md`には、以下の項目が有用です。[^4][^5]

- 中核となる技術スタックとアーキテクチャ
- コーディング規約
- 現在のスプリント目標とブロッカー
- compact時に必ず残すべき情報
- 詳細な文書へつなぐ`Load on Demand`リンク

つまり良い`CLAUDE.md`とは、すべてを盛り込んだ文書ではなく、**何をすぐ読み、何を後で読むかを決めてくれるインデックス**に近いものです。

## 戦略7: Skillsを積極的に使い、文書を「常時ロード」から「必要時ロード」に変える

ここからもう一段進むと、`CLAUDE.md`だけでは足りません。繰り返し呼び出されるワークフロー、特定ドメインの手順、レビュー基準、デプロイのチェックリスト、セキュリティレビューのルーチンといったものは、**skillとして外部化する**ほうがはるかに優れています。

Anthropicの公式Skillsガイドは、この点をかなり明確に説明しています。[^15] skillsは基本的に**3段階の段階的開示（progressive disclosure）**の構造を持ちます。

- YAML frontmatterは常にロードされます。
- `SKILL.md`の本文は、そのskillが関連あると判断されたときにのみロードされます。
- `references/`のような連結文書は、必要なときにだけ追加で探索されます。

つまりskillの核心的な価値は「知識をたくさん入れること」ではなく、**知識を一度に全部入れないこと**にあります。ここにサブエージェントまで組み合わせれば、効果はさらに大きくなります。Anthropicのsubagent文書も、サブエージェントがメインの会話とは**分離されたコンテキストウィンドウ**を使うことで、メインセッションの汚染を減らすと説明しています。[^16]

ただし、ここで一つだけ正確に押さえておくべきことがあります。Anthropicの公式文書が「すべての文書を200行以下に保て」と直接規定しているわけではありません。公式ガイドが述べているのは、より一般的な原則です。`SKILL.md`には中核の指針だけを載せ、詳細な文書は`references/`に逃がし、大きなコンテキストの問題が生じたら`SKILL.md`を**5,000語以下**に保つ、というものです。[^15] 私がここに付け加えたい実務上のルールは、もっと攻めたものです。**実際に参照される文書の断片は、200行以内に分割しておくほうがよい**ということです。そうしてこそ、skillが必要な文書だけを選んで読むときに、その単位が大きくなりすぎずに済みます。

たとえば、以下のように構成するほうが望ましいでしょう。

```text
.claude/
├── CLAUDE.md
├── agents/
│   └── code-reviewer.md
└── skills/
    └── security-review/
        ├── SKILL.md
        └── references/
            ├── auth-checklist.md
            ├── input-validation.md
            └── secrets-policy.md
```

この構造の利点は二つあります。第一に、メインセッションにはskillを「いつ使うべきか」だけが残ります。第二に、詳細な文書は実際に必要になったときにだけ入ってきます。トークンの節約は、この第二段階で発生します。

実測データも方向性は同じです。SkillsBenchは、7つのモデル／ハーネスの組み合わせにおいて**キュレーションされたskillsが平均+16.2ポイントの成功率向上**をもたらしたと報告しています。[^17] Claude Code Opus 4.6は30.6%から44.5%へ、Codex GPT-5.2は30.6%から44.7%へ、Claude Code Sonnet 4.5は17.3%から31.8%へ上昇しました。[^17] さらに興味深いのはトークンです。この研究では、skillsがすべての環境で無条件にトークンを減らしたわけではありませんでした。GPT-5.2とGemini 3 Flashでは、skillの文脈が加わることで総トークンが6〜13%増えました。一方でGemini 3 Proは総トークンが約6%減り、Claude Code Opus 4.6は観測可能な入力トークンが**1,947Kから1,448Kへ、約26%減少**しました。[^17]

この数値が語っていることは明白です。skillは「文書をより多く入れる技術」ではなく、**探索を減らして手順を再利用する技術**なのです。よく設計されたskillは試行錯誤を減らして全体のトークンを下げられますが、逆に大きすぎるskill、多すぎるskill、丸ごとロードされるskillは、かえってコンテキストの負債になります。

結論として、skill戦略の核心は次の3行に集約されます。

- 頻繁に繰り返される手順はskillへ昇格させる。
- `SKILL.md`は短く保ち、詳細な文書は`references/`に分離する。
- 実際に参照される文書は小さく分割し、オンデマンドのロードが意味を持つように作る。

## 戦略8: 大きなログや検索作業は、サブエージェントか別セッションに隔離する

Web検索、長いログの分析、ビルド出力のレビュー、広範なコード探索は、いずれも成果物が長くなります。この種の作業をメインセッションで直接処理すると、コンテキストは急速に汚染されます。ideationでも、こうしたノイズの多い作業はサブエージェントに委譲し、**結果の要約だけをメインコンテキストに返してもらう方式**を推奨しています。[^9]

このパターンはClaude Codeだけでなく、CodexやGemini CLIにもそのまま当てはまります。重要なのは、どのツールを使うかよりも、**ノイズの多い作業と判断が必要な作業を同じセッションに混ぜないこと**です。

## 戦略9: 検索ベースのコンテキスト注入をデフォルトにする

大規模なコードベースで、ファイル全体をそのまま読ませる方式は長くは持ちません。ideation文書には、関数やシンボル単位の依存グラフを作って必要な断片だけを与える高度なパターンも紹介されており、この方式であれば実測ベースで**80%以上の削減**が可能だという事例まで出ています。[^10]

もちろん、すべてのチームがすぐにMCPサーバーや依存グラフを作る必要はありません。しかし原則そのものは、いますぐ適用できます。

- まず検索する。
- 関連するファイルとシンボルだけを絞り込む。
- その断片だけをコンテキストに入れる。

つまり、リポジトリ全体をダンプする代わりに、**検索してから注入する**ことをデフォルトにすべきなのです。

## 戦略10: MCPサーバーも、つないでおくだけでコストになる

MCPは強力ですが、有効化されたサーバーとツールが多いほど、コンテキストとシステム指示文は膨らみます。ideation文書が指摘するとおり、現在の作業と無関係なMCPを常時オンにしておくことは、最初のプロンプトを送る前から予算を食い潰すやり方です。[^11]

したがってMCPの戦略も、「たくさんつなぐ」ではなく「必要なときだけつなぐ」が正解です。長期的には、これもまた段階的開示（Progressive Disclosure）の一部です。

## 戦略11: ツールごとに役割を分ける

ideationは、Claude Code、Codex、Geminiをそれぞれ異なる特性として整理しています。[^12][^13][^14]

- Claude Codeは複雑な推論とデバッグに強い一方で、セッション管理が重要です。
- Gemini CLIは長いコンテキストの分析に有利ですが、`.geminiignore`のような除外戦略が必須です。
- Codexは比較的大きなコンテキストを扱えますが、結局はcompactionと範囲管理の原則から自由ではありません。

これはつまり、すべてのツールを一つのやり方で使うな、という意味です。コードベース全体のマッピングは長いコンテキストのツールに任せ、実際の修正は短く集中したセッションに渡す、といった**役割分担**が、コストと品質の両面で有利です。

## アンチパターン

逆に、次のパターンはほぼ常にトークンの負債を生みます。

- 「プロジェクト全体を見て、いい感じにやっておいて」のような広すぎる依頼
- 一つのセッションに探索・実装・デバッグ・振り返りをすべて積み上げるやり方
- 大きな`tasks.md`、巨大なルールファイル、肥大化したskillを常に丸ごとロードする構造
- skillの中にすべての背景知識を1ファイルに詰め込み、`references/`を事実上使っていない構造
- ビルドログ、diff、検索結果を圧縮せずそのまま貼り付ける習慣
- 現在の作業と無関係なMCPサーバーやツールを常時有効にしている設定
- 大きなコンテキストウィンドウがあるのだから整理しなくてよい、という態度

長いコンテキストは、より多くのゴミを収められるようにしてくれるだけであって、重要な情報をより上手に選び取れるようにしてくれるわけではありません。

## 現実的な適用の優先順位

本文もおおむね削減効率の順に整理しましたが、実際の着手順はチームの規模や投資の余力によって多少変わり得ます。実務的には、たいてい以下の三段階で捉えると理解しやすいでしょう。

1. すぐに適用
`.claudeignore`、`tasks.md`の分割、`/clear`・`/compact`、handoff文書
2. 今週中に定着
`Plan mode`、`CLAUDE.md`のスリム化、繰り返す手順のskillへの昇格
3. その次の構造投資
サブエージェントによる隔離、検索ベースのコンテキスト提供、MCPの最小化、ツール別の役割分担

つまり大半のチームは、高度なインフラより先に**文書構造とセッションの習慣**を変えるだけでも、大きな違いを体感できるということです。

## 結論

バイブコーディングのトークン管理戦略は、結局のところ一文に要約されます。**モデルに多くを見せるのではなく、いま必要なものだけを正確に見せよ。** セッションは短く保ち、繰り返す説明は文書とskillに外部化し、大きなタスクはインデックスと計画段階に分割し、ノイズの多い作業は別セッションに隔離すべきです。

トークンを節約するチームの生産性が高い理由は、お金を使わないからではありません。モデルが混乱する余地を減らしたからです。良いバイブコーダーとは、長いプロンプトを書く人ではなく、**コンテキストを設計する人**なのです。

[^1]: Best Practices for Claude Code, Anthropic Docs: https://code.claude.com/docs/en/best-practices
[^2]: Managing Claude Code context to reduce limits: https://mcpcat.io/guides/managing-claude-code-context/
[^3]: 45 Claude Code Tips From basics to advanced: https://github.com/ykdojo/claude-code-tips
[^4]: The Complete Guide to Claude Code Context: https://supatest.ai/blog/claude-context-management-guide
[^5]: Claude Code 컨텍스트 최적화 가이드 - 인포그랩: https://insight.infograb.net/blog/2026/01/14/claudecode-context/
[^6]: 7 Ways to Cut Your Claude Code Token Usage: https://dev.to/boucle2026/7-ways-to-cut-your-claude-code-token-usage-elb
[^7]: How I Reduced Claude Code Token Consumption by 50%: https://32blog.com/en/claude-code/claude-code-token-cost-reduction-50-percent
[^8]: CLAUDE-CODE의 토큰을 절약하기 - tasks.md의 문서 구조 개편: https://developer-youn.tistory.com/196
[^9]: How to Use Claude Code: A Guide to Slash Commands: https://www.producttalk.org/how-to-use-claude-code-features/
[^10]: I cut Claude Code's token usage by 65% by building a ... https://www.reddit.com/r/ClaudeAI/comments/1rby0gt/i_cut_claude_codes_token_usage_by_65_by_building/
[^11]: Tips after using Claude Code daily: context management ... https://www.reddit.com/r/ClaudeCode/comments/1pawyud/tips_after_using_claude_code_daily_context/
[^12]: Best practices for cost-efficient, high-quality context management in long AI chats: https://community.openai.com/t/best-practices-for-cost-efficient-high-quality-context-management-in-long-ai-chats/1373996
[^13]: How to Leverage Gemini CLI's 1M Token Context Window: https://inventivehq.com/knowledge-base/gemini/how-to-leverage-1m-token-context
[^14]: What Is the Token Limit for Codex Requests?: https://apidog.com/blog/token-limit-for-codex-requests/
[^15]: The Complete Guide to Building Skills for Claude, Anthropic: https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf
[^16]: Subagents, Anthropic Docs: https://docs.anthropic.com/en/docs/claude-code/sub-agents
[^17]: SkillsBench: Benchmarking How Well Agent Skills Work Across Diverse Tasks: https://www.skillsbench.ai/skillsbench.pdf
