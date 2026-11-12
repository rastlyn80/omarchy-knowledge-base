.pragma library

// Omarchy Knowledge Base — content index, search, and the command allowlist.
//
// Structure only lives here: every piece of human text is a catalog key read
// through Commons.Translations, so the tutorial follows Setup > Language the
// way the built-in plugins do. `i18n/en.json` carries the English copy.
//
// Nothing in this file executes anything. Panel.qml asks `allowedCommand()`
// before it runs a single thing, and that gate is the only way out.

// ---------------------------------------------------------------- chapters
//
// Each lesson is { id, keys, cmds, actions, tags }:
//   keys    — keybinding chips, shown verbatim (never translated)
//   cmds    — commands shown as read-only lines, for anything too big or too
//             destructive to put behind a one-tap button (`omarchy update`)
//   actions — { labelKey, argv } one-tap runnables; argv must pass the gate
//   tags    — extra search terms in English, on top of the translated text

var CHAPTERS = [
  {
    id: "start",
    icon: "",
    lessons: [
      {
        id: "start.menu",
        keys: ["SUPER + SPACE"],
        actions: [{ labelKey: "action.openMenu", argv: ["omarchy", "menu"] }],
        tags: ["menu", "launcher", "command palette", "space", "start here", "everything"]
      },
      {
        id: "start.apps",
        keys: ["SUPER + ALT + SPACE", "SUPER + RETURN", "SUPER + SHIFT + RETURN", "SUPER + SHIFT + N"],
        actions: [
          { labelKey: "action.openTerminal", argv: ["omarchy", "launch", "terminal"] },
          { labelKey: "action.openBrowser", argv: ["omarchy", "launch", "browser"] }
        ],
        tags: ["apps", "launch", "open", "terminal", "browser", "editor", "run program", "app launcher"]
      },
      {
        id: "start.keys",
        keys: ["SUPER + K", "SUPER + ESCAPE"],
        tags: ["keybindings", "shortcuts", "hotkeys", "cheat sheet", "what key", "bindings list"]
      },
      {
        id: "start.bar",
        keys: ["SUPER + CTRL + A", "SUPER + CTRL + N", "SUPER + CTRL + B", "SUPER + CTRL + P", "SUPER + CTRL + D"],
        tags: ["bar", "status bar", "panel", "widget", "tray", "audio", "network", "bluetooth", "wifi", "volume"]
      },
      {
        id: "start.cli",
        cmds: ["omarchy commands", "omarchy theme --help"],
        actions: [{ labelKey: "action.listCommands", argv: ["omarchy", "launch", "terminal", "omarchy", "commands"] }],
        tags: ["cli", "command line", "omarchy command", "terminal", "help", "discover"]
      },
      {
        id: "start.notifications",
        keys: ["SUPER + comma", "SUPER + SHIFT + comma", "SUPER + SHIFT + ALT + comma"],
        tags: ["notifications", "toast", "dismiss", "history", "alerts"]
      }
    ]
  },
  {
    id: "windows",
    icon: "",
    lessons: [
      {
        id: "windows.focus",
        keys: ["SUPER + ← → ↑ ↓", "ALT + TAB", "ALT + SHIFT + TAB"],
        tags: ["focus", "switch window", "move between windows", "arrows", "alt tab"]
      },
      {
        id: "windows.move",
        keys: ["SUPER + SHIFT + ← → ↑ ↓", "SUPER + J", "SUPER + W"],
        tags: ["move window", "swap", "rearrange", "split", "close window", "quit window"]
      },
      {
        id: "windows.size",
        keys: ["SUPER + - / =", "SUPER + ALT + - / =", "SUPER + F", "SUPER + T", "SUPER + ALT + F"],
        tags: ["resize", "resize window", "window size", "bigger", "smaller", "maximize", "fullscreen", "float", "floating", "tiling", "width"]
      },
      {
        id: "windows.workspaces",
        keys: ["SUPER + 1 … 9", "SUPER + TAB", "SUPER + CTRL + TAB", "SUPER + SHIFT + 1 … 9"],
        tags: ["workspace", "desktop", "virtual desktop", "switch workspace", "move to workspace"]
      },
      {
        id: "windows.layouts",
        keys: ["SUPER + L", "SUPER + ALT + L"],
        tags: ["layout", "master", "dwindle", "floating workspace", "tiling layout", "arrangement"]
      },
      {
        id: "windows.scratchpad",
        keys: ["SUPER + S", "SUPER + ALT + S", "SUPER + grave", "SUPER + M"],
        tags: ["scratchpad", "quake console", "dropdown terminal", "minimize", "hide window", "dock"]
      },
      {
        id: "windows.groups",
        keys: ["SUPER + G", "SUPER + ALT + TAB", "SUPER + ALT + ← →"],
        tags: ["group", "tabbed", "tabs", "stack windows", "grouping"]
      },
      {
        id: "windows.monitors",
        keys: ["SUPER + SHIFT + CTRL + ← →", "SUPER + SHIFT + ALT + ← →", "CTRL + ALT + TAB"],
        tags: ["monitor", "display", "second screen", "move to monitor", "multi monitor", "external"]
      }
    ]
  },
  {
    id: "look",
    icon: "",
    lessons: [
      {
        id: "look.themes",
        keys: ["SUPER + CTRL + T", "SUPER + SHIFT + CTRL + SPACE"],
        cmds: ["omarchy theme set catppuccin", "omarchy theme list"],
        actions: [
          { labelKey: "action.nextTheme", argv: ["omarchy", "theme", "next"] },
          { labelKey: "action.themeMenu", argv: ["omarchy", "menu", "theme"] }
        ],
        tags: ["theme", "change theme", "switch theme", "colors", "colour", "change colors", "dark mode", "light mode", "palette", "appearance", "skin"]
      },
      {
        id: "look.background",
        keys: ["SUPER + CTRL + SPACE", "SUPER + CTRL + W"],
        tags: ["background", "change background", "wallpaper", "change wallpaper", "set wallpaper", "desktop image", "picture"]
      },
      {
        id: "look.font",
        cmds: ["omarchy font list", "omarchy font set \"JetBrainsMono Nerd Font\""],
        actions: [{ labelKey: "action.listFonts", argv: ["omarchy", "launch", "terminal", "omarchy", "font", "list"] }],
        tags: ["font", "change font", "switch font", "set font", "typeface", "monospace", "nerd font", "typography"]
      },
      {
        id: "look.textsize",
        cmds: ["omarchy display text size 1.25", "omarchy display text size reset"],
        tags: ["text size", "change text size", "scaling", "dpi", "bigger text", "font size", "readability", "zoom"]
      },
      {
        id: "look.gaps",
        keys: ["SUPER + BACKSPACE", "SUPER + SHIFT + BACKSPACE", "SUPER + CTRL + BACKSPACE"],
        tags: ["gaps", "borders", "rounding", "transparency", "opacity", "looknfeel", "spacing", "padding"]
      },
      {
        id: "look.bar",
        cmds: ["omarchy bar move omarchy.clock --section right", "omarchy bar position bottom"],
        actions: [
          { labelKey: "action.cycleBarBackground", argv: ["omarchy", "bar", "background", "cycle"] },
          { labelKey: "action.barBottom", argv: ["omarchy", "bar", "position", "bottom"] },
          { labelKey: "action.barTop", argv: ["omarchy", "bar", "position", "top"] }
        ],
        tags: ["bar layout", "move widget", "move the bar", "bar position", "bar background", "glassy", "rearrange bar"]
      },
      {
        id: "look.nightlight",
        keys: ["SUPER + CTRL + ALT + W"],
        actions: [{ labelKey: "action.toggleNightlight", argv: ["omarchy", "toggle", "nightlight"] }],
        tags: ["night light", "nightlight", "warm", "blue light", "hyprsunset", "eye strain", "evening"]
      }
    ]
  },
  {
    id: "capture",
    icon: "",
    lessons: [
      {
        id: "capture.screenshot",
        keys: ["PRINT", "SUPER + CTRL + ALT + C"],
        actions: [
          { labelKey: "action.shotRegion", argv: ["omarchy", "capture", "screenshot", "region"] },
          { labelKey: "action.shotWindow", argv: ["omarchy", "capture", "screenshot", "windows"] }
        ],
        tags: ["screenshot", "screen shot", "capture", "print screen", "snip", "region", "grab screen"]
      },
      {
        id: "capture.record",
        keys: ["ALT + PRINT"],
        cmds: ["omarchy capture screenrecording --fullscreen", "omarchy capture screenrecording --stop-recording"],
        actions: [{ labelKey: "action.stopRecording", argv: ["omarchy", "capture", "screenrecording", "--stop-recording"] }],
        tags: ["screen recording", "record", "video", "screencast", "gif", "webcam"]
      },
      {
        id: "capture.ocr",
        keys: ["SUPER + CTRL + PRINT"],
        actions: [{ labelKey: "action.ocr", argv: ["omarchy", "capture", "text"] }],
        tags: ["ocr", "extract text", "copy text from image", "read screen", "text capture"]
      },
      {
        id: "capture.color",
        keys: ["SUPER + PRINT"],
        tags: ["color picker", "colour picker", "eyedropper", "hex code", "pick color"]
      },
      {
        id: "capture.share",
        keys: ["SUPER + CTRL + S", "SUPER + CTRL + PERIOD"],
        tags: ["share", "upload", "send file", "transcode", "convert video"]
      },
      {
        id: "capture.clipboard",
        keys: ["SUPER + CTRL + V", "SUPER + CTRL + E"],
        tags: ["clipboard", "clipboard history", "history", "paste", "copy", "emoji", "emojis", "emoji picker"]
      }
    ]
  },
  {
    id: "config",
    icon: "",
    lessons: [
      {
        id: "config.where",
        cmds: ["~/.config/hypr/", "~/.config/omarchy/shell.json", "/usr/share/omarchy/  ← never edit"],
        tags: ["config", "config files", "configuration", "where", "files", "dotfiles", "edit config", "settings", "my settings"]
      },
      {
        id: "config.bindings",
        cmds: ["~/.config/hypr/bindings.lua", "hyprctl reload", "hyprctl configerrors"],
        actions: [{ labelKey: "action.editBindings", argv: ["omarchy", "launch", "editor", "~/.config/hypr/bindings.lua"] }],
        tags: ["keybinding", "add shortcut", "rebind", "bind", "custom key", "o.bind", "hotkey"]
      },
      {
        id: "config.monitors",
        cmds: ["~/.config/hypr/monitors.lua", "hyprctl monitors"],
        actions: [{ labelKey: "action.editMonitors", argv: ["omarchy", "launch", "editor", "~/.config/hypr/monitors.lua"] }],
        tags: ["monitor", "resolution", "change resolution", "set resolution", "refresh rate", "scale", "external display", "hdmi", "arrangement"]
      },
      {
        id: "config.shell",
        cmds: ["~/.config/omarchy/shell.json"],
        actions: [{ labelKey: "action.editShell", argv: ["omarchy", "launch", "editor", "~/.config/omarchy/shell.json"] }],
        tags: ["shell.json", "bar layout", "sections", "widgets", "hot reload", "omarchy shell"]
      },
      {
        id: "config.idle",
        keys: ["SUPER + CTRL + L"],
        cmds: ["\"idle\": { \"screensaver\": 150, \"lock\": 300 }"],
        actions: [{ labelKey: "action.lock", argv: ["omarchy", "system", "lock"] }],
        tags: ["idle", "lock", "screensaver", "sleep", "timeout", "screen off", "lock screen"]
      },
      {
        id: "config.plugins",
        cmds: ["omarchy plugin list", "omarchy plugin clone omarchy.workspaces"],
        actions: [{ labelKey: "action.listPlugins", argv: ["omarchy", "launch", "terminal", "omarchy", "plugin", "list"] }],
        tags: ["plugin", "widget", "clone", "customize widget", "quickshell", "qml"]
      },
      {
        id: "config.hooks",
        cmds: ["omarchy hook install theme-set ~/bin/my-script"],
        tags: ["hook", "automation", "on theme change", "script", "event", "trigger"]
      }
    ]
  },
  {
    id: "care",
    icon: "",
    lessons: [
      {
        id: "care.update",
        cmds: ["omarchy update"],
        tags: ["update", "update omarchy", "upgrade", "new version", "pacman", "latest"]
      },
      {
        id: "care.packages",
        cmds: ["omarchy pkg add ripgrep", "omarchy pkg aur add some-aur-package", "omarchy install docker"],
        tags: ["install", "package", "software", "pacman", "aur", "add program", "uninstall"]
      },
      {
        id: "care.debug",
        cmds: ["omarchy debug --no-sudo --print"],
        actions: [{ labelKey: "action.debug", argv: ["omarchy", "launch", "terminal", "omarchy", "debug", "--no-sudo", "--print"] }],
        tags: ["debug", "broken", "diagnostics", "logs", "troubleshoot", "not working", "bug report"]
      },
      {
        id: "care.reset",
        cmds: ["omarchy refresh shell", "omarchy refresh hyprland", "omarchy refresh config hypr/bindings.lua"],
        tags: ["reset", "defaults", "refresh", "restore", "undo changes", "broke my config", "start over"]
      },
      {
        id: "care.reminders",
        keys: ["SUPER + CTRL + R", "SUPER + CTRL + ALT + R"],
        cmds: ["omarchy reminder 15 \"Pickup Jack\""],
        actions: [{ labelKey: "action.showReminders", argv: ["omarchy", "reminder", "show"] }],
        tags: ["reminder", "set reminder", "timer", "set a timer", "minutes", "alarm", "remind me", "notification later"]
      },
      {
        id: "care.restart",
        cmds: ["omarchy restart shell", "omarchy restart terminal"],
        actions: [{ labelKey: "action.restartShell", argv: ["omarchy", "restart", "shell"] }],
        tags: ["restart", "reload", "bar frozen", "shell stuck", "apply changes"]
      }
    ]
  }
]

