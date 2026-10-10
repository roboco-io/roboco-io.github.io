---
title: "オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（2/4）：誰がマージするのか"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - openclaw
  - code-review
  - best-practices
---

> 「（マイグレーション・スキーマ・同期のパスへの変更は）マージ前に実際の人間によるレビューを受ける。例外も、セルフマージも、ボットだけによる承認もない（a real human review before merge — no exceptions, no self-merge, no bot-only approval）」 – Beads `PR_MAINTAINER_GUIDELINES.md`[^1]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

この記事は、4回シリーズ「オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス」の第2回です。

**シリーズの構成**

1. [判定基準と12のリポジトリ：何をファクトリーと呼び、どこで動いているのか](/ja/posts/software-factory-best-practices-from-open-source/)
2. 誰がマージするのか：リスクに基づく委任と権限構造（本記事）
3. [証拠でふるいにかけるファクトリー：「修正前には失敗する」ことの証明](/ja/posts/software-factory-evidence-before-fix/)
4. [失敗をルールに：自己改善ループとその限界](/ja/posts/software-factory-failures-into-rules/)

[第1回](/ja/posts/software-factory-best-practices-from-open-source/)では、公開リポジトリ12か所をリバースエンジニアリングし、8か所をソフトウェアファクトリーと判定しました。[^2] そのうち、ボットがmainブランチへのマージを大量に行っていることを確認できたのはOpenClawだけでした。ほかのファクトリーでは人による最終マージが主に観察され、そのマージはたいてい一人に集中していました。

今回はこの違いを掘り下げます。OpenClawはどのような条件でボットにマージを任せたのでしょうか。人のアカウントによるマージが観察されたプロジェクトは、なぜボットにマージを任せなかったのでしょうか。そして、その代わりに何によってエージェントの権限を制限しているのでしょうか。数値は第1回と同じく、2026年10月10日にGitHub APIで取得した値です。

## TL;DR

- OpenClawは、変更のリスク階層ごとに自動化の権限を変えています。ドキュメントの変更はエージェントがmainに直接pushし、通常のコードはゲートを通過すればボットがマージし、セキュリティポリシーとリリースは人が承認します。この階層はポリシーファイルとCODEOWNERSで定義されています。
- 人のアカウントによるマージが観察されたプロジェクトのリポジトリからは、その背景を3つ読み取れます。GitHub Appは自分のPRを承認できないという構造的な制約、レビューを省いたマージが事故を招いたという経験、そして何を作るか、変更が意図に合っているかは人が決めるという原則です。
- 人がマージした記録は、人がレビューした記録ではありません。BunではボットPRの82%が、GitHubの承認要件が残った状態でマージされました。OpenHandsでは、AIレビューボットの承認だけで必須承認を満たしたPRが多く見られました。マージ権限よりも重要なのは、その権限を行使する前に何を確認させるかです。

---

## 1. マージ権限のスペクトラム

まず、ファクトリーと判定したプロジェクトがマージをどう処理しているかを一つの表にまとめました。「マージ集中度」は、対象のPR群で最も多くマージした一つのアカウントの割合です。ブランチルールは、GitHub APIでmainブランチのルールを取得して確認しました。[^3]

| プロジェクト | マージゲート（ブランチルール） | 観察されたマージ主体 | マージ集中度 |
|---|---|---|---|
| OpenClaw | 必須チェック1つ、必須承認0件 + CODEOWNERSのパスのみ承認が必要 | 直近のマージ300件のうち203件をボットがマージ | - |
| Vercel AI SDK | 必須承認1件 + 必須チェック4つ | 9月のファクトリーPR 294件すべてを承認済みの状態で人がマージ | 294件中63% |
| OpenHands | 必須チェック1つ + 必須承認1件 | 直近のマージ100件すべてを人がマージ | 100件中69% |
| Beads | 必須チェック2つ + マージキュー | 直近のマージ300件のうち296件を一つのアカウントがマージ | 99% |
| mastra | 公開APIでは確認できず | 9月のボットPR 434件すべてを人がマージ | 82% |
| Bun | 公開APIでは確認できず | 9月のrobobun PR 446件のうち443件を人がマージ | 78% |
| Astro | 必須チェックのリストが空 | 9月のファクトリーPR 31件すべてを人が承認・マージ | 31件中28件 |

