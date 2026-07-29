---
title: "Karpathy LLM Wikiは本当に効果があるのか - 72-runベンチマーク"
date: 2026-05-07T11:00:00+09:00
draft: false
toc: false
images:
tags:
  - llm-wiki
  - karpathy
  - claude-code
  - context-engineering
  - agentic-dev
  - benchmark
  - graphrag
---

> 「エージェントが毎回すべてを再導出しないようにするには、コンパイルされた知識アーティファクトが必要だ。」 — Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04)[^karpathy]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

## TL;DR

- Andrej Karpathyの**LLM Wikiパターン**（「毎回読み直すのではなく、一度コンパイルした知識を再利用せよ」[^karpathy]）が実際に得なのかを、30リポジトリのマイグレーション用ワークスペースで**8タスク × 3手法 × 3反復 = 72 run**のベンチマークとして測定しました。
- **LLM Wikiがトークン・時間・品質の3次元すべてで1位。**Vanilla比で**トークン54%削減、時間39%短縮**（統計的にlarge effect、§4）、品質はVanillaと同等でGraphifyより優位。
- **Graphify（GraphRAG）は既定ツールとして不適合。**トークン削減はわずか、時間は最長、品質は最低。
- **ただし万能ではない。**複数のソースを総合するタスクではWikiの圧勝ですが、答えが単一のソースに明確にあるタスク（全件grep・特定の表の参照）では直接readのほうが速く正確です（§3）。
- 結果を受けて、その日の夕方にプロジェクトの既定コンテキスト検索ツールはLLM Wikiに変わりました。

| 手法 | トークン（平均） | 時間（平均） | 品質（25点） |
|------|-----------:|-----------:|-----------:|
| Vanilla（直接read/grep） | 755K | 167s | 15.1 |
| **LLM Wiki** | **350K** | **101s** | **16.0** |
| Graphify (GraphRAG) | 617K | 180s | 13.6 |

以下はこの結論を裏付ける実験設計と詳細な数値です。

---

## 1. 比較した三つの手法

| 手法 | 動作方式 | 追加で露出した資料 |
|-----|----------|--------------|
| **Vanilla** | 補助ツールなしでファイルを直接read/grep | （なし） |
| **LLM Wiki** | LLMがあらかじめコンパイルしておいたマークダウンのwikiを先に読む | `wiki/` 全体 + 引用ルール |
| **Graphify** | エンティティ・関係グラフ（GraphRAG）を先に問い合わせる | `graphify-out/` + CLI |

LLM Wikiパターンの核心はRAGとの違いです。RAGは問い合わせのたびに埋め込み・ベクトル検索・チャンク注入を繰り返す**stateless**なサイクルであるため、総合・相互参照・矛盾処理を毎回ゼロからやり直します。LLM Wikiはこれを逆転させ、**新しいソースが入ってきたときに一度コンパイル**（要約・相互参照・衝突の明記）しておき、問い合わせの時点ではすでに総合されたマークダウンページを読みます。**コンパイルは一度、問い合わせは複数回** — この非対称なコスト配分がトークン削減の源泉です。

---

## 2. 実験設計

**意思決定の問い**: 「このマイグレーションのワークロードにおいて、トークン効率と回答品質を同時に満たす手法は何か？」従属変数の優先順位は ① トークンコスト ② 回答品質 ③ 作業時間。

**ワークロード — 8タスク（T1–T8）**:

| ID | 問いの要点 | タスク種別 |
|----|---------|----------|
| T1 | cyrupの9folders独自パッチの数と領域 | パッチ分析 |
| T2 | notifier_go ↔ rework-notify 間のSNSフロー | cross-language依存 |
| T3 | cyrus-imapd 9foldersがmaster比でパッチした規模 | 大規模パッチ分析 |
| T4 | pam-jwtがproductionで呼び出されているか | 全件grep |
| T5 | cyrus-imapd 4ブランチの活性度比較 | git history |
| T6 | Stalwart JMAPの韓国ビジネスロジックへの適合度 | 外部資料の統合 |
| T7 | R12 PoCシナリオ6件の依存commit SHA | コード分析 |
| T8 | X-AUTH-01に影響するR項目とcapability ID | cross-domain |

**隔離**: 三つの手法をgit worktree 3つに分離し、各worktreeに専用のCLAUDE.mdを上書きしました。submodule・PRD・コード・gitは共通で、**違いは補助ツールだけ**です。worktreeのパスが分かれているおかげで、trial間のprompt cache汚染はありません。

**採点（Judge） — 外部モデル（codex/GPT-5）**: actorがClaudeであるため、self-evaluationのバイアスを避けようと外部モデルで採点しました。4次元0–25のrubricです。

| 次元 | 重み | 定義 |
|-----|-------|-----|
| 正確性 | 0.4 | ground truthの核心事実との一致率 |
| 完結性 | 0.3 | 核心事実の抜けがないか |
| 引用 | 0.2 | `[[wiki/..]]`、`PRD §X`、`9folders <SHA>` の明示 |
| 過剰（逆指標） | 0.1 | 不要な思弁・ハルシネーション・繰り返しの割合 |

タスクのプロンプトにはground truthを露出させず、judgeだけが保持します。Inter-rater agreement（Cohenのκ）は加重平均0.86でrubricを通過しました（excess次元のみκ=0.25と弱いものの、重みは0.1）。

---

## 3. タスク別の勝者 — パターンは単純ではない

全体平均はWikiに軍配を上げますが、タスク種別によって勝者が分かれます。平均スコア基準の1位は次のとおりです。

