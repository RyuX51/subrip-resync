//
//  SettingsView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 21.10.23.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var settings: Settings
  @Binding var isPresented: Bool

  var body: some View {
    ZStack(alignment: .topTrailing) {
      VStack {
        Text("Settings")
          .font(.title)
          .padding()
        Form {
          Section(header: Text("ASS").font(.headline.bold())) {
            Toggle(isOn: $settings.onlyShowText) {
              Text("Show only text fields")
            }
          }
        }
      }
      .padding([.bottom, .horizontal])

      Button(action: {
        isPresented = false
      }, label: {
        Image(systemName: "xmark")
          .font(.headline.bold())
          .foregroundColor(.white)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(
            Rectangle()
              .fill(Color.red)
          )
      })
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  SettingsView(isPresented: .constant(false))
}