表の左の列が示すとおり、ボットによるマージを許す鍵はブランチルールです。OpenClawのmainブランチは必須承認の数が0です。その代わり、CODEOWNERSで指定したパスには該当チームの承認を求め、新しいコミットがpushされると以前の承認を無効にします。[^4] 一方、Vercel AI SDKとOpenHandsは1件以上の必須承認を求めます。この条件では、ファクトリーのAppは自分が作成したPRの承認要件を自分で満たせません。ただし、ほかのボットによる承認までは防げません。OpenHandsでは、実際にそうしたマージが多く見られました（5節）。

---

## 2. OpenClawがボットにマージを任せた条件

OpenClawでマージを行うボットは、メンテナンスボットのClawSweeperです。ClawSweeperはどんなPRでもマージするわけではありません。READMEに記された自動マージの条件は次のとおりです。最新のコミット（exact head）に対するレビューの判定が通過し、必須チェックがすべて通過し、マージ可能な状態であること。さらに、セキュリティチェック、メンテナーによる停止・承認の状態、リポジトリのポリシーゲートもすべて通過する必要があります。[^5] 観察日時点で、`clawsweeper:automerge`ラベルが付いたPR 803件のうち576件がマージされていました。

重要なのは、この自動マージが **オプトイン** だという点です。メンテナーがPRに`@clawsweeper automerge`と書いて初めて自動マージの対象になり、`@clawsweeper stop`と書くと自動マージが止まり、人によるレビューのラベルが付きます。これらのコマンドは書き込み権限を持つ人しか使えません。観察日時点で、`clawsweeper:human-review`ラベルが付いた項目は210件です。[^5]

さらに、変更の種類によって自動化に許される作業が異なります。リポジトリのファイルを総合すると、次のようなリスク階層が見えてきます。

| 変更の種類 | 自動化の権限 | 根拠ファイル |
|---|---|---|
| ドキュメント（`docs/*`、README、既存のCHANGELOGミラー） | Docs Agentは、許可されたパスにある既存ファイルの更新とミラーの再生成しかできない。ファイルの追加・削除やほかのパスの修正があれば失敗し、通過すればPRなしでmainに直接push | `docs-agent.yml`[^6] |
| 通常のコード | 必須チェックとボットのレビューを通過し、メンテナーがオプトインすればボットがマージ | ClawSweeper README[^5] |
| Issueから自動生成したPR | 自動マージしない。人がマージ | ClawSweeper README[^5] |
| 機密性の高いパス（認証など） | メンテナー権限のない作成者（エージェントを含む）は承認コマンドを受ける必要がある | `security-review-policy.yml`[^7] |
| セキュリティポリシー・CIのセキュリティ設定ファイル | 作成者に関係なくSecOpsチームの独立したレビューが必要 | `CODEOWNERS`[^4] |
| リリース・デプロイ、依存関係、スキーマ・権限の変更 | 人による明示的な承認が必要 | `AGENTS.md`[^8] |

機密性の高いパスを定めた`security-review-policy.yml`は、認証などのカテゴリーごとにパスのパターンを定義し、テストとドキュメントのパスは除外しています。2026年9月の変更により、メンテナー権限のない作成者は`/allow-security-sensitive-change`のようなコマンドでメンテナーの承認を得る必要があります。OpenClawの製品そのもので動くエージェントのアカウント（roboclaw-bot）もこれに含まれます。[^9] `CODEOWNERS`の1行目のコメントには「強いセキュリティ階層：すべての作成者に独立したSecOpsのレビューが必要（Hard security tier: an independent SecOps review is required for every author）」と書かれています。これに該当する項目が18個、リリース管理者チームが所有する項目が5個あります。[^4]

