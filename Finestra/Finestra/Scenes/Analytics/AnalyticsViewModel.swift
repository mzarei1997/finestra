//
//  AnalyticsViewModel.swift
//  Finestra
//

import Foundation
import Observation

@MainActor
@Observable
final class AnalyticsViewModel {
    let model = AnalyticsModel()
    private let sessionRepository: SessionRepositoryProtocol
    private(set) var sessions: [SessionModel] = []
    private(set) var errorMessage: String?
    var editingSession: SessionModel?

    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
        loadSessions()
    }

    func loadSessions() {
        do {
            sessions = try sessionRepository.loadAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ session: SessionModel) {
        do {
            try sessionRepository.delete(session)
            loadSessions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func update(_ session: SessionModel) {
        do {
            try sessionRepository.update(session)
            loadSessions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
