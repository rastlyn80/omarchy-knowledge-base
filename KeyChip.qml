import QtQuick
import qs.Ui
import qs.Commons
import qs.Commons as Commons

// A keybinding, drawn as a key. Never translated: SUPER is SUPER in every
// language, and a chip that read "SUPER + MELLEMRUM" would not match the
// keyboard in front of the reader.
BorderSurface {
  id: root

  property string label: ""
  property color foreground: Commons.Color.foreground
  property color accent: Commons.Color.accent
  property string fontFamily: Style.font.family

  implicitWidth: chipLabel.implicitWidth + Style.space(14)
  implicitHeight: chipLabel.implicitHeight + Style.space(7)
  color: Style.normalFillFor(foreground, accent)
  borderSpec: Border.controlSpec("normal", foreground, accent)
  radius: Style.cornerRadius

  PlainText {
    id: chipLabel
    anchors.centerIn: parent
    text: root.label
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
    font.letterSpacing: 0.6
    wrapMode: Text.NoWrap
  }
}
