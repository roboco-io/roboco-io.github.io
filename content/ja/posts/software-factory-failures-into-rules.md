---
title: "オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（4/4）：失敗をルールに"
date: 2026-10-10T10:00:00+09:00
draft: false
toc: false
images:
tags:
  - software-factory
  - agentic-dev
  - agents-md
  - continuous-improvement
  - best-practices
---

> 「この経路には成功率に応じた実行制限がなく、制限を設けない理由も見つからなかった（The lane has no rate gate, and I found no reason for that）」 – OpenClaw ClawSweeper PR #1855[^1]

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

---

この記事は、4回シリーズ「オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス」の最終回です。

**シリーズの構成**

1. [判定基準と12のリポジトリ：何をファクトリーと呼び、どこで動いているのか](/ja/posts/software-factory-best-practices-from-open-source/)
2. [誰がマージするのか：リスクに基づく委任と権限構造](/ja/posts/software-factory-who-merges/)
3. [証拠でふるいにかけるファクトリー：「修正前には失敗する」ことの証明](/ja/posts/software-factory-evidence-before-fix/)
4. 失敗をルールに：自己改善ループとその限界（本記事）

冒頭の引用は、OpenClawの自動実装ワーカーが1週間で52回成功し256回失敗したあと、それを報告したPRに書かれた一文です。そのPRは、失敗率が高いと自動実装を止める仕組みを追加しました。[^1] 失敗を発見し、原因を突き止め、二度と起きないようにルールや仕組みを変えること。これが[第1回](/ja/posts/software-factory-best-practices-from-open-source/)で定めた判定基準の6番目、自己改善ループです。[^2]

[第3回](/ja/posts/software-factory-evidence-before-fix/)では、証拠の仕組みも回避されたり、意図を見落としたりしうることを見ました。[^3] 今回は、そうした失敗が起きたあとを扱います。プロジェクトは失敗をどこに、どのような形で戻しているのでしょうか？ そして、そのループはどこで途切れるのでしょうか？ 数値はこれまでの回と同じく、2026年10月10日にGitHub APIで取得した値です。

## TL;DR

- 観察したファクトリーは、失敗を4つの場所に戻しています。エージェント向けの指示とスキル、CIチェック、サーバーやワークフローの仕組み、そして自動化を止めたり縮小したりする決定です。
- 事例をもとに、私は3つのことを勧めます。失敗を根拠とともに記録すること、原因をエージェントではなく指示文と仕組みに求めること、そして可能であれば指示とCIチェックを一緒に直すことです。
- 今回の公開資料の調査では、最後の段階である効果確認の運用記録は限られていました。ルールを追加した記録は多いものの、そのルールが守られているかを定期的に自動で確認する記録は見つけにくいものでした。取り消した決定が記憶されず、同じミスが繰り返された事例もあります。

---

## 1. 自己改善ループの4つの段階

自己改善ループは4つの段階に分けられます。失敗を発見し、原因を診断し、ルールや仕組みに変え、その効果を確認することです。各段階がリポジトリでどのように見えたかをまとめると、次のとおりです。

| 段階 | リポジトリで観察した例 |
|---|---|
| 1. 発見 | OpenClawの失敗率の集計、OpenHandsの日次検証、Beadsによるマージ済みPR 440件の監査、Vercel AI SDKの`factory-flawed`ラベル |
| 2. 診断 | Astroの「合理化の余地」の診断、OpenClawによる指示の切り詰めの発見、Claude Codeによる権限モードの誤作動の発見 |
| 3. ルール化 | Beads・OpenClaw・Bunの指示の修正、Astroのスキルの修正、mastraのサーバー側の仕組みの追加、OpenClawのサーキットブレーカー |
| 4. 効果確認 | 公開記録は限られている。Astroはスキル評価（eval）を作ったが、CIにはつないでいない |

前の3つの段階は複数のプロジェクトで観察されました。4番目の段階は、今回の調査では公開された記録だけではほとんど確認できませんでした。この差については、記事の後半で改めて扱います。

---

## 2. 失敗を根拠とともに記録する

ルールだけを残して理由を消すと、あとでそのルールを守るべきか廃止すべきかを判断できなくなります。エージェントも、ルールの範囲を推測しなければなりません。うまく機能しているプロジェクトは、ルールのそばに、そのルールを生んだ出来事を残しています。

