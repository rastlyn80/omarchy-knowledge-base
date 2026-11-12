import QtQuick
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// One lesson, as a row: a done marker, the title, and optionally the chapter
// it came from (which the search results want and the chapter list does not).
//
// The row owns no state. Hover reports upward through `entered()` so the
// panel's single cursor stays authoritative — a row never decides on its own
// that it is highlighted.
Item {
  id: root

  property string title: ""
  property string chapterTitle: ""
  property bool showChapter: false
  property bool done: false
  property bool hot: false

  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property color dim: Qt.darker(foreground, 1.45)
  property color fainter: Qt.darker(foreground, 2.0)
  property string fontFamily: Style.font.family

  signal entered()
  signal activated()

  implicitHeight: Math.max(content.implicitHeight + Style.space(6), Style.space(26))

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
    anchors.rightMargin: Style.space(8)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(8)

    PlainText {
      text: root.done ? "" : ""
      color: root.done ? root.accent : root.fainter
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      anchors.verticalCenter: parent.verticalCenter
    }

    PlainText {
      width: content.width - Style.space(30)
        - (chapterLabel.visible ? chapterLabel.implicitWidth + Style.space(8) : 0)
      text: root.title
      color: root.done ? root.dim : root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
      maximumLineCount: 1
      wrapMode: Text.NoWrap
      anchors.verticalCenter: parent.verticalCenter
    }

    PlainText {
      id: chapterLabel
      visible: root.showChapter && root.chapterTitle !== ""
      text: root.chapterTitle
      color: root.fainter
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      wrapMode: Text.NoWrap
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onContainsMouseChanged: if (containsMouse) root.entered()
    onClicked: root.activated()
  }
}