`AGENTS.md`は、人による明示的な承認が必要な作業をリストにしています。プロトコル・バージョンの変更、依存関係のパッチ、有料サービス、リリースとデプロイ、新しい設定オプション、公開されている契約を壊す変更、スキーマ・保持期間・権限の変更、破壊的な操作、50件を超える一括クローズがこれに含まれます。逆に、作業範囲内のバグ修正は改めて承認を得ずに進めて構いません。[^8] この連載の第1回の冒頭に引用した「修正して出荷する権限は、リリースする権限ではない（fix/ship authority is not release authority）」が、このリストの要約です。

まとめると、OpenClawがボットにマージを任せられた条件は3つです。第一に、ボットがマージしてよい変更の範囲がファイルで定義されています。第二に、セキュリティポリシーのファイルや機密性の高いパスのようにリスクの大きい変更は、CODEOWNERSとセキュリティガードが機械的に防ぎます。リリースや依存関係など残りの承認要件は`AGENTS.md`のガイドラインとして定められており、リリースは手動で実行するワークフローからしか始まりません。リリース環境に必須の承認者が設定されているかどうかは、公開APIでは確認できませんでした。第三に、人はいつでもオプトインを取り消して自動化を止められます。

---

## 3. 人によるマージを残した理由

人のアカウントによるマージが観察されたプロジェクトは、なぜボットにマージを任せなかったのでしょうか。リポジトリから読み取れる背景は3つあります。プロジェクトが自ら理由を明かしている場合もあれば、仕組みから推論した場合もあります。

### 3.1 GitHub Appは自分のPRを承認できない

Astro、mastra、Vercel AI SDKのファクトリーは、いずれもGitHub AppでPRを作成します。GitHubは、Appが自分で作成したPRを承認できないようにしています。そのため、Astroのレビュー用ペルソナは判定を承認レビューではなくコメントとして残し、mastraのレビューエージェントも自分のPRに対する判定を通常のコメントとして投稿します。[^10][^11] 必須承認が1件以上のリポジトリでは、ファクトリーのAppは自分のPRの承認要件を満たせません。そのため、ほかのボットが承認しない限り、人による承認が残ります。Vercel AI SDKはリリースPRの自動マージに個人のトークンを使っていますが、ワークフローのコメントはその理由を「本来はAppのトークンにすべきだが、そのためには2つ目のAppを登録する必要がある。vercel=ai-sdkのAppがすでにPRを作成しており、Appは自分のPRを承認できないからだ（this should really be an app token. But for that we would need to register a secondary app, since the vercel=ai-sdk app already creates the pull request and it cannot approve its own pull requests.）」と説明しています。[^12]

### 3.2 レビューを省いたマージが事故を起こした

Beadsはマージ済みのPR 440件を2か月かけて監査し、プロジェクトの最悪の欠陥は「レビューを省いた、実際の内容を隠した、あるいは残っていた反対意見を押し切ったマージ（merges that skipped review, hid their real contents, or overrode an outstanding objection）」から入り込んだと結論づけました。その結果、些細ではないPRのセルフマージを禁止し、マイグレーション・スキーマ・同期のパスには、この記事の冒頭の引用のとおり例外のない人によるレビューを求めるようにしました。[^1] 実際に、レビュー0件でセルフマージされたマイグレーションのPRがデータ破損を引き起こした記録が残っています。[^13]

ただし、このルールはまだ文書の中にしかありません。観察日時点で、Beadsのブランチルールが求めているのは必須チェックとマージキューだけで、レビューの必須条件はありません。文書自身も「これらのパスは慣習だけでなく、ブランチ保護（レビュー必須）で強制すべきだ（These paths should be enforced by branch protection (review-required), not just convention.）」と書き、その作業をプロジェクトオーナーの課題として残しています。[^1]

