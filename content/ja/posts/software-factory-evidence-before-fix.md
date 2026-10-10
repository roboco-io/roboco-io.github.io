---
title: "オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（3/4）：証拠でふるいにかけるファクトリー"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - testing
  - code-review
  - best-practices
---

> 「`USE_SYSTEM_BUN=1`で通るテストは有効ではない（Your test is NOT VALID if it passes with `USE_SYSTEM_BUN=1`）」 – Bun `CLAUDE.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

この記事は、4回シリーズ「オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス」の第3回です。

**シリーズの構成**

1. [判定基準と12のリポジトリ：何をファクトリーと呼び、どこで動いているのか](/ja/posts/software-factory-best-practices-from-open-source/)
2. [誰がマージするのか：リスクに基づく委任と権限構造](/ja/posts/software-factory-who-merges/)
3. 証拠でふるいにかけるファクトリー：「修正前には失敗する」ことの証明（本記事）
4. [失敗をルールに：自己改善ループとその限界](/ja/posts/software-factory-failures-into-rules/)

冒頭の引用は、Bunリポジトリのエージェント向け指示にある一文です。`USE_SYSTEM_BUN=1`は、修正する前の既存のBunリリースでテストを実行させる設定です。つまりこのルールは、「修正前のコードでも通るテストは何も証明しない」という意味です。

[第2回](/ja/posts/software-factory-who-merges/)では、マージ権限を誰に与えるかよりも、マージ前に何が確認されるよう強制するかが重要だとまとめました。[^2] 今回はその確認の中身を扱います。エージェントはコードを素早く書きますが、常に通る無意味なテストや、実際より誇張した作業報告も簡単に作ります。そしてBunのエージェント`robobun`が2026年9月の1か月間に作成したPRは2,313件です。[^3] この規模では、人がすべてのdiffを読むことはできません。そこでファクトリーは、人がコードを読む前にまず**証拠**を見るようにしています。数値はこれまでの回と同じく、2026年10月10日にGitHub APIで取得した値です。

## TL;DR

- 観察した事例をまとめると、ファクトリーが求める証拠は三層です。問題が実際に存在することを示す再現、修正前には失敗し修正後には通るテスト、そして単体テストを超えた実際の動作の証拠です。
- そのうち3つのプロジェクトがそれぞれ異なる方法で実装した仕組みが、「修正前の失敗」の証明です。BunはPR本文に修正前の失敗ログを添付し、mastraはCIが新しいテストを修正前のコードに対して実行して失敗するかを確認し、観察したVercel AI SDKの修正PRは再現 → 失敗するテスト → 修正の順にコミットを積み上げていました。
- 証拠は回避されることがあります。mastraでは修正前失敗ゲートの失敗ラベルが付いたままマージされたPRがあり、Astroでは「動作する」と確認された修正が意図と異なっていたため差し戻されました。証拠の仕組みは、マージ条件と結びついたとき、そして意図まで確認したときに効力を持つと私は考えています。

---

## 1. 三層の証拠

観察したプロジェクトがエージェントに求める証拠を私の基準でまとめると、3種類になります。

| 証拠の種類 | 問いかける質問 | 代表的な仕組み |
|---|---|---|
| 再現 | 問題は実際に存在するか | Vercel AI SDKの再現PR、Astroの再現ステップ |
| 修正前の失敗 | このテストは本当にその問題を捉えるか | Bunの証拠ブロック、mastraの修正前コードテストゲート、Vercel AI SDKのコミット順序 |
| 実際の動作 | 単体テストの外でも動作するか | OpenClawの動作証拠ラベル、OpenHandsのライブE2E、Astroのプレビューリリース |

私は、この三層が順番に積み重なるものだと考えています。再現がなければ何を直したのかがわからず、修正前の失敗がなければテストが何を証明しているのかがわかりません。そして、単体テストが通っても実際の環境では壊れることがある、というのが三層目が必要な理由です。

---

## 2. まず再現する

Vercel AI SDKのファクトリーは、バグのIssueを受け取るとまず再現を試みます。再現に成功すると、サンプルファイルと再現記録ファイル（`reproduction-replay.json`）を含むドラフトPRを作成します。観察したIssue #22412の再現PRは、確認後にクローズされました。[^4] 再現結果はラベルとして残ります。`task-bug-reproduction-success`、`-cannot-reproduce`、`-issue-invalid`、`-out-of-scope`といったラベルがあり、サポートしているバージョン（v5、v6）ごとに結果を個別に記録します。[^5] この結果によって次のステップが分岐するように見えますが、ファクトリーの内部ルールはリポジトリの外にあるため、確認できませんでした。

Astroのファクトリーは、再現 → 診断 → 意図の検証 → 修正の順に作業します。各ステップには止まるためのルールがあります。再現用サーバーの起動に2回失敗すると、あきらめてレポートを書きます。診断の確信度が低ければ、そこで止まります。意図の検証ステップで「意図された動作」と判定すると、修正しません。[^6] 確信度が低いときには、コードを直す代わりに失敗するテストと`// TRIAGE:`コメントだけを残す経路もあります。人が引き継げるように、手がかりだけを残すのです。

