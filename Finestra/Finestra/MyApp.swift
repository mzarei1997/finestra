import SwiftUI

@main struct MyApp: App {
    @State private var appState = AppState(
        authManager: AuthManager(),
        userRepository: UserRepository()
    )
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(appState)
        }
    }
}
