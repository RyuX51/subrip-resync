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
      Text("Drop SRT here")
        .font(.title)
        .fontWeight(.bold)
        .padding()
    }
    .foregroundStyle(Color.cyan)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.black.opacity(0.7))
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.cyan, lineWidth: 10)
    )
    .cornerRadius(10)
  }
}

#Preview {
  DropHereView()
}
