import QtQuick
import qs.Commons
import qs.Commons as Commons

// Every string this plugin draws goes through here.
//
// QML's Text defaults to Text.AutoText, which will happily interpret
// markup-shaped input as rich text and fetch whatever it references. This
// panel renders command output, file paths and model answers, so the plain
// format is pinned once, in one place, rather than remembered per Text.
Text {
  textFormat: Text.PlainText
  color: Commons.Color.foreground
  font.family: Style.font.family
  font.pixelSize: Style.font.body
  wrapMode: Text.WordWrap
  renderType: Text.NativeRendering
}
