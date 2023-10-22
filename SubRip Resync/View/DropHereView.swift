//
//  DropHereView.swift
//  SubRip Resync
//
//  Created by Mario Stief on 18.10.23.
//

import SwiftUI

struct DropHereView: View {
  var body: some View {
    VStack {
      Image(systemName: "arrow.down.circle")
        .resizable()
        .frame(width: 100, height: 100)
        .padding()
      Text("Drop subtitle file here")
        .font(.system(.title).bold())
        .padding()
    }
    .foregroundColor(Color.white.opacity(0.8))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
      ZStack {
        Color.white
        Color.black.opacity(0.8)
      }
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.blue, lineWidth: 10)
    )
    .cornerRadius(8)
  }
}

#Preview {
  DropHereView()
}
