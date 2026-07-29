---
title: "AIでアーキテクチャ図を描く"
date: 2025-06-14T12:35:06+09:00
draft: true
toc: false
images:
tags:
  - productivity
  - tips
  - aws
  - drawio
---

{{< figure src="/posts/images/Dohyun.png" title="チョン・ドヒョン - ROBOCO首席コンサルタント" style=".author-image">}}

バイブコーディングをするとき、人はしばしばコードさえあれば十分だと考えがちです。しかし現実は違います。文書化のないコードは、地図を持たずに出かける旅のようなものです。目的地がどこなのか、道のりがどうなっているのかが分からなければ、誰も一緒に来てはくれません。バイブコーディングにおいて文書化が特に重要なのは、コードが単に動作するためのものではなく、アイデアと設計の意図を他の人に正確に共有するためのものだからです。文書化は協働を滑らかにし、プロジェクトの方向性を明確にし、ひいては持続可能な開発環境を築く土台になります。

私は文書化の作業をコードと一緒に管理する方式を強くおすすめします。特にMarkdownとmermaidを使えば、シンプルで明確な図をすばやく作成できます。複雑な構造や流れを長い言葉の代わりに図ひとつで表せるので、意思疎通がはるかに効果的になります。

もちろん、mermaidだけでは足りないこともあります。より精緻で複雑な図が必要なときは、draw.ioを使うことができます。draw.ioはXMLベースの.drawioというファイル形式を使うため、AIにこの形式で図を生成するよう指示すれば比較的簡単に作業できます。ただし、AWSアイコンのような特定のアイコンのIDは公開されていないので、AIがそのまま活用するのは容易ではありません。

そこで私は、draw.ioクライアントからAWSアーキテクチャアイコンのIDを直接抽出し、別途[文書化](https://github.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/blob/main/docs/aws-2025-icons-drawio.md)しました。これによってAIにアイコンIDを教え、望むアイコンを正確に活用できるようにしたわけです。この文書は、次のGitHubリポジトリで実際に作業した例を通して確認できます。

## TL;DR

- バイブコーディングにおいて文書化は選択肢ではなく、設計意図と協働の文脈を共有するための中核的な作業です。
- 単純な構造ならMarkdownとmermaidで十分ですが、より精緻なアーキテクチャ図はdraw.ioファイルをAIと一緒に生成できます。
- AWSアイコンのようにAIが知りにくい細かなIDは、別文書として与えれば望みどおりの図をより正確に作れます。

[ECS - Fargate Fast Scaleout](https://github.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/)

このようにして生成された図は、VS Codeのdrawio関連の拡張機能を使えば手軽にプレビューしたり修正したりできます。また、draw.ioクライアントをインストールすると一緒に提供されるCLIツールで、簡単にSVGやPNG形式の画像に変換して文書へ挿入することもできます。

![alt text](https://raw.githubusercontent.com/Hands-On-Vibe-Coding/ecs-fargate-fast-scaleout/abbb4dee4d89070692fc4edc0e81a313c910c52b/docs/diagrams/architecture.svg)

一方で、最近のmermaidの最新バージョンでは、AWSアイコンをはじめとするさまざまなアーキテクチャアイコンが標準でサポートされ始めました。[公式ドキュメント](https://mermaid.js.org/syntax/architecture.html)を参照すればすぐに活用できます。ただし、GitHubではまだこの最新機能がサポートされていないため、先ほど説明した方法が当面は最も有用なアプローチになるでしょう。

良い文書は単なる説明書にとどまらず、協働の質を高め、長期的にプロジェクトの価値を持続させます。バイブコーディングにおいて文書化は選択ではなく必須です。
