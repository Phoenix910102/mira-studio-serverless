import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: StudioViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.05, blue: 0.09), Color(red: 0.18, green: 0.05, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 0) {
                controlPanel
                    .frame(width: 430)
                Divider().overlay(Color.white.opacity(0.12))
                previewPanel
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $model.showingSettings) {
            SettingsView()
                .environmentObject(model)
        }
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Text("MIRA STUDIO")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("本機自然語言 · 按需租用 GPU")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 10) {
                Label("描述你想要的畫面", systemImage: "text.bubble.fill")
                    .font(.headline)
                TextEditor(text: $model.naturalLanguage)
                    .font(.system(size: 15))
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 180)
                    .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12)))
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("成人尺度")
                    .font(.headline)
                Picker("成人尺度", selection: $model.level) {
                    ForEach(AdultLevel.allCases) { level in
                        Text(level.label).tag(level)
                    }
                }
                .pickerStyle(.segmented)

                Text("所有模式固定為 28 歲虛構成人；禁止未成年、真人換臉與非自願情境。")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.52))
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("畫布")
                    .font(.headline)
                Picker("畫布", selection: $model.canvas) {
                    ForEach(CanvasPreset.allCases) { preset in
                        Text(preset.label).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Circle()
                        .fill(model.isConfigured ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                    Text(model.status)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(3)
                    Spacer()
                    Button {
                        model.showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .buttonStyle(.plain)
                }

                Button(action: model.generate) {
                    HStack {
                        if model.isGenerating {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(model.isGenerating ? "生成中…" : "生成圖片")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.72, green: 0.12, blue: 0.30))
                .disabled(model.isGenerating || model.naturalLanguage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(30)
    }

    private var previewPanel: some View {
        VStack(spacing: 18) {
            Spacer()
            if let image = model.resultImage {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.5), radius: 30)
                    .padding(34)

                Button("在 Finder 顯示", action: model.revealResult)
                    .buttonStyle(.bordered)
            } else {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 74, weight: .thin))
                    .foregroundStyle(.white.opacity(0.22))
                Text("生成結果會顯示在這裡")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
                Text("只有按下生成時才會喚醒遠端 GPU")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.35))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var model: StudioViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("RunPod Serverless 設定")
                .font(.title2.bold())

            Text("Endpoint ID")
                .font(.headline)
            TextField("例如 abcdef123456", text: $model.endpointID)
                .textFieldStyle(.roundedBorder)

            Text("API Key")
                .font(.headline)
            SecureField(model.hasSavedAPIKey ? "已安全存於 macOS 鑰匙圈；留空可保留" : "輸入 RunPod API Key", text: $model.apiKeyDraft)
                .textFieldStyle(.roundedBorder)

            Label("API Key 不會寫入專案檔案，只儲存在這台 Mac 的鑰匙圈。", systemImage: "lock.shield.fill")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button("取消") { model.showingSettings = false }
                Button("儲存") { model.saveSettings() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(28)
        .frame(width: 520)
    }
}
