;; -*- lexical-binding: t -*-

;; leafインストール
(eval-when-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-when-compile
  (require 'package)
  (customize-set-variable
   'package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                      ("melpa" . "https://melpa.org/packages/")
                      ("org"   . "https://orgmode.org/elpa/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))
  (require 'leaf)
  (leaf-keywords-init))

;; ================================================================

;; 変数と関数を事前に宣言
(eval-when-compile
  (defvar meow-cheatsheet-layout-qwerty)
  (defvar meow-cheatsheet-layout)
  (defvar vundo-mode-map)
  (defvar vundo-unicode-symbols)
  ;; vertico関連の変数を追加
  (defvar vertico--index)
  (defvar vertico-map)  ;; vertico-mapを追加
  (defvar orderless-component-separator)  ;; orderless-component-separatorを追加
  (defvar orderless-matching-styles)  ;; orderless-matching-stylesを追加
  (declare-function meow-setup "meow")
  (declare-function meow-normal-define-key "meow")
  (declare-function meow-define-keys "meow")
  (declare-function meow-motion-overwrite-define-key "meow")
  (declare-function meow-global-mode "meow")
  (declare-function meow-keypad-define-key "meow")
  (declare-function mac-ime-deactivate "mac-ime")
  (declare-function meow-insert-exit "meow")
  ;; vundo関連の関数を追加
  (declare-function vundo-backward "vundo")
  (declare-function vundo-next "vundo")
  (declare-function vundo-previous "vundo")
  (declare-function vundo-forward "vundo")
  (declare-function vundo-quit "vundo")
  (declare-function vundo-confirm "vundo")
  ;; 追加の関数宣言
  (declare-function meow-quit "init")
  ;; vertico関連の関数を追加
  (declare-function vertico-mode "vertico") 
  ;; consult関連の関数を追加
  (declare-function consult-completion-in-region "consult")
  (declare-function project-root "project")
  (declare-function consult-dir-jump-file "consult-dir")
  ;; embark関連の関数を追加
  (declare-function embark-prefix-help-command "embark")
  ;; orderless関連の関数を追加
  (declare-function orderless-escapable-split-on-space "orderless")
  ;; marginalia関連の関数を追加
  (declare-function marginalia-mode "marginalia"))

;; leaf設定
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

;; テーマ設定
(leaf catppuccin-theme 
  :ensure t
  :config
  (load-theme 'catppuccin t))

;; nerd-icons
;; (leaf nerd-icons
;;   :ensure t
;;   :package-download t  ;; 追加
;;   :if (display-graphic-p)
;;   :commands (nerd-icons-install-fonts)
;;   :custom
;;   (nerd-icons-font-family . "Symbols Nerd Font Mono")
;;   :config
;;   (unless (find-font (font-spec :family "Symbols Nerd Font Mono"))
;;     (message "nerd-iconsのフォントがインストールされていません。M-x nerd-icons-install-fontsを実行してください")))

;; なんか諸々設定
(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin" "internal"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))

  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "")
            (user-mail-address . "")
            (user-login-name . "")
            (create-lockfiles . nil)
            (debug-on-error . t)
            (init-file-debug . t)
            (frame-resize-pixelwise . t)
            (enable-recursive-minibuffers . t)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (scroll-preserve-screen-position . t)
            (scroll-conservatively . 100)
            (mouse-wheel-scroll-amount . '(1 ((control) . 5)))
            (ring-bell-function . 'ignore)
            (text-quoting-style . 'straight)
            (truncate-lines . t)
            (use-dialog-box . nil)
            (use-file-dialog . nil)
            (menu-bar-mode . nil)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil)))

;; 一般設定
(leaf *general-settings
  :config
  ;; yes/noをy/nに置き換え
  (defalias 'yes-or-no-p 'y-or-n-p)
  
  ;; C-hをバックスペースに
  (keyboard-translate ?\C-h ?\C-?))

;; 特殊バッファの設定
(leaf special-mode
  :config
  (define-key special-mode-map (kbd "h") 'backward-char)
  (define-key special-mode-map (kbd "l") 'forward-char)
  (define-key special-mode-map (kbd "j") 'next-line)
  (define-key special-mode-map (kbd "k") 'previous-line)
  ;; visual-stateの設定を追加
  (define-key special-mode-map (kbd "v") 'set-mark-command)
  (define-key special-mode-map (kbd "y") 'kill-ring-save))

;; meowモーダル編集の設定
(leaf meow
  :ensure t
  :require t
  
  :preface
  ;; バイトコンパイル時のための関数宣言
  (declare-function meow-yank "meow")  ;; meow-yankを事前に宣言
  
  ;; クリップボードの内容が行全体の場合のみ下に貼り付けるスマート関数
  (defun smart-yank ()
    "クリップボードの内容が行全体の場合はカーソル行の下に貼り付け、
それ以外の場合は通常の meow-yank を実行します。"
    (interactive)
    (let ((clipboard-text (current-kill 0)))
      (if (and clipboard-text
               (string-match-p "\n$" clipboard-text)  ;; 改行で終わる場合は行全体とみなす
               (not (string-match-p "\n.+\n" clipboard-text))) ;; 複数行の中間に改行がない場合
          ;; 行全体の場合は下に貼り付け
          (progn
            (end-of-line)
            (newline)
            (meow-yank))
        ;; それ以外は通常の貼り付け
        (meow-yank))))
  
  :custom
  (meow-use-clipboard . t)
  (meow-selection-command-fallback . '((meow-change . meow-change-char)
                                      (meow-kill . meow-kill-whole-line)
                                      (meow-cancel-selection . keyboard-quit)
                                      (meow-pop-selection . meow-pop-grab)
                                      (meow-beacon-change . meow-beacon-change-char)))

  :init
  ;; jjでescする設定用の変数
  (defvar my-meow-insert-j-timer nil
    "jjエスケープシーケンスを処理するためのタイマー")
  
  (defvar my-meow-insert-j-delay 0.2
    "2回目のjキー入力を待つ時間（秒）")
  
  (defun my-meow-insert-j-handler ()
    "インサートステートでのjキー入力を処理する
jjが入力された場合はノーマルモードに戻る"
    (interactive)
    (if my-meow-insert-j-timer
        (progn
          (cancel-timer my-meow-insert-j-timer)
          (setq my-meow-insert-j-timer nil)
          (delete-char -1)
          (meow-insert-exit))
      (progn
        (insert "j")
        (setq my-meow-insert-j-timer
              (run-with-timer my-meow-insert-j-delay nil
                             (lambda ()
                               (setq my-meow-insert-j-timer nil)))))))

  :hook
  ;; インサートモード終了時のime制御
  ((meow-insert-exit-hook . (lambda ()
                             (if (eq system-type 'darwin)
                                 (when (fboundp 'mac-ime-deactivate)
                                   (mac-ime-deactivate))
                               (deactivate-input-method)))))

  :config
  ;; vimライクなコマンドをメインの設定ブロックの外に定義（スコープの問題を解決）
  (defun meow-quit ()
    "vimの:qコマンドのような動作を実装。カレントウィンドウを閉じる。
  単一ウィンドウの場合はスクラッチバッファを表示する。"
    (interactive)
    (if (> (length (window-list)) 1)
        ;; 複数ウィンドウがある場合はウィンドウを閉じる
        (delete-window)
      ;; 単一ウィンドウの場合はスクラッチバッファを表示
      (save-buffers-kill-terminal)))
  
  (when (require 'meow nil t)
    ;; vimライクなコマンド実装
    (defun meow-ex-command (arg)
      "vimライクなexコマンド(:q, :wq等)を実行する"
      (interactive "M:")
      (pcase arg
        ("q" (meow-quit))
        ("q!" (kill-emacs))  ;; kill-emacsに変更
        ("w" (save-buffer))
        ("wq" (progn (save-buffer) (meow-quit)))
        (_ (message "unknown command: %s" arg))))

    (defun meow-setup ()
      (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)

      ;; motionステートのキー設定
      (meow-motion-overwrite-define-key
       '("j" . meow-next)
       '("k" . meow-prev))

      ;; insertステートのキー設定
      (meow-define-keys 'insert
        '("c-a" . meow-back-to-indentation)
        '("c-u" . scroll-down)
        '("c-d" . scroll-up)
        '("s-a" . mark-whole-buffer)
        '("s-c" . meow-save)
        '("s-s" . save-buffer)
        '("s-x" . meow-kill)
        '("s-v" . meow-yank)
        '("j" . my-meow-insert-j-handler))
      
      ;; normalステートのキー設定（重複を削除）
      (meow-normal-define-key
       ;; vimライクなコマンド
       '(":" . meow-ex-command)
       
       ;; ctrlキー
       '("c-a" . meow-back-to-indentation)
       '("c-u" . scroll-down)
       '("c-d" . scroll-up)

       ;; superキー
       '("s-a" . mark-whole-buffer)
       '("s-c" . meow-save)
       '("s-s" . save-buffer)
       '("s-v" . meow-yank)

       ;; ページ移動
       '("g g" . beginning-of-buffer)
       '("G" . end-of-buffer)  ;; 'g'から'G'に修正

       ;; 基本コマンド
       '(", u" . meow-universal-argument)
       '(", c" . comment-line)
       '(", e e" . "c-x c-e")
       '(", e m" . pp-macroexpand-last-sexp)
       '(", x" . execute-extended-command)

       ;; バッファ操作
       '(", b d" . kill-this-buffer)
       
       ;; ウィンドウ操作
       '(", w d" . delete-window)
       '("s s" . split-window-vertically)
       '("s v" . split-window-horizontally)
       '("s h" . windmove-left)
       '("s l" . windmove-right)
       '("s j" . windmove-down)
       '("s k" . windmove-up)

       ;; ベースレイアウト（重複を削除）
       '("0" . meow-expand-0)
       '("9" . meow-expand-9)
       '("8" . meow-expand-8)
       '("7" . meow-expand-7)
       '("6" . meow-expand-6)
       '("5" . meow-expand-5)
       '("4" . meow-expand-4)
       '("3" . meow-expand-3)
       '("2" . meow-expand-2)
       '("1" . meow-expand-1)
       '("-" . negative-argument)
       '(";" . meow-reverse)
       '("[" . meow-beginning-of-thing)
       '("]" . meow-end-of-thing)
       '("a" . meow-append)
       '("b" . switch-to-buffer)  ;; どちらか一方のみ残す
       '("d" . meow-kill-whole-line)  ;; どちらか一方のみ残す
       '("e" . meow-next-symbol)  ;; どちらか一方のみ残す
       '("f" . find-file)
       '("h" . meow-left)
       '("i" . meow-insert)
       '("j" . meow-next)
       '("k" . meow-prev)
       '("l" . meow-right)
       '("m" . meow-join)
       '("n" . meow-search)
       '("o" . meow-open-below)
       '("p" . smart-yank)  ;; スマート貼り付け関数を割り当て
       '("q" . meow-goto-line)
       '("r" . meow-replace)
       '("t" . meow-till)
       '("u" . vundo)
       '("U" . meow-undo-in-selection)
       '("v i" . meow-inner-of-thing)
       '("v a" . meow-bounds-of-thing)
       '("v b" . meow-block)
       '("v l" . meow-line)
       '("v s" . meow-mark-symbol)
       '("v w" . meow-mark-word)
       '("y" . meow-save)
       '("Y" . meow-sync-grab)
       '("z" . meow-pop-selection)
       '("'" . repeat)
       '("/" . meow-visit)))
    )
  
  (meow-setup)
  (meow-global-mode 1))

;; vundoパッケージを追加
(leaf vundo
  :ensure t
  :require t  ; パッケージを必ず読み込む
  :custom
  (vundo-glyph-alist . vundo-unicode-symbols)
  :config  ; パッケージ読み込み後に実行
  (keymap-set vundo-mode-map "h" #'vundo-backward)
  (keymap-set vundo-mode-map "j" #'vundo-next)
  (keymap-set vundo-mode-map "k" #'vundo-previous)
  (keymap-set vundo-mode-map "l" #'vundo-forward)
  (keymap-set vundo-mode-map "q" #'vundo-quit)
  (keymap-set vundo-mode-map "RET" #'vundo-confirm)
  (keymap-set vundo-mode-map "C-g" #'vundo-quit))

;; Vertico補完フレームワークの設定
(leaf vertico
  :ensure t
  :custom
  (vertico-resize . nil)    ;; ミニバッファのサイズを固定
  (vertico-count . 10)      ;; 表示する候補の数を20に設定
  (vertico-cycle . t)       ;; 候補の循環を有効化
  :bind (:vertico-map
         ("DEL" . vertico-directory-delete-char))  ;; DELキーでディレクトリ削除
  :init
  (vertico-mode)            ;; Verticoモードを有効化
  
  ;; verticoの選択行を指す指アイコンを追加
  :config
  ;; nerd-iconsの条件付き使用
  (when (require 'nerd-icons nil t)  ;; 存在する場合のみ読み込む
    (defvar +vertico-current-arrow t)
    (cl-defmethod vertico--format-candidate :around
      (cand prefix suffix index start &context ((and +vertico-current-arrow
                                                    (not (bound-and-true-p vertico-flat-mode)))
                                                (eql t)))
      (setq cand (cl-call-next-method cand prefix suffix index start))
      (if (= vertico--index index)  ;; この行で vertico--index を使用
          (let ((arrow (if (fboundp 'nerd-icons-faicon)
                          (nerd-icons-faicon "nf-fa-hand_o_right")
                        "→")))  ;; フォールバックとして通常の矢印を使用
            (if (bound-and-true-p vertico-grid-mode)
                (concat arrow " " cand)
              (concat " " arrow " " cand)))
        (if (bound-and-true-p vertico-grid-mode)
            (concat #("_" 0 1 (display " ")) cand)
          (concat "    " cand))))))

;; consultの設定
(leaf consult
  :ensure t
  :bind (("C-x b" . consult-buffer)          ;; バッファ切り替え
         ("C-s" . consult-line)              ;; インクリメンタル検索
         ("C-c i" . consult-imenu)           ;; imenu
         ("C-x r b" . consult-bookmark)      ;; ブックマーク
         ("C-x p b" . consult-project-buffer) ;; プロジェクトバッファ
         ("M-g g" . consult-goto-line)       ;; 指定行へ移動
         ("M-g M-g" . consult-goto-line)     ;; 指定行へ移動（代替）
         ("M-g f" . consult-flymake)         ;; flymakeエラー
         ("M-g i" . consult-imenu)           ;; imenu
         ("M-s f" . consult-find)            ;; ファイル検索
         ("M-s g" . consult-grep)            ;; grep検索
         ("M-s r" . consult-ripgrep))        ;; ripgrep検索
  :bind (:minibuffer-local-map
         ("M-r" . consult-history))          ;; ミニバッファ履歴
  :custom
  (consult-project-root-function . (lambda () 
                                     (when-let (project (project-current))
                                       (project-root project))))
  :config
  ;; メニューアイテムを追加
  (setq completion-in-region-function #'consult-completion-in-region))

(leaf consult-dir
  ;; :ensure t
  :bind (("C-x C-d" . consult-dir))
  :after (consult vertico)
  :config
  (with-eval-after-load 'vertico
    (define-key vertico-map (kbd "C-x C-d") #'consult-dir)
    (define-key vertico-map (kbd "C-x C-j") #'consult-dir-jump-file)))

(leaf consult-flycheck
  :ensure t
  :after (consult flycheck))

;; (leaf consult-eglot
;;   ;; :ensure t
;;   :after (consult eglot))

(leaf embark
  :ensure t
  :bind (("C-." . embark-act)
         ("M-." . embark-dwim)
         ("C-h B" . embark-bindings))
  :custom
  (prefix-help-command . #'embark-prefix-help-command))

(leaf embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Orderless - 柔軟な補完スタイルを提供
(leaf orderless
  :ensure t
  :custom
  ;; 基本の補完スタイルを設定
  (completion-styles . '(orderless basic))
  ;; ファイル補完に対しては基本的な部分一致を使用
  (completion-category-overrides . '((file (styles basic partial-completion))))
  ;; スペースを区切り文字として使用する設定（重要）
  (orderless-component-separator . #'orderless-escapable-split-on-space)
  ;; 補完スタイルを詳細に設定
  (orderless-matching-styles . '(orderless-literal
                                 orderless-regexp
                                 orderless-initialism
                                 orderless-prefixes))
  :config
  ;; デバッグ用：補完スタイルの状態を確認
  (message "Current completion styles: %s" completion-styles)
  (message "Current orderless-component-separator: %s" 
           (symbol-name orderless-component-separator)))

;; Marginalia - ミニバッファの候補にリッチな注釈を追加
(leaf marginalia
  :ensure t
  :init
  (marginalia-mode))

(provide 'init)
