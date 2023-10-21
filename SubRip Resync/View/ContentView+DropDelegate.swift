//
//  ContentView+DropDelegate.swift
//  SubRip Resync
//
//  Created by Mario Stief on 20.10.23.
//

import SwiftUI

extension ContentView: DropDelegate {

  func performDrop(info: DropInfo) -> Bool {
    guard let itemProvider = info.itemProviders(for: [.fileURL]).first else { return false }
    itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, _ in
      DispatchQueue.main.async {
        guard let urlData = urlData as? Data, let url = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL? else { return }
        self.viewModel.parseFile(url: url)
      }
    }
    return true
  }
}