Bunでは、エージェントがIssueに再現結果を直接書き込みます。2026年9月に作成されたIssueのうち441件にrobobunのコメントがあり、再現できなかった場合は、公式リリースのバイナリで実行した記録とともに「再現できない」と残します。[^7]

---

## 3. 修正前には失敗しなければならない

再現が問題の存在を証明するなら、修正前の失敗はテストの価値を証明します。3つのプロジェクトが、これをそれぞれ異なる方法で実装しました。

### 3.1 Bun：PR本文の証拠ブロック

Bunのエージェント向け指示は、修正前のリリースで通るテストを無効と定めています。[^1] このルールはPR本文に機械的に表れます。2026年9月にrobobunが作成したPR 2,313件のうち、1,827件に証拠ブロックがあります。[^3] 証拠ブロックには、「修正なしでmainで失敗（fails on main, without fix）」した実行ログ、ゲートを何回繰り返して通過したか、そして変更したファイルごとに何回読み、直し、テストしたかが含まれています。[^8] PR本文も、問題（Problem）、検証（Verified）、短所（Downsides）といった固定のセクションに従います。レビュアーはコードを読む前に、まずこの証拠を見ます。

### 3.2 mastra：修正前のコードに新しいテストを実行するCI

mastraは同じ原則をCIで検査しています。`changed-test-gate.yml`はPRの基準コミットをチェックアウトしたうえで、PRが変更したテストファイルだけをPR側から取り込み、修正前のコードに対して実行します。このテストは失敗するのが正常です。結果はラベルとして付きます。失敗すれば「変更されたテストが想定どおり基準コードで失敗した」という意味の`tests: green ✅`、通ってしまえば`tests: failing ❌`、テストがなければ`tests: no tests added`です。[^9]

このワークフローはセキュリティにも配慮しています。PRのコードはシークレットのない環境で実行し、ラベルを付ける書き込み処理は別のワークフローに分離しました。エージェントが書いたテストコードが、書き込み権限を持つトークンに触れないようにするためです。[^9] 2026年9月にマージされたボットのPR 434件のラベルは、`tests: green ✅`が354件、`tests: no tests added`が33件、`tests: failing ❌`が24件でした。[^10]

### 3.3 Vercel AI SDK：コミットの順序が証拠になる

