/**
 * Sora UI
 * ============================================================
 * 使い方:
 *   1. index.html に以下を追加する:
 *        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
 *        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
 *        <script src="sora-ui.js"></script>
 *      （ui-codespace でシンタックスハイライトを使わない場合、highlight.js は省略可）
 *
 *   2. UIを表示したい場所に
 *        <div id="app" data-soraui-src="page.soraui"></div>
 *      と書く
 *
 *   3. page.soraui (JSON) に font / theme / mode / titlebar / tabs / components を書く
 *
 * このファイルは編集不要です。
 * UIの追加・変更はすべて .soraui ファイル側で行います。
 *
 * ============================================================
 * v2 新機能:
 *
 * 【サイズ系設定】コンポーネントの大きさ
 *   size キーで指定するか、width/height に以下のキーワードを使用可:
 *   - "auto"    : 親要素の幅・高さ両方に 100% フィット
 *   - "xauto"   : 横幅だけ 100%（縦は height で指定するか内容に従う）
 *   - "yauto"   : 縦幅だけ 100%（横は width で指定するか内容に従う）
 *   - "custom"  : width/height に指定した値をそのまま使用（デフォルト）
 *   例:
 *     { type: "image", size: "auto" }
 *     { type: "section", size: "yauto", title: "ヒーロー" }
 *
 * 【位置系個別指定】各コンポーネントの微調整
 *   position でプリセット配置(top-left等)を指定した後、
 *   offsetTop / offsetRight / offsetBottom / offsetLeft で個別に位置を調整可:
 *   例:
 *     { type: "text", position: "top-right", offsetTop: 12, offsetRight: 8 }
 *
 * 【スマホ対応】mobile オーバーライド
 *   各コンポーネントに mobile: { ...プロパティ上書き } を記述すると、
 *   スマホ幅(≤720px)の時だけその設定に切り替わる。
 *   titlebar / tabs / sidebar / 各component単位で指定可:
 *   例:
 *     { type: "text", title: "PC用", mobile: { title: "スマホ用" } }
 *     { title: "App", mobile: { icon: "📱" } }  (titlebar)
 *
 * 【タイトルバー常時表示】
 *   タイトルバーが position: sticky で常に画面上部に固定される。
 *   Docs モードでも同様に タイトルバーが最上部に表示されるように改善。
 *
 * 【Docs モード全面改善】
 *   - タイトルバーが Page モードと統一されたデザインで表示
 *   - tabs が指定されている場合、タブ毎に sidebar を切り替え可能
 *   - モバイル幅ではタイトルバーのハンバーガーでサイドバー開閉
 *   - sticky な sidebar が titlebar の高さを考慮して配置される
 *
 * ============================================================
 */

