//
//  ModelSelectView.swift
//  macLlama
//
//  Created by Minyoung Yoo on 5/13/25.
//

import SwiftUI

struct ModelSelectView: View {
    @EnvironmentObject var serverStatus: ServerStatus
    @Binding var modelList: [OllamaModel]
    @Binding var currentModel: String
    @Binding var isModelLoading: Bool
    
    let ollamaNetworkService: OllamaNetworkService
    let reloadButtonAction: () -> Void
    
    static var modelNameWithRemovedPrefix: (String) -> String? {
        { modelName in
            let pattern = "hf\\.co/[^/]+/"
            do{
                let regex = try NSRegularExpression(pattern: pattern)
                let range = NSRange(location: 0, length: modelName.utf8.count)
                return regex.stringByReplacingMatches(in: modelName, options: [], range: range, withTemplate: "")
            } catch {
                return nil
            }
        }
    }
    
    var body: some View {
        HStack{
            Circle()
                .fill(serverStatus.isOnline ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Picker("Current Model", selection: $currentModel) {
                ForEach(modelList, id: \.self) { model in
                    Text(ModelSelectView.modelNameWithRemovedPrefix(model.name) ?? "Unknown Model")
                        .foregroundStyle(.primary)
                        .tag(model.name)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(width: Units.appFrameMinWidth * 0.5)
            .onChange(of: currentModel) { oldValue, newValue in
                Task {
                    if !currentModel.isEmpty {
                        await self.ollamaNetworkService.changeModel(model: newValue)
                        UserDefaults.standard.set(newValue, forKey: "currentModel")
                    }
                }
            }
            .task {
                guard let lastModelUsed = UserDefaults.standard.string(forKey: "currentModel") else { return }
                if !lastModelUsed.isEmpty,
                   !currentModel.isEmpty {
                    await self.ollamaNetworkService.changeModel(model: lastModelUsed)
                    self.currentModel = lastModelUsed
                }
            }
            
            Button {
                withAnimation {
                    self.isModelLoading.toggle()
                }
                
                Task {
                    self.isModelLoading = true
                    
                    try? await serverStatus.updateServerStatus()
                    
                    if serverStatus.isOnline {
                        reloadButtonAction()
                    } else {
                        modelList.removeAll()
                        self.isModelLoading = false
                    }
                    
                    try? await serverStatus.updateServerStatus()
                    self.isModelLoading = false
                }
                
            } label: {
                VStack {
                    if self.isModelLoading {
                        Label("Loading...", systemImage: "rays")
                    } else {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                }
                .padding(.vertical, Units.normalGap / 8)
                .frame(idealWidth: 100)
            }
            .tint(.primary)
            .controlSize(.regular)
            .buttonStyle(.bordered)
        }
        .padding()
        .task {
            try? await serverStatus.updateServerStatus()
        }
    }
}
