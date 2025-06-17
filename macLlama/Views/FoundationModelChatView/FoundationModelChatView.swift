//
//  FoundationModelChatView.swift
//  macLlama
//
//  Created by Minyoung Yoo on 6/17/25.
//

import SwiftUI
import FoundationModels

struct ConversationContent: Identifiable {
    var id: UUID { UUID() }
    let isUser: Bool
    var text: String
}

@available(macOS 26.0, *)
struct FoundationModelChatView: View {
    @State private var foundationModelSession: LanguageModelSession = .init()
    @State private var isThinking: Bool = false
    @State private var prompt: String = ""
    @State private var images: [NSImage] = []
    @State private var conversation: [ConversationContent] = []
    var body: some View {
        ScrollView {
            ForEach(conversation) { item in
                if item.isUser {
                    //user text
                } else {
                    //agent text
                }
            }
        }
        ChatInputView(isThinking: $isThinking, prompt: $prompt, images: $images) {
            self.conversation.append(ConversationContent(isUser: true, text: self.prompt))
            Task {
                await generateAnswer()
            }
        }
    }
}

@available(macOS 26.0, *)
extension FoundationModelChatView {
    private func generateAnswer() async -> Void {
        self.conversation.append(ConversationContent(isUser: false, text: ""))
        
        var temperature: Double = 0.8
        var responseStream: LanguageModelSession.ResponseStream<String>
        
        do {
            responseStream = self.foundationModelSession.streamResponse(to: self.prompt,
                                                         options: GenerationOptions(temperature: temperature))
            for try await partial in responseStream {
                guard var response = self.conversation.last else { return }
                response.text = partial
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