(function () {
  "use strict";

  /* ============================================================
   * 1. テーマ定義
   *    新しいテーマを増やしたい場合はここに追加する
   *    （.sorauiファイルの "theme" で名前を指定して使う）
   * ============================================================ */
  const THEMES = {
    darkorange: {
      primary: "#ff8c42",
      primaryHover: "#ff7a1f",
      bg: "#1a1410",
      surface: "#241c16",
      border: "#3a2c20",
      text: "#f5e8dc",
      textMuted: "#caa98f",
    },
    whiteorange: {
      primary: "#ff8c42",
      primaryHover: "#e6741f",
      bg: "#fff8f0",
      surface: "#ffffff",
      border: "#f0ddc8",
      text: "#2d2424",
      textMuted: "#8a7565",
    },
    darkblue: {
      primary: "#4f8cff",
      primaryHover: "#3672e6",
      bg: "#10141a",
      surface: "#1a212b",
      border: "#2a3340",
      text: "#e8eef5",
      textMuted: "#8a99ab",
    },
    whiteblue: {
      primary: "#4f8cff",
      primaryHover: "#3672e6",
      bg: "#f5f8ff",
      surface: "#ffffff",
      border: "#dde6f5",
      text: "#1e2733",
      textMuted: "#74859c",
    },
  };

  const DEFAULT_THEME = "whiteorange";

  // 親要素基準の9方向 position -> flexboxの配置に変換
  const POSITION_MAP = {
    "top-left": { justify: "flex-start", align: "flex-start" },
    "top-center": { justify: "center", align: "flex-start" },
    "top-right": { justify: "flex-end", align: "flex-start" },
    "center-left": { justify: "flex-start", align: "center" },
    "center": { justify: "center", align: "center" },
    "center-right": { justify: "flex-end", align: "center" },
    "bottom-left": { justify: "flex-start", align: "flex-end" },
    "bottom-center": { justify: "center", align: "flex-end" },
    "bottom-right": { justify: "flex-end", align: "flex-end" },
  };

  /* ============================================================
   * 2. フォント読み込み
   *    拡張子(.ttf/.otf/.woff/.woff2)があればファイルとして@font-face、
   *    なければGoogle Fontsの名前として<link>タグを注入する
   * ============================================================ */
  const FONT_FILE_EXTENSIONS = [".ttf", ".otf", ".woff", ".woff2"];

  function isFontFilePath(font) {
    const lower = font.toLowerCase();
    return FONT_FILE_EXTENSIONS.some((ext) => lower.endsWith(ext));
  }

  function loadFont(font) {
    if (!font) return "sans-serif";

    if (isFontFilePath(font)) {
      const familyName = "SoraCustomFont";
      const style = document.createElement("style");
      style.setAttribute("data-sora-font", "true");
      style.textContent = `
        @font-face {
          font-family: "${familyName}";
          src: url("${font}");
        }
      `;
      document.head.appendChild(style);
      return `"${familyName}"`;
    }

    // Google Fonts名として扱う
    const link = document.createElement("link");
    link.rel = "stylesheet";
    link.href = `https://fonts.googleapis.com/css2?family=${encodeURIComponent(font)}:wght@400;600;700&display=swap`;
    document.head.appendChild(link);
    return `"${font}"`;
  }

  /* ============================================================
   * 3. スタイル注入
   *    CSSファイルを使わず、JSの中からstyleタグを生成する
   * ============================================================ */
  function injectStyles(themeName, fontFamily) {
    const theme = THEMES[themeName] || THEMES[DEFAULT_THEME];

    const cssVars = Object.entries(theme)
      .map(([key, value]) => `--ui-${key}: ${value};`)
      .join("\n      ");

    const css = `
      :root {
        ${cssVars}
      }

      .ui-root {
        font-family: ${fontFamily}, -apple-system, BlinkMacSystemFont, "Segoe UI", Hiragino Sans, sans-serif;
        background: var(--ui-bg);
        color: var(--ui-text);
        min-height: 100%;
        box-sizing: border-box;
      }

      .ui-root * {
        box-sizing: border-box;
      }

      .ui-page-body {
        padding: 0;
      }

      /* ---- Titlebar ----
         常に画面上部に固定表示（sticky）。Page / Docs 両モード共通で使う。 */
      .ui-titlebar {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 14px 24px;
        border-bottom: 1px solid var(--ui-border);
        background: var(--ui-surface);
        position: sticky;
        top: 0;
        z-index: 200;
      }

      .ui-titlebar-icon {
        width: 24px;
        height: 24px;
        object-fit: contain;
        flex-shrink: 0;
      }

      .ui-titlebar-title {
        font-size: 16px;
        font-weight: 700;
      }

      .ui-titlebar-tabs {
        display: flex;
        gap: 4px;
        margin-left: 24px;
      }

      /* ---- Hamburger (mobile menu button) ---- */
      .ui-hamburger {
        display: none;
        background: none;
        border: none;
        padding: 6px;
        margin-left: auto;
        cursor: pointer;
        flex-direction: column;
        gap: 4px;
        justify-content: center;
      }

      /* サイドバー開閉用ハンバーガー（Docsモード）。タイトルバー左端に出すので
         右寄せの margin-left:auto を打ち消す。常にモバイル幅でのみ表示。 */
      .ui-hamburger--sidebar {
        display: none;
        margin-left: 0;
        margin-right: 4px;
      }

      .ui-hamburger span {
        display: block;
        width: 20px;
        height: 2px;
        background: var(--ui-text);
        border-radius: 1px;
      }

      /* タブのドロップダウン（モバイルでハンバーガーを押した時に出る） */
      .ui-titlebar-tabs-dropdown {
        display: none;
        position: absolute;
        top: 100%;
        right: 16px;
        background: var(--ui-surface);
        border: 1px solid var(--ui-border);
        border-radius: 8px;
        padding: 6px;
        flex-direction: column;
        gap: 2px;
        min-width: 160px;
        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
        z-index: 50;
      }

      .ui-titlebar-tabs-dropdown.is-open {
        display: flex;
      }

      .ui-titlebar-tabs-dropdown .ui-titlebar-tab-item {
        padding: 10px 12px;
        border-bottom: none;
        border-radius: 6px;
      }

      .ui-titlebar-tabs-dropdown .ui-titlebar-tab-item.is-active {
        background: var(--ui-bg);
      }

      @media (max-width: 720px) {
        .ui-titlebar-tabs {
          display: none;
        }

        .ui-hamburger {
          display: flex;
        }
      }

      @media (max-width: 860px) {
        .ui-hamburger--sidebar {
          display: flex;
        }
      }

      /* ---- Tab (shared by page mode top bar & docs mode top bar) ---- */
      .ui-tabbar {
        display: flex;
        gap: 4px;
        border-bottom: 1px solid var(--ui-border);
        margin-bottom: 20px;
        padding: 0 24px;
      }

      .ui-tabbar-item,
      .ui-titlebar-tab-item {
        padding: 10px 18px;
        cursor: pointer;
        color: var(--ui-textMuted);
        border-bottom: 2px solid transparent;
        font-size: 14px;
        font-weight: 600;
        transition: color 0.15s ease, border-color 0.15s ease;
        user-select: none;
        white-space: nowrap;
      }

      .ui-tabbar-item:hover,
      .ui-titlebar-tab-item:hover {
        color: var(--ui-text);
      }

      .ui-tabbar-item.is-active,
      .ui-titlebar-tab-item.is-active {
        color: var(--ui-primary);
        border-bottom-color: var(--ui-primary);
      }

      .ui-tabpanel {
        display: none;
      }

      .ui-tabpanel.is-active {
        display: block;
      }

      /* ---- Section ----
         画面幅ジャストの帯状ブロック。角丸なし、Section同士の間隔はゼロ。
         左右の余白は内側の padding で確保する（外枠は画面端まで届く） */
      .ui-section {
        width: 100%;
        background: var(--ui-surface);
        border-top: 1px solid var(--ui-border);
        border-bottom: 1px solid var(--ui-border);
        padding: 28px 32px;
        display: flex;
        flex-direction: column;
        box-sizing: border-box;
      }

      /* 連続するSection同士は二重線にならないよう、上のボーダーを重ねて消す */
      .ui-section + .ui-section,
      .ui-section + .ui-imagesection,
      .ui-imagesection + .ui-section,
      .ui-imagesection + .ui-imagesection {
        border-top: none;
        margin-top: -1px;
      }

      .ui-section-title {
        font-size: 15px;
        font-weight: 700;
        margin: 0 0 14px 0;
        color: var(--ui-text);
      }

      .ui-section-body {
        flex: 1;
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        overflow: auto;
      }

      /* ---- Image Section ----
         画面幅ジャスト。children を画像の上に重ねて配置できる */
      .ui-imagesection {
        width: 100%;
        position: relative;
        overflow: hidden;
        background: var(--ui-surface);
        border-top: 1px solid var(--ui-border);
        border-bottom: 1px solid var(--ui-border);
        box-sizing: border-box;
      }

      .ui-imagesection img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
      }

      .ui-imagesection-overlay {
        position: absolute;
        inset: 0;
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
        padding: 24px 32px;
        box-sizing: border-box;
      }

      /* 文字や背景のないボタン等が写真に埋もれないよう、薄い影をデフォルトで付ける */
      .ui-imagesection-overlay .ui-text-title,
      .ui-imagesection-overlay .ui-text-description,
      .ui-imagesection-overlay .ui-text-body {
        color: #ffffff;
        text-shadow: 0 1px 4px rgba(0, 0, 0, 0.5);
      }

      /* ---- Image (section内に置く単体の画像) ---- */
      .ui-image-wrap {
        display: flex;
        max-width: 100%;
      }

      .ui-image-wrap img {
        max-width: 100%;
        height: auto;
        display: block;
        border-radius: 8px;
      }

      /* ---- InSection ----
         section内の独立した区切り。こちらは角丸カード型を維持 */
      .ui-insection-row {
        display: flex;
        gap: 10px;
        width: 100%;
      }

      .ui-insection {
        flex: 1;
        min-width: 0;
        background: var(--ui-bg);
        border: 1px solid var(--ui-border);
        padding: 14px;
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
      }

      /* ---- Button ---- */
      .ui-button {
        appearance: none;
        border: none;
        border-radius: 8px;
        padding: 10px 18px;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        transition: background 0.15s ease, transform 0.05s ease;
      }

      .ui-button:active {
        transform: scale(0.98);
      }

      .ui-button--primary {
        background: var(--ui-primary);
        color: #ffffff;
      }

      .ui-button--primary:hover {
        background: var(--ui-primaryHover);
      }

      .ui-button--secondary {
        background: transparent;
        color: var(--ui-text);
        border: 1px solid var(--ui-border);
      }

      .ui-button--secondary:hover {
        background: var(--ui-border);
      }

      /* ---- Text ---- */
      .ui-text-block {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }

      .ui-text-title {
        font-size: 18px;
        font-weight: 700;
        color: var(--ui-text);
        margin: 0;
      }

      .ui-text-description {
        font-size: 13px;
        color: var(--ui-textMuted);
        margin: 0;
      }

      .ui-text-body {
        font-size: 14px;
        color: var(--ui-text);
        line-height: 1.6;
        margin: 0;
      }

      /* ---- Table ---- */
      .ui-table-wrap {
        width: 100%;
        overflow-x: auto;
        border: 1px solid var(--ui-border);
        border-radius: 10px;
      }

      .ui-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 14px;
      }

      .ui-table th,
      .ui-table td {
        padding: 10px 14px;
        text-align: left;
        border-bottom: 1px solid var(--ui-border);
        white-space: nowrap;
      }

      .ui-table th {
        background: var(--ui-surface);
        color: var(--ui-textMuted);
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.03em;
      }

      .ui-table tr:last-child td {
        border-bottom: none;
      }

      .ui-table tbody tr:hover {
        background: var(--ui-surface);
      }

      /* ---- List ---- */
      .ui-list {
        width: 100%;
        display: flex;
        flex-direction: column;
        border: 1px solid var(--ui-border);
        border-radius: 10px;
        overflow: hidden;
      }

      .ui-list-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px 16px;
        border-bottom: 1px solid var(--ui-border);
        font-size: 14px;
        color: var(--ui-text);
      }

      .ui-list-item:last-child {
        border-bottom: none;
      }

      .ui-list--ordered .ui-list-item {
        counter-increment: ui-list-counter;
      }

      .ui-list--ordered {
        counter-reset: ui-list-counter;
      }

      .ui-list--ordered .ui-list-item::before {
        content: counter(ui-list-counter) ".";
        color: var(--ui-textMuted);
        font-weight: 700;
        min-width: 20px;
      }

      .ui-list--unordered .ui-list-item::before {
        content: "•";
        color: var(--ui-primary);
        font-weight: 700;
      }

      /* ---- Codespace ---- */
      .ui-codespace {
        position: relative;
        background: #0d1117;
        border: 1px solid var(--ui-border);
        border-radius: 10px;
        overflow: hidden;
        width: 100%;
      }

      .ui-codespace pre {
        margin: 0;
        padding: 16px;
        overflow: auto;
        font-size: 13px;
        line-height: 1.5;
      }

      .ui-codespace-copy {
        position: absolute;
        top: 8px;
        right: 8px;
        background: rgba(255, 255, 255, 0.1);
        color: #fff;
        border: none;
        border-radius: 6px;
        padding: 5px 10px;
        font-size: 12px;
        cursor: pointer;
      }

      .ui-codespace-copy:hover {
        background: rgba(255, 255, 255, 0.2);
      }

      .ui-error {
        color: #d64545;
        font-family: monospace;
        white-space: pre-wrap;
        padding: 16px;
        border: 1px solid #d64545;
        border-radius: 8px;
        margin: 24px;
      }

      /* ---- Docs mode ----
         titlebar (sticky, top:0) の下に sidebar + content を並べる。
         sidebar は titlebar の高さを引いた残りの領域で sticky させる。
         CSS変数 --ui-titlebar-h は JS 側で titlebar の実測高さを入れる
         （titlebar が無い場合は 0px）。 */
      .ui-docs-wrap {
        --ui-titlebar-h: 0px;
      }

      /* タブ付きDocsモード: タブごとに丸ごとの docsRow(sidebar+content) を
         切り替える。非アクティブなものは display:none で隠す */
      .ui-docs-tabwrapper {
        display: block;
      }

      .ui-docs-tabpanel {
        display: none;
      }

      .ui-docs-tabpanel.is-active {
        display: flex;
      }

      .ui-docs {
        display: flex;
        align-items: stretch;
        gap: 0;
        min-height: calc(100vh - var(--ui-titlebar-h));
      }

      /* .ui-docs と .ui-docs-tabpanel の両方を持つ要素は、CSS定義順に関わらず
         タブの開閉状態を確実に優先させる */
      .ui-docs.ui-docs-tabpanel {
        display: none;
      }

      .ui-docs.ui-docs-tabpanel.is-active {
        display: flex;
      }

      .ui-docs-sidebar {
        width: 260px;
        flex-shrink: 0;
        background: var(--ui-surface);
        border-right: 1px solid var(--ui-border);
        padding: 16px 12px 24px;
        position: sticky;
        top: var(--ui-titlebar-h);
        height: calc(100vh - var(--ui-titlebar-h));
        overflow-y: auto;
      }

      .ui-docs-content {
        flex: 1;
        padding: 48px 56px;
        min-width: 0;
        display: flex;
        justify-content: center;
      }

      .ui-docs-content-inner {
        width: 100%;
        max-width: 720px;
      }

      /* ---- Docs: mobile sidebar overlay ----
         モバイル幅では titlebar のハンバーガーで開閉する。
         サイドバーは titlebar の下から画面下端まで覆う固定パネルになる。 */
      .ui-docs-overlay {
        display: none;
        position: fixed;
        top: var(--ui-titlebar-h);
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.4);
        z-index: 90;
      }

      .ui-docs-overlay.is-open {
        display: block;
      }

      @media (max-width: 860px) {
        .ui-docs {
          position: relative;
        }

        .ui-docs-sidebar {
          position: fixed;
          top: var(--ui-titlebar-h);
          left: 0;
          height: calc(100vh - var(--ui-titlebar-h));
          z-index: 100;
          transform: translateX(-100%);
          transition: transform 0.2s ease;
          box-shadow: 4px 0 16px rgba(0, 0, 0, 0.2);
        }

        .ui-docs-sidebar.is-open {
          transform: translateX(0);
        }

        .ui-docs-content {
          padding: 32px 20px;
        }
      }

      .ui-docs-category {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 12px;
        font-weight: 700;
        color: var(--ui-textMuted);
        padding: 6px 10px;
        margin: 18px 0 4px;
        text-transform: uppercase;
        letter-spacing: 0.04em;
      }

      .ui-docs-category:first-of-type {
        margin-top: 8px;
      }

      .ui-docs-icon {
        width: 18px;
        height: 18px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        flex-shrink: 0;
      }

      .ui-docs-icon img {
        width: 16px;
        height: 16px;
        object-fit: contain;
      }

      .ui-docs-page {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 14px;
        color: var(--ui-textMuted);
        padding: 7px 10px 7px 24px;
        margin: 1px 0;
        border-radius: 6px;
        cursor: pointer;
        user-select: none;
        border-left: 2px solid transparent;
        transition: background 0.12s ease, color 0.12s ease;
      }

      .ui-docs-page:hover {
        background: var(--ui-border);
        color: var(--ui-text);
      }

      .ui-docs-page.is-active {
        background: var(--ui-border);
        color: var(--ui-primary);
        font-weight: 700;
        border-left-color: var(--ui-primary);
      }

      .ui-docs-page.is-hidden,
      .ui-docs-category.is-hidden {
        display: none;
      }

      .ui-docs-panel {
        display: none;
      }

      .ui-docs-panel.is-active {
        display: block;
      }

      .ui-docs-panel-title {
        font-size: 28px;
        font-weight: 700;
        margin: 0 0 24px 0;
        color: var(--ui-text);
      }

      .ui-docs-search {
        width: 100%;
        padding: 8px 10px;
        margin-bottom: 8px;
        font-size: 13px;
        border: 1px solid var(--ui-border);
        border-radius: 6px;
        background: var(--ui-bg);
        color: var(--ui-text);
        outline: none;
      }

      .ui-docs-search::placeholder {
        color: var(--ui-textMuted);
      }

      .ui-docs-search:focus {
        border-color: var(--ui-primary);
      }

      .ui-docs-pagenav {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        margin-top: 40px;
        padding-top: 20px;
        border-top: 1px solid var(--ui-border);
      }

      .ui-docs-pagenav-link {
        flex: 1;
        max-width: 48%;
        display: flex;
        flex-direction: column;
        gap: 4px;
        padding: 12px 16px;
        border: 1px solid var(--ui-border);
        border-radius: 8px;
        cursor: pointer;
        transition: border-color 0.12s ease, background 0.12s ease;
      }

      .ui-docs-pagenav-link:hover {
        border-color: var(--ui-primary);
        background: var(--ui-surface);
      }

      .ui-docs-pagenav-link--next {
        margin-left: auto;
        text-align: right;
        align-items: flex-end;
      }

      .ui-docs-pagenav-label {
        font-size: 11px;
        color: var(--ui-textMuted);
        text-transform: uppercase;
        letter-spacing: 0.04em;
      }

      .ui-docs-pagenav-title {
        font-size: 14px;
        font-weight: 600;
        color: var(--ui-primary);
      }
    `;

    let styleTag = document.querySelector("style[data-sora-ui]");
    if (!styleTag) {
      styleTag = document.createElement("style");
      styleTag.setAttribute("data-sora-ui", "true");
      document.head.appendChild(styleTag);
    }
    styleTag.textContent = css;
  }

  /* ============================================================
   * 4. アイコン要素生成（絵文字 / 画像URL / パス どれでも対応）
   * ============================================================ */
  function looksLikeImagePath(value) {
    return /\.(png|jpe?g|svg|gif|webp)$/i.test(value) || value.startsWith("http") || value.startsWith("/");
  }

  function createIconElement(icon, className) {
    if (!icon) return null;
    const wrap = document.createElement("span");
    wrap.className = className || "ui-docs-icon";

    if (looksLikeImagePath(icon)) {
      const img = document.createElement("img");
      img.src = icon;
      img.alt = "";
      wrap.appendChild(img);
    } else {
      wrap.textContent = icon;
    }
    return wrap;
  }

  /* ============================================================
   * 5. position / size / mobile の適用
   * ------------------------------------------------------------
   * position: 親要素基準の9方向プリセット（従来通り）
   * offset(top/right/bottom/left): 個別の位置を1つずつ上書き指定できる
   *   例: { position: "top-right", offsetTop: 12, offsetRight: 12 }
   *   -> 9方向の配置はそのまま使いつつ、絶対位置で微調整したい場合は
   *      offsetX/offsetY を指定すると要素自体を相対的にずらす(transform)
   * size: 大きさ系のキーワード
   *   - "auto"   : 親(セレクション)の幅・高さの両方に合わせる
   *   - "xauto"  : 横幅だけ親に合わせる(縦は内容に従う/heightで個別指定可)
   *   - "yauto"  : 縦幅だけ親に合わせる(横は内容に従う/widthで個別指定可)
   *   - "custom" : width / height に指定した値をそのまま使う(従来通り)
   *   size を指定しない場合は、width/height の値がそのままキーワードかどうかも
   *   個別にチェックする(後方互換: width:"auto" 等の直接指定にも対応)
   * ============================================================ */
  function applyPosition(el, position) {
    if (!position) return;
    const map = POSITION_MAP[position];
    if (!map) {
      console.warn(`[Sora UI] unknown position: "${position}"`);
      return;
    }
    el.style.justifyContent = map.justify;
    el.style.alignItems = map.align;
  }

  // 個別オフセット(offsetTop/offsetRight/offsetBottom/offsetLeft)を適用する。
  // 指定がある場合は要素を position:relative にして個別にずらす。
  // position(9方向プリセット)と併用可能（プリセットで大まかに置いてから微調整する用途）。
  function applyOffset(el, def) {
    const hasOffset =
      def.offsetTop !== undefined ||
      def.offsetRight !== undefined ||
      def.offsetBottom !== undefined ||
      def.offsetLeft !== undefined;
    if (!hasOffset) return;

    const currentPosition = el.style.position;
    if (!currentPosition || currentPosition === "static") {
      el.style.position = "relative";
    }
    if (def.offsetTop !== undefined) el.style.top = toCssSize(def.offsetTop);
    if (def.offsetRight !== undefined) el.style.right = toCssSize(def.offsetRight);
    if (def.offsetBottom !== undefined) el.style.bottom = toCssSize(def.offsetBottom);
    if (def.offsetLeft !== undefined) el.style.left = toCssSize(def.offsetLeft);
  }

  // 数値が来たら px を付け、文字列(例: "1.5rem")はそのまま使う
  function toCssSize(value) {
    return typeof value === "number" ? `${value}px` : value;
  }

  const SIZE_KEYWORDS = ["auto", "xauto", "yauto", "custom"];

  function isSizeKeyword(value) {
    return typeof value === "string" && SIZE_KEYWORDS.includes(value);
  }

  /**
   * 大きさ系の設定を要素に適用する。
   * def.size（推奨）、または def.width / def.height にキーワードを直接書く
   * 後方互換の両方に対応する。
   *
   *   size: "auto"    -> width:100%; height:100%
   *   size: "xauto"   -> width:100%; height は def.height があればそれを使う(無ければ auto)
   *   size: "yauto"   -> height:100%; width は def.width があればそれを使う(無ければ auto)
   *   size: "custom"  -> width/height を def.width / def.height の値そのまま使う
   *
   * def.width / def.height は size とは独立して個別にも解釈される:
   *   width: "auto"  -> その要素の width だけ親に合わせる
   *   width: "xauto" / "yauto" は width 単体では意味が無いため auto 扱いにフォールバックする
   */
  function applySize(el, def) {
    const size = def.size;

    function resolveAxis(axisValue, fillKeyword) {
      // "auto" 系キーワードが来たら 100%、"custom" または通常値はそのまま、未指定は触らない
      if (axisValue === undefined || axisValue === null) return undefined;
      if (axisValue === fillKeyword || axisValue === "auto") return "100%";
      if (axisValue === "custom") return undefined; // custom指定だが値が無い -> 何もしない
      return toCssSize(axisValue);
    }

    if (size === "auto") {
      el.style.width = "100%";
      el.style.height = "100%";
    } else if (size === "xauto") {
      el.style.width = "100%";
      if (def.height !== undefined) el.style.height = resolveAxis(def.height, "yauto");
    } else if (size === "yauto") {
      el.style.height = "100%";
      if (def.width !== undefined) el.style.width = resolveAxis(def.width, "xauto");
    } else {
      // size: "custom" または size 未指定 -> width/height を個別に見る
      // （width/height自体に auto系キーワードが直接書かれているケースも吸収する）
      if (def.width !== undefined) {
        if (def.width === "auto" || def.width === "xauto") {
          el.style.width = "100%";
        } else if (def.width !== "custom" && def.width !== "yauto") {
          el.style.width = toCssSize(def.width);
        }
      }
      if (def.height !== undefined) {
        if (def.height === "auto" || def.height === "yauto") {
          el.style.height = "100%";
        } else if (def.height !== "custom" && def.height !== "xauto") {
          el.style.height = toCssSize(def.height);
        }
      }
    }
  }

  /* ============================================================
   * 5b. モバイル判定 & コンポーネント単位のモバイル上書き
   * ------------------------------------------------------------
   * 各コンポーネント定義に "mobile": { ...上書きしたいプロパティ } を
   * 書くと、画面幅が MOBILE_BREAKPOINT 以下の時だけそのプロパティで
   * 上書きしたものとして扱う。ネストした mobile.mobile は無視する。
   * ============================================================ */
  const MOBILE_BREAKPOINT = 720;

  function isMobileViewport() {
    return window.matchMedia(`(max-width: ${MOBILE_BREAKPOINT}px)`).matches;
  }

  // def と def.mobile をマージした「実際に使う定義」を返す。
  // モバイル幅でなければ def をそのまま返す。
  function resolveResponsive(def) {
    if (!def || !def.mobile || !isMobileViewport()) return def;
    return Object.assign({}, def, def.mobile, { mobile: undefined });
  }

  /* ============================================================
   * 6. アクションの実行（ui-button の action）
   *    type: link / external / switchTab / toggleSection / copy / scrollTo
   * ============================================================ */
  function runAction(action, ctx) {
    if (!action || !action.type) return;

    switch (action.type) {
      case "link":
        if (action.url) window.location.href = action.url;
        break;

      case "external":
        if (action.url) window.open(action.url, "_blank", "noopener");
        break;

      case "switchTab":
        if (action.target && ctx.switchTab) ctx.switchTab(action.target);
        break;

      case "toggleSection": {
        if (!action.target) return;
        const target = document.getElementById(action.target);
        if (target) target.classList.toggle("is-hidden");
        break;
      }

      case "copy":
        if (action.text && navigator.clipboard) {
          navigator.clipboard.writeText(action.text).catch((err) => console.error("[Sora UI] copy failed", err));
        }
        break;

      case "scrollTo": {
        if (!action.target) return;
        const target = document.getElementById(action.target);
        if (target) target.scrollIntoView({ behavior: "smooth", block: "start" });
        break;
      }

      default:
        console.warn(`[Sora UI] unknown action type: "${action.type}"`);
    }
  }

  /* ============================================================
   * 7. コンポーネント生成（JSON -> DOM）
   *    ctx には switchTab などの、その場のレンダリングコンテキストが入る
   * ============================================================ */

  // type: "button"
  function createButton(def, ctx) {
    const variant = def.color === "secondary" ? "secondary" : "primary";
    const el = document.createElement("button");
    el.type = "button";
    el.className = `ui-button ui-button--${variant}`;
    el.textContent = def.title || "";
    if (def.id) el.id = def.id;

    el.addEventListener("click", () => runAction(def.action, ctx));
    return el;
  }

  // type: "text"
  // プリセット: title(大) / description(小・薄) / body(本文)
  // カスタムサイズ: titleSize / descriptionSize / bodySize を数値(px)で指定すると上書きできる
  // size/width/height: ブロック全体の大きさ(auto/xauto/yauto/custom)
  // offsetTop/Right/Bottom/Left: position プリセットからの微調整
  function createText(def) {
    const wrap = document.createElement("div");
    wrap.className = "ui-text-block";
    if (def.id) wrap.id = def.id;
    applyPosition(wrap, def.position);
    applySize(wrap, def);
    applyOffset(wrap, def);

    if (def.title) {
      const h = document.createElement("h3");
      h.className = "ui-text-title";
      h.textContent = def.title;
      if (def.titleSize) h.style.fontSize = toCssSize(def.titleSize);
      wrap.appendChild(h);
    }
    if (def.description) {
      const p = document.createElement("p");
      p.className = "ui-text-description";
      p.textContent = def.description;
      if (def.descriptionSize) p.style.fontSize = toCssSize(def.descriptionSize);
      wrap.appendChild(p);
    }
    if (def.body) {
      const p = document.createElement("p");
      p.className = "ui-text-body";
      p.textContent = def.body;
      if (def.bodySize) p.style.fontSize = toCssSize(def.bodySize);
      wrap.appendChild(p);
    }
    return wrap;
  }

  // type: "table"
  // def: { columns: ["名前", "値"], rows: [["A", "1"], ["B", "2"]] }
  function createTable(def) {
    const wrap = document.createElement("div");
    wrap.className = "ui-table-wrap";
    if (def.id) wrap.id = def.id;

    const table = document.createElement("table");
    table.className = "ui-table";

    if (Array.isArray(def.columns) && def.columns.length > 0) {
      const thead = document.createElement("thead");
      const tr = document.createElement("tr");
      def.columns.forEach((col) => {
        const th = document.createElement("th");
        th.textContent = col;
        tr.appendChild(th);
      });
      thead.appendChild(tr);
      table.appendChild(thead);
    }

    const tbody = document.createElement("tbody");
    (def.rows || []).forEach((row) => {
      const tr = document.createElement("tr");
      row.forEach((cell) => {
        const td = document.createElement("td");
        td.textContent = cell;
        tr.appendChild(td);
      });
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);

    wrap.appendChild(table);
    return wrap;
  }

  // type: "list"
  // def: { ordered: true/false, items: ["項目1", "項目2"] }
  function createList(def) {
    const isOrdered = !!def.ordered;
    const wrap = document.createElement("div");
    wrap.className = `ui-list ${isOrdered ? "ui-list--ordered" : "ui-list--unordered"}`;
    if (def.id) wrap.id = def.id;

    (def.items || []).forEach((item) => {
      const li = document.createElement("div");
      li.className = "ui-list-item";
      li.textContent = item;
      wrap.appendChild(li);
    });

    return wrap;
  }

  // type: "codespace"
  function createCodespace(def) {
    const wrap = document.createElement("div");
    wrap.className = "ui-codespace";
    if (def.id) wrap.id = def.id;

    const copyBtn = document.createElement("button");
    copyBtn.className = "ui-codespace-copy";
    copyBtn.textContent = "Copy";
    copyBtn.addEventListener("click", () => {
      navigator.clipboard.writeText(def.code || "").then(() => {
        copyBtn.textContent = "Copied!";
        setTimeout(() => (copyBtn.textContent = "Copy"), 1500);
      });
    });

    const pre = document.createElement("pre");
    const code = document.createElement("code");
    if (def.language) code.className = `language-${def.language}`;
    code.textContent = def.code || "";
    pre.appendChild(code);

    wrap.appendChild(copyBtn);
    wrap.appendChild(pre);

    // highlight.js が読み込まれていればハイライトする（任意）
    if (window.hljs) {
      window.hljs.highlightElement(code);
    }

    return wrap;
  }

  // type: "imagesection"
  // children を指定すると、画像の上に重ねて表示する（見出し・ボタンなどを置けるヒーロー的な使い方）
  // 横幅は常に画面幅いっぱい(帯)。高さは size:"yauto"(画面の高さに合わせる) または
  // 数値・height で個別指定できる。
  function createImageSection(def, ctx) {
    const wrap = document.createElement("div");
    wrap.className = "ui-imagesection";
    if (def.id) wrap.id = def.id;

    if (def.size === "auto" || def.size === "yauto") {
      wrap.style.height = "100vh";
    } else if (def.height) {
      wrap.style.height = toCssSize(def.height);
    }
    applyOffset(wrap, def);

    const img = document.createElement("img");
    img.src = def.image || "";
    img.alt = def.title || "";
    wrap.appendChild(img);

    if (Array.isArray(def.children) && def.children.length > 0) {
      const overlay = document.createElement("div");
      overlay.className = "ui-imagesection-overlay";
      applyPosition(overlay, def.position);

      def.children.forEach((child) => {
        const childEl = createComponent(child, ctx);
        if (childEl) overlay.appendChild(childEl);
      });

      wrap.appendChild(overlay);
    }

    return wrap;
  }

  // type: "image"
  // section の中などに置く単体の画像。position で section 内の配置を指定できる
  // size: "auto"(セレクションの大きさに合わせる) / "xauto"(横幅のみ) / "yauto"(縦幅のみ) / "custom"(width/heightをそのまま使用)
  function createImage(def) {
    const wrap = document.createElement("div");
    wrap.className = "ui-image-wrap";
    if (def.id) wrap.id = def.id;
    applyPosition(wrap, def.position);
    applyOffset(wrap, def);

    const img = document.createElement("img");
    img.src = def.src || def.image || "";
    img.alt = def.alt || "";
    applySize(img, def);

    wrap.appendChild(img);
    return wrap;
  }

  // type: "insection" の1個分（横並びの中の1枠）
  // size: "auto"/"xauto"/"yauto"/"custom" で枠自体の大きさを制御できる
  function createInSection(def, ctx) {
    const el = document.createElement("div");
    el.className = "ui-insection";
    if (def.id) el.id = def.id;
    if (def.radius !== undefined) {
      el.style.borderRadius = typeof def.radius === "number" ? `${def.radius}px` : def.radius;
    }
    applyPosition(el, def.position);
    applySize(el, def);
    applyOffset(el, def);

    (def.children || []).forEach((child) => {
      const childEl = createComponent(child, ctx);
      if (childEl) el.appendChild(childEl);
    });

    return el;
  }

  // type: "section"
  // size: "yauto"/"auto" を指定すると画面の高さに揃う(ヒーローセクション的な使い方ができる)
  function createSection(def, ctx) {
    const wrap = document.createElement("section");
    wrap.className = "ui-section";
    if (def.id) wrap.id = def.id;

    if (def.size === "auto" || def.size === "yauto") {
      wrap.style.height = "100vh";
    } else if (def.height) {
      wrap.style.height = toCssSize(def.height);
    }
    applyOffset(wrap, def);

    if (def.title) {
      const h = document.createElement("h3");
      h.className = "ui-section-title";
      h.textContent = def.title;
      wrap.appendChild(h);
    }

    const body = document.createElement("div");
    body.className = "ui-section-body";
    applyPosition(body, def.position);

    const children = (def.children || []).map(resolveResponsive);

    // children が insection だけの場合は、横並びの行としてまとめる
    const insections = children.filter((c) => c.type === "insection");
    const others = children.filter((c) => c.type !== "insection");

    if (insections.length > 0) {
      const row = document.createElement("div");
      row.className = "ui-insection-row";
      insections.forEach((child) => {
        const childEl = createInSection(child, ctx);
        if (childEl) row.appendChild(childEl);
      });
      body.appendChild(row);
    }

    others.forEach((child) => {
      const childEl = createComponent(child, ctx);
      if (childEl) body.appendChild(childEl);
    });

    wrap.appendChild(body);
    return wrap;
  }

  // type に応じて生成関数を振り分ける
  // ここで resolveResponsive を一度だけ通すことで、mobile オーバーライドが
  // 全コンポーネントタイプに対して自動的に効くようにしている
  function createComponent(rawDef, ctx) {
    const def = resolveResponsive(rawDef);
    switch (def.type) {
      case "button":
        return createButton(def, ctx);
      case "section":
        return createSection(def, ctx);
      case "imagesection":
        return createImageSection(def, ctx);
      case "image":
        return createImage(def);
      case "insection":
        return createInSection(def, ctx);
      case "text":
        return createText(def);
      case "codespace":
        return createCodespace(def);
      case "table":
        return createTable(def);
      case "list":
        return createList(def);
      default:
        console.warn(`[Sora UI] unknown component type: "${def.type}"`);
        return null;
    }
  }

  /* ============================================================
   * 7b. Titlebar 生成（Page / Docs 共通）
   * ------------------------------------------------------------
   * titlebarDef: data.titlebar の内容
   * tabs: data.tabs（タブの配列。空配列ならタブUIは作らない）
   * ctx: switchTab を持つ共有コンテキスト
   * options.sidebarToggle: Docsモードのサイドバー開閉ハンバーガーを
   *   タイトルバーの左側に追加したい場合に、その場で呼ぶ関数を渡す
   * 戻り値: { el: タイトルバーのDOM要素 }
   * ============================================================ */
  function createTitlebar(titlebarDef, tabs, ctx, options) {
    options = options || {};
    const titlebar = document.createElement("div");
    titlebar.className = "ui-titlebar";

    // Docsモードのサイドバー開閉ボタン（指定があれば左端に出す）
    if (options.sidebarToggle) {
      const sidebarHamburger = document.createElement("button");
      sidebarHamburger.type = "button";
      sidebarHamburger.className = "ui-hamburger ui-hamburger--sidebar";
      sidebarHamburger.setAttribute("aria-label", "サイドバーを開く");
      sidebarHamburger.innerHTML = "<span></span><span></span><span></span>";
      sidebarHamburger.addEventListener("click", options.sidebarToggle);
      titlebar.appendChild(sidebarHamburger);
    }

    const icon = createIconElement(titlebarDef.icon, "ui-titlebar-icon-wrap");
    if (icon) {
      // titlebar用は img のサイズをそのまま使うので class を差し替える
      if (icon.firstChild && icon.firstChild.tagName === "IMG") {
        icon.firstChild.className = "ui-titlebar-icon";
        titlebar.appendChild(icon.firstChild);
      } else {
        titlebar.appendChild(icon);
      }
    }

    if (titlebarDef.title) {
      const title = document.createElement("span");
      title.className = "ui-titlebar-title";
      title.textContent = titlebarDef.title;
      titlebar.appendChild(title);
    }

    // タブは titlebar の中に表示する
    // （デスクトップ幅では横並び、モバイル幅ではハンバーガー+ドロップダウンに切り替わる）
    if (tabs.length > 0) {
      const tabWrap = document.createElement("div");
      tabWrap.className = "ui-titlebar-tabs";

      const dropdown = document.createElement("div");
      dropdown.className = "ui-titlebar-tabs-dropdown";

      tabs.forEach((tab, index) => {
        const makeTabItem = () => {
          const tabItem = document.createElement("div");
          tabItem.className = "ui-titlebar-tab-item" + (index === 0 ? " is-active" : "");
          tabItem.textContent = tab.title || tab.id;
          tabItem.dataset.tabId = tab.id;
          tabItem.addEventListener("click", () => {
            if (ctx.switchTab) ctx.switchTab(tab.id);
            dropdown.classList.remove("is-open");
          });
          return tabItem;
        };

        tabWrap.appendChild(makeTabItem());
        dropdown.appendChild(makeTabItem());
      });

      titlebar.appendChild(tabWrap);

      // ハンバーガーボタン（モバイル幅でのみ表示される。タブ切り替え用）
      const hamburger = document.createElement("button");
      hamburger.type = "button";
      hamburger.className = "ui-hamburger";
      hamburger.setAttribute("aria-label", "メニューを開く");
      hamburger.innerHTML = "<span></span><span></span><span></span>";
      hamburger.addEventListener("click", () => {
        dropdown.classList.toggle("is-open");
      });

      titlebar.appendChild(hamburger);
      titlebar.appendChild(dropdown);
    }

    return titlebar;
  }

  // titlebar の実測高さを CSS変数 --ui-titlebar-h に反映する。
  // Docs モードのサイドバー sticky / overlay の top 位置計算に使う。
  // ResizeObserver があれば、タブ⇔ハンバーガー切り替え等で titlebar の
  // 高さが変わった時にも自動で追従させる（無ければ初回計測のみ）。
  function syncTitlebarHeightVar(root, titlebarEl) {
    const update = () => {
      const h = titlebarEl ? titlebarEl.getBoundingClientRect().height : 0;
      root.style.setProperty("--ui-titlebar-h", `${h}px`);
    };
    update();

    if (titlebarEl && typeof ResizeObserver !== "undefined") {
      const observer = new ResizeObserver(update);
      observer.observe(titlebarEl);
    }
  }

  /* ============================================================
   * 8. page モードの描画
   *    titlebar の中にタブを表示し、タブごとに components を振り分ける
   * ============================================================ */
  function renderPage(root, data) {
    const titlebarDef = resolveResponsive(data.titlebar);
    const tabs = (data.tabs || []).map(resolveResponsive);
    const components = data.components || [];

    const panels = {};
    const ctx = { switchTab: null };

    // ---- Titlebar ----
    if (titlebarDef) {
      const titlebar = createTitlebar(titlebarDef, tabs, ctx);
      root.appendChild(titlebar);
      syncTitlebarHeightVar(root, titlebar);
    }

    const pageBody = document.createElement("div");
    pageBody.className = "ui-page-body";

    // タブが無い場合は components をそのまま流し込む
    if (tabs.length === 0) {
      components.forEach((c) => {
        const el = createComponent(c, ctx);
        if (el) pageBody.appendChild(el);
      });
      root.appendChild(pageBody);
      return;
    }

    tabs.forEach((tab, index) => {
      const panel = document.createElement("div");
      panel.className = "ui-tabpanel" + (index === 0 ? " is-active" : "");
      panel.dataset.tabId = tab.id;
      panels[tab.id] = panel;
      pageBody.appendChild(panel);
    });

    ctx.switchTab = function (tabId) {
      document.querySelectorAll(".ui-titlebar-tab-item").forEach((el) => {
        el.classList.toggle("is-active", el.dataset.tabId === tabId);
      });
      Object.entries(panels).forEach(([id, panel]) => {
        panel.classList.toggle("is-active", id === tabId);
      });
    };

    components.forEach((c) => {
      const el = createComponent(c, ctx);
      if (!el) return;
      const targetPanel = c.tab && panels[c.tab] ? panels[c.tab] : panels[tabs[0].id];
      targetPanel.appendChild(el);
    });

    root.appendChild(pageBody);
  }

  /* ============================================================
   * 9. Docs モードの描画（GitBook / Notion風）
   *    sidebar定義から「カテゴリ -> ページ」の1階層サイドバーを作り、
   *    componentsをpage idごとに振り分けて右側に表示する。
   *    titlebar / tabs は Page モードと同じ共通関数で生成し、常に
   *    画面上部に固定表示する。tabs を指定した場合は、タブごとに
   *    sidebar + components の組がまるごと切り替わる
   *    （tab.sidebar / 各componentのtabプロパティで振り分け）。
   * ============================================================ */
  function renderDocs(root, data) {
    const titlebarDef = resolveResponsive(data.titlebar);
    const tabs = (data.tabs || []).map(resolveResponsive);
    const sidebarDef = (data.sidebar || []).map(resolveResponsive);
    const components = data.components || [];

    root.classList.add("ui-docs-wrap");

    const ctx = { switchTab: null };

    // ---- サイドバー開閉（モバイル幅でタイトルバーのハンバーガーから操作） ----
    const overlay = document.createElement("div");
    overlay.className = "ui-docs-overlay";

    function closeSidebar() {
      sidebarEls.forEach((s) => s.classList.remove("is-open"));
      overlay.classList.remove("is-open");
    }

    function openSidebar() {
      sidebarEls.forEach((s) => s.classList.add("is-open"));
      overlay.classList.add("is-open");
    }

    overlay.addEventListener("click", closeSidebar);

    // ---- Titlebar（Pageモードと共通。常に最上部にsticky表示） ----
    const sidebarEls = [];
    if (titlebarDef) {
      const titlebar = createTitlebar(titlebarDef, tabs, ctx, {
        sidebarToggle: openSidebar,
      });
      root.appendChild(titlebar);
      syncTitlebarHeightVar(root, titlebar);
    } else {
      root.style.setProperty("--ui-titlebar-h", "0px");
    }

    // ---- タブが無い場合は、sidebarDef 1セットだけのシンプルな Docs ----
    if (tabs.length === 0) {
      const built = buildDocsBody(sidebarDef, components, ctx, closeSidebar, null);
      sidebarEls.push(built.sidebarEl);
      root.appendChild(overlay);
      root.appendChild(built.docsRow);
      return;
    }

    // ---- タブがある場合: タブごとに「カテゴリ一覧 + ページ」一式を切り替える ----
    // tab.sidebar が指定されていればそのタブ専用のサイドバーを使い、
    // 無ければルートの sidebarDef を共通で使う。
    // component の振り分けは component.tab で行う（無指定の場合は最初のタブに入る）。
    const tabBodies = {};
    const wrapper = document.createElement("div");
    wrapper.className = "ui-docs-tabwrapper";

    tabs.forEach((tab, index) => {
      const tabSidebarDef = (tab.sidebar || sidebarDef).map(resolveResponsive);
      const tabComponents = components.filter((c) => (c.tab || tabs[0].id) === tab.id);
      const built = buildDocsBody(tabSidebarDef, tabComponents, ctx, closeSidebar, tab.id);
      built.docsRow.classList.toggle("is-active", index === 0);
      built.docsRow.classList.add("ui-docs-tabpanel");
      sidebarEls.push(built.sidebarEl);
      tabBodies[tab.id] = built.docsRow;
      wrapper.appendChild(built.docsRow);
    });

    ctx.switchTab = function (tabId) {
      document.querySelectorAll(".ui-titlebar-tab-item").forEach((el) => {
        el.classList.toggle("is-active", el.dataset.tabId === tabId);
      });
      Object.entries(tabBodies).forEach(([id, el]) => {
        el.classList.toggle("is-active", id === tabId);
      });
    };

    root.appendChild(overlay);
    root.appendChild(wrapper);
  }

  // sidebar + content の組を1セット作る。タブ無し/タブ1つ分のどちらでも使う。
  // 戻り値: { docsRow, sidebarEl }
  function buildDocsBody(sidebarDef, components, ctx, closeSidebar, tabId) {
    const docsRow = document.createElement("div");
    docsRow.className = "ui-docs";
    if (tabId) docsRow.dataset.tabId = tabId;

    const sidebar = document.createElement("nav");
    sidebar.className = "ui-docs-sidebar";

    const searchBox = document.createElement("input");
    searchBox.type = "text";
    searchBox.className = "ui-docs-search";
    searchBox.placeholder = "ページを検索...";
    sidebar.appendChild(searchBox);

    const content = document.createElement("div");
    content.className = "ui-docs-content";

    const contentInner = document.createElement("div");
    contentInner.className = "ui-docs-content-inner";
    content.appendChild(contentInner);

    const panels = {};
    const pageOrder = [];
    let firstPageId = null;

    sidebarDef.forEach((category) => {
      const catEl = document.createElement("div");
      catEl.className = "ui-docs-category";

      const catIcon = createIconElement(category.icon);
      if (catIcon) catEl.appendChild(catIcon);

      const catLabel = document.createElement("span");
      catLabel.textContent = category.title || category.id;
      catEl.appendChild(catLabel);

      sidebar.appendChild(catEl);

      (category.pages || []).forEach((page) => {
        if (!firstPageId) firstPageId = page.id;
        pageOrder.push({ id: page.id, title: page.title || page.id });

        const pageEl = document.createElement("div");
        pageEl.className = "ui-docs-page";
        pageEl.dataset.pageId = page.id;
        pageEl.dataset.searchText = (page.title || page.id).toLowerCase();

        const pageIcon = createIconElement(page.icon);
        if (pageIcon) pageEl.appendChild(pageIcon);

        const pageLabel = document.createElement("span");
        pageLabel.textContent = page.title || page.id;
        pageEl.appendChild(pageLabel);

        pageEl.addEventListener("click", () => activatePage(page.id));
        sidebar.appendChild(pageEl);

        const panel = document.createElement("div");
        panel.className = "ui-docs-panel";
        panel.dataset.pageId = page.id;

        if (page.title) {
          const h = document.createElement("h1");
          h.className = "ui-docs-panel-title";
          h.textContent = page.title;
          panel.appendChild(h);
        }

        panels[page.id] = panel;
        contentInner.appendChild(panel);
      });
    });

    function activatePage(pageId) {
      sidebar.querySelectorAll(".ui-docs-page").forEach((el) => el.classList.remove("is-active"));
      Object.values(panels).forEach((panel) => panel.classList.remove("is-active"));

      const targetLink = sidebar.querySelector(`.ui-docs-page[data-page-id="${pageId}"]`);
      if (targetLink) targetLink.classList.add("is-active");
      if (panels[pageId]) panels[pageId].classList.add("is-active");

      content.scrollTop = 0;
      closeSidebar(); // モバイルでページを選んだら、開いていたサイドバーを閉じる
    }

    searchBox.addEventListener("input", () => {
      const query = searchBox.value.trim().toLowerCase();
      sidebar.querySelectorAll(".ui-docs-category").forEach((catEl) => {
        let visibleCount = 0;
        let sibling = catEl.nextElementSibling;
        while (sibling && sibling.classList.contains("ui-docs-page")) {
          const matches = !query || sibling.dataset.searchText.includes(query);
          sibling.classList.toggle("is-hidden", !matches);
          if (matches) visibleCount++;
          sibling = sibling.nextElementSibling;
        }
        catEl.classList.toggle("is-hidden", visibleCount === 0);
      });
    });

    pageOrder.forEach((page, index) => {
      const prev = pageOrder[index - 1];
      const next = pageOrder[index + 1];
      if (!prev && !next) return;

      const nav = document.createElement("div");
      nav.className = "ui-docs-pagenav";

      if (prev) {
        nav.appendChild(createPageNavLink(prev, "前へ", "prev", activatePage));
      } else {
        nav.appendChild(document.createElement("span"));
      }
      if (next) {
        nav.appendChild(createPageNavLink(next, "次へ", "next", activatePage));
      }

      panels[page.id].appendChild(nav);
    });

    if (firstPageId) activatePage(firstPageId);

    components.forEach((c) => {
      const el = createComponent(c, ctx);
      if (!el) return;

      const targetPanel = c.page && panels[c.page] ? panels[c.page] : panels[firstPageId];
      if (!targetPanel) return;

      const nav = targetPanel.querySelector(".ui-docs-pagenav");
      if (nav) {
        targetPanel.insertBefore(el, nav);
      } else {
        targetPanel.appendChild(el);
      }
    });

    docsRow.appendChild(sidebar);
    docsRow.appendChild(content);

    return { docsRow, sidebarEl: sidebar };
  }

  function createPageNavLink(page, label, direction, onClick) {
    const link = document.createElement("div");
    link.className = `ui-docs-pagenav-link ui-docs-pagenav-link--${direction}`;

    const labelEl = document.createElement("span");
    labelEl.className = "ui-docs-pagenav-label";
    labelEl.textContent = label;

    const titleEl = document.createElement("span");
    titleEl.className = "ui-docs-pagenav-title";
    titleEl.textContent = page.title;

    link.appendChild(labelEl);
    link.appendChild(titleEl);
    link.addEventListener("click", () => onClick(page.id));
    return link;
  }

  /* ============================================================
   * 10. サンプル JSON の例
   *    以下は .soraui ファイルの記述例。data-soraui-src で指定したファイルに
   *    このような JSON を書いて SoraUI.render("#app", data) で動作する。
   *
   * ---- Page モード（タブ付き）の例 ----
   * {
   *   "theme": "whiteorange",
   *   "mode": "Page",
   *   "titlebar": { "title": "My App", "icon": "🚀" },
   *   "tabs": [
   *     { "id": "home", "title": "ホーム" },
   *     { "id": "settings", "title": "設定" }
   *   ],
   *   "components": [
   *     {
   *       "type": "section",
   *       "tab": "home",
   *       "title": "ウェルカム",
   *       "size": "yauto",
   *       "children": [
   *         {
   *           "type": "text",
   *           "position": "center-middle",
   *           "offsetTop": 20,
   *           "title": "PC/スマホ対応",
   *           "body": "このテキストは両デバイスで表示されます",
   *           "mobile": { "title": "スマホでは短い" }
   *         }
   *       ]
   *     },
   *     {
   *       "type": "text",
   *       "tab": "settings",
   *       "title": "設定画面",
   *       "body": "スマホでは非表示にしたい項目..."
   *     }
   *   ]
   * }
   *
   * ---- Docs モード（サイドバー + タブ）の例 ----
   * {
   *   "theme": "darkblue",
   *   "mode": "Docs",
   *   "titlebar": { "title": "ドキュメント", "icon": "📘" },
   *   "tabs": [
   *     { "id": "guide", "title": "ガイド" },
   *     { "id": "api", "title": "API リファレンス" }
   *   ],
   *   "sidebar": [
   *     {
   *       "id": "intro",
   *       "title": "はじめに",
   *       "icon": "🚀",
   *       "pages": [
   *         { "id": "overview", "title": "概要" },
   *         { "id": "install", "title": "インストール" }
   *       ]
   *     },
   *     {
   *       "id": "advanced",
   *       "title": "詳細",
   *       "icon": "⚙️",
   *       "pages": [
   *         { "id": "config", "title": "設定" }
   *       ]
   *     }
   *   ],
   *   "components": [
   *     { "type": "text", "tab": "guide", "page": "overview", "title": "ガイド: 概要", "body": "..." },
   *     { "type": "text", "tab": "api", "page": "api-page", "title": "API リファレンス", "body": "..." }
   *   ]
   * }
   *
   * ---- 新機能: size / offset / mobile の使い方 ----
   * {
   *   "components": [
   *     {
   *       "type": "image",
   *       "src": "pic.png",
   *       "size": "xauto",
   *       "height": 300,
   *       "mobile": { "size": "auto", "height": 150 }
   *     },
   *     {
   *       "type": "text",
   *       "position": "top-right",
   *       "offsetTop": 16,
   *       "offsetRight": 12,
   *       "title": "コーナー配置 + 微調整",
   *       "mobile": { "position": "top-center", "offsetTop": 0, "offsetRight": 0 }
   *     }
   *   ]
   * }
   *
   * ============================================================ */

  /* ============================================================
   * 11. エラー表示（読み込み・JSON解析に失敗した場合）
   * ============================================================ */
  function renderError(root, message) {
    const pre = document.createElement("div");
    pre.className = "ui-error";
    pre.textContent = `[Sora UI] ${message}`;
    root.appendChild(pre);
  }

  /* ============================================================
   * 12. 描画の共通処理
   * ============================================================ */
  function renderData(root, data) {
    root.innerHTML = "";
    root.className = "";

    const fontFamily = loadFont(data.font);
    injectStyles(data.theme, fontFamily);
    root.classList.add("ui-root");

    if (data.mode === "Docs") {
      renderDocs(root, data);
    } else {
      renderPage(root, data);
    }
  }

  /* ============================================================
   * 13. 起動処理（ファイル読み込みルート）
   * ============================================================ */
  async function mountElement(root) {
    const src = root.dataset.sorauiSrc;
    if (!src) return;

    try {
      const res = await fetch(src);
      if (!res.ok) {
        throw new Error(`"${src}" の読み込みに失敗しました (status: ${res.status})`);
      }
      const data = await res.json();
      renderData(root, data);
    } catch (err) {
      injectStyles(DEFAULT_THEME, "sans-serif");
      root.classList.add("ui-root");
      renderError(root, err.message);
      console.error("[Sora UI]", err);
    }
  }

  /* ============================================================
   * 13. 外部APIルート（JSオブジェクトを直接渡して描画したい場合）
   *    例: SoraUI.render("#app", data);
   * ============================================================ */
  function render(target, data) {
    const root = typeof target === "string" ? document.querySelector(target) : target;
    if (!root) {
      console.error(`[Sora UI] render() の対象要素が見つかりません: "${target}"`);
      return;
    }

    try {
      renderData(root, data);
    } catch (err) {
      injectStyles(DEFAULT_THEME, "sans-serif");
      root.classList.add("ui-root");
      renderError(root, err.message);
      console.error("[Sora UI]", err);
    }
  }

  function init() {
    document.querySelectorAll("[data-soraui-src]").forEach(mountElement);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }

  window.SoraUI = { reload: init, render: render };
})();