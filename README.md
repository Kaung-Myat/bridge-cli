# 🌉 Bridge CLI

**Bridge CLI** is a powerful developer tool designed to bridge the gap between your **Frontend** and **Backend** codebases. It generates a single, AI-optimized context file (`.ai-bridge.md`) that allows AI models like **Qwen, DeepSeek, Gemini, and ChatGPT** to understand your entire full-stack architecture at once.

Whether you are using **Flutter with Dart Frog** or **React with Node.js**, Bridge CLI gives the AI the "big picture" without the noise of implementation details.

> 🚀 **v1.1:** Now supports **JavaScript & TypeScript** ecosystems! (Node.js, Express, React, Next.js).

## ✨ Key Features

- **Multi-Language Support:** Automatically detects and parses **Dart**, **JavaScript**, and **TypeScript** files (`.dart`, `.js`, `.ts`, `.jsx`, `.tsx`).
- **Signature Extraction:** Extracts structural "blueprints" (classes, methods, fields) while stripping away heavy function bodies to save AI context tokens.
- **Absolute Path Mapping:** Maps files using absolute paths so AI CLIs can edit files across different directories accurately without switching terminals.
- **Multi-Project Linking:** Link unlimited projects (e.g., a Flutter App + Node Backend) into one unified context via `bridge.yaml`.
- **Live Watch Mode:** Automatically updates the context file whenever you save changes in any linked project.

## 📦 Installation

### Option 1: Download Pre-built Binaries (Recommended)

You can find the latest binaries for **Linux**, **Windows**, and **macOS** on our **[Releases](https://github.com/Kaung-Myat/bridge-cli/releases/tag/v1.1.0)** page.

#### 🐧 Linux (Ubuntu/Debian/Fedora)

1. Download the `bridge` binary.
2. Open your terminal and run:
   ```bash
   chmod +x bridge
   sudo mv bridge /usr/local/bin/
   ```

#### 🪟 Windows

1. Download bridge.exe.
2. Add the folder containing the .exe to your System Environment Variables > Path.

#### 🍎 macOS

1. Download the bridge binary.
2. Run chmod +x bridge && sudo mv bridge /usr/local/bin/.
3. If macOS blocks it, go to System Settings > Privacy & Security and click "Allow Anyway".

### Option 2: Build from Source (Requires Dart SDK)

```bash
git clone [https://github.com/Kaung-Myat/bridge_cli.git](https://github.com/Kaung-Myat/bridge_cli.git)
cd bridge_cli
dart compile exe bin/bridge_cli.dart -o bridge
sudo mv bridge /usr/local/bin/
```

## 🚀 Quick Start

#### 1. Initialize & Link Projects

Navigate to your main project folder and run:

```bash
# Initialize current folder (e.g., React Frontend)
bridge init

# Link external project (e.g., Node Backend)
bridge init ../my_express_api
```

#### 2. Build Context

Generate the context file for your AI:

```bash
bridge build
```

#### 4. Watch Mode (Live Updates)

Instead of running `bridge build` manually after every code change, you can keep the bridge running:

```bash
bridge watch
```