観察したVercel AI SDKの修正PR #22424は、「再現 → 失敗するテスト → 修正」の順にコミットを積み上げていました。コミットのタイトルは「reproduction (reproduced)」「failing tests」「fix #22412」の順です。コミット履歴そのものが、修正前にテストが失敗していたことの記録になります。続いてAIレビューが、最初の再現をもう一度実行した結果を真っ先に確認し、Issueが解決されたか、副作用や性能上のリスクはないかを判定します。このPRでは、AIレビューが1回目にプロダクションのコードパスが修正されていないとして変更を要求し、修正後に承認しました。[^11] 2026年9月のファクトリーのPRのうち、AIレビューが1回目に変更を要求したPRは20件です。[^5]

OpenClawの自動実装ワーカーとAstroのファクトリーも、修正前に失敗する回帰テストを先に作るよう指示されています。[^12][^6]

---

## 4. 単体テストだけでは足りない

修正前に失敗するテストも、結局は単体テストであることがあります。いくつかのプロジェクトは、ここからさらに一歩進みました。

OpenClawは2026年10月、最近の作業で単体テストが捉えられなかった欠陥5件がそのまま出荷されたと記録し、指示を変更しました。欠陥の中には、キャッシュトークンが0として記録される問題、コストをかけて得た結果を捨ててしまう問題、状態の表示を保存しないために同じ処理が繰り返されるループがありました。変更後の指示は、テストの数よりも意味のある統合の証拠を優先します。[^13] `AGENTS.md`の原則も「テストの数より動作（Behavior over test count）」です。[^14] 外部コントリビューターのPRには実際の動作の証拠を確認するワークフローが走り、証拠が十分かどうかを`proof: sufficient`のようなラベルで示します。[^15]

OpenHandsのPRテンプレートは、エージェントに「単体テストを実行するだけでは不十分です。実行したコマンドを正確に説明し、ログ、スクリーンショット、または再現メモを含めてください（Just running unit tests is NOT sufficient. Explain exactly what command you ran and include logs, screenshots, or reproduction notes.）」と指示しています。フロントエンドを変更したPRは、実行中のアプリのスクリーンショットか動画がなければCIを通過できません。[^16][^17] CIは実際のエージェントサーバーを立ち上げてライブE2Eを実行し、その結果の動画をPRコメントとして残します。[^18] そして毎日、エージェントがベースライン以降に変わった機能だけを実際のUIで再検証します。[^19]

Beadsのエージェント向け指示は、この原則を一文で書いています。「変更がエンドツーエンドで動作するという証拠が必要です。『単体テストが通る』だけでは証拠になりません（Evidence that the change works end-to-end is required; "unit tests pass" alone is not evidence.）」[^20]

Astroは人を証拠集めに巻き込みました。ファクトリーが作った修正をまずインストール可能なプレビューパッケージとして公開し、Issueを報告した人かメンテナーが自分の環境で動作を確認して初めてPRが作成されます。2026年9月のファクトリーのPR 31件のうち、19件はIssueの報告者が、12件はメンテナーが確認しました。[^21]

StrongDMは逆方向の極端を選んだと説明しています。検証シナリオをコードリポジトリの外に置いてエージェントがシナリオをコードに合わせて書き換えられないようにし、この「ホールドアウトシナリオ」が通るまでループを回すというものです。[^22] ただし、これは企業自身による説明であり、公開リポジトリでは確認できませんでした。

---

## 5. 証拠を回避させない

証拠の仕組みは回避されることがあります。観察したプロジェクトは、いくつかの回避経路を塞いでいました。

