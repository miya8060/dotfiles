# dotfiles

macOS 向けの個人用 dotfiles。ターミナル環境（`alacritty` + `tmux` + `fish`）、`skhd`/`yabai` によるウィンドウ管理、Neovim、Claude Code の設定をまとめている。

## 構成

Git で追跡しているのは以下:

| パス | 役割 | 配置先 |
| --- | --- | --- |
| `alacritty/` | ターミナルエミュレータ設定（Catppuccin Mocha テーマ） | `~/.config/alacritty/` （ディレクトリリンク） |
| `nvim/` | Neovim 設定（dpp.vim ベース、Lua + TOML + TypeScript） | `~/.config/nvim/` （ディレクトリリンク） |
| `tmux/` | tmux 設定とステータスライン | `~/.config/tmux/` （ディレクトリリンク） |
| `fish/` | fish シェル設定・プラグイン・関数 | `~/.config/fish/` （ディレクトリリンク） |
| `skhd/` | skhd のキーバインド設定 | `~/.config/skhd/` （ディレクトリリンク） |
| `yabai/` | yabai のウィンドウ管理設定 | `~/.config/yabai/` （ディレクトリリンク） |
| `claude/settings.json` | Claude Code の設定 | `~/.claude/settings.json` （ファイル単位リンク） |
| `claude/statusline.sh` | Claude Code のステータスラインスクリプト | `~/.claude/statusline.sh` （ファイル単位リンク） |

`~/.claude/` 配下には `projects/`（会話履歴・auto-memory）、`sessions/`、`history.jsonl` など動的・機密ファイルが混在するため、ディレクトリ単位ではなくファイル単位でリンクする。

### 追跡していないもの

作業ツリーには存在するがコミット対象から外しているもの:

- `github-copilot/` — 認証情報を含むため公開しない
- `nvim/startuptime.log` — Neovim 起動時間の計測ログ
- `.emacs.d/` — 以前は `init.el` のみ追跡していたが、Emacs から移行したため管理対象外
- `fish/functions/` 配下の fisher 管理ファイル — `fish_plugins` から `fisher update` で再取得できるため（`fzf_change_directory.fish` など手書きの関数は追跡する）
- `fish/fish_variables` — fish が自動で書き換える universal variable の保存先

詳細は `.gitignore` を参照。

## 前提環境