// Flat lesson list, in chapter order, with the chapter stamped on each lesson.
function allLessons() {
  var out = []
  for (var c = 0; c < CHAPTERS.length; c++) {
    var chapter = CHAPTERS[c]
    for (var l = 0; l < chapter.lessons.length; l++) {
      var lesson = chapter.lessons[l]
      out.push({
        id: lesson.id,
        chapterId: chapter.id,
        chapterIcon: chapter.icon,
        index: out.length,
        keys: lesson.keys || [],
        cmds: lesson.cmds || [],
        actions: lesson.actions || [],
        tags: lesson.tags || []
      })
    }
  }
  return out
}

function lessonCount() {
  var n = 0
  for (var c = 0; c < CHAPTERS.length; c++) n += CHAPTERS[c].lessons.length
  return n
}

// ------------------------------------------------------------------ search
//
// Scores every lesson against the query and returns the best few. `translate`
// is Translations.t, so matching happens in whatever language is on screen;
// the English `tags` ride along so "wifi" still finds the bar lesson in Danish.

function normalize(text) {
  return String(text === undefined || text === null ? "" : text)
    .toLowerCase()
    .replace(/[^\p{L}\p{N}+#.\-\s]/gu, " ")
    .replace(/\s+/g, " ")
    .replace(/^ | $/g, "")
}

// Words that carry no signal in a question about a desktop. Anything that
// could name a feature stays in, even when it is also a common verb ("set",
// "move", "lock"), because those are exactly the words the index is full of.
var STOPWORDS = {
  "a": 1, "about": 1, "after": 1, "all": 1, "an": 1, "and": 1, "any": 1, "are": 1, "as": 1,
  "at": 1, "be": 1, "but": 1, "by": 1, "can": 1, "could": 1, "did": 1, "do": 1, "does": 1,
  "for": 1, "from": 1, "get": 1, "has": 1, "have": 1, "how": 1, "i": 1, "if": 1, "in": 1,
  "into": 1, "is": 1, "it": 1, "its": 1, "just": 1, "me": 1, "my": 1, "need": 1, "not": 1,
  "of": 1, "on": 1, "one": 1, "or": 1, "out": 1, "please": 1, "should": 1, "so": 1, "some": 1,
  "than": 1, "that": 1, "the": 1, "their": 1, "then": 1, "there": 1, "this": 1, "to": 1,
  "up": 1, "use": 1, "very": 1, "want": 1, "was": 1, "way": 1, "we": 1, "what": 1, "when": 1,
  "where": 1, "which": 1, "who": 1, "why": 1, "will": 1, "with": 1, "would": 1, "you": 1,
  "your": 1,
  // In a knowledge base about Omarchy, "omarchy" is in every lesson. Keeping
  // it would let "update omarchy" score every lesson that mentions the name.
  "omarchy": 1
}

function tokenize(query) {
  var words = normalize(query).split(" ")
  var out = []
  for (var i = 0; i < words.length; i++) {
    var w = words[i]
    // Numbers never appear in the index — "lock after 10 minutes" is about
    // locking, and counting the 10 against the lesson only penalizes it.
    if (w.length < 2 || STOPWORDS[w] || /^[\d.]+$/.test(w)) continue
    if (out.indexOf(w) < 0) out.push(w)
  }
  return out
}

// How strongly one token hits one field.
//
// A whole word is worth the field's full weight. A longer token may also
// match the start of a word, for the suffixes English adds on its own
// ("resize" in "resizing", "theme" in "themes"), and a longer one still may
// match inside a word. Short tokens get neither: "set" would otherwise score
// on "settings" and "ocr" on "record", which is how a question about setting
// something up ends up confidently answered with the wrong lesson.
function hit(haystack, token, weight) {
  if (!haystack || haystack.indexOf(token) < 0) return 0
  var escaped = token.replace(/[.+\-]/g, "\\$&")
  if (new RegExp("(^| )" + escaped + "( |$)").test(haystack)) return weight
  if (token.length < 4) return 0
  if (new RegExp("(^| )" + escaped).test(haystack)) return weight * 0.75
  return token.length >= 5 ? weight * 0.4 : 0
}

// Returns [{ lesson, score }], best first, score roughly 0..1.
//
// Two numbers decide a lesson: how strongly the words that matched it
// matched, and how much of the question it accounted for. Strength alone
// would make "how do I set up a kubernetes cluster" confident about the
// update lesson, on the strength of "set"; coverage alone would throw away
// "lock after 10 minutes", where only one word of three is ever going to be
// in a desktop's index. Each token is scored against its best field rather
// than summed across all of them, so a word in both the title and the tags
// counts once, at its strongest.
function search(query, lessons, translate) {
  var tokens = tokenize(query)
  if (tokens.length === 0) return []
  var phrase = tokens.join(" ")
  var scored = []

  for (var i = 0; i < lessons.length; i++) {
    var lesson = lessons[i]
    var fields = [
      [normalize(translate("ls." + lesson.id + ".title")), 6],
      [normalize(lesson.tags.join(" ")), 4.5],
      [normalize(lesson.keys.join(" ")), 3],
      [normalize(lesson.cmds.concat(lesson.actions.map(function(a) {
        return a.argv.join(" ")
      })).join(" ")), 3],
      [normalize(translate("ch." + lesson.chapterId + ".title")), 2],
      [normalize(translate("ls." + lesson.id + ".body")), 1.5]
    ]

    var total = 0
    var matched = 0
    for (var tk = 0; tk < tokens.length; tk++) {
      var best = 0
      for (var f = 0; f < fields.length; f++)
        best = Math.max(best, hit(fields[f][0], tokens[tk], fields[f][1]))
      if (best > 0) matched++
      total += best
    }
    if (matched === 0) continue

    var strength = total / (matched * 6)
    var coverage = matched / tokens.length
    var score = strength * (0.25 + 0.75 * coverage)

    // The question's own words, in order, appearing in a title or a tag is as
    // close to certain as this index gets. Matched against the tokens rather
    // than the raw query, so the padding in "how do I change the theme" does
    // not stop "change theme" from being recognised.
    if (phrase.length >= 4
        && (fields[0][0].indexOf(phrase) >= 0 || fields[1][0].indexOf(phrase) >= 0))
      score += 0.25

    scored.push({ lesson: lesson, score: Math.min(1, score) })
  }

  scored.sort(function(a, b) { return b.score - a.score || a.lesson.index - b.lesson.index })
  return scored.slice(0, 6)
}

// Above this the local index answers on its own; below it the question is
// worth handing to Claude.
var CONFIDENT = 0.55

// ------------------------------------------------- the command gate
//
// Every argv that reaches a one-tap button goes through here, whether it came
// from a lesson in this file or out of a model's answer. Two independent
// checks: the route must be listed, and the words must look like words.
//
// Listed routes are reversible and never ask for a password. Deliberately
// absent: refresh / reinstall (they overwrite config), update / pkg / install /
// setup / uninstall (long, privileged, interactive), dev (source workflows),
// drive / hibernation / channel / migrate (system surgery), and every `system`
// action but `lock`.

var SAFE_ROUTES = {
  "about": { "": 1 },
  "bar": { "position": 1, "background": 1, "move": 1, "put": 1, "set": 1, "get": 1, "use": 1 },
  "capture": { "screenshot": 1, "screenrecording": 1, "text": 1, "qr": 1, "webcam": 1 },
  "commands": { "": 1, "--json": 1 },
  "debug": { "--no-sudo": 1 },
  "display": { "text": 1 },
  "dock": { "position": 1, "autohide": 1, "pin": 1, "unpin": 1, "pinned": 1 },
  "font": { "list": 1, "current": 1, "set": 1, "cjk": 1 },
  "hook": { "list": 1 },
  "launch": { "*": 1 },
  "menu": { "": 1, "*": 1 },
  "plugin": { "list": 1, "validate": 1 },
  "reminder": { "*": 1 },
  "restart": { "*": 1 },
  "system": { "lock": 1 },
  "theme": { "set": 1, "next": 1, "previous": 1, "list": 1, "current": 1, "menu": 1 },
  "toggle": { "*": 1 },
  "version": { "": 1 }
}

// Flags that turn a listed route into something that does not ask twice.
var BLOCKED_FLAGS = /^--?(y|yes|force|dangerous|no-confirm|assume-yes)$/i

function allowedCommand(argv) {
  if (!argv || !argv.length || argv.length > 12) return false
  if (argv[0] !== "omarchy") return false

  for (var i = 0; i < argv.length; i++) {
    var word = String(argv[i])
    // Exec goes through an argv vector rather than a shell, so metacharacters
    // cannot escape — but a newline or a NUL means the string was never a
    // single argument to begin with, and that is worth refusing outright.
    if (word.length === 0 || word.length > 96) return false
    if (/[\0\n\r\t]/.test(word)) return false
    if (BLOCKED_FLAGS.test(word)) return false
  }

  var group = String(argv[1] || "")
  var action = String(argv[2] || "")
  var allowed = SAFE_ROUTES[group]
  if (!allowed) return false
  return !!(allowed[action] || allowed["*"] || (action === "" && allowed[""]))
}

// ------------------------------------------- reading an answer from Claude
//
// The model is asked for plain lines, with any command on its own line behind
// "$ ". Everything here treats that answer as untrusted text: it is clipped,
// stripped of control characters, and never rendered as anything but plain
// text. Commands are split on whitespace into an argv vector and only become
// a button if `allowedCommand` says so.

var MAX_ANSWER = 2600
var MAX_LINES = 14

function parseAnswer(raw) {
  var text = String(raw === undefined || raw === null ? "" : raw)
    .replace(/\r/g, "")
    .replace(/[\0-\x08\x0b\x0c\x0e-\x1f\x7f]/g, "")
  if (text.length > MAX_ANSWER) text = text.slice(0, MAX_ANSWER) + "…"

  var lines = text.split("\n")
  var prose = []
  var commands = []

  for (var i = 0; i < lines.length && prose.length < MAX_LINES; i++) {
    var line = lines[i].replace(/\s+$/, "")
    var command = line.match(/^\s*\$\s+(.{1,160})$/)
    if (command) {
      if (commands.length >= 5) continue
      var argv = command[1].replace(/\s+$/, "").split(/\s+/)
      var allowed = allowedCommand(argv)
      var seen = false
      for (var s = 0; s < commands.length; s++) if (commands[s].text === command[1]) seen = true
      if (!seen) commands.push({ text: command[1], argv: argv, runnable: allowed })
      continue
    }
    // Strip the markdown the prompt asks it not to use, in case it does.
    line = line.replace(/^#{1,6}\s*/, "").replace(/\*\*/g, "").replace(/`/g, "")
    if (line.replace(/^\s+/, "") === "" && (prose.length === 0 || prose[prose.length - 1] === "")) continue
    prose.push(line)
  }

  while (prose.length && prose[prose.length - 1] === "") prose.pop()
  return { prose: prose.join("\n"), commands: commands }
}

// The system prompt is pinned here rather than built from the question, so a
// question can never rewrite the instructions around it.
var ASK_RULES = [
  "You answer questions about Omarchy, an Arch Linux desktop running Hyprland,",
  "inside a small status-bar panel. Rules:",
  "- At most six short lines. Plain text. No markdown headings, no bold, no backticks.",
  "- Put each shell command on its own line, prefixed with '$ '. Nothing else on that line.",
  "- Prefer the `omarchy` CLI (e.g. `omarchy theme set <name>`) over raw tooling.",
  "- User config lives in ~/.config/hypr/ and ~/.config/omarchy/. Never tell the user to edit",
  "  anything under /usr/share/omarchy/ — the next update overwrites it.",
  "- Hyprland config is Lua (~/.config/hypr/bindings.lua, monitors.lua, looknfeel.lua).",
  "- The bar, panels and idle behaviour are configured in ~/.config/omarchy/shell.json.",
  "- If you are not sure, say so in one line and name the command that would show the answer.",
  "- Answer the question only. No preamble, no sign-off."
].join("\n")

function askPrompt(question) {
  var q = String(question || "").replace(/[\0-\x08\x0b\x0c\x0e-\x1f\x7f]/g, " ")
  if (q.length > 400) q = q.slice(0, 400)
  return ASK_RULES + "\n\nQuestion: " + q
}
