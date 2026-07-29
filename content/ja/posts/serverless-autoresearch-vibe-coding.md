---
title: "Serverless Autoresearch：バイブコーディングでML実験パイプラインをサーバーレス化した記録"
date: 2026-03-29T16:00:00+09:00
draft: false
toc: false
images:
tags:
  - vibe-coding
  - agentic-dev
  - ml-engineering
  - aws
  - sagemaker
---

> バイブコーディングの本当の価値は、コードを速く書くことだけにあるのではありません。高くつく実験を、より安く、より速く繰り返せる運用のあり方を設計することにあります。

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

たいていの人はバイブコーディングを、まずWebアプリのプロトタイピングやCRUD自動化と結びつけます。しかしROBOCOの[`serverless-autoresearch`](https://github.com/roboco-io/serverless-autoresearch)リポジトリは、このフレームを大きく広げます。このプロジェクトは、Andrej Karpathyの`autoresearch`が前提とする「H100を1台、数時間つかんでおく」やり方の代わりに、AWS SageMaker Spotの上で並列実験を短く爆発的に実行する構造を作っています。[^1]

この事例が興味深いのは、結果が安く出たからではありません。このリポジトリには、**最初のアイデアを練り上げる深層インタビュー**、**計画中心のアーキテクチャ設計**、**クラウドインフラのデバッグ**、**反復実験の自動化**、**失敗を文書とスキルへ還元していく過程**がすべて残っています。とくに`docs/vibe-coding-tutorial`は、コードの説明書ではなく、対話型のAIコーディングが実際にどうエンジニアリングの成果物として固まっていくのかを示すログに近いものです。[^2]

まず数字から整理しておく必要があります。チュートリアルは2026年3月27〜28日の初期実行区間を中心に、**25回の実験、総費用0.44ドル、最高`val_bpb` 1.0643**を記録しています。[^2][^10] 一方でリポジトリのREADMEは、その後に拡張された図として**83回の実験を約3.5時間、約1.33ドル**で実施する方向を示し、もとの逐次実行に比べ**2.3倍速く、5〜18倍安い構造**であることを強調しています。[^1] つまり「0.44ドル」は初期検証の費用であり、「1.33ドル」は拡張された運用モデルの費用です。二つの数値は矛盾しておらず、異なる段階の結果です。

## TL;DR

- `serverless-autoresearch`は、バイブコーディングをWebアプリ自動化ではなく、ML実験パイプラインとクラウド運用設計の問題へ拡張した事例です。
- 核心は、H100を長く占有するやり方の代わりに、SageMaker Spotベースの並列実験によって安い失敗と速い学習を可能にした点にあります。
- 良い結果は、コード生成量よりも、問題定義・計画・インフラ検証・失敗を文書とスキルへ還元する運用のあり方から生まれます。

## 1. このプロジェクトが実際に変えたこと

Karpathyのオリジナルの`autoresearch`は一度に一つの実験を回し、基本的にはH100のような高性能GPUを長く占有する流れに近いものです。`serverless-autoresearch`は、この流れを**並列進化**（parallel evolution）に変えました。[^1][^4]

核心は二つです。

- 実験一つを長くつかんでおく代わりに、複数の候補を同時に短く実行します。
- GPUを24時間つけておく代わりに、必要なときだけSpotインスタンスを立ち上げ、終わったらすぐに落とします。

このリポジトリはこれを**HUGI**（Hurry Up and Get Idle）パターンと呼んでいます。[^1] サーバーを長く維持する代わりに、短く一気に計算してただちにアイドル状態へ戻る方式です。この単純な転換が費用構造を完全に変えます。「サーバーレス」という言葉が関数呼び出しだけを意味するのではなく、GPUワークロードにも適用可能な運用哲学であることを示しているわけです。

チュートリアルを基準に見ると、実際の検証もかなり具体的です。

| 区間 | 内容 | 費用 |
|---|---|---|
| 初期の成功実験 | L40S Spotで最初のend-to-end成功 | $0.06 |
| バッチサイズの罠の検証 | 4回の並列実験で誤った仮説を除去 | $0.07 |
| 5世代の自律進化 | 20回の実験で最適パラメータを探索 | $0.31 |
| 合計 | 25回の実験 | **$0.44** |

つまりこのプロジェクトのポイントは「安いGPUでも動く」ことではなく、**安い失敗をたくさん買える**という点にあります。[^6][^7][^8][^10]

## 2. チュートリアルが示す本当のポイント

### 2.1 曖昧な依頼は深層インタビューで絞り込むべき

チュートリアルの最初の場面はコードではなく質問です。ユーザーは「autoresearchの実験を再現したい」という依頼とともに、必要なら深層インタビューをするよう指示します。[^3] その結果、目標は単なる再現ではなく次の三つとして定義し直されます。

- SageMaker Managed Spot Trainingベースのサーバーレス実行
- OMCベースの自律反復実験
- 教育用／デモ用に再利用可能な文書化

これは小さく見えて非常に重要な転換です。漠然とした「再現」は、しばしばオリジナルを真似るだけで終わります。一方、インタビューを経れば「何を学ぶのか」「何を自動化するのか」「何を残すのか」が明確になります。バイブコーディングはプロンプトを長く書く技術ではなく、**良い問題定義を引き出すインタビューの技術**に近いという事実を示しています。

### 2.2 実装より先に計画モードが必要

第2章でAIはすぐにコードを書きません。まず上流の`autoresearch`コードベースと、ユーザーの既存のSageMakerパターンを探索したうえで、候補生成器・バッチランチャー・結果収集器・選択モジュールに分かれたパイプライン構造を計画します。[^4]

途中でユーザーが「クラウドの利点である並列実行とHUGIを積極的に活用せよ」という条件を追加すると、設計は逐次実行から**population-based parallel evolution**の構造へ変わります。[^4] この箇所は、バイブコーディングが「AIが勝手に書いたコード」ではなく、**計画段階でアーキテクチャを修正できてはじめて有用性が大きくなる**という点をよく示しています。

実際にチュートリアルは、このセッションで23個のファイルが作られ、`make dry-run`で全経路を検証したと記録しています。[^4] 重要なのは生成の速さよりも、生成の前に構造が合意されていたことです。

### 2.3 インフラの問題は周辺的な課題ではなく中核的な設計変数

第3章はこのプロジェクトの白眉です。コードは準備できているのに、AWSインフラが足を引っ張ります。GPU Spotのクォータは既定値が0であり、リージョンごとにSpotの可用性も極端に異なります。[^5][^11]

チュートリアルで最も実戦的な教訓は`aws ec2 get-spot-placement-scores`です。同じ`g7e`系のインスタンスでも、`us-west-2`ではスコア1〜2でほとんど確保できませんが、`us-east-1`ではスコア9で素早く割り当てられます。[^5][^11] 多くのチームはここで時間を浪費します。インフラの問題を「コードができあがったあとに解決すること」と見ているからです。しかしこのリポジトリは逆のことを言います。**どのリージョンを使うか、どのインスタンスを使うか、クォータがどれだけ速く承認されるかが、そのままパイプライン設計の一部**なのです。

ここでもう一つ目を引くのが、GPUの種類による承認の違いです。`g7e`は比較的速く承認されますが、`p5`や`p6`は手動審査で何日もかかることがあります。[^5][^11] こうした知識はコードの中には現れません。だからこそ文書化と運用上のメモリがより重要になります。

### 2.4 安い実験は安い教訓を素早く与える

第4章と第5章は「安い実験」の本当の意味を示します。最初の成功実験でL40SはFlash Attention 3をきちんとサポートせずランタイムのCUDAエラーを出し、結局GPU capabilityを明示的にチェックしてPyTorch SDPAへフォールバックするロジックが入りました。[^6] この修正で最初の成功実験は回りましたが、MFUはH100比で半分程度の約20.5%にとどまりました。[^6]

話はここで終わりません。次の実験ではVRAMに余裕があるので`DEVICE_BATCH_SIZE`を大きくすれば良くなりそうに思えましたが、結果はむしろ悪化しました。理由は、総トークン数が増えないままgradient accumulationだけが減ったからです。[^7][^11] これは多くのMLチームが実際にも混同するポイントです。GPUメモリをより多く使ったからといって、学習がより多く進んだわけではありません。

このプロジェクトは、こうした誤解を安く検証します。大きな予算がかかるH100の実験で同じ間違いを繰り返していたら、はるかに高くついたはずです。

### 2.5 自律実験は「大胆な変更」より「小さな調整」で成果を出した

自律進化の段階で最も興味深い結果は、派手なアーキテクチャ変更ではなく、**保守的な学習率の調整が最もよく効いた**という点です。`EMBEDDING_LR`と`SCALAR_LR`の小さな変更は改善につながりましたが、`DEPTH`の増加、`TOTAL_BATCH_SIZE`の拡大、`WINDOW_PATTERN`の変更といった中規模以上の介入は、ほとんどが悪化するかタイムアウトで終わりました。[^8][^10]

このパターンは思ったより重要です。短い5分の訓練予算では、複雑な構造変更は収束する時間を得られません。そのためこの環境でのAIエージェントは、「大胆な発明家」よりも「小さな数値を執拗に調整する運用者」であるときのほうが強いのです。バイブコーディングが常に創造的な飛躍を生むわけではなく、**短いフィードバックループの中で小さな改善を素早く積み重ねることに強い**という意味です。

## 3. 失敗をスキルへ還元するやり方がとくに良い

このリポジトリがROBOCOの観点からとくに良いのは、最後の処理の仕方です。実験が終わったあと結果を要約するところで止まらず、`docs/insights.md`に12個のインサイトを整理したうえで、これをClaude Code用の再利用可能なスキルへつなげています。[^9][^11]

ここに収められている内容は単なるメモではありません。

- リージョンごとにSpotスコアは極端に異なります。
- 小さなインスタンスが常により安いとは限りません。
- `DEVICE_BATCH_SIZE`はスループットというよりVRAM使用量に近いものです。
- 安価なSpot GPUは、高価なH100訓練の前の仮説検証用プロキシとして十分に使えます。

この形の整理が、バイブコーディングの成熟度を分けます。多くのチームはAIとのセッションが終わると学んだことを忘れてしまいます。しかしうまくやるチームは、失敗を文書にし、文書を再びスキルとルールに変えます。そうすれば次のセッションの品質が上がります。つまり生産性の源泉がモデルそのものではなく、**蓄積される運用知識**になるのです。

## 4. ROBOCOがここから見る結論

`serverless-autoresearch`は、バイブコーディングがおもちゃレベルのアプリ制作を超えて、ML実験パイプラインとクラウド運用設計まで扱えることを示しています。そしてその成否は、コード生成量よりも次の四つにかかっています。

- 最初の依頼をどれだけうまくインタビューして問題を絞り込むか
- 実装の前にアーキテクチャをどれだけ明確に合意するか
- インフラと費用構造をどれだけ速く検証するか
- 失敗をどれだけ速く文書とスキルへ還元するか

結局のところ、このプロジェクトの中心的なメッセージは単純です。バイブコーディングはエンジニアリングを置き換えません。その代わり、エンジニアリングの中心を**自分でタイピングする仕事**から**問い、設計し、実験し、教訓を蓄積する仕事**へ移します。`serverless-autoresearch`は、その移動が実際にどのような姿をしているのかをよく示す事例です。

オリジナルのリポジトリとチュートリアルを併せて読むと、「AIがコードを書いてくれた」よりもはるかに興味深い場面が見えてきます。**AIとともに実験システムそのものを設計した過程**が残っているからです。[^1][^2]

---

[^1]: Serverless Autoresearch README: https://github.com/roboco-io/serverless-autoresearch/blob/main/README.md
[^2]: Vibe Coding Tutorial README: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/README.md
[^3]: Chapter 1, "The Idea": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/01-the-idea.md
[^4]: Chapter 2, "Building the Pipeline": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/02-building-the-pipeline.md
[^5]: Chapter 3, "Infrastructure Adventures": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/03-infrastructure-adventures.md
[^6]: Chapter 4, "First Experiment": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/04-first-experiment.md
[^7]: Chapter 5, "The Batch Size Trap": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/05-the-batch-size-trap.md
[^8]: Chapter 6, "Autonomous Evolution": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/06-autonomous-evolution.md
[^9]: Chapter 7, "Insights & Skills": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/07-insights-and-skills.md
[^10]: Chapter 8, "Results & Comparison": https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/vibe-coding-tutorial/08-results-and-comparison.md
[^11]: Key Insights: https://github.com/roboco-io/serverless-autoresearch/blob/main/docs/insights.md
