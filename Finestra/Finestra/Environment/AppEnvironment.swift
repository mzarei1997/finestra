import Foundation

struct AppEnvironment {
    let apiBaseURL: URL
    let userDefaultsKeys: UserDefaultsKeys

    static let live = AppEnvironment(
        apiBaseURL: URL(string: "https://api.example.com")!,
        userDefaultsKeys: .init()
    )
    
    static let accessToken = "user-access-token-credentials"
}

struct UserDefaultsKeys {
    let hasCompletedOnboarding = "hasCompletedOnboarding"
}
