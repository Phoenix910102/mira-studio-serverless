import SwiftUI

@main
struct MiraStudioApp: App {
    @StateObject private var viewModel = StudioViewModel()

    var body: some Scene {
        WindowGroup("Mira Studio") {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 1080, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