最も徹底しているのはBeadsです。メンテナー向け指針の「マージの規律（Merge Discipline）」節は2026年6月12日に追加され、根拠としてマージ済みPR 440件を2か月にわたって監査した結果を挙げています。[^4] 「先行事例の確認（Prior art）」節は2026年7月27日に追加され、その前日に起きた出来事を「きっかけとなった出来事（Motivating incident）」として記しています。作成から44日たったPRが20日間マージ可能な状態で待っている間に、作成から5日の重複PRが一つのコメントもなく自動マージされた出来事です。その結果、すべてのレビューの前に同じテーマのオープンなPRを探す手順が義務になりました。[^5] `CODEOWNERS`のコメントにも、マイグレーション事故を起こしたPRの番号が書かれています。[^6]

Bunは記録を逆向きに活用しました。レビューのフィードバックが修正コミットにつながったマージ済みPR約2,500件のレビュー履歴から、マージを止めた理由だけを集めて`REVIEW.md`を作りました。このファイルはエージェント向け指示の一部として使われています。レビューボットもこのファイルを基準にしているように見えますが、その接続設定は公開リポジトリでは確認できませんでした。[^7] OpenClawは、指示を変更するPRの本文に、根拠となった実際の欠陥を列挙します。2026年10月のあるPRは、単体テストが見逃した欠陥5件を一つずつ挙げたうえで、テストの指針を変更しました。[^8]

---

## 3. 原因を指示文と仕組みに求める

エージェントがミスをしたときに「エージェントが力不足だった」と結論づけると、直すものがなくなります。観察したプロジェクトは、原因をエージェントに与えた指示文や仕組みに求めていました。

### 3.1 指示文が合理化を許していた

Astroのファクトリーが作ったPRは、changeset（リリースノート用の変更記録ファイル）なしで提出されることがよくありました。Astroはその原因を、軽微な修正なら省略してもよいとLLMが合理化できるように書かれた指示文にあると診断しました。そして、任意の段階だったchangesetの作成を必須に書き直し、例外を許す文言を削除し、作業を終える直前に`git status`を確認する段階を追加しました。[^9] Astroのリポジトリには、こうした修正が続いています。

| 日付 | 観察された失敗 | スキルの変更 |
|---|---|---|
| 2026-05-20 | バグは早い段階で確認したが、古いサーバーと格闘するうちにタイムアウトし、報告書を書けなかった | サーバーの起動に2回失敗したら諦めるルール[^10] |
| 2026-07-20 | 一部のボットPRがlintと型チェックを通らなかった | チェックの強化、トークンを節約する`lint:ai`コマンドの追加[^11] |
| 2026-08-20 | ボットPRでchangesetがよく抜けていた | 上で述べた指示文の書き直し[^9] |
| 2026-09-28 | ボットPRが一時的な再現環境の項目を`pnpm-lock.yaml`に含めていた | 作業の後片付けの段階にロックファイルの復元を追加[^12] |

最後の事例では、Issueが開かれてから約4時間で修正がマージされました。修正コミットはファクトリーのボットが自ら作りました。

### 3.2 指示が長すぎて切り詰められていた

OpenClawは、`AGENTS.md`がエージェントに注入される際に20,000文字で切り詰められていることを発見しました。中核となるルールが、エージェントには断片的にしか見えていなかったのです。そこで27,913文字あったファイルを18,900文字に減らし、細かいルールをその領域を担当するスキルに移しました。[^13] 指示ファイルにも長さの予算が必要だということを示した事例です。

Beadsの`CODEOWNERS`のコメントには、性質の異なる警告があります。防御的なコードを黙って付け足してきた結果、設計判断の記録（ADR）を書くまでに、その場しのぎのコミットが8件以上たまったというものです。[^6] 原因を整理せずに症状ごとにルールを付け足すと、ルールそのものが負債になるという警告として読めます。

### 3.3 指示とCIを一緒に直す

同じ失敗を2つの層で防ぐ事例も多くあります。Bunは、エージェントが冗長なコードコメントを書く問題を指示のルールで防ぐと同時に、`claude`ラベルの付いたエージェントPRの`src/`の変更から2行以上の新しいコメントを探して削除を求めるCI（`comment-cop`）を置いています。`SAFETY:`の印が付いたコメントは例外です。[^14] Claude Codeのリポジトリは、Issueの重複判定ジョブが古いモデルのせいで意図した権限モードで動いていなかったことを発見し、同じPRでワークフローのセキュリティチェックスクリプトと、そのチェックを飛ばしたり弱めたりしてはならないという`CLAUDE.md`のルールを一緒に追加しました。[^15] OpenAI Codexは、レビューボットがロックファイルの変更を誤って求めることが繰り返されたため、`AGENTS.md`にレビューボットがそうした要求をしないよう書き込みました。[^16] OpenHandsは、既存のツールで検証できないユーザー経路を「ハーネスの隙間（harness gaps）」と定義し、使い捨てのスクリプトで回避せず、検証ツールそのものを拡張するよう定めています。[^17]

