//
//  ContentView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

struct ContentView: View {
  @StateObject var viewModel = ContentViewModel()
  @State private var isListVisible = false
  @State private var searchText = ""

  var body: some View {
    VStack(spacing: 0) {
      LogoView().frame(height: 100)
      if viewModel.subtitles.isEmpty {
        DropHereView()
      } else {
        listView
        HStack {
          saveButton
          if viewModel.fileExtension == "ass" {
            convertButton
          }
        }
      }
    }
    .background(Color.cyan)
    .onDrop(of: [.fileURL], delegate: self)
    .alert(isPresented: $viewModel.showMoreThanTwoSelectedAlert, content: {
      Alert(title: Text("Information"), message: Text("If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."), dismissButton: .default(Text("OK")))
    })
    .alert(isPresented: $viewModel.showInvalidFileAlert, content: {
      Alert(title: Text("Error"), message: Text("This version supports SRT and ASS files."), dismissButton: .default(Text("OK")))
    })
  }

  private var listView: some View {
    List {
      TextField("Search", text: $searchText)
        .padding(4)
      ForEach(viewModel.subtitles.filter { subtitle in
        let text = subtitle.components.reduce("") { $0 + " " + $1 }
        return self.searchText.isEmpty ? true : text.contains(self.searchText)
      }) { subtitle in
        ZStack {
          subtitle.useForResync ? Color.green.opacity(0.2) : Color.clear
          SubtitleRow(subtitle: subtitle, viewModel: viewModel)
            .padding(6)
        }
      }
    }.listStyle(PlainListStyle())
  }

  private var saveButton: some View {
    Button(action: {
      viewModel.assemble(from: viewModel.subtitles)
    }, label: {
      Label("Save \(viewModel.fileExtension.uppercased())", systemImage: "opticaldiscdrive.fill")
        .font(.title)
        .fontDesign(.monospaced)
        .fontWeight(.bold)
        .padding(8)
        .frame(minWidth: 200)
    })
    .buttonStyle(.borderedProminent)
    .clipShape(.capsule)
    .padding(8)
  }

  private var convertButton: some View {
    Button(action: {
      viewModel.convertToSRT()
    }, label: {
      Label("Save as SRT", systemImage: "opticaldiscdrive.fill")
        .font(.title)
        .fontDesign(.monospaced)
        .fontWeight(.bold)
        .padding(8)
        .frame(minWidth: 200)
    })
    .buttonStyle(.borderedProminent)
    .clipShape(.capsule)
    .padding(8)
  }
}

#Preview {
  ContentView()
}
