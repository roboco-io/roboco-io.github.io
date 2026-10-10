---
title: "オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（1/4）：判定基準と12のリポジトリ"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - vibe-coding
  - openclaw
  - best-practices
---

> 「修正して出荷する権限は、リリースする権限ではない（fix/ship authority is not release authority）」 – OpenClaw `AGENTS.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

2026年3月、OpenClawのリポジトリを分析して[バイブコーディングの9つのベストプラクティス](/ja/posts/openclaw-vibe-coding-best-practices/)をまとめました。[^2] 一人の開発者が複数のAIエージェントを指揮して、大規模なモノレポを運営するやり方でした。9月には[バイブコーディングを超えて、ソフトウェアファクトリーへ](/ja/posts/beyond-vibe-coding-software-factory/)という記事で、その次の段階を展望しました。[^3] 要件の把握から設計、実装、検証、デプロイ、運用の観察までが一つの流れとしてつながり、人は目標と制約を決め、判断が必要な場面でだけ介入する運営方式です。私はこれを**ソフトウェアファクトリー**と呼びました。

その記事は展望であり、事例はありませんでした。そこで今回は、実際にファクトリーのように動いているプロジェクトを探しました。方法は前回と同じです。公開リポジトリに残されたエージェント向けの指示ファイル、CIワークフロー、ボットの設定、コミット・PR・Issueの履歴を直接読み、運営方式を逆算して再構成しました。一種のリバースエンジニアリングです。運営の証拠はリポジトリで確認できたものを中心とし、企業ブログのような自社による説明は出典を明記して区別して引用しました。数値は2026年10月10日にGitHub APIで取得した値で、サンプルと期間は本文に併記しています。

この記事は、4回シリーズ「オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス」の第1回です。今回は判定基準と全体の結果、そしてプロジェクト間で繰り返し見られたパターンをまとめます。第2〜4回では、そのパターンのうち3つを一つずつ深く掘り下げます。

**シリーズの構成**

1. 判定基準と12のリポジトリ：何をファクトリーと呼び、どこで動いているのか（本記事）
2. [誰がマージするのか：リスクに基づく委任と権限構造](/ja/posts/software-factory-who-merges/)
3. [証拠でふるいにかけるファクトリー：「修正前には失敗する」ことの証明](/ja/posts/software-factory-evidence-before-fix/)
4. [失敗をルールに：自己改善ループとその限界](/ja/posts/software-factory-failures-into-rules/)

## TL;DR

- 公開リポジトリ12か所（BeadsとGas Townは別々に数えています）を分析しました。そのうち8か所、プロジェクト単位にまとめると7つ（OpenClaw、OpenHands、Beads/Gas Town、mastra、Bun、Astro、Vercel AI SDK）をソフトウェアファクトリーと判定しました。
- ボットがmainブランチへのマージを大量に行っていることを確認できたのはOpenClawだけです。ほかのファクトリーでは人による最終マージが主に観察され、そのマージはたいてい一人に集中していました。
- 共通する実践は、「修正前には失敗する」という証拠の要求、権限構造で実装した委任の境界、そして失敗を根拠とともにルールへ変える習慣です。また、Issueからマージまで人を介さずに流すよりも、作業の着手と結果の確認の地点に境界を置いた事例が多く見られました。

---

## 1. 何をソフトウェアファクトリーと呼ぶのか

エージェントが大量のコードを書いているという事実だけでは、ファクトリーとは呼べません。一人の人がターミナルでエージェントと対話しながらコードを書くのも、エージェントがコードを書いていることに変わりはないからです。ファクトリーとバイブコーディングを分けるのは、**流れが人の毎回の指示なしに続くかどうか**です。そこで9月の記事の定義を、リポジトリで確認できる6つの基準に置き換えました。

| # | 基準 | リポジトリで確認したこと |
|---|---|---|
| 1 | 作業流入の自動化 | Issue・フィードバック・エラーが、人が毎回指示しなくてもエージェントの作業になるか |
| 2 | 複数の並列フロー | 複数のエージェントの作業が同時に進み、衝突を防ぐルールがあるか |
| 3 | 自動化された検証ゲート | テスト・レビューボット・品質ゲートがマージの可否を決めているか |
| 4 | リスクに基づく委任範囲 | 自動マージが許される変更と、人の承認が必要な変更が分かれているか |
| 5 | 報告体制 | 人がすべてのログを読まなくても判断できるか |
| 6 | 自己改善ループ | 運用中の失敗がテスト・指示・ワークフローの修正に戻っていくか |

各基準は4段階で判定しました。**充足**は、仕組みと実際に動いた痕跡の両方がリポジトリにあることを意味します。**部分的**は、そのどちらか一方しかないか、中核となる段階を人が担っていることを意味します。**未充足**は反対の証拠があることを、**未確認**は公開リポジトリだけでは判断できないことを意味します。

総合判定のしきい値は2つです。第一に、製品コードの開発の流れが公開リポジトリで観察できること。第二に、6つの基準すべてで仕組みが確認できること、つまり未充足や未確認が一つもないことです。このしきい値を越えれば、充足の数にかかわらずファクトリーと判定しました。充足の数は、ファクトリーの成熟度を比較するために使いました。

参考までに、「ソフトウェアファクトリー」という言葉をいち早く使ったStrongDMは、これを「仕様とシナリオが、コードを書くエージェントを動かす非対話型の開発（non-interactive development where specs + scenarios drive agents that write code）」と定義しています。[^4] 人がコードを書いてもレビューしてもならない、というルールも置いています。私の基準ともっとも大きく異なるのは4番目です。私はリスクに応じて人の承認を残すことをファクトリーの要件と見ていますが、StrongDMは人のレビューをなくし、検証ハーネスを強化する道を選びました。この違いは第2回で改めて取り上げます。

---

## 2. 12か所を調べた結果

候補は2つの経路で集めました。一つはすでに知られていた事例（OpenClaw、Aider、OpenHands、Codex、Claude Code、StrongDM、Gas Town）、もう一つはエージェントのボットが作成したマージ済みPRが多いリポジトリをGitHub検索で探したもの（Vercel AI SDK、Astro、mastra、Bun）です。BeadsはGas Townと同じチームのリポジトリなので、あわせて調べました。

| プロジェクト | 1 流入 | 2 並列 | 3 ゲート | 4 委任 | 5 報告 | 6 改善 | 総合判定 |
|---|---|---|---|---|---|---|---|
| [OpenClaw](https://github.com/openclaw/openclaw) | 充足 | 充足 | 充足 | 充足 | 充足 | 充足 | ファクトリー |
| [Beads](https://github.com/gastownhall/beads) | 充足 | 充足 | 充足 | 部分的 | 充足 | 充足 | ファクトリー |
| [Gas Town](https://github.com/gastownhall/gastown) | 充足 | 充足 | 充足 | 部分的 | 充足 | 部分的 | ファクトリー（mainは7月以降停止） |
| [mastra](https://github.com/mastra-ai/mastra) | 充足 | 部分的 | 充足 | 部分的 | 充足 | 充足 | ファクトリー |
| [Bun](https://github.com/oven-sh/bun) | 部分的 | 充足 | 充足 | 部分的 | 部分的 | 充足 | ファクトリー |
| [Astro](https://github.com/withastro/astro) | 充足 | 充足 | 部分的 | 部分的 | 充足 | 部分的 | ファクトリー |
| [Vercel AI SDK](https://github.com/vercel/ai) | 充足 | 部分的 | 充足 | 部分的 | 充足 | 部分的 | ファクトリー（エンジン非公開） |
| [OpenHands](https://github.com/OpenHands/OpenHands) | 部分的 | 部分的 | 充足 | 部分的 | 部分的 | 充足 | ファクトリー（着手・マージは人） |
| [Aider](https://github.com/Aider-AI/aider) | 部分的 | 未充足 | 部分的 | 未充足 | 充足 | 部分的 | 高度化したバイブコーディング |
| [OpenAI Codex](https://github.com/openai/codex) | 部分的 | 未確認 | 充足 | 部分的 | 部分的 | 充足 | 判断不能（2026年8月末以降は社内リポジトリのミラー） |
| [Claude Code](https://github.com/anthropics/claude-code) | 充足 | 部分的 | 部分的 | 部分的 | 部分的 | 部分的 | 判断不能（製品ソース非公開、Issue運用のみ観察） |
| [StrongDM](https://factory.strongdm.ai/) | 未確認 | 部分的 | 部分的 | 未確認 | 未確認 | 部分的 | 観察不能（ファクトリー運用の本体は非公開） |

表でまず目を引くのは4列目です。ファクトリーと判定した8か所のうち、リスクに基づく委任を充足したのはOpenClawだけです。ほかはコードの変更を主に人がマージしているため、リスクに応じて自動マージの範囲を変える仕組みが見えてきませんでした。しきい値をもっともぎりぎりで越えたのはOpenHandsです。充足は2つだけで、実装の着手もマージも人が行っています。

規模を示す数値もあります。Bunでは、Claudeベースのエージェント`robobun`が2026年9月の1か月だけでPRを2,313件作成し、その月にマージされたPR 560件のうち446件を作成しました。[^5] Vercel AI SDKでは、9月にマージされたPR 845件のうち294件（34.8%）をファクトリーのボットが作成しました。[^6] Vercelはブログで、ファクトリーが週ごとのマージ済みPRの25〜35%を書いていると述べており、月単位の実測値もこの範囲に収まっています。ただし期間の単位が異なるため、直接検証したわけではありません。[^7] mastraでは、9月にマージされたPR 1,531件のうち434件をボットが書きました。[^8]

判定できなかったリポジトリにも意味があります。OpenAI Codexのリポジトリでは、2026年8月27日以降、ミラーリング用のボットが社内リポジトリの変更を持ち込んだマージ済みPRが2,170件あり、直近のマージ済みPR 200件はすべてこのボットが作成していました。9月30日には、ルートの`AGENTS.md`と12個のスキルが公開リポジトリから削除されました。[^9] Claude Codeのリポジトリには製品のソースがなく、Issue運用の自動化だけが公開されています。リバースエンジニアリングで見えるのは、公開されている範囲までです。

---

## 3. マージ権限とエンジンの所在

12か所を2つの問いで改めて分けると、構造がよりはっきり見えてきます。一つは「誰がmainブランチにマージするのか」、もう一つは「ファクトリーを動かすエンジンと設定はどこにあるのか」です。

| マージする主体 \ エンジンの所在 | リポジトリの外（非公開） | 一部公開 | 公開リポジトリ |
|---|---|---|---|
| ボットがmainへ大量にマージ | | | **OpenClaw**（直近のマージ300件中203件） |
| 人による最終マージが主に観察された | Vercel AI SDK、Bun | OpenHands | mastra、Astro、Beads、Aider（対照事例） |
| マージの主体を確認できなかった | OpenAI Codex、Claude Code | StrongDM | Gas Town |

ボットにmainへのマージを大量に任せていることを確認できたのは、エンジンまで公開しているOpenClawだけです。OpenClawは保守ボットのClawSweeperを別の公開リポジトリで運用し、ボットがマージしてよい条件をREADMEに明記しています。[^10] Astroもエンジンを別の公開リポジトリ（`withastro/factory`）に置いていますが、9月のファクトリーPRはすべて人がマージしました。[^11] Gas Townでは、マージ済みPR 200件のうち173件を一つのアカウントがマージしていますが、このアカウントが人なのか、エージェントの経路なのかは確認できませんでした。人によるマージが主に観察されたところにも例外はあります。たとえばBunでは、9月にマージされたrobobunのPR 446件のうち1件を別のボットアカウントがマージしていました。

エンジンの所在は、リバースエンジニアリングで見える深さを決めます。右の列では、エージェントの指示から実行エンジンまで読むことができます。左の列では、ボットが残したラベル、コメント、PRしか見えません。Vercel AI SDKのファクトリーのボットは非公開のGitHub Appなので、自己改善ループが実際にプロンプトを修正したかどうかは確認できませんでした。

---

## 4. 7か月後のOpenClaw

3月の記事では、OpenClawをバイブコーディングの観点から分析しました。今回の基準で改めて見ると、OpenClawは今回の調査で6つの基準をすべて充足した唯一のプロジェクトでした。その間に新しく生まれた仕組みも多くあります。それらは第2〜4回で詳しく扱い、ここでは3月の記事から変わった点だけを押さえます。

- **保守ボットClawSweeper**：2026年4月23日に別のリポジトリとして作られました。IssueやPRのイベントを受け取り、レビュー、ラベル付け、修復、マージを行います。厳格なバグ条件を通過したIssueについてはCodexでPRを自動生成しますが、こうして作られたPRは自動マージしません。[^10]
- **リスク階層ごとの権限**：ドキュメントだけが変わる変更は、Docs Agentがパスの許可リストを確認したうえでmainに直接pushします。[^12] 通常のコードは、必須チェック一つとボットのレビューでマージできます。機密性の高いパスはポリシーファイルで別途管理し、セキュリティポリシーのファイル自体はSecOpsチームが承認します。[^13] リリースは人が手動で実行します。この記事の冒頭の引用が、この原則を要約しています。
- **失敗率のサーキットブレーカー**：自動実装ワーカーの成功率は、10月3〜9日に16.9%（成功52回、失敗256回）まで落ち込みました。その後、直近7日間に10回以上実行され、かつ成功率が50%未満であれば自動実装を止める仕組みが追加されました。[^14]

3月の記事の内容から変わったこともあります。`CLAUDE.md`のシンボリックリンクは2026年9月19日に廃止され、現在は`AGENTS.md`だけが正本です。[^15] CONTRIBUTINGにあったAI利用の開示義務も、8月30日に削除されました。[^16] その代わりに、PRには動作の証拠（Evidence）を添付するよう求めています。エージェントが書いたかどうかを問うのではなく、動作する証拠を問う方向に変わったのです。

---

## 5. プロジェクト間で繰り返された6つのパターン

ツールや規模は異なりましたが、次の6つは3か所以上で繰り返し見られました。

### 5.1 マージはまだ人の仕事で、一人に集中している

2026年9月の時点で、BunではrobobunのPRのマージの78%を、mastraではボットのPRのマージの82%を、それぞれ一人が行っていました。[^5][^8] Astroでは、9月のファクトリーPR 31件のうち28件を一人のメンテナーが承認してマージしました。[^11] コードの生産は自動化されましたが、マージの判断はスループットのボトルネックであり、単一障害点として残っています。その単一障害点が実際に止まった事例がAiderです。最近のリリースでは新しいコードの21〜88%をAider自身が書いていましたが、メンテナーがほかの仕事で忙しくなると、コミットはほとんど止まりました。[^17]（第2回で扱います。）

### 5.2 「修正前には失敗する」ことを証拠として求める

エージェントは、常に通ってしまう意味のないテストを簡単に作ります。5か所が、修正前に失敗することの証拠を求めるか、検査しています。Bunは修正前の失敗ログをPRの本文に添付し、既存のリリースでも通ってしまうテストは無効とみなします。[^18] mastraでは、CIがPRで変更されたテストだけを修正前のコードに対して実行し、失敗するかを確認します。[^19] ただし結果はラベルとして付くだけで、失敗のラベルが付いたままマージされたPRもあります。Vercel AI SDKは、再現→失敗するテスト→修正の順にコミットを積み、最初の再現をもう一度実行して解決したかを判定します。[^20] OpenClawとAstroのエージェントも、修正の前に失敗する回帰テストを先に作るよう指示されています。（第3回で扱います。）

### 5.3 判断はエージェントが、取り消しにくい実行は決定的なコードが担う

Claude Codeのリポジトリでは、Issueの重複判定はClaudeが行いますが、実際にIssueを閉じるのは猶予期間（重複の場合は3日）が過ぎた後のルールベースのスクリプトです。[^21] Astroのファクトリーは、書き込みトークンをエージェントに渡さず、コミット・プッシュの段階のワークフローのコードにだけ持たせています。[^11] mastraでは、エージェントが作業カードを「完了」に移せないようにサーバーが防ぎ、マージだけがカードを完了にします。[^22] 委任の境界を、プロンプトではなく権限構造で実装しているのです。（第2回で扱います。）

### 5.4 失敗を根拠とともにルールに変える

Beadsの保守ガイドラインは、ルールごとに、そのルールが生まれるきっかけとなった事故を日付とPR番号で記録しています。[^23] Astroは、エージェントがchangesetをたびたび漏らす原因を「些細な修正なら省略してよいと正当化できてしまう指示文」と診断し、指示文を書き直しました。[^24] Bunは、マージ済みPR約2,500件のレビュー履歴から、マージを止めた理由だけを集めて`REVIEW.md`を作りました。[^25] ただし、ルールが実際に守られているかを自動で測っているところは多くありません。Astroのスキル評価（eval）はCIにつながっていません。（第4回で扱います。）

### 5.5 着手と確認の地点に境界を置く

OpenAI Codexは、IssueをPRに変えていたワークフローを、2025年8月に「設計上の問題」を理由に削除しました。[^26] mastraは、自動モードから手動モードに戻ったとブログで述べており、9月22日以降のボットのPRの82%には作業を始めた人が記録されています。[^27] Astroは修正を自動で作りますが、人がプレビューリリースで動作を確認するまではPRを開きません。[^28] OpenClawは、自動実装を厳格なバグに限定し、失敗率のサーキットブレーカーを付けました。Issueの分類は自動化しつつも、実装の着手やPRの作成には人の確認や厳格な条件を置いた事例が多く見られました。

### 5.6 エージェントの身元と人の責任を記録でつなぐ

OpenHandsは、PRの本文を`HUMAN:`と`AGENT:`の区画に分けています。指示ではエージェントが`HUMAN:`の区画を書くことを禁じ、CIはその区画に人が書いた内容が最低限の長さ以上あるかを検査します。[^29][^30] Beadsは、エージェントの行為に`Agent-Signature:`のトレーラーを残し、モデルが分からなければ推測せずに`unknown-model`と書くよう求めています。[^31] mastraはボットのPRに「Opened by @人」を、OpenClawは「Worked on by @人」を付けています。エージェントが何をしたのかと、誰がその結果に責任を持つのかを、あわせて残しているのです。

---

## 6. まだ解けていない問題

公開された失敗の中には、コードは動いても、意図やリポジトリの外への影響を見落とした事例がありました。コード品質の問題とは異なり、こうした失敗はテストやレビューボットでは捉えにくいものです。

- **「動く」と「意図に合っている」は違います。** Astroのファクトリーは、意図された動作をバグとみなして修正しました。この修正は人が動作を確認したうえでマージされましたが、リリース前に差し戻されました。[^32] 同じ問題で新しいIssueが開かれると、ファクトリーは同じ修正をもう一度作り、そのPRは閉じられました。[^33]
- **リポジトリの外への影響は見えません。** OpenHandsでは、AIレビューボットの承認だけでマージされたエージェントのPRが、別のリポジトリ（enterprise）で機能を使えなくするおそれがあるという理由で差し戻されました。[^34] CIもレビューボットも、そのリポジトリを見ることはできませんでした。
- **マージする人がそのままスループットになります。** 5.1で見たとおり、一人の時間がファクトリー全体の速度を決めています。

この調査の限界も記しておきます。エンジンが非公開のところでは、成果物しか見えません。数値の多くは2026年9月の1か月分か、直近のPR 100〜300件のサンプルです。エージェントの作業が人のアカウントで提出されるところ（OpenHandsなど）では、エージェントの比率をPR本文の署名からしか数えられないため、実際より小さく見積もられている可能性があります。

---

## 結論

7か月前にOpenClawを分析したとき、核心は一人の人が複数のエージェントをどう指揮するかでした。今回調べたプロジェクトの問いは違いました。エージェントが生み出した結果を**何でふるいにかけ、どこまで任せ、失敗をどうルールに変えるのか**です。

ソフトウェアファクトリーは、すでに公開リポジトリで動いています。ただし、人なしで回る工場はまだほとんどありません。人がコードを直接書く比率は下がりましたが、着手を承認し、マージし、失敗からルールを作る仕事の比率は高まりました。そして今は、その仕事がファクトリーの速度と品質をともに決めています。

次回は、最初の問いである「誰がマージするのか」を取り上げます。OpenClawがボットにマージを任せられた条件と、ほかのプロジェクトが人によるマージを残した理由を、リポジトリのポリシーファイルと権限構造から比較します。

**次の記事：** [（2/4）誰がマージするのか：リスクに基づく委任と権限構造](/ja/posts/software-factory-who-merges/)

---

[^1]: OpenClaw AGENTS.md：https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^2]: OpenClaw：世界最大のバイブコーディングプロジェクトから学ぶ9つのベストプラクティス：https://roboco.io/ja/posts/openclaw-vibe-coding-best-practices/
[^3]: バイブコーディングを超えて、ソフトウェアファクトリーへ：https://roboco.io/ja/posts/beyond-vibe-coding-software-factory/
[^4]: StrongDM, Software Factory：https://factory.strongdm.ai/
[^5]: oven-sh/bun、robobunが作成したPR。2026年9月に作成・マージされたPRをGitHub APIで集計（2026年10月10日）：https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^6]: vercel/ai、ai-sdk-factoryボットが作成したマージ済みPR。2026年9月にマージされたPRをGitHub APIで集計（2026年10月10日）：https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^7]: Vercel, "Building a software factory for AI SDK"：https://vercel.com/blog/building-a-software-factory-for-ai-sdk
[^8]: mastra-ai/mastra、mastra-platformボットが作成したマージ済みPR。2026年9月にマージされたPRをGitHub APIで集計（2026年10月10日）：https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^9]: openai/codex PR #49713：https://github.com/openai/codex/pull/49713
[^10]: openclaw/clawsweeper README：https://github.com/openclaw/clawsweeper/blob/main/README.md
[^11]: withastro/factory README：https://github.com/withastro/factory
[^12]: OpenClaw docs-agent.yml：https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^13]: OpenClaw security-review-policy.yml：https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^14]: openclaw/clawsweeper PR #1855：https://github.com/openclaw/clawsweeper/pull/1855
[^15]: OpenClawのコミット 9c831c7551、"chore: retire CLAUDE.md files"：https://github.com/openclaw/openclaw/commit/9c831c7551
[^16]: OpenClaw PR #132968：https://github.com/openclaw/openclaw/pull/132968
[^17]: AiderのIssue #4613、"Where is Paul?"：https://github.com/Aider-AI/aider/issues/4613
[^18]: oven-sh/bun CLAUDE.md：https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^19]: mastra changed-test-gate.yml：https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^20]: vercel/ai PR #22424：https://github.com/vercel/ai/pull/22424
[^21]: anthropics/claude-code issue-lifecycle.ts：https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^22]: Mastra Factory README、Board transition policy：https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^23]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md：https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^24]: withastro/astro PR #17475：https://github.com/withastro/astro/pull/17475
[^25]: oven-sh/bun REVIEW.md：https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^26]: openai/codex PR #2729：https://github.com/openai/codex/pull/2729
[^27]: Mastra, "Announcing Mastra Factory Beta"：https://mastra.ai/blog/announcing-mastra-factory-beta
[^28]: withastro/astro factory.yml：https://github.com/withastro/astro/blob/main/.github/factory.yml
[^29]: OpenHandsのPRテンプレート：https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^30]: OpenHands check_pr_description.py：https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^31]: gastownhall/beads AGENT_SIGNING.md：https://github.com/gastownhall/beads/blob/main/engdocs/AGENT_SIGNING.md
[^32]: withastro/astro PR #18030、"Revert forwarding user class to Picture's outer element"：https://github.com/withastro/astro/pull/18030
[^33]: withastro/astro PR #18052：https://github.com/withastro/astro/pull/18052
[^34]: OpenHands PR #18048：https://github.com/OpenHands/OpenHands/pull/18048