- macOS (Darwin)
- [alacritty](https://github.com/alacritty/alacritty)
- [tmux](https://github.com/tmux/tmux)
- [fish](https://fishshell.com/)
- [skhd](https://github.com/koekeishiya/skhd) / [yabai](https://github.com/koekeishiya/yabai)
- [Neovim](https://neovim.io/)（0.10 以降推奨）
- [Deno](https://deno.com/)（Neovim の `denops.vim` が必須）
- [Claude Code](https://docs.claude.com/en/docs/claude-code)
- [macSKK](https://github.com/mtgto/macSKK)（日本語入力）

## セットアップ

symlink を自動配置するスクリプトは含まれていない。以下の例を参考に手動で配置する:

```sh
# 想定パス
DOTFILES="$HOME/src/github.com/R2I5w/dotfiles"

# alacritty
ln -sfn "$DOTFILES/alacritty" "$HOME/.config/alacritty"

# nvim
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"

# tmux
ln -sfn "$DOTFILES/tmux" "$HOME/.config/tmux"

# fish / skhd / yabai
ln -sfn "$DOTFILES/fish" "$HOME/.config/fish"
ln -sfn "$DOTFILES/skhd" "$HOME/.config/skhd"
ln -sfn "$DOTFILES/yabai" "$HOME/.config/yabai"

# claude code
mkdir -p "$HOME/.claude"
ln -sfn "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
ln -sfn "$DOTFILES/claude/statusline.sh" "$HOME/.claude/statusline.sh"
```

Neovim 初回起動時に `:DppInstall` でプラグインを clone する。

## Neovim 設定の概要

- プラグイン管理は [`Shougo/dpp.vim`](https://github.com/Shougo/dpp.vim) + [`vim-denops/denops.vim`](https://github.com/vim-denops/denops.vim)。
- 補完は [`ddc.vim`](https://github.com/Shougo/ddc.vim)、ファジーファインダは [`ddu.vim`](https://github.com/Shougo/ddu.vim)。
- プラグイン spec は `*.toml`、ランタイム設定（denops 経由）は `*.ts`、Lua 側のキーマップや options は `lua/config/` に分離。
- colorscheme は `rose-pine/neovim`（variant: `moon`）。背景は透過させて alacritty の背景色を出す。

ロードフロー、キャッシュのトラブルシュート、プラグイン追加手順などのより詳細な情報は [`CLAUDE.md`](./CLAUDE.md) を参照。

## 日本語入力 (macSKK)

macOS 全体の日本語入力には [macSKK](https://github.com/mtgto/macSKK) を使う。Nvim 内は [skkeleton](https://github.com/vim-skk/skkeleton)（`ddc.toml` で設定済み）で、それ以外のアプリは macSKK、という使い分け。

sandbox アプリのため設定ファイルは `~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/` 配下に置かれ、このリポジトリでは追跡しない（バイナリ plist と個人辞書が中心のため）。

### セットアップ

```sh
# 1. インストール
brew install --cask macskk

# 2. 一度アプリを起動して container を生成
open "/Library/Input Methods/macSKK.app"

# 3. 辞書 (SKK-JISYO.L, EUC-JP) を配置
DICT_DIR="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
curl -fsSL -o "$DICT_DIR/SKK-JISYO.L" \
  "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L"
```

その後 GUI で:

1. `システム設定 → キーボード → テキスト入力 → 入力ソース → 編集 → ＋` から macSKK の「ひらがな」「ABC」を追加
2. 入力メニューの macSKK → `環境設定 → 辞書` で `SKK-JISYO.L` を有効化（エンコーディングは EUC-JP）

入力ソースが System Settings に現れない場合、Sequoia 以降の Launch Services キャッシュ問題の可能性があるので:

```sh
# Launch Services に再登録
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister \
  -f "/Library/Input Methods/macSKK.app"
killall TextInputMenuAgent TextInputSwitcher 2>/dev/null
```

それでも出なければ macOS を再起動する。

## ファイル一覧

```
.
├── CLAUDE.md              # Claude Code 用のプロジェクトガイド（アーキテクチャ詳細）
├── alacritty/
│   ├── alacritty.toml     # メイン設定
│   ├── catppuccin-mocha.toml
│   └── themes/            # alacritty-theme 提供のテーマ集
├── claude/
│   ├── settings.json      # Claude Code の設定
│   └── statusline.sh      # ステータスラインスクリプト
├── fish/
│   ├── config.fish        # エントリポイント
│   ├── fish_plugins       # fisher で管理するプラグイン一覧
│   ├── conf.d/            # 自動読み込みされる設定スニペット
│   └── functions/         # ユーザー定義関数（fisher 由来のファイルは .gitignore で除外）
├── skhd/
│   └── skhdrc             # skhd のキーバインド
├── yabai/
│   └── yabairc            # yabai のウィンドウ管理ルール
├── nvim/
│   ├── init.lua           # エントリポイント
│   ├── dpp.{toml,ts}      # dpp 本体 + denops の設定
│   ├── dpp_lazy.toml      # lazy ロードする plugin spec
│   ├── ddc.{toml,ts}      # 補完エンジン
│   ├── ddu.{toml,ts}      # ファジーファインダ
│   ├── lsp.toml           # LSP プラグイン
│   └── lua/
│       ├── config/        # keymaps / options / autocmd
│       └── hooks/         # プラグイン個別の setup
└── tmux/
    ├── tmux.conf
    └── statusline.conf
```