### 3.3 意図を判断する人が必要

Astroのファクトリーのドキュメントは、作成エージェントが「決してマージしない（never merges）」と明記しています。作成エージェントはレビュアーの変更要求やCIの失敗に対して最大5ラウンドまで修正し、予算を使い切ると`factory: needs human`ラベルを付けて自ら手を引きます。[^10] mastraでは、バグではないIssue（機能要望など）が人による受け入れの記録なしに計画の段階へ進めないよう、サーバーが止めています。観察日時点で、この承認を待っている未解決のIssueが50件あります。[^11] 何を作るか、その変更が意図に合っているかは人が決めるという原則です。

コードレビューについては、StrongDMが正反対のアプローチを取りました。StrongDMも、人が最初の仕様を与え、エージェントの質問に答える場面は残しています。しかし「コードを人間がレビューしてはならない（Code must not be reviewed by humans）」というルールを置き、人のレビューの代わりに、コードリポジトリの外に置いたシナリオで検証すると説明しています。[^14] ただし、第1回で取り上げたとおり、その運用は公開リポジトリでは観察できません。

---

## 4. 権限をコードで実装する方法

人がマージするとしても、エージェントにできることは絞る必要があります。観察したプロジェクトは、この境界をプロンプトではなく権限構造で実装していました。共通する原則は、 **判断はエージェントが行い、取り消しにくい実行はルールベースのコードが行う** ということです。

- **書き込みツールを絞り、回数を制限する。** Claude CodeのリポジトリにあるIssue分類エージェントが使えるのは、読み取り専用のGitHubコマンドのラッパーと、ラベル編集スクリプトだけです。ラベル編集スクリプトは1回の実行につき2回までしか呼び出せず、ファイルの編集とWebへのアクセスは禁止されています。誰でもIssueを作成してこの処理を実行させられるからです。[^15]
- **取り消しにくい行動は、猶予期間の後にスクリプトが行う。** 同じリポジトリでは、Issueを実際にクローズするのはエージェントではなく、ルールベースのスクリプトです。重複候補には3日、情報提供の依頼には7日、古いIssueには14日の猶予期間があります。[^16] 重複候補は、Issueの作成者が反対の意思表示をするか、新しいコメントが付けばクローズしません。[^17] 賛成のリアクションが10個以上あるか、担当者が割り当てられているIssueは、古いIssueの処理から除外されます。[^18]
- **書き込みトークンをエージェントに渡さない。** Astroのファクトリーでは、書き込みトークンはコミット・pushの段階のワークフローコードにしかありません。分類器と動作確認エージェントにはツールがなく、レビュアーは読み取り専用のツールしか使いません。レビューの設定とスキルは、PRのブランチではなく対象ブランチから読み込みます。そのため、PRがレビューのルールを一緒に変更しても、そのPRのレビューには適用されません。[^10] OpenAI CodexのIssue自動化も、Codexを読み取り専用のサンドボックスで実行し、コメントの投稿はCodexを含まない別のジョブが担当します。[^19]
- **状態遷移をサーバーが検査する。** mastraのファクトリーサーバーは、作業カードのすべての遷移をリビジョン検査付きのトランザクションで処理します。人が行うべき遷移は、要求した主体と要求が届いた経路の両方が人に該当する場合にのみ通過します。エージェントはカードを完了に移せず、カードを完了にできるのはマージだけです。[^11]
- **実行の直前に状態を再確認する。** OpenClawのClawSweeperは、コントリビューターのブランチにpushする前に90秒待ってからPRの最新コミットを読み直し、その間に変わっていればpushせずにキューへ戻します。[^5]

---

## 5. 人がマージした記録は、人がレビューした記録ではない

第1回では、マージが一人に集中していると書きました。さらに詳しく見ると、集中よりも目立つ点があります。マージの記録は残っていても、レビューの記録がないケースが多いということです。

