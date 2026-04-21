# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリの性質

個人用の dotfiles リポジトリ。macOS 環境を想定（`alacritty` + `tmux` + `fish`、`skhd`/`yabai` によるウィンドウ管理）。Git で管理しているのは一部のみで、`.gitignore` で以下が **意図的に除外** されている:

- `/fish/`, `/yabai/`, `/tmux/`, `/skhd/`, `/github-copilot/`
- `/nvim/startuptime.log`
- `.emacs.d` 配下の自動生成物（`elpa/`, `elpaca/`, `savehist`, `eshell/`, `url/`, `var/`, `tree-sitter/` 等）

作業ツリー上にはこれらのディレクトリが **存在する**（ローカルの実設定として機能している）が、**コミットには含まれない**。ファイルを編集する際は `git ls-files` で tracked かを必ず確認すること。未追跡のディレクトリに変更を加えても差分には出ない。

追跡されている設定は実質的に `nvim/` と `alacritty/` と `.emacs.d/init.el` のみ。

## デプロイ方法

このリポジトリ自体に symlink 配置スクリプトは含まれていない。各ディレクトリは手動で `~/.config/` 配下にリンクされている前提（例: `nvim/` → `~/.config/nvim/`、`alacritty/` → `~/.config/alacritty/`）。

## Neovim 設定のアーキテクチャ

**dpp.vim**（`Shougo/dpp.vim` + `vim-denops/denops.vim`）ベースの Lua + TOML + TypeScript 構成。プラグイン管理・補完（ddc.vim）・ファジーファインダ（ddu.vim）が Shougo 系ツールで揃えられている。Deno が必須（denops.vim が要求）。

### ロードフロー

1. `nvim/init.lua` が `~/.cache/dpp/` 配下の dpp 本体と各拡張（`dpp-ext-toml`, `dpp-ext-lazy`, `dpp-ext-installer`, `dpp-protocol-git`）を `runtimepath` に追加。
2. `dpp.load_state(dppBase)` を呼ぶ:
   - **キャッシュ有効** → `state.vim` / `startup.vim` をそのまま読み込み、プラグイン spec の再評価はスキップ（高速起動）。
   - **キャッシュ無効** → denops を runtimepath に追加し、`User DenopsReady` autocmd で `dpp.make_state(dppBase, "~/.config/nvim/dpp.ts")` を実行してキャッシュ再生成。
3. `BufRead`/`CursorHold`/`InsertEnter` の最初の発火で `lua/config/{keymaps,options,autocmd}.lua` を遅延 require。

### 設定ファイルの分担

TOML と TypeScript が対になっている箇所は、TOML が plugin spec、TS が denops 経由のランタイム設定を持つ役割分担。

- `dpp.toml` — denops.vim + dpp 本体 + dpp 拡張（非 lazy ロード）。
- `dpp.ts` — dpp の config エントリポイント。以下の順で各 TOML をロード:
  - `dpp.toml` (lazy=false) → `dpp_lazy.toml` (lazy=true) → `lsp.toml` (lazy=true) → `ddu.toml` (lazy=false) → `ddc.toml` (lazy=true)
- `dpp_lazy.toml` — 遅延ロードするプラグイン spec（colorscheme、treesitter、UI 系など）。大半のプラグインはここ。
- `ddc.toml` / `ddc.ts` — 補完エンジン ddc.vim の plugin spec と TypeScript 設定。sources（`lsp`, `around`, `vsnip`, `file`, `skkeleton`）と sourceOptions を定義。
- `ddu.toml` / `ddu.ts` — ファジーファインダ ddu.vim の設定。
- `lsp.toml` — `neovim/nvim-lspconfig` など LSP 関連プラグインの spec。

### プラグイン追加・更新

- プラグイン追加は該当する `*.toml` の `[[plugins]]` テーブルに `repo = "owner/name"` で追記（lazy ロードしたいなら `dpp_lazy.toml`、補完系なら `ddc.toml`）。
- リポジトリ名と plugin 名が不一致な場合は `name = "..."` で明示が必要（例: `rose-pine/neovim` → `name = "rose-pine"`）。
- 反映コマンド（`init.lua` で定義）:
  - `:DppInstall` — 未インストールプラグインを非同期 clone。
  - `:DppUpdate` — 全プラグイン更新。
  - `:DppMakestate` — spec をパースし直して state.vim を再生成。
- **TOML を書き換えただけでは反映されない**。state.vim に古い結果がキャッシュされているので、`:DppMakestate` を叩くか、`~/.cache/dpp/nvim/state.vim` を削除してから nvim を再起動すること。
- `make_state` は denops 依存なので `DenopsReady` 後に実行される。headless で反映する場合は `autocmd User DenopsReady ++once call timer_start(N, {-> execute("qa!")})` で denops 起動と state 生成の完了を待つ必要がある。

### Lua 側の構成

- `lua/config/`
  - `keymaps.lua` / `options.lua` / `autocmd.lua` — プラグインに依存しない基本設定。`BufRead`/`CursorHold`/`InsertEnter` の最初の発火で require される。
- `lua/hooks/` — 個別プラグインの setup を外出ししたモジュール。TOML の `lua_source` から `require("hooks/xxx")` で呼ばれる。
  - `deol.lua` / `insx.lua` / `lsp.lua`

### colorscheme

`dpp_lazy.toml` の `rose-pine/neovim`（variant: `moon`）を使用。`autocmd.lua` の `VimEnter` で `colorscheme rose-pine` を適用。背景は `disable_background = true` で透過させ、alacritty 側の背景色（`#2a1f3d`）が見える状態。

### キャッシュのトラブルシュート

- プラグインが有効化されない / 更新が反映されない → `rm ~/.cache/dpp/nvim/state.vim ~/.cache/dpp/nvim/startup.vim` で再生成を強制。
- `vim load_state is failed` のメッセージは「キャッシュが無かったので make_state を走らせます」の意味（エラーではない）。
- プラグイン本体は `~/.cache/dpp/repos/github.com/<owner>/<name>/` に clone される。完全にクリーンな状態にしたい場合はここを削除してから `:DppInstall`。
