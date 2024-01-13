//
//  FocusAwareTextField.swift
//  SubRip Resync
//
//  Created by Mario Stief on 13.01.24.
//

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
