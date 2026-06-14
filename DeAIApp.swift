import SwiftUI

@main
struct DeAIApp: App {
    @State private var appState = AppState()
    @State private var showLaunch = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunch {
                    LaunchView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showLaunch = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainView()
                        .environment(appState)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.6), value: showLaunch)
        }
    }
}