- **不安定なテスト（flaky test）を言い訳にさせない。** BunのPRマージ手順の指示は、すべてのプラットフォームでCIが通ることを必須条件とし、「おそらく不安定なテストだ」と主張するなら、mainで同じ失敗が起きたリンクを添付するよう求めています。[^23] OpenClawは、不安定なテストを再実行や再pushでやり過ごすことを禁止し、原因分析を求めました。[^24] OpenAI CodexのPR監視エージェントは、不安定な失敗を最大3回までしか再実行できませんでした。[^25]
- **レビュアーが証拠を自分で作り直す。** mastraのレビューエージェントは、サンドボックスで変更されたパッケージのテストと型チェックを自ら実行します。その際、GitHubトークンを環境から消去します。CIの結果は参考にとどめ、判定を投稿する直前に、PRの最新コミットが自分の検証したコミットと同じかを再確認します。[^26]
- **誇張した報告を防ぐ。** Bunのエージェント向け指示には「謙虚かつ正直であれ。コミット、PR、ユーザーへのメッセージで、やり遂げたことや実際に動くものを決して誇張するな（Be humble & honest - NEVER overstate what you got done or what actually works in commits, PRs or in messages to the user.）」と書かれています。[^1] そしてPRに`slop`ラベルが付くと、ワークフローがタイトルを変更してPRをクローズします。その際に残すメッセージは、理由として、問題が実際に存在するかを確認していないこと、修正が動作するかをテストしていないこと、コードベースについての誤った前提、不完全または誤解を招く変更を挙げています。このラベルを自動で付けるワークフローはないため、人が付けているものと見られます。このラベルが付いたPR 248件のうち、228件がrobobunのPRです。[^27]

それでも穴は残っています。

- **証拠とマージ条件の結びつきが弱い。** mastraの修正前失敗ゲートは、結果をラベルとして付けます。ところが、`tests: failing ❌`ラベルが付いたままマージされたPRが83件あります。[^10] ブランチ保護の設定は公開APIでは確認できないため、これがルール上許容されたものなのか、人が回避したものなのかはわかりません。Astroは公開APIで見る限り、mainブランチの必須ステータスチェックのリストが空で、リリースPRの1件はWindowsのE2Eテストが失敗した状態でマージされました。[^28]
- **「動作する」という証拠は「意図に合っている」ことを保証しない。** Astroでは、メンテナーが動作を確認したファクトリーの修正がマージされましたが、実際には意図された動作を変えるものだったため、リリース前に差し戻されました。[^29] 動作確認を経ていたにもかかわらず、そうなったのです。

---

## 6. ベストプラクティス

1. **修正前のコードで通るテストは無効と定める。** ルールをエージェント向け指示に書き、修正前の失敗ログをPR本文に添付させます。（Bun）
2. **そのルールをCIで検査し、結果をマージ条件に結びつける。** PRが変更したテストだけを修正前のコードに対して実行します。ラベルとして残すだけでは回避されます。（mastraの仕組み、mastraとAstroの教訓）
3. **再現 → 失敗するテスト → 修正の順にコミットし、最初の再現をもう一度実行して解決を判定する。** コミット履歴がそのまま証拠になります。（Vercel AI SDK）
4. **再現と診断の各ステップに停止条件を設ける。** 再現できない、または確信度が低い場合は修正せず、手がかりだけを残します。（Astro）
5. **単体テストの外での動作の証拠を求める。** 実行したコマンドとログ、スクリーンショット、ライブE2E、実際のユーザーによる確認のように、実際の環境に近い証拠を求めます。（OpenClaw、OpenHands、Beads、Astro）
6. **エージェントが書いたテストコードは、シークレットと書き込み権限のない場所で実行する。** （mastra）
7. **不安定なテストを理由にやり過ごすなら根拠を求め、再試行の回数を制限する。** （Bun、OpenClaw、OpenAI Codex）

---

## 結論

エージェントが1日に数十件のPRを作成する環境では、レビュアーがdiffを読むだけでは品質を守れません。観察したファクトリーは、レビューの出発点をコードから証拠へ移しました。問題が存在することを示す再現、テストがその問題を捉えることを示す修正前の失敗、そして実際の環境での動作の証拠です。

しかし、証拠も万能ではありません。証拠がマージ条件と結びついていなければ回避されることがあり、動作するという証拠があっても意図と異なることがあります。次回は、こうした失敗が起きた後を扱います。プロジェクトが失敗をどのようにルールや指示に変えているのか、そしてその自己改善ループがまだどこで途切れているのかを見ていきます。

