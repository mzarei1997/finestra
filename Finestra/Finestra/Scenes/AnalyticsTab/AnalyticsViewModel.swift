//
//  AnalyticsViewModel.swift
//  Finestra
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class AnalyticsViewModel {
    let model = AnalyticsModel()
    private let sessionRepository: SessionRepositoryProtocol
    private(set) var sessions: [SessionModel] = []
    private(set) var errorMessage: String?
    var editingSession: SessionModel?
    var todayOrder: [String] = []
    
    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
        loadSessions()
    }
    
    func loadSessions() {
        do {
            sessions = try sessionRepository.loadAll()
            todayOrder = todayOrder.filter { id in
                sessions.contains { $0.id == id }
            }
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
    
    func updateStatus(_ status: SessionStatus, for session: SessionModel) {
        update(SessionModel(
            id: session.id,
            note: session.note,
            duration: session.duration,
            type: session.type,
            scheduledFor: session.scheduledFor,
            startTime: session.startTime,
            reminder: session.reminder,
            priority: session.priority,
            status: status
        ))
    }
    
    func moveTodaySessions(from offsets: IndexSet, to destination: Int) {
        var ids = orderedTodaySessions.map(\.id)
        ids.move(fromOffsets: offsets, toOffset: destination)
        todayOrder = ids
    }
    
    var orderedTodaySessions: [SessionModel] {
        let today = sessions.filter { Calendar.current.isDateInToday($0.scheduledFor) }
        let indexed = Dictionary(uniqueKeysWithValues: today.map { ($0.id, $0) })
        let ordered = todayOrder.compactMap { indexed[$0] }
        let remaining = today.filter { !todayOrder.contains($0.id) }
        return ordered + remaining
    }
    
    var upcomingSessions: [SessionModel] {
        sessions.filter {
            !Calendar.current.isDateInToday($0.scheduledFor) &&
            $0.scheduledFor >= Calendar.current.startOfDay(for: .now)
        }
    }
    
    var historySessions: [SessionModel] {
        sessions.filter {
            !Calendar.current.isDateInToday($0.scheduledFor) &&
            $0.scheduledFor < Calendar.current.startOfDay(for: .now)
        }
    }
}
