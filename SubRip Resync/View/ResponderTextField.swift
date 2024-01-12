//
//  ResponderTextField.swift
//  SubRip Resync
//
//  Created by Mario Stief on 12.01.24.
//

import SwiftUI

struct ResponderTextField: NSViewRepresentable {
  @Binding var text: String
  var isFirstResponder: Bool = false
  var onEditingChanged: (Bool) -> Void
  var onCommit: () -> Void

  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: ResponderTextField

    init(_ parent: ResponderTextField) {
      self.parent = parent
    }

    func controlTextDidBeginEditing(_ obj: Notification) {
      DispatchQueue.main.async {
        self.parent.isFirstResponder = true
      }
    }

    func controlTextDidEndEditing(_ obj: Notification) {
      DispatchQueue.main.async {
        self.parent.isFirstResponder = false
        self.parent.onCommit()
      }
    }

    func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        if self.parent.text != textField.stringValue {
          self.parent.text = textField.stringValue
          self.parent.onEditingChanged(false)
        }
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField(string: text)
    textField.delegate = context.coordinator
    return textField
  }

  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = text
    if isFirstResponder && nsView.window?.firstResponder != nsView {
      nsView.becomeFirstResponder()
    }
  }
}