| Task | 1位 | 2位 | 3位 | 備考 |
|------|----|----|----|-----|
| T1（cyrupパッチ） | wiki 17.67 | graphify 17.50 | vanilla 16.33 | 僅差 |
| T2（cross-language SNS） | **wiki 18.00** | vanilla 14.50 | graphify 13.17 | wikiの圧勝 |
| T3（cyrus-imapdパッチ規模） | graphify 9.50 | vanilla 8.33 | wiki 7.83 | **すべて低調** |
| T4（pam-jwt使用有無） | **vanilla 18.17** | wiki 17.50 | graphify 14.83 | vanilla優勢 |
| T5（cyrusブランチ活性度） | wiki 15.83 | vanilla/graphify 14.17 | — | wiki優勢 |
| T6（Stalwart JMAP適合度） | **wiki 16.83** | graphify 11.50 | vanilla 11.33 | wikiの圧勝 |
| T7（R12 PoC SHA） | wiki 18.00 | vanilla 17.67 | graphify 16.33 | 僅差 |
| T8（X-AUTH-01 cross-domain） | **vanilla 20.33** | wiki 16.33 | graphify 11.50 | vanillaの圧勝 |

- **Wikiは混合型・総合型のタスクでrobust**です。8件中5件（T1・T2・T5・T6・T7）で1位。とくに複数のソースを総合しなければならないT2（cross-language）・T6（外部資料）で強い。キュレーションが値打ちを発揮しています。
- **Vanillaが勝つタスクが二つあります。**T4（全件grep）・T8（cross-domain）です。どちらも**答えが単一のソースに明確にあり、キュレーションがかえって損失になる**ケースです。T4はコード全体のgrepで片が付き、T8はPRDの表を直接読むのが最も正確です。
- **GraphifyはT3の1件だけが1位で、それも9.50/25と絶対スコアが低い。**強みを期待していたcross-language（T2）でもwikiに大きく負けました — INFERRED edgeがノイズを加え、query overheadが時間を押し上げたのです。

---

## 4. 統計的有意性

Friedmanの主効果: 時間 p=4.5e-07、品質 p=0.0016（どちらも強力）、トークン p=0.093（限界的）。

Wilcoxonのpairwise（Bonferroni補正）:

| 比較 | 次元 | p_corr | Cohen's d | 判定 |
|-----|-----|--------|-----------|------|
| vanilla > wiki | トークン | 0.0105 | +0.842 | **有意 (large)** |
| vanilla > wiki | 時間 | 3.93e-05 | +0.975 | **有意 (large)** |
| graphify > wiki | 時間 | 3.58e-07 | -1.150 | **有意 (large)** |
| wiki > graphify | 品質 | 0.00678 | +0.666 | **有意 (medium-large)** |
| vanilla vs wiki | 品質 | 0.7312 | -0.216 | 差なし |
| vanilla vs graphify | 品質 | 0.2459 | +0.420 | 差なし |

まとめると、**Wikiはvanilla比でトークン・時間を大きな効果量で削減し（品質は同等）、graphify比では品質・時間ともに優越**しています。graphify-firstは私たちのワークロードでは既定ツールとして不適合です。

---

## 5. では、どう運用するのか

ベンチマーク結果を受けて整理した既定のポリシーです。

1. **Wiki-first** — 運用上の事実は `wiki/index.md` → 関連ノートを先に読む。
2. **なければ即座に原典へ** — wikiになければ PRD → コードのread/grep。決して作り出さない。
3. **単一ソースでの回収が明確ならwikiを飛ばす** — 一つのノートに絞り込めないなら、素早く直接readへ移る（T4・T8型）。
4. **Graphifyは補助** — cross-componentの依存関係の追跡にのみ選択的に使う。

運用して得た最大の教訓は別にあります。**wikiを作ることよりも、回答のたびに出典を引用させるほうが難しく、より重要です。**初期は記録は活発だったのに、回答の `[[..]]` 引用が10%未満だったため、wikiの価値が半分しか発揮されていませんでした。回答の直前に「この事実にwikiの引用があるか？」を強制するチェックルール一つで、引用率はすぐに正常化しました。

---

## 6. 留意点

- **excess次元のIRRが弱い**（κ=0.25）。すべての手法のtranscriptを一緒に見ながらの採点だったため、excessのスコアが一律に厳しくなりました。重みが0.1なので結論への影響は小さいものの、絶対値は保守的に見るべきです。
- **Wiki biasへの懸念**: 8タスクすべてでwikiにground truthがあるため、有利になっている可能性があります。ただしjudgeはsourceではなくground truthの事実そのものを評価します。
- **Claude Codeベースの測定**です。他のモデル・ツール環境では結果が異なり得ます。この数値は私たちの環境におけるポリシーの根拠であって、universal claimではありません。

---

## まとめ

Karpathyの LLM Wiki パターンは、私たちのドメインで**トークン54%削減、時間39%短縮、品質は同等以上**の効果を出し、統計的にもlarge effectで有意でした。既定ツールをwikiに変えた決定はデータに裏付けられています。

ただしパターンを直訳してはいけません。答えが単一のソースに明確にあるタスクではキュレーションのコストが損失になりますし、Graphifyは既定ツールとしては不適合であるものの、特定の経路の問い合わせではwikiより優れています。**パターンは受け入れつつ、自分のワークロードのタスク分布とソース構造を併せて見るべきです。**8タスク × 3手法 × 3トライアル = 72 runであれば1〜2日で答えが出るので、ぜひ一度ご自分で測定してみることをお勧めします。

---

[^karpathy]: Andrej Karpathy, *LLM Wiki* (GitHub Gist, 2026-04). https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