---

## 4. エージェントが自分のルールを直す

新しいのは、エージェントが自分の指示を直接直しているという点です。ただし、その多くは人が指示した、あるいは承認した修正です。

- OpenClawのルートの`AGENTS.md`は、2026年3月以降456回修正されました。作成者はメンテナーのsteipeteが320件で最も多く、OpenClaw製品で動くエージェントroboclaw-botも直接修正PRを出しています。[^18] 先に見た欠陥5件のPRもroboclaw-botが出したものです。
- Bunの`CLAUDE.md`のコミット50件のうち、4件はrobobunが、32件（64%）は一人のメンテナーが作成しました。[^19] robobunは、90日間更新のない自分のPRを自動で閉じるワークフローも自ら作り[^20]、その後2回修正しました。[^21][^22]
- mastraのレビュースキルのコミット20件（2026年7月23日〜9月30日）のうち、3件はボットが作成しました。[^23] レビューボットが以前の判定本文を再利用し、「承認」と「変更要求」が混ざったレビューを投稿した出来事のあと、投稿直前に判定とコミットを照合させる修正もボットが書きました。ただし、そのPRには作業を始めた人が記録されています。[^24]
- Astroのロックファイル修正のコミットはファクトリーのボットが作り、人がPRを開いて承認・マージしました。[^12]

このうちAstroの事例では、指示の変更も通常のPRとして提出され、人が承認してマージしました。mastraの事例も通常のPRとして提出され、人がマージしました。私はこの点が重要だと考えます。指示の変更がコードの変更と同じレビューを受ける限り、エージェントが自分の指示を直すことは、リスクというより自己改善ループを速く回すための手段になります。

---

## 5. 自動化そのものを直す、あるいは止める

失敗が繰り返されるとき、ルールを足す代わりに自動化を縮小する決定もループの一部です。

- OpenClawは、自動実装の成功率が16.9%に落ち、失敗した実行が123時間分の作業時間を使ったことを受けて、成功率に基づくサーキットブレーカーを追加しました。[^1] それに先立つ2026年7月には、最後の1か月間に一度も成功しなかったコミットレビューの経路を丸ごと廃止しています。[^25]
- mastraは、ファクトリーを自動モードで動かしたものの、PRが押し寄せるように大量に出てレビューが難しくなったため、手動モードに切り替えたと明らかにしています。[^26]
- OpenAI Codexは、IssueをPRに変えていたワークフローを「設計上の問題」を理由に削除しました。[^27]

自動化を止める決定は、失敗を認めることではなく、自動化の範囲を実際の成功率に合わせる調整です。OpenClawのサーキットブレーカーは、この調整を人の判断ではなく基準にしました。

---

## 6. ループが途切れるところ

ここまでがうまく機能している部分です。リポジトリをさらに詳しく見ると、ループが途切れる地点もはっきりしています。

- **効果を定期的に測定した記録がありません。** Astroはスキル8個に対して評価ケース24個を作りましたが、コストと非決定性を理由にCIにはつないでいません。観察日時点で、評価ファイル8個のうち6個は最初に追加された2026年8月13日以降変更されておらず、前掲の表にあるchangesetの欠落とロックファイルへの混入は評価ケースとして追加されていませんでした。[^28] 手動実行の記録はリポジトリに残らないため、確認できませんでした。今回の調査で確認できた範囲では、ルールは作られたものの、そのルールが守られているかを定期的に自動で確認する仕組みはありませんでした。
- **取り消した決定が記憶されません。** Astroのファクトリーが意図された動作をバグとみなして直した修正は、マージ後に取り消されました。ところが、同じ問題で新しいIssueが開かれると、ファクトリーは同じ修正を再び作りました。[^29] 観察日時点で、関連するスキルは変更されていませんでした。私はこれを、取り消した決定が次の作業に伝わらなかった事例と見ています。
- **文書にだけ残っています。** Beadsの「スキーマの変更は例外なく人がレビューする」というルールは、ブランチルールでは強制されていません。[^30] Bunの`CLAUDE.md`はブランチ名を`claude/`で始めるよう求めていますが、実際のrobobunのブランチは`robobun/`で始まっています。[^31]
- **外部から報告された自動化のバグが残っています。** Claude Codeのリポジトリには、重複Issueの自動クローズに関するバグ報告が観察日時点で開いたままです。案内文では誰でも反対の意思を示せば自動クローズを止められるとしているのに、コードはIssueの作成者の反対しか認めないという報告と、自動クローズがラベルの一覧を`duplicate`一つで上書きし、領域やプラットフォームといった他のラベルを消してしまうという報告です。[^32][^33]
- **ループがリポジトリの外に消えています。** Vercel AI SDKは失敗の分類（`factory-flawed` 11件、`factory-blocked` 60件）をラベルとして公開していますが、その失敗を受けて直すべきプロンプトと評価セットはリポジトリの外にあります。[^34] OpenAI Codexは、レビューボットと`AGENTS.md`の間の改善ループが公開リポジトリで回っていた記録を残しましたが、2026年9月30日に`AGENTS.md`とスキルを公開リポジトリから削除しました。[^35]

