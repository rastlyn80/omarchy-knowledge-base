import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import qs.Commons as Commons
import "Kb.js" as Kb

// Omarchy Knowledge Base — a bar panel that teaches Omarchy and answers
// questions about it.
//
// Three things share one panel:
//   · a tutorial in chapters, with per-lesson progress kept in shell.json so
//     it survives a shell restart and an update;
//   · an ask box that searches the bundled index first and only reaches for
//     the `claude` CLI when the index has nothing confident to say;
//   · one-tap actions that run real `omarchy` commands.
//
// Everything runnable goes through Kb.allowedCommand() first, including
// commands lifted out of a model's answer. Routes on that list are reversible
// and never need a password; resets, updates and privileged commands are
// shown as text and never wired to a button.
//
// Displayed text goes through PlainText.qml. Answers, command lines and file
// paths are untrusted input, and the shell this runs in is long-lived and
// unsandboxed.
Panel {
  id: root
  moduleName: "io.github.rastlyn80.knowledge-base"
  ipcTarget: "io.github.rastlyn80.knowledge-base"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // ---- strings ------------------------------------------------------------
  Commons.Translations {
    id: strings
    directory: Qt.resolvedUrl("i18n")
  }

  function t(key) { return strings.t(key) }
  function lessonTitle(id) { return strings.t("ls." + id + ".title") }
  function chapterTitle(id) { return strings.t("ch." + id + ".title") }

  // ---- theme --------------------------------------------------------------
  readonly property color foreground: bar ? bar.foreground : Commons.Color.foreground
  readonly property color accent: Commons.Color.accent
  readonly property color dim: Qt.darker(foreground, 1.45)
  readonly property color fainter: Qt.darker(foreground, 2.0)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property string iconGlyph: ""

  // ---- content ------------------------------------------------------------
  readonly property var lessons: Kb.allLessons()
  readonly property int lessonTotal: lessons.length
  readonly property var chapters: Kb.CHAPTERS

  function lessonById(id) {
    for (var i = 0; i < lessons.length; i++) if (lessons[i].id === id) return lessons[i]
    return null
  }

  function chapterLessons(chapterId) {
    return lessons.filter(function(l) { return l.chapterId === chapterId })
  }

  function chapterIcon(chapterId) {
    for (var i = 0; i < chapters.length; i++) if (chapters[i].id === chapterId) return chapters[i].icon
    return ""
  }

  // ---- progress -----------------------------------------------------------
  // Filtered against the live index on read, so a lesson that is renamed or
  // dropped in a later version leaves no phantom in the count.
  // The one piece of this plugin that leaves the machine, so it is a setting
  // rather than a hardcoded behaviour. Off means the bundled index is the
  // only thing that ever answers a question.
  readonly property bool claudeFallback: setting("claudeFallback", true) !== false

  readonly property var completed: {
    var stored = setting("completed", [])
    if (!Array.isArray(stored)) return []
    var out = []
    for (var i = 0; i < stored.length && out.length <= lessonTotal; i++) {
      var id = String(stored[i])
      if (lessonById(id) && out.indexOf(id) < 0) out.push(id)
    }
    return out
  }
  readonly property int completedCount: completed.length
  readonly property bool allDone: lessonTotal > 0 && completedCount >= lessonTotal

  function isDone(id) { return completed.indexOf(id) >= 0 }

  function toggleDone(id) {
    if (!lessonById(id)) return
    var next = completed.slice()
    var at = next.indexOf(id)
    if (at >= 0) next.splice(at, 1)
    else next.push(id)
    persistSettings({ completed: next })
  }

  function resetProgress() { persistSettings({ completed: [] }) }

  // Applied locally first so the panel redraws on the click itself, then
  // handed to the bar, which writes it back into this widget's shell.json
  // entry. With no writable entry (the widget is not in the layout) it stays
  // a session preference rather than doing nothing.
  function persistSettings(values) {
    var entry = { id: root.moduleName }
    for (var existing in root.settings) if (existing !== "id") entry[existing] = root.settings[existing]
    for (var key in values) entry[key] = values[key]
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
  }

  // ---- what the panel is showing -----------------------------------------
  property string openChapter: "start"
  property string currentLessonId: ""
  property string query: ""

  // "idle" · "asking" · "answered" · "failed"
  property string askState: "idle"
  property string answerBody: ""
  property var answerCommands: []
  property var answerMatches: []

  readonly property var currentLesson: currentLessonId !== "" ? lessonById(currentLessonId) : null
  readonly property string trimmedQuery: query.replace(/^\s+|\s+$/g, "")

  // Precedence, strongest first: an answer, then whatever is being typed,
  // then the lesson being read, then the chapter list. Typing has to beat the
  // lesson, or a question typed while reading one leaves the old lesson on
  // screen under the half-typed question.
  readonly property bool showingAnswer: askState !== "idle"
  readonly property bool showingSearch: !showingAnswer && trimmedQuery !== ""
  readonly property bool showingLesson: !showingAnswer && !showingSearch && !!currentLesson
  readonly property bool showingHome: !showingAnswer && !showingSearch && !currentLesson

  // Recomputed on every keystroke, and on a language switch — `strings.language`
  // is read here so the binding depends on it.
  readonly property var liveMatches: {
    if (!showingSearch) return []
    var language = strings.language
    return Kb.search(trimmedQuery, lessons, function(key) { return strings.t(key) })
  }
  readonly property var liveMatchIds: liveMatches.map(function(h) { return h.lesson.id })

  function openLesson(id) {
    if (!lessonById(id)) return
    clearAnswer()
    // The question has been answered by opening this; leaving it in the box
    // would keep the search results in front of the lesson it chose.
    clearQuery()
    root.currentLessonId = id
    root.openChapter = lessonById(id).chapterId
    root.cursor = 0
    scrollToTop()
  }

  function stepLesson(delta) {
    if (!currentLesson) return
    var next = lessons[currentLesson.index + delta]
    if (next) openLesson(next.id)
  }

  function goHome() {
    clearAnswer()
    root.currentLessonId = ""
    root.cursor = 0
    scrollToTop()
  }

  function clearQuery() {
    root.query = ""
    if (field) field.text = ""
  }

  function clearAnswer() {
    askTimeout.stop()
    askProc.running = false
    root.askState = "idle"
    root.answerBody = ""
    root.answerCommands = []
    root.answerMatches = []
  }

  // Escape unwinds one level at a time and only closes the panel from the top.
  function goBack() {
    if (showingAnswer) { clearAnswer(); cursor = 0; return }
    if (showingSearch) { clearQuery(); cursor = 0; return }
    if (showingLesson) { goHome(); return }
    close()
  }

  // ---- asking -------------------------------------------------------------
  //
  // The index answers first. It is instant, works offline, and for the
  // questions this plugin exists to answer it is also more reliable than a
  // model recalling a CLI from memory. Claude is the fallback, and the
  // escalate button keeps it a choice rather than a surprise.
  function ask(question) {
    var q = String(question || "").replace(/^\s+|\s+$/g, "")
    if (q.length < 2) return
    var hits = Kb.search(q, lessons, function(key) { return strings.t(key) })
    if (hits.length > 0 && hits[0].score >= Kb.CONFIDENT) {
      openLesson(hits[0].lesson.id)
      return
    }
    // With the fallback switched off the panel stays offline: the question
    // keeps its own search results on screen, headed by "nothing matches",
    // and nothing leaves the machine.
    if (claudeFallback) askClaude(q)
  }

  function askClaude(question) {
    if (!claudeFallback) return
    var q = String(question || "").replace(/^\s+|\s+$/g, "")
    if (q.length < 2) return
    clearAnswer()
    root.askState = "asking"
    root.answerMatches = Kb.search(q, lessons, function(key) { return strings.t(key) })
      .slice(0, 3).map(function(h) { return h.lesson.id })
    askProc.prompt = Kb.askPrompt(q)
    askProc.running = true
    askTimeout.restart()
    root.cursor = 0
    scrollToTop()
  }

  // `claude` runs through a login shell so it is found the way the user's own
  // shell finds it (a mise shim, ~/.local/bin, a package). The question rides
  // in as a positional parameter that bash expands without re-tokenizing, so
  // it is never part of the command string. Tools are capped at the read-only
  // three: a question can answer itself from this machine's own config
  // without the model being able to change anything.
  Process {
    id: askProc
    property string prompt: ""
    command: ["bash", "-lc",
              "exec claude -p --output-format text \"$1\" --allowed-tools \"Read\" \"Grep\" \"Glob\"",
              "bash", askProc.prompt]

    stdout: StdioCollector { id: askOut; waitForEnd: true }
    stderr: StdioCollector { id: askErr; waitForEnd: true }

    onExited: function(exitCode, exitStatus) {
      askTimeout.stop()
      if (root.askState !== "asking") return
      if (exitCode !== 0) {
        root.askState = "failed"
        root.answerBody = root.t("kb.ask.failed")
        return
      }
      var parsed = Kb.parseAnswer(askOut.text)
      if (parsed.prose.replace(/^\s+|\s+$/g, "") === "" && parsed.commands.length === 0) {
        root.askState = "failed"
        root.answerBody = root.t("kb.ask.empty")
        return
      }
      root.askState = "answered"
      root.answerBody = parsed.prose
      root.answerCommands = parsed.commands
      root.cursor = 0
    }
  }

  Timer {
    id: askTimeout
    interval: 90000
    onTriggered: {
      if (root.askState !== "asking") return
      askProc.running = false
      root.askState = "failed"
      root.answerBody = root.t("kb.ask.timeout")
    }
  }

  // ---- doing things -------------------------------------------------------
  //
  // The only path from this plugin to a running command. Nothing else calls
  // execDetached or execArgv, and the gate runs on every argv regardless of
  // where it came from.
  function run(argv) {
    if (!Kb.allowedCommand(argv)) return false
    Util.execArgv(argv)
    close()
    return true
  }

  property string copiedText: ""

  function copy(text) {
    var value = String(text || "")
    if (value === "" || value.length > 4000 || /[\0\n\r]/.test(value)) return
    Util.execArgv(value.charAt(0) === "-" ? ["wl-copy", "--", value] : ["wl-copy", value])
    root.copiedText = value
    copiedReset.restart()
  }

  Timer {
    id: copiedReset
    interval: 1600
    onTriggered: root.copiedText = ""
  }

  // ---- the cursor ---------------------------------------------------------
  //
  // One flat list of targets for whatever is on screen, and one index into
  // it. Mouse hover writes the same index, so there is never more than one
  // highlight and the pointer and the keyboard never disagree.
  property int cursor: 0

  readonly property var targets: {
    var out = []
    if (showingAnswer) {
      for (var c = 0; c < answerCommands.length; c++)
        if (answerCommands[c].runnable) out.push({ kind: "answerCmd", index: c })
      for (var m = 0; m < answerMatches.length; m++)
        out.push({ kind: "lesson", id: answerMatches[m] })
      out.push({ kind: "dismiss" })
      return out
    }
    if (showingSearch) {
      for (var s = 0; s < liveMatchIds.length; s++) out.push({ kind: "lesson", id: liveMatchIds[s] })
      if (claudeFallback) out.push({ kind: "escalate" })
      return out
    }
    if (showingLesson) {
      for (var a = 0; a < currentLesson.actions.length; a++) out.push({ kind: "action", index: a })
      for (var k = 0; k < currentLesson.cmds.length; k++) out.push({ kind: "cmd", index: k })
      out.push({ kind: "done" })
      if (currentLesson.index + 1 < lessonTotal) out.push({ kind: "next" })
      out.push({ kind: "home" })
      return out
    }
    for (var ch = 0; ch < chapters.length; ch++) {
      out.push({ kind: "chapter", id: chapters[ch].id })
      if (chapters[ch].id !== openChapter) continue
      var inner = chapterLessons(chapters[ch].id)
      for (var i = 0; i < inner.length; i++) out.push({ kind: "lesson", id: inner[i].id })
    }
    return out
  }

  readonly property int cursorMax: Math.max(0, targets.length - 1)
  readonly property var cursorTarget: targets.length ? targets[Math.min(cursor, cursorMax)] : null

  // Whether a given target is the one under the cursor. Every row asks this
  // rather than comparing indices itself.
  function at(kind, key) {
    var target = cursorTarget
    if (!target || target.kind !== kind) return false
    if (key === undefined) return true
    return target.id === key || target.index === key
  }

  function moveCursor(delta) {
    if (targets.length === 0) return
    root.cursor = Util.clamp(Math.min(cursor, cursorMax) + delta, 0, cursorMax)
  }

  function pointAt(kind, key) {
    for (var i = 0; i < targets.length; i++) {
      var target = targets[i]
      if (target.kind !== kind) continue
      if (key === undefined || target.id === key || target.index === key) { root.cursor = i; return }
    }
  }

  function activate() {
    var target = cursorTarget
    if (!target) return
    switch (target.kind) {
      case "chapter":
        root.openChapter = openChapter === target.id ? "" : target.id
        pointAt("chapter", target.id)
        return
      case "lesson":
        openLesson(target.id)
        return
      case "action":
        if (currentLesson && currentLesson.actions[target.index])
          run(currentLesson.actions[target.index].argv)
        return
      case "cmd":
        if (currentLesson && currentLesson.cmds[target.index])
          copy(currentLesson.cmds[target.index])
        return
      case "answerCmd":
        var entry = answerCommands[target.index]
        if (entry && entry.runnable) run(entry.argv)
        return
      case "done":     toggleDone(currentLessonId); return
      case "next":     stepLesson(1); return
      case "home":     goHome(); return
      case "dismiss":  clearAnswer(); return
      case "escalate": askClaude(trimmedQuery); return
    }
  }

  // ---- scrolling the cursor into view ------------------------------------
  //
  // Rows report their own position when they light up, so the scroll view can
  // follow the keyboard without every list doing the arithmetic. The buttons
  // at the foot of a view have nothing above them worth keeping on screen, so
  // the cursor landing there just goes to the bottom.
  readonly property Item field: panel.loadedContent ? panel.loadedContent.askField : null
  readonly property Item scroller: panel.loadedContent ? panel.loadedContent.scrollArea : null
  readonly property Item body: panel.loadedContent ? panel.loadedContent.bodyColumn : null

  function scrollToTop() {
    if (scroller) scroller.contentItem.contentY = 0
  }

  function scrollToBottom() {
    if (!scroller) return
    var view = scroller.contentItem
    view.contentY = Math.max(0, view.contentHeight - scroller.height)
  }

  function noteCursorRow(item) {
    if (!item || !scroller || !body) return
    var view = scroller.contentItem
    var top = item.mapToItem(body, 0, 0).y
    var bottom = top + item.height
    var pad = Style.space(10)
    if (top - pad < view.contentY) view.contentY = Math.max(0, top - pad)
    else if (bottom + pad > view.contentY + scroller.height)
      view.contentY = Math.min(Math.max(0, view.contentHeight - scroller.height),
                              bottom + pad - scroller.height)
  }

  onCursorChanged: {
    var kind = cursorTarget ? cursorTarget.kind : ""
    if (kind === "done" || kind === "next" || kind === "home"
        || kind === "dismiss" || kind === "escalate") Qt.callLater(scrollToBottom)
  }

  // ---- lifecycle ----------------------------------------------------------
  function open() {
    root.cursor = 0
    root.controller.show()
    Qt.callLater(function() {
      if (!root.opened) return
      root.scrollToTop()
      if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
    })
  }

  function close() {
    if (field) field.focus = false
    root.controller.hide()
  }

  function toggle() { root.opened ? close() : open() }

  // ---- bar button ---------------------------------------------------------
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.iconGlyph
    tooltipText: root.t("kb.tooltip")
    active: root.opened
    onPressed: function(pressedButton) {
      // Right-click opens it on the chapter list, whatever it was last on.
      if (pressedButton === Qt.RightButton && !root.opened) {
        root.goHome()
        root.clearQuery()
      }
      root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: panel.loadedContent
    contentWidth: panel.fittedContentWidth(Style.space(470))
    contentHeight: panel.fittedContentHeight(panel.loadedContentHeight, Style.space(620))

    content: PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      implicitHeight: bodyCol.implicitHeight

      property alias askField: askInput
      property alias scrollArea: scrollView
      property alias bodyColumn: bodyCol

      // While the ask box has focus every key belongs to it; the field's own
      // handler gives back the ones that mean navigation.
      blocked: askInput.activeFocus

      onMoveRequested: function(dx, dy) { if (dy !== 0) root.moveCursor(dy) }
      onActivateRequested: root.activate()
      onCloseRequested: root.goBack()
      onDeleteRequested: root.goBack()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text, modifiers) {
        if (modifiers & Qt.ControlModifier) return
        if (text === "/" || text === "?") {
          askInput.forceActiveFocus()
          askInput.selectAll()
        } else if (text === "d") {
          if (root.showingLesson) root.toggleDone(root.currentLessonId)
          else if (root.cursorTarget && root.cursorTarget.kind === "lesson")
            root.toggleDone(root.cursorTarget.id)
        } else if (text === "n") {
          root.stepLesson(1)
        } else if (text === "p") {
          root.stepLesson(-1)
        } else if (text === "g") {
          root.goHome()
        }
      }

      ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: bodyCol.implicitHeight > height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        Binding {
          target: scrollView.contentItem
          property: "interactive"
          value: bodyCol.implicitHeight > scrollView.height
        }

        Column {
          id: bodyCol
          width: scrollView.availableWidth
          spacing: Style.space(12)

          // ------------------------------------------------ hero
          PanelHero {
            title: root.t("kb.title")
            meta: root.allDone
              ? root.t("kb.allDone").arg(Commons.I18n.formatNumber(root.lessonTotal))
              : root.t("kb.progress")
                  .arg(Commons.I18n.formatNumber(root.completedCount))
                  .arg(Commons.I18n.formatNumber(root.lessonTotal))
            detail: root.currentLesson
              ? Commons.I18n.formatNumber(root.currentLesson.index + 1)
                + "/" + Commons.I18n.formatNumber(root.lessonTotal)
              : ""
            foreground: root.foreground
            fontFamily: root.fontFamily

            iconComponent: Component {
              PlainText {
                text: root.iconGlyph
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.display
              }
            }

            trailingControl: Component {
              PanelActionButton {
                iconText: ""
                tooltipText: root.t("kb.resetProgress")
                foreground: root.foreground
                fontFamily: root.fontFamily
                visible: root.completedCount > 0
                onClicked: root.resetProgress()
              }
            }
          }

          // ------------------------------------------------ ask box
          TextField {
            id: askInput
            width: bodyCol.width
            foreground: root.foreground
            accent: root.accent
            placeholderText: root.t("kb.ask.placeholder")
            font.family: root.fontFamily
            enabled: root.askState !== "asking"

            onTextChanged: {
              root.query = text
              // Typing over an answer puts the panel back into search.
              if (root.showingAnswer && text !== "") root.clearAnswer()
              root.cursor = 0
            }

            Keys.onPressed: function(event) {
              if (event.key === Qt.Key_Escape) {
                if (askInput.text !== "") {
                  askInput.text = ""
                } else {
                  askInput.focus = false
                  if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
                }
                event.accepted = true
              } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.ask(askInput.text)
                askInput.focus = false
                if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
                event.accepted = true
              } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                askInput.focus = false
                if (panel.loadedContent) panel.loadedContent.forceActiveFocus()
                root.moveCursor(event.key === Qt.Key_Down ? 1 : -1)
                event.accepted = true
              }
            }
          }

          // ------------------------------------------------ an answer
          Column {
            width: bodyCol.width
            spacing: Style.space(8)
            visible: root.showingAnswer

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: root.askState === "asking" ? root.t("kb.ask.asking") : root.t("kb.ask.fromClaude")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            PlainText {
              width: parent.width
              visible: root.askState === "asking"
              text: root.t("kb.ask.thinking")
              color: root.dim
              font.family: root.fontFamily
            }

            PlainText {
              width: parent.width
              visible: root.answerBody !== ""
              text: root.answerBody
              color: root.askState === "failed" ? root.dim : root.foreground
              font.family: root.fontFamily
              lineHeight: 1.3
            }

            // Commands the model offered. Only the ones that pass the gate get
            // a play button; the rest copy, and say why in the tooltip.
            Column {
              width: parent.width
              spacing: Style.space(3)
              visible: root.answerCommands.length > 0

              Repeater {
                model: root.answerCommands

                delegate: CommandRow {
                  id: answerCmdRow
                  required property var modelData
                  required property int index

                  width: bodyCol.width
                  command: modelData.text
                  runnable: modelData.runnable
                  copied: root.copiedText === modelData.text
                  hot: modelData.runnable && root.at("answerCmd", index)
                  tooltip: modelData.runnable ? modelData.text : root.t("kb.ask.notRunnable")
                  foreground: root.foreground
                  accent: root.accent
                  dim: root.dim
                  fainter: root.fainter
                  fontFamily: root.fontFamily

                  onHotChanged: if (hot) root.noteCursorRow(answerCmdRow)
                  onEntered: if (modelData.runnable) root.pointAt("answerCmd", index)
                  onActivated: modelData.runnable ? root.run(modelData.argv) : root.copy(modelData.text)
                }
              }
            }
          }

          // ------------------------------------------------ index matches
          Column {
            width: bodyCol.width
            spacing: Style.space(5)
            visible: root.showingSearch || (root.showingAnswer && root.answerMatches.length > 0)

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: root.showingSearch && root.liveMatchIds.length === 0
                ? root.t("kb.ask.noMatch")
                : root.t("kb.ask.matches")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Repeater {
              model: root.showingAnswer ? root.answerMatches : root.liveMatchIds

              delegate: LessonRow {
                id: matchRow
                required property var modelData

                width: bodyCol.width
                title: root.lessonTitle(modelData)
                chapterTitle: root.lessonById(modelData)
                  ? root.chapterTitle(root.lessonById(modelData).chapterId) : ""
                showChapter: true
                done: root.isDone(modelData)
                hot: root.at("lesson", modelData)
                foreground: root.foreground
                accent: root.accent
                dim: root.dim
                fainter: root.fainter
                fontFamily: root.fontFamily

                onHotChanged: if (hot) root.noteCursorRow(matchRow)
                onEntered: root.pointAt("lesson", modelData)
                onActivated: root.openLesson(modelData)
              }
            }

            Button {
              visible: root.showingSearch && root.claudeFallback
              text: root.t("kb.ask.escalate")
              iconText: ""
              bordered: true
              hasCursor: root.at("escalate")
              foreground: root.foreground
              accent: root.accent
              fontFamily: root.fontFamily
              fontSize: Style.font.bodySmall
              onHovered: function(on) { if (on) root.pointAt("escalate") }
              onClicked: root.askClaude(root.trimmedQuery)
            }
          }

          // ------------------------------------------------ one lesson
          Column {
            width: bodyCol.width
            spacing: Style.space(10)
            visible: root.showingLesson

            PanelSeparator { foreground: root.foreground }

            Row {
              width: parent.width
              spacing: Style.space(9)

              PlainText {
                text: root.currentLesson ? root.chapterIcon(root.currentLesson.chapterId) : ""
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.subtitle
                anchors.top: parent.top
              }

              PlainText {
                width: parent.width - Style.space(28)
                text: root.currentLesson ? root.lessonTitle(root.currentLesson.id) : ""
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.subtitle
                font.bold: true
              }
            }

            PlainText {
              width: parent.width
              text: root.currentLesson ? strings.t("ls." + root.currentLesson.id + ".body") : ""
              color: root.dim
              font.family: root.fontFamily
              lineHeight: 1.35
            }

            Flow {
              width: parent.width
              spacing: Style.space(6)
              visible: !!root.currentLesson && root.currentLesson.keys.length > 0

              Repeater {
                model: root.currentLesson ? root.currentLesson.keys : []

                delegate: KeyChip {
                  required property var modelData
                  label: modelData
                  foreground: root.foreground
                  accent: root.accent
                  fontFamily: root.fontFamily
                }
              }
            }

            // Shown for reading and copying, not running: paths, config
            // snippets, and the commands that reset or update things and want
            // a terminal in front of them.
            Column {
              width: parent.width
              spacing: Style.space(3)
              visible: !!root.currentLesson && root.currentLesson.cmds.length > 0

              PanelSectionHeader {
                text: root.t("kb.commands")
                foreground: root.foreground
                fontFamily: root.fontFamily
              }

              Repeater {
                model: root.currentLesson ? root.currentLesson.cmds : []

                delegate: CommandRow {
                  id: cmdRow
                  required property var modelData
                  required property int index

                  width: bodyCol.width
                  command: modelData
                  runnable: false
                  copied: root.copiedText === String(modelData)
                  hot: root.at("cmd", index)
                  tooltip: root.copiedText === String(modelData) ? root.t("kb.copied") : root.t("kb.copy")
                  foreground: root.foreground
                  accent: root.accent
                  dim: root.dim
                  fainter: root.fainter
                  fontFamily: root.fontFamily

                  onHotChanged: if (hot) root.noteCursorRow(cmdRow)
                  onEntered: root.pointAt("cmd", index)
                  onActivated: root.copy(modelData)
                }
              }
            }

            Column {
              width: parent.width
              spacing: Style.space(6)
              visible: !!root.currentLesson && root.currentLesson.actions.length > 0

              PanelSectionHeader {
                text: root.t("kb.actions")
                foreground: root.foreground
                fontFamily: root.fontFamily
              }

              Flow {
                width: parent.width
                spacing: Style.space(6)

                Repeater {
                  model: root.currentLesson ? root.currentLesson.actions : []

                  delegate: Button {
                    required property var modelData
                    required property int index
                    text: root.t(modelData.labelKey)
                    iconText: ""
                    bordered: true
                    hasCursor: root.at("action", index)
                    tooltipText: modelData.argv.join(" ")
                    foreground: root.foreground
                    accent: root.accent
                    fontFamily: root.fontFamily
                    fontSize: Style.font.bodySmall
                    onHovered: function(on) { if (on) root.pointAt("action", index) }
                    onClicked: root.run(modelData.argv)
                  }
                }
              }
            }

            PanelSeparator { foreground: root.foreground }

            Flow {
              width: parent.width
              spacing: Style.space(6)

              Button {
                text: root.isDone(root.currentLessonId) ? root.t("kb.markUndone") : root.t("kb.markDone")
                iconText: root.isDone(root.currentLessonId) ? "" : ""
                bordered: true
                selected: root.isDone(root.currentLessonId)
                hasCursor: root.at("done")
                foreground: root.foreground
                accent: root.accent
                fontFamily: root.fontFamily
                fontSize: Style.font.bodySmall
                onHovered: function(on) { if (on) root.pointAt("done") }
                onClicked: root.toggleDone(root.currentLessonId)
              }

              Button {
                visible: !!root.currentLesson && root.currentLesson.index + 1 < root.lessonTotal
                text: root.t("kb.next")
                iconText: ""
                bordered: true
                hasCursor: root.at("next")
                foreground: root.foreground
                accent: root.accent
                fontFamily: root.fontFamily
                fontSize: Style.font.bodySmall
                onHovered: function(on) { if (on) root.pointAt("next") }
                onClicked: root.stepLesson(1)
              }

              Button {
                text: root.t("kb.back")
                iconText: ""
                bordered: true
                hasCursor: root.at("home")
                foreground: root.foreground
                accent: root.accent
                fontFamily: root.fontFamily
                fontSize: Style.font.bodySmall
                onHovered: function(on) { if (on) root.pointAt("home") }
                onClicked: root.goHome()
              }
            }
          }

          // ------------------------------------------------ chapters
          Column {
            width: bodyCol.width
            spacing: Style.space(3)
            visible: root.showingHome

            PanelSeparator { foreground: root.foreground }

            PanelSectionHeader {
              text: root.t("kb.chapters")
              foreground: root.foreground
              fontFamily: root.fontFamily
            }

            Repeater {
              model: root.chapters

              delegate: Column {
                id: chapterBlock
                required property var modelData

                readonly property string chapterId: modelData.id
                readonly property bool expanded: root.openChapter === chapterId
                readonly property var inner: root.chapterLessons(chapterId)
                readonly property int innerDone: inner.filter(function(l) { return root.isDone(l.id) }).length

                width: bodyCol.width
                spacing: Style.space(2)

                Item {
                  id: chapterHeader
                  width: parent.width
                  implicitHeight: Math.max(chapterRow.implicitHeight + Style.space(8), Style.space(32))

                  readonly property bool hot: root.at("chapter", chapterBlock.chapterId)
                  onHotChanged: if (hot) root.noteCursorRow(chapterHeader)

                  CursorSurface {
                    anchors.fill: parent
                    hasCursor: chapterHeader.hot
                    current: chapterBlock.expanded
                    foreground: root.foreground
                    accent: root.accent
                  }

                  Row {
                    id: chapterRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.space(8)
                    anchors.rightMargin: Style.space(8)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Style.space(10)

                    PlainText {
                      width: Style.space(16)
                      text: modelData.icon
                      color: root.dim
                      font.family: root.fontFamily
                      anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                      width: chapterRow.width - Style.space(62)
                      anchors.verticalCenter: parent.verticalCenter
                      spacing: 0

                      PlainText {
                        width: parent.width
                        text: root.chapterTitle(chapterBlock.chapterId)
                        color: root.foreground
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.bodySmall
                        font.bold: true
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.NoWrap
                      }

                      PlainText {
                        width: parent.width
                        text: strings.t("ch." + chapterBlock.chapterId + ".blurb")
                        color: root.fainter
                        font.family: root.fontFamily
                        font.pixelSize: Style.font.caption
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.NoWrap
                      }
                    }

                    PlainText {
                      text: Commons.I18n.formatNumber(chapterBlock.innerDone)
                        + "/" + Commons.I18n.formatNumber(chapterBlock.inner.length)
                      color: chapterBlock.innerDone === chapterBlock.inner.length ? root.accent : root.fainter
                      font.family: root.fontFamily
                      font.pixelSize: Style.font.caption
                      font.bold: true
                      wrapMode: Text.NoWrap
                      anchors.verticalCenter: parent.verticalCenter
                    }
                  }

                  MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onContainsMouseChanged: if (containsMouse) root.pointAt("chapter", chapterBlock.chapterId)
                    onClicked: {
                      root.openChapter = chapterBlock.expanded ? "" : chapterBlock.chapterId
                      root.pointAt("chapter", chapterBlock.chapterId)
                    }
                  }
                }

                // The chapter's lessons, revealed in place and indented under it.
                Column {
                  x: Style.space(16)
                  width: parent.width - Style.space(16)
                  spacing: Style.space(2)
                  visible: chapterBlock.expanded

                  Repeater {
                    model: chapterBlock.expanded
                      ? chapterBlock.inner.map(function(l) { return l.id })
                      : []

                    delegate: LessonRow {
                      id: chapterLessonRow
                      required property var modelData

                      width: bodyCol.width - Style.space(16)
                      title: root.lessonTitle(modelData)
                      done: root.isDone(modelData)
                      hot: root.at("lesson", modelData)
                      foreground: root.foreground
                      accent: root.accent
                      dim: root.dim
                      fainter: root.fainter
                      fontFamily: root.fontFamily

                      onHotChanged: if (hot) root.noteCursorRow(chapterLessonRow)
                      onEntered: root.pointAt("lesson", modelData)
                      onActivated: root.openLesson(modelData)
                    }
                  }
                }
              }
            }
          }

          // ------------------------------------------------ footer
          Column {
            width: bodyCol.width
            spacing: Style.space(6)

            PanelSeparator { foreground: root.foreground }

            PlainText {
              width: parent.width
              text: root.t("kb.ask.hint")
              color: root.fainter
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }
}
