# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリの性質

個人用の dotfiles リポジトリ。macOS 環境を想定（`alacritty` + `tmux` + `fish`、`skhd`/`yabai` によるウィンドウ管理）。Git で管理しているのは一部のみで、`.gitignore` で以下が **意図的に除外** されている:

- `/fish/`, `/yabai/`, `/tmux/`, `/skhd/`, `/github-copilot/`
- `/nvim/startuptime.log`
- `.emacs.d` 配下の自動生成物（`elpa/`, `elpaca/`, `savehist`, `eshell/`, `url/`, `var/`, `tree-sitter/` 等）

作業ツリー上にはこれらのディレクトリが **存在する**（ローカルの実設定として機能している）が、**コミットには含まれない**。ファイルを編集する際は `git ls-files` で tracked かを必ず確認すること。未追跡のディレクトリに変更を加えても差分には出ない。

追跡されている設定は実質的に `nvim/` と `alacritty/` と `.emacs.d/init.el` のみ。

`nvim-old/` は旧 dpp.vim 構成のバックアップ（`nvim/` からのリネームとして git に記録されているが未コミット）。LazyVim への切り替え確認が済んだら整理予定の退避ディレクトリ。

## デプロイ方法

このリポジトリ自体に symlink 配置スクリプトは含まれていない。各ディレクトリは手動で `~/.config/` 配下にリンクされている前提（例: `nvim/` → `~/.config/nvim/`、`alacritty/` → `~/.config/alacritty/`）。

## Neovim 設定のアーキテクチャ

**LazyVim**（`folke/lazy.nvim` 上の preset ディストリビューション）をベースにした Lua 設定。プラグインマネージャは lazy.nvim。

### ロードフロー

1. `nvim/init.lua` が `vim.loader` を有効化し、デバッグ用グローバル `dd` を定義後、`require("config.lazy")` を呼ぶ。
2. `nvim/lua/config/lazy.lua` が `stdpath("data")/lazy/lazy.nvim` に lazy.nvim を bootstrap（未インストール時のみ git clone）、`require("lazy").setup({...})` で以下を読み込む:
   - `LazyVim/LazyVim` 本体（`import = "lazyvim.plugins"`、`colorscheme = "solarized-osaka"`）
   - LazyVim extras: `linting.eslint`, `formatting.prettier`, `lang.typescript`, `lang.json`, `lang.rust`, `lang.tailwind`, `util.mini-hipatterns`
   - ユーザ定義: `lua/plugins/` 配下の全 spec（`{ import = "plugins" }`）
3. LazyVim 側が `config/options.lua` → プラグイン spec → `config/keymaps.lua` → `config/autocmds.lua` の順でロードする（LazyVim の規約）。

### プラグイン追加・更新

- ユーザプラグイン追加: `nvim/lua/plugins/` 配下の既存ファイル（`coding.lua`, `editor.lua`, `lsp.lua`, `treesitter.lua`, `ui.lua`, `colorscheme.lua`）の spec テーブルに追記、または新しい `*.lua` を作成し return で spec を返す。
- LazyVim extras の増減: `config/lazy.lua` の `spec` 内の `{ import = "lazyvim.plugins.extras.*" }` を編集（`:LazyExtras` からも管理可能、結果は `lazyvim.json` に保存）。
- 反映コマンド（lazy.nvim 標準）:
  - `:Lazy` — UI を開く
  - `:Lazy sync` / `:Lazy update` — 更新
  - `:Lazy restore` — `lazy-lock.json` のバージョンに固定し直す
- `lazy-lock.json` と `lazyvim.json` は tracked。プラグインバージョンの再現は lock ファイル経由。
- `config/lazy.lua` の `dev.path = "~/.ghq/github.com"` により、`dev = true` な spec は ghq で clone 済みのローカルリポジトリを参照する。

### Lua 側の構成

- `lua/config/`
  - `lazy.lua` — lazy.nvim bootstrap + LazyVim setup。
  - `options.lua` / `keymaps.lua` / `autocmds.lua` — LazyVim のデフォルトに対する上書き。
- `lua/plugins/` — ユーザ追加/上書きプラグイン spec 群。
- `lua/craftzdog/` — craftzdog の設定を参考にした補助モジュール。
  - `discipline.lua` — `cowboy()` を `keymaps.lua` 冒頭で呼んでおり、`hjkl` 連打など「悪癖」入力に警告を出す。
  - `hsl.lua` — `replaceHexWithHSL()`（`<leader>r`）で hex カラーを HSL 記法に置換。
  - `lsp.lua` — `toggleInlayHints()`（`<leader>i`）と `toggleAutoformat()`（`:ToggleAutoformat`）を提供。
- `lua/util/debug.lua` — `dd()`（= `vim.print`）のダンプ実装。

### keymap / autocmd の要所

- `mapleader` / `maplocalleader` は LazyVim のデフォルト（スペース）。
- `keymaps.lua` で `s` をウィンドウ操作の prefix に割り当て: `ss` 横分割、`sv` 縦分割、`sh/sj/sk/sl` でウィンドウ間移動。**通常の `s`（文字置換）は潰れている** 点に留意。
- 他: `x` / `<Leader>p` / `<Leader>c` / `<Leader>d` を black hole レジスタ経由にしてヤンク汚染を防止、`+`/`-` で `<C-a>`/`<C-x>`、`<C-a>` で全選択、`<tab>` / `<s-tab>` でタブ移動など。
- `autocmds.lua`: `InsertLeave` で `set nopaste`、`FileType json/jsonc/markdown` で `conceallevel=0`。

### LSP / 補完

LSP セットアップは LazyVim extras（`lang.typescript`, `lang.rust`, `lang.tailwind`, `lang.json`）と `lua/plugins/lsp.lua` のユーザオーバーライドの合成で成立する。サーバ固有の細かい設定を入れるときは `lua/plugins/lsp.lua` を編集する（旧 dpp 構成の `hooks/lsp.lua` は存在しない）。補完は LazyVim 標準（blink.cmp または nvim-cmp、LazyVim バージョン依存）。

補足: `lazy-lock.json` のコミットが常に最新プラグインバージョンに追随するわけではないので、環境を合わせたいときは `:Lazy restore` を挟むこと。