- Bunで9月にマージされたrobobunのPR 446件のうち368件（82%）は、GitHub上で承認要件が残った状態（`REVIEW_REQUIRED`）のまま、メンテナー権限でマージされました。[^20] マージした人が実際にどこまで確認したのかは、記録からは確認できません。記録上は、マージした人が最終的な判断者です。
- mastraでは、ファクトリーのレビューエージェントが最後に変更を要求したボットPRを、人がそのままマージしたケースがありました。サンプル27件中3件、ラベル基準では9月のボットPRで14件です。[^21]
- OpenHandsは必須承認を1件求めていますが、直近にマージされたPR 40件のうち26件は、AIレビューボットの承認だけでこの要件を満たしていました。[^22] そうしてマージされたエージェントのPRの一つは、ほかのリポジトリの機能を壊すおそれがあるという理由で、人によって差し戻されました。[^23]

反対に、Vercel AI SDKの9月のファクトリーPR 294件は、すべて承認（`APPROVED`）の状態で人がマージしていました。承認者が人かどうかは20件のサンプルで確認し、すべて人でした。[^24] また、ボットPRのバックポートPRは、元のPRを最後にレビューした人を担当者に割り当てます。[^25] レビューした人に後続の作業を任せる仕組みだと読めます。

---

## 6. ベストプラクティス

観察した仕組みを、ほかのチームが取り入れられる形にまとめると次のとおりです。各項目に、根拠となったプロジェクトを記しました。

1. **変更の種類ごとのリスク階層をファイルで定義し、階層ごとに自動化の権限を変える。** ドキュメント、通常のコード、機密性の高いパス、セキュリティポリシー、リリースを分け、セキュリティポリシーや機密性の高いパスのようにリスクの大きい階層は、CODEOWNERSとセキュリティガードで機械的に強制します。（OpenClaw）
2. **ボットの自動マージはオプトインから始め、人がいつでも止められるようにする。** 停止コマンドと人によるレビューのラベルを用意し、そのコマンドを使える人を書き込み権限を持つ人に限定します。（OpenClaw）
3. **エージェントに書き込みトークンを渡さず、書き込みは狭い専用の段階でのみ行わせる。** 書き込みツールは呼び出し回数まで制限します。（Astro、Claude Code、OpenAI Codex）
4. **取り消しにくい行動は、猶予期間と反対のシグナルの確認を経て、ルールベースのスクリプトに実行させる。** （Claude Code）
5. **レビューのルールは、文書ではなくブランチルールで強制する。** 文書にしかないルールは守られないことがあります。（Beadsの教訓）
6. **承認とレビューを記録に残し、レビューした人を後続作業の担当者に割り当てる。** （Vercel AI SDK）

最後に、観察から出てきた提案を一つ付け加えます。公開資料からは、マージがどれだけ一人に集中しているかを指標として管理している形跡は見つかりませんでした。しかし第1回で見たように、Aiderではメンテナーがほかの仕事で忙しくなると、コード開発が大きく減りました。Issue整理のボットは今も動いていますが、コードをマージする人がいません。マージ集中度と、承認なしでマージされた割合を定期的に確認するだけでも、ファクトリーの単一障害点を事前に把握できます。これはリポジトリで観察した事実ではなく、観察をもとにした私の提案です。

---

## 結論

誰がマージするのかという問いへの答えは、思ったほど単純ではありませんでした。OpenClawはボットにマージを任せましたが、その代わりにリスク階層、ブランチルール、オプトインと停止コマンドを綿密に設計しました。ほかのプロジェクトは人によるマージを残しましたが、その人が実際に何を確認したのかはプロジェクトによって大きく異なりました。

結局のところ、ファクトリーの安全性を決めるのは、マージ権限を誰に与えるかよりも、マージの前に何が確認されるよう強制するかです。次回は、その確認の核心である証拠を取り上げます。エージェントが作った修正が本当に問題を解決したのかを、各プロジェクトがどのように証明させているのかを、「修正前には失敗する」という証拠を中心に見ていきます。

