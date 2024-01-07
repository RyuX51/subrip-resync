//
//  ContentView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

struct ContentView: View {
  @StateObject var viewModel = ContentViewModel()
  @ObservedObject var selectedFile: SelectedFile

  var body: some View {
    VStack(spacing: 0) {
      if viewModel.subtitles.isEmpty {
        LogoView().frame(height: 100)
        DropHereView()
      } else {
        searchView
        headerView
        listView
      }
      HStack {
        Spacer()
        HStack {
          if !viewModel.fileExtension.isEmpty {
            saveButton
          }
          if viewModel.fileExtension == "ass" {
            convertButton
          }
        }
        Spacer()
        settingsButton
      }
    }
    .background(Color.blue)
    .onDrop(of: [.fileURL], delegate: self)
    .onChange(of: selectedFile.url) { newValue in
      if let url = newValue {
        viewModel.parseFile(url: url)
      }
    }
    .alert(isPresented: $viewModel.showMoreThanTwoSelectedAlert, content: {
      Alert(title: Text("Information"), message: Text("If more then 2 subtitles are active, the offsets will be calculated linearly between the first and the last one to archive the best result."), dismissButton: .default(Text("OK")))
    })
    .alert(isPresented: $viewModel.showInvalidFileAlert, content: {
      Alert(title: Text("Error"), message: Text("This version supports SRT and ASS files."), dismissButton: .default(Text("OK")))
    })
    .sheet(isPresented: $viewModel.showSettings) {
      SettingsView(isPresented: $viewModel.showSettings)
    }
  }

  private var searchView: some View {
    HStack {
      Image(systemName: "magnifyingglass")
      TextField("Search", text: $viewModel.searchText)
        .font(.system(.headline, design: .monospaced))
    }
    .padding(8)
    .background(
      ZStack {
        Color.white
        Color.black.opacity(0.7)
      }
    )
  }

  private var headerView: some View {
    HStack {
      Text("")
        .frame(width: 50)
      Text("Start --> End  ")
        .frame(width: 300)
      Text("Text")
        .frame(minWidth: 300)
      Spacer()
      Text("Offset")
        .frame(width: 200)
      Text("")
        .frame(width: 40)
    }
    .font(.system(.headline, design: .monospaced).bold())
    .padding(8)
  }

  private var listView: some View {
    List {
      ForEach(viewModel.subtitles.filter { subtitle in
        let text = subtitle.components.joined()
        return viewModel.searchText.isEmpty ? true : text.contains(viewModel.searchText)
      }) { subtitle in
        ZStack {
          subtitle.id % 2 == 0 ? Color.blue.opacity(0.2) : Color.clear
          subtitle.useForResync ? Color.red.opacity(0.2) : Color.clear
          SubtitleRow(subtitle: subtitle, viewModel: viewModel)
        }
      }
    }
    .listStyle(.plain)
  }

  private var saveButton: some View {
    Label("Save \(viewModel.fileExtension.uppercased())", systemImage: "opticaldiscdrive.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .frame(minWidth: 256)
      .onTapGesture {
        viewModel.assemble(from: viewModel.subtitles)
      }
      .background(Capsule().fill(Color.white.opacity(0.5)))
      .padding(8)
  }

  private var convertButton: some View {
    Label("Save as SRT", systemImage: "opticaldiscdrive.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .frame(minWidth: 256)
      .onTapGesture {
        viewModel.convertToSRT()
      }
      .background(Capsule().fill(Color.white.opacity(0.5)))
      .padding(8)
  }

  private var settingsButton: some View {
    Image(systemName: "gearshape.fill")
      .font(.system(.title, design: .monospaced).bold())
      .padding(8)
      .onTapGesture {
        viewModel.showSettings.toggle()
      }
      .background(Circle().fill(Color.white.opacity(0.5)))
      .padding(8)
  }
}

#Preview {
  ContentView(selectedFile: .init())
}