**次の記事：** [（4/4）失敗をルールに：自己改善ループとその限界](/ja/posts/software-factory-failures-into-rules/)

---

[^1]: oven-sh/bun CLAUDE.md：https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^2]: オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（2/4）：誰がマージするのか：https://roboco.io/ja/posts/software-factory-who-merges/
[^3]: oven-sh/bun、robobunが作成したPR。2026年9月に作成されたPRとPR本文をGitHub APIで集計（2026年10月10日）：https://github.com/oven-sh/bun/pulls?q=is%3Apr+author%3Arobobun
[^4]: vercel/ai PR #22416（再現PR）：https://github.com/vercel/ai/pull/22416
[^5]: vercel/ai ラベル一覧。ラベルごとのPR数をGitHub APIで集計（2026年10月10日）：https://github.com/vercel/ai/labels
[^6]: withastro/astro .agents/skills（triageスキル）：https://github.com/withastro/astro/tree/main/.agents/skills
[^7]: oven-sh/bun Issue #44276：https://github.com/oven-sh/bun/issues/44276
[^8]: oven-sh/bun PR #40556：https://github.com/oven-sh/bun/pull/40556
[^9]: mastra changed-test-gate.yml：https://github.com/mastra-ai/mastra/blob/main/.github/workflows/changed-test-gate.yml
[^10]: mastra-ai/mastra、2026年9月にマージされたボットのPR 434件のテストゲートラベルの分布と、`tests: failing ❌`ラベルが付いたマージ済みPRの数をGitHub APIで集計（2026年10月10日）：https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+label%3A%22tests%3A+failing+%E2%9D%8C%22
[^11]: vercel/ai PR #22424：https://github.com/vercel/ai/pull/22424
[^12]: openclaw/clawsweeper README：https://github.com/openclaw/clawsweeper/blob/main/README.md
[^13]: OpenClaw PR #168083：https://github.com/openclaw/openclaw/pull/168083
[^14]: OpenClaw AGENTS.md：https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^15]: OpenClaw real-behavior-proof.yml：https://github.com/openclaw/openclaw/blob/main/.github/workflows/real-behavior-proof.yml
[^16]: OpenHands PRテンプレート：https://github.com/OpenHands/OpenHands/blob/main/.github/pull_request_template.md
[^17]: OpenHands check_pr_description.py：https://github.com/OpenHands/OpenHands/blob/main/.github/scripts/check_pr_description.py
[^18]: OpenHands ci.yml：https://github.com/OpenHands/OpenHands/blob/main/.github/workflows/ci.yml
[^19]: OpenHands verify-openhandsスキル、daily.md：https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/references/daily.md
[^20]: gastownhall/beads AGENTS.md：https://github.com/gastownhall/beads/blob/main/AGENTS.md
[^21]: withastro/astro factory.yml：https://github.com/withastro/astro/blob/main/.github/factory.yml
[^22]: StrongDM, Software Factory：https://factory.strongdm.ai/
[^23]: oven-sh/bun .claude/docs/landing-prs.md：https://github.com/oven-sh/bun/blob/main/.claude/docs/landing-prs.md
[^24]: OpenClaw コミット 3b76ad8461：https://github.com/openclaw/openclaw/commit/3b76ad8461
[^25]: openai/codex babysit-prスキル（削除前のバージョン）：https://github.com/openai/codex/blob/5e96aabd68dc6194f5ad928cb7f5d0bc71b72df9/.codex/skills/babysit-pr/SKILL.md
[^26]: mastra factory-reviewスキル：https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^27]: oven-sh/bun on-slop.yml：https://github.com/oven-sh/bun/blob/main/.github/workflows/on-slop.yml
[^28]: withastro/astro PR #18113：https://github.com/withastro/astro/pull/18113
[^29]: withastro/astro PR #18030：https://github.com/withastro/astro/pull/18030