**次の記事：** [（3/4）証拠でふるいにかけるファクトリー：「修正前には失敗する」ことの証明](/ja/posts/software-factory-evidence-before-fix/)

---

[^1]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md：https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^2]: オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（1/4）：判定基準と12のリポジトリ：https://roboco.io/ja/posts/software-factory-best-practices-from-open-source/
[^3]: GitHub REST API、ブランチルールの取得 `GET /repos/{owner}/{repo}/rules/branches/main`（2026-10-10）：https://docs.github.com/en/rest/repos/rules
[^4]: OpenClaw CODEOWNERS：https://github.com/openclaw/openclaw/blob/main/.github/CODEOWNERS
[^5]: openclaw/clawsweeper README：https://github.com/openclaw/clawsweeper/blob/main/README.md
[^6]: OpenClaw docs-agent.yml：https://github.com/openclaw/openclaw/blob/main/.github/workflows/docs-agent.yml
[^7]: OpenClaw security-review-policy.yml：https://github.com/openclaw/openclaw/blob/main/.github/security-review-policy.yml
[^8]: OpenClaw AGENTS.md：https://github.com/openclaw/openclaw/blob/main/AGENTS.md
[^9]: OpenClaw PR #152415：https://github.com/openclaw/openclaw/pull/152415
[^10]: withastro/factory README：https://github.com/withastro/factory
[^11]: Mastra Factory README：https://github.com/mastra-ai/mastra/blob/main/mastracode/factory/README.md
[^12]: vercel/ai auto-merge-release-prs.yml：https://github.com/vercel/ai/blob/main/.github/workflows/auto-merge-release-prs.yml
[^13]: gastownhall/beads PR #4039：https://github.com/gastownhall/beads/pull/4039
[^14]: StrongDM, Software Factory：https://factory.strongdm.ai/
[^15]: anthropics/claude-code claude-issue-triage.yml：https://github.com/anthropics/claude-code/blob/main/.github/workflows/claude-issue-triage.yml
[^16]: anthropics/claude-code issue-lifecycle.ts：https://github.com/anthropics/claude-code/blob/main/scripts/issue-lifecycle.ts
[^17]: anthropics/claude-code auto-close-duplicates.ts：https://github.com/anthropics/claude-code/blob/main/scripts/auto-close-duplicates.ts
[^18]: anthropics/claude-code sweep.ts：https://github.com/anthropics/claude-code/blob/main/scripts/sweep.ts
[^19]: openai/codex issue-deduplicator.yml：https://github.com/openai/codex/blob/main/.github/workflows/issue-deduplicator.yml
[^20]: oven-sh/bun、robobunが作成したPR。2026年9月にマージされたPRのレビュー状態をGitHub APIで集計（2026-10-10）：https://github.com/oven-sh/bun/pulls?q=is%3Apr+is%3Amerged+author%3Arobobun
[^21]: mastra-ai/mastra、mastra-platformボットが作成したマージ済みPR。2026年9月にマージされたPRをGitHub APIで集計（2026-10-10）：https://github.com/mastra-ai/mastra/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fmastra-platform
[^22]: OpenHands/OpenHands、直近にマージされたPR 40件のレビュー記録をGitHub APIで確認（2026-10-10）：https://github.com/OpenHands/OpenHands/pulls?q=is%3Apr+is%3Amerged
[^23]: OpenHands PR #18048：https://github.com/OpenHands/OpenHands/pull/18048
[^24]: vercel/ai、ai-sdk-factoryボットが作成した2026年9月のマージ済みPRのレビュー状態をGitHub APIで集計（2026-10-10）：https://github.com/vercel/ai/pulls?q=is%3Apr+is%3Amerged+author%3Aapp%2Fai-sdk-factory
[^25]: vercel/ai backport.yml：https://github.com/vercel/ai/blob/main/.github/workflows/backport.yml
