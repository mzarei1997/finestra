import Foundation
import Observation

@MainActor
@Observable
final class MenuViewModel {
    let model = MenuModel(greeting: "Good morning", featuredSport: "Your next challenge")
    let sessionRepository: SessionRepositoryProtocol

    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }
}
