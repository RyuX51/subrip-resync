//
//  CloseButton.swift
//  SubRip Resync
//
//  Created by Mario Stief on 22.10.23.
//

import SwiftUI

struct CloseButton: View {
  @Binding var isPresented: Bool
  @State private var isHovering: Bool = false

  var body: some View {
    ZStack {
      Circle()
        .frame(width: 12, height: 12)
        .foregroundColor(.red)
        .padding(.horizontal, 8)
        .padding(.vertical, 8)

      if isHovering {
        Image(systemName: "xmark")
          .resizable()
          .frame(width: 6, height: 6)
          .foregroundColor(.black)
      }
    }.onTapGesture {
      isPresented = false
    }
    .buttonStyle(.plain)
    .onHover { hovering in
      isHovering = hovering
    }
  }
}

#Preview {
  CloseButton(isPresented: .constant(false))
}