9月に書いた[バイブコーディングを超えて、ソフトウェアファクトリーへ](/ja/posts/beyond-vibe-coding-software-factory/)で、私は「その改善結果も検証しなければなりません。成功基準まで勝手に変えてしまえば、改善したという判断自体を信頼しにくくなります」と書きました。[^36] 観察したプロジェクトは、このリスクを一部防いでいます。AstroのファクトリーはPRではなく対象ブランチのレビュールールを読み[^37]、StrongDMは検証シナリオをコードリポジトリの外に置いていると説明しています。[^38] しかし、今回の調査では公開された記録だけでは、改善に実際の効果があったかを定期的に測定しているところを確認できませんでした。

---

## 7. ベストプラクティス

1. **ルールごとに、そのルールを生んだ出来事を日付とPR番号とともに書く。** あとでルールを維持するか廃止するかを判断する根拠になります。（Beads、OpenClaw）
2. **レビュー履歴からマージを止めた理由を抽出し、エージェントとレビューボットが一緒に読むルール文書にする。** （Bun）
3. **失敗の原因を指示文に求める。** エージェントに合理化の余地を与える任意の表現や例外の文言を探して削除します。（Astro）
4. **指示ファイルに長さの予算を設け、細かいルールは担当のスキルに分ける。** （OpenClaw）
5. **同じ失敗を、指示とCIチェックの2つの層で防ぐ。** （Bun、Claude Code）
6. **エージェントによる指示の修正にも、コードの変更と同じPRレビューを通す。** （OpenClaw、Bun、mastra、Astro）
7. **自動化の経路ごとに成功率を集計し、基準を下回ったら自動で止める。** （OpenClaw）
8. **新しいルールを作るときは評価ケースも一緒に追加し、その評価を定期的に実行する。** 今回の調査の公開記録では、これを定期的に行っているところは確認できませんでした。Astroの事例をもとにした私の提案です。

---

## シリーズを終えて

4回にわたり、公開リポジトリ12か所をリバースエンジニアリングしました。第1回では判定基準を立て、8か所をソフトウェアファクトリーと判定しました。第2回ではマージ権限を、第3回では検証の証拠を、今回は自己改善ループを扱いました。

3つのテーマを貫く私の結論は一つです。これらの事例で、ファクトリーの品質を守る鍵は**エージェントを取り巻く仕組み** でした。何を自動でマージしてよいかを定めたリスク区分、エージェントの主張に代わる証拠、そして失敗を根拠とともにルールに変える習慣がその仕組みです。そして、この仕組みの多くは公開リポジトリのファイルとして残っているため、誰でも読んで自分のチームに合わせて取り入れることができます。

同時に、人の役割もはっきりしました。多くの事例で、人は作業の着手を承認し、マージし、失敗からルールを直す役割を担い、必要なときには実装にも直接参加していました。まだ解けていない問題、つまり意図を確認すること、リポジトリの外への影響を見ること、改善の効果を測定することも、今は人の役割です。次の段階のファクトリーは、おそらくこの3つをどう仕組みにするかで分かれるでしょう。

---

