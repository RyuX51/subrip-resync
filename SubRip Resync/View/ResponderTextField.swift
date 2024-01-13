//
//  ResponderTextField.swift
//  SubRip Resync
//
//  Created by Mario Stief on 12.01.24.
//

import AppKit
import SwiftUI

class FocusAwareTextField: NSTextField {
  var onFocusChange: (Bool) -> Void = { _ in }

  override func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    if result {
      onFocusChange(true)
    }
    return result
  }

  override func resignFirstResponder() -> Bool {
    let result = super.resignFirstResponder()
    if result {
      onFocusChange(false)
    }
    return result
  }
}

struct ResponderTextField: NSViewRepresentable {
  @Binding var text: String
  @Binding var isFirstResponder: Bool
  var onEditingChanged: (Bool) -> Void
  var onCommit: () -> Void

  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: ResponderTextField

    init(_ parent: ResponderTextField) {
      self.parent = parent
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
    let textField = FocusAwareTextField(string: text)
    textField.onFocusChange = { isFocused in
      DispatchQueue.main.async {
        self.isFirstResponder = isFocused
      }
    }
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
