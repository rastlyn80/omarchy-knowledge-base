import QtQuick
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// A command on one line, with one button on the end.
//
// `runnable` decides which: a play button that runs it, or a copy button that
// puts it on the clipboard. The row never decides that itself — the panel
// asks the command gate first and passes the answer down. A command that did
// not pass is still shown, in dimmer ink, because knowing the command is most
// of the value even when the plugin will not run it for you.
Item {
  id: root

  property string command: ""
  property bool runnable: false
  property bool copied: false
  property bool hot: false
  property string tooltip: ""

  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color dim: Qt.darker(foreground, 1.45)
  property color fainter: Qt.darker(foreground, 2.0)
  property string fontFamily: Style.font.family

  signal entered()
  signal activated()

  implicitHeight: Math.max(content.implicitHeight + Style.space(4), Style.space(25))

  CursorSurface {
    anchors.fill: parent
    hasCursor: root.hot
    foreground: root.foreground
    accent: root.accent
  }

  Row {
    id: content
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: Style.space(8)
    anchors.rightMargin: Style.space(4)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(8)

    PlainText {
      visible: root.runnable
      text: ""
      color: root.fainter
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      anchors.verticalCenter: parent.verticalCenter
    }

    PlainText {
      width: content.width - button.width - Style.space(20)
        - (root.runnable ? Style.space(18) : 0)
      text: root.command
      color: root.runnable ? root.foreground : root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
      maximumLineCount: 1
      wrapMode: Text.NoWrap
      anchors.verticalCenter: parent.verticalCenter
    }

    PanelActionButton {
      id: button
      iconText: root.runnable ? "" : (root.copied ? "" : "")
      tooltipText: root.tooltip
      foreground: root.foreground
      fontFamily: root.fontFamily
      anchors.verticalCenter: parent.verticalCenter
      onHovered: function(on) { if (on) root.entered() }
      onClicked: root.activated()
    }
  }

  MouseArea {
    anchors.fill: parent
    anchors.rightMargin: button.width + Style.space(8)
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onContainsMouseChanged: if (containsMouse) root.entered()
    onClicked: root.activated()
  }
}