[^1]: openclaw/clawsweeper PR #1855：https://github.com/openclaw/clawsweeper/pull/1855
[^2]: オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（1/4）：判定基準と12のリポジトリ：https://roboco.io/ja/posts/software-factory-best-practices-from-open-source/
[^3]: オープンソースプロジェクトから学ぶソフトウェアファクトリーのベストプラクティス（3/4）：証拠でふるいにかけるファクトリー：https://roboco.io/ja/posts/software-factory-evidence-before-fix/
[^4]: gastownhall/beadsのコミット 9a9da38c：https://github.com/gastownhall/beads/commit/9a9da38c
[^5]: gastownhall/beadsのコミット c989b6b8：https://github.com/gastownhall/beads/commit/c989b6b8
[^6]: gastownhall/beads CODEOWNERS：https://github.com/gastownhall/beads/blob/main/.github/CODEOWNERS
[^7]: oven-sh/bun REVIEW.md：https://github.com/oven-sh/bun/blob/main/REVIEW.md
[^8]: OpenClaw PR #168083：https://github.com/openclaw/openclaw/pull/168083
[^9]: withastro/astro PR #17475：https://github.com/withastro/astro/pull/17475
[^10]: withastro/astro PR #16802：https://github.com/withastro/astro/pull/16802
[^11]: withastro/astro PR #17352：https://github.com/withastro/astro/pull/17352
[^12]: withastro/astro PR #18168：https://github.com/withastro/astro/pull/18168
[^13]: OpenClaw PR #163325：https://github.com/openclaw/openclaw/pull/163325
[^14]: oven-sh/bun comment-cop.yml：https://github.com/oven-sh/bun/blob/main/.github/workflows/comment-cop.yml
[^15]: anthropics/claude-code PR #97952：https://github.com/anthropics/claude-code/pull/97952
[^16]: openai/codex PR #29720：https://github.com/openai/codex/pull/29720
[^17]: OpenHandsのverify-openhandsスキル：https://github.com/OpenHands/OpenHands/blob/main/.agents/skills/verify-openhands/SKILL.md
[^18]: OpenClaw AGENTS.mdのコミット履歴：https://github.com/openclaw/openclaw/commits/main/AGENTS.md
[^19]: oven-sh/bun CLAUDE.mdのコミット履歴。作成者別のコミット数をGitHub APIで集計（2026年10月10日）：https://github.com/oven-sh/bun/commits/main/CLAUDE.md
[^20]: oven-sh/bun PR #27125：https://github.com/oven-sh/bun/pull/27125
[^21]: oven-sh/bun PR #27126：https://github.com/oven-sh/bun/pull/27126
[^22]: oven-sh/bun PR #41079：https://github.com/oven-sh/bun/pull/41079
[^23]: mastra factory-reviewスキルのコミット履歴。作成者別のコミット数をGitHub APIで集計（2026年10月10日）：https://github.com/mastra-ai/mastra/commits/main/mastracode/factory/factory-skills/factory-review/SKILL.md
[^24]: mastra-ai/mastra PR #25494：https://github.com/mastra-ai/mastra/pull/25494
[^25]: openclaw/clawsweeper README：https://github.com/openclaw/clawsweeper/blob/main/README.md
[^26]: Mastra, "Announcing Mastra Factory Beta"：https://mastra.ai/blog/announcing-mastra-factory-beta
[^27]: openai/codex PR #2729：https://github.com/openai/codex/pull/2729
[^28]: withastro/astro .agents/evals README：https://github.com/withastro/astro/blob/main/.agents/evals/README.md
[^29]: withastro/astro PR #18052：https://github.com/withastro/astro/pull/18052
[^30]: gastownhall/beads PR_MAINTAINER_GUIDELINES.md：https://github.com/gastownhall/beads/blob/main/PR_MAINTAINER_GUIDELINES.md
[^31]: oven-sh/bun CLAUDE.md：https://github.com/oven-sh/bun/blob/main/CLAUDE.md
[^32]: anthropics/claude-codeのIssue #79146：https://github.com/anthropics/claude-code/issues/79146
[^33]: anthropics/claude-codeのIssue #98160：https://github.com/anthropics/claude-code/issues/98160
[^34]: vercel/aiのラベル一覧。ラベル別の項目数をGitHub APIで集計（2026年10月10日）：https://github.com/vercel/ai/labels
[^35]: openai/codex PR #49713：https://github.com/openai/codex/pull/49713
[^36]: バイブコーディングを超えて、ソフトウェアファクトリーへ：https://roboco.io/ja/posts/beyond-vibe-coding-software-factory/
[^37]: withastro/factory README：https://github.com/withastro/factory
[^38]: StrongDM, Software Factory：https://factory.strongdm.ai/
