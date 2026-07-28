import AppKit
import Foundation
import SwiftUI

@MainActor
final class StudioViewModel: ObservableObject {
    @Published var naturalLanguage = "蜜菈穿著黑紅色高衩晚禮服，在豪華飯店房間自信地看向鏡頭，動漫寫實風、柔光、全身"
    @Published var level: AdultLevel = .glamour
    @Published var canvas: CanvasPreset = .portrait
    @Published var endpointID = UserDefaults.standard.string(forKey: "runpodEndpointID") ?? ""
    @Published var apiKeyDraft = ""
    @Published var isGenerating = false
    @Published var status = "等待設定 RunPod Serverless"
    @Published var resultImage: NSImage?
    @Published var resultURL: URL?
    @Published var showingSettings = false

    var hasSavedAPIKey: Bool { KeychainStore.loadAPIKey()?.isEmpty == false }
    var isConfigured: Bool { !endpointID.trimmingCharacters(in: .whitespaces).isEmpty && hasSavedAPIKey }

    func saveSettings() {
        let trimmedEndpoint = endpointID.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmedEndpoint, forKey: "runpodEndpointID")
        do {
            if !apiKeyDraft.isEmpty {
                try KeychainStore.saveAPIKey(apiKeyDraft)
                apiKeyDraft = ""
            }
            status = isConfigured ? "已連接；閒置時不會啟動 GPU" : "請完成 Endpoint 與 API Key 設定"
            showingSettings = false
            objectWillChange.send()
        } catch {
            status = error.localizedDescription
        }
    }

    func generate() {
        guard !isGenerating else { return }
        guard let apiKey = KeychainStore.loadAPIKey(), isConfigured else {
            status = StudioError.missingSettings.localizedDescription
            showingSettings = true
            return
        }

        isGenerating = true
        resultImage = nil
        resultURL = nil
        status = "正在喚醒租賃 GPU；冷啟動可能需要數十秒……"

        Task {
            do {
                let compiled = try PromptCompiler().compile(naturalLanguage, level: level)
                let workflow = try WorkflowBuilder().build(
                    prompt: compiled,
                    canvas: canvas,
                    seed: UInt64.random(in: 1...UInt64.max - 1)
                )
                status = "GPU 已接收工作，正在生成精緻圖片……"
                let url = try await RunPodClient().generate(
                    endpointID: endpointID,
                    apiKey: apiKey,
                    workflow: workflow
                )
                resultURL = url
                resultImage = NSImage(contentsOf: url)
                status = "完成。圖片已存入「圖片／Mira Studio」。GPU 將依閒置設定自動關閉。"
            } catch {
                status = error.localizedDescription
            }
            isGenerating = false
        }
    }

    func revealResult() {
        guard let resultURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([resultURL])
    }
}
