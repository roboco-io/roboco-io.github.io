---
title: "What Google's Prompt Engineering Whitepaper Says About Vibe Coding"
date: 2025-04-13T08:32:57+09:00
draft: true
toc: false
images:
tags:
  - prompt-engineering
---

{{< figure src="/posts/images/Dohyun.png" title="Dohyun Jung - Principal Consultant, ROBOCO" style=".author-image">}}

## TL;DR

- The code prompting section of Google's prompt engineering whitepaper is a great starting point for using vibe coding at a professional level.
- Prompting for writing, explaining, translating, and debugging/reviewing code maps directly onto the vibe coding structure, where humans define the problem and AI carries it out.
- To get good results, spell out your output requirements, give positive instructions, and keep experimenting with and documenting reusable prompts.

## Introduction - Prompt Engineering and Vibe Coding

Whenever I pick up a new technology or need to get up to speed on a topic, the first thing I read is the whitepaper published by the vendor behind it. Most technical whitepapers are free, and they pack in a lot of information, which saves me time.

Google has now released a whitepaper on prompt engineering.

> [Google Prompt Engineering Whitepaper](https://www.kaggle.com/whitepaper-prompt-engineering)

Prompt engineering is a critical piece of vibe coding. If you intend to use it at a professional level, this whitepaper is an excellent place to start. It runs only about 60 pages, so I recommend reading the original if you can. But for those who aren't comfortable with English or are short on time, I've summarized it here with a focus on the code prompting material that relates to vibe coding.

---


## **Code Prompting Overview**

Code prompting is the practice of designing prompts so that an AI language model performs development tasks such as writing, explaining, translating, and debugging code. This lines up exactly with the core idea of vibe coding: **"a development approach in which the human defines the problem and the AI becomes the agent that solves it."**

---

## **Code Prompting Techniques in Detail**

There are four types of prompting.

### 1. **Prompts for writing code**

- Give the AI a prompt so it can automatically write code in a specific programming language.
- Examples:
  - Generating a Bash script that automates renaming files in a given folder
  - Automating file renaming and string handling with a Python script

### 2. **Prompts for explaining code**

- Have the AI explain, in natural language, what existing code means and how it works.
- Example:
  - Having the AI walk through the behavior of a Bash script step by step

### 3. **Prompts for translating code**

- Automatically translate code written in one programming language into another.
- Example:
  - Converting a Bash script into Python code

### 4. **Prompts for debugging and reviewing code**

- Use AI to automatically identify errors in code and receive suggestions for improvement.
- Example:
  - Finding the errors in broken Python code, explaining the fix step by step, and providing improved code

---

## **Best Practices for Code Prompting**

The AI prompting best practices that matter most for code prompting (vibe coding) are as follows.

### **Be specific about output requirements**

- Describe the exact result or structure you want from the code so the AI isn't left guessing.

### **Use positive instructions**

- Focus on what to do rather than what not to do. When asking for code, for example, state the goal clearly instead of listing restrictions.

### **Prompt with variables**

- Write prompts you can reuse, using variables to improve reusability and maintainability.

### **Experiment with prompt formats and styles**

- Try different phrasings, tones, and instruction styles to find what works best.

### **Document your prompting results**

- Record your various attempts so you can identify what worked and continuously improve prompt quality.

---

## **How This Connects to Vibe Coding**

The code prompting techniques presented in this document are closely tied to the core concepts of vibe coding.

- **Defining the problem and giving instructions (writing the prompt)** → **the human's job**
- **Writing, explaining, translating, and debugging code (the prompt's output)** → **the AI's job**

With this approach, developers spend less time on repetitive work and error fixing, and can focus on creative work such as generating ideas and defining problems.

In other words, the heart of vibe coding is **using code prompting techniques well so that AI can generate and manage code more accurately and efficiently.**


## Prompting Best Practices

For the best prompting performance, the following are recommended.

- **Provide examples** to improve the model's accuracy.
- Design prompts to be **simple and clear**.
- **Be specific about output requirements**.
- **Use positive instructions instead of constraints** so you don't confuse the model.
- **Control the maximum token length** for efficiency.
- **Use variables** to make prompts reusable.
- **Experiment with different input formats and writing styles** to find the optimal prompting style.
- For classification tasks, **mix up the classes in few-shot prompts** to prevent overfitting.
- **Keep adjusting your prompts** as models are updated.
- Use JSON and **structure your data with schemas**.
- **Experiment collaboratively** with other engineers to work more efficiently.
- Document the prompts you've tried to **systematize your knowledge**.

---

## Closing Thoughts

Prompt engineering is a field that calls for an iterative, systematic approach in order to get the most out of an LLM. With the right settings and a range of techniques, you can draw out an LLM's full potential. I wrote this post for developers who are always pressed for schedule, to help them pick up prompting techniques and best practices with minimal time and effort and get the results they want efficiently. That said, the whitepaper is full of insights from cover to cover, so if you can spare half a day, I recommend reading the original.
