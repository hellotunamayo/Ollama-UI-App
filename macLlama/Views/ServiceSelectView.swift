//
//  ServiceSelectView.swift
//  macLlama
//
//  Created by Minyoung Yoo on 6/17/25.
//

import SwiftUI

@available(macOS 26.0, *)
struct ServiceSelectView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                ConversationView()
                    .navigationTitle("macLlama")
                    .navigationBarBackButtonHidden(true)
            } label: {
                HStack {
                    Image("llama_white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: Units.normalGap, height: Units.normalGap)
                    Text("New Chat with Ollama")
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            NavigationLink {
                FoundationModelChatView()
                    .navigationTitle("Foundation Model")
                    .navigationBarBackButtonHidden(true)
            } label: {
                Label("New Foundation Model Chat", systemImage: "apple.intelligence")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
