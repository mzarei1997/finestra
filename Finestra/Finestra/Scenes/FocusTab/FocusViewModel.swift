//
//  FocusViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/11/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class FocusViewModel {
    private let sessionRepository: SessionRepositoryProtocol
    private(set) var sessions: [SessionModel] = []
    private(set) var errorMessage: String?
    private(set) var activeSessions: [ActiveSession] = []
    private var activeSessionsTimer: Timer?

    var todaysSessions: [SessionModel] {
        sessions.filter {
            Calendar.current.isDateInToday($0.scheduledFor) &&
            !nearbySessionIDs.contains($0.id) &&
            !activeSessionIDs.contains($0.id)
        }
    }

    var upcomingSessions: [SessionModel] {
        sessions.filter {
            !Calendar.current.isDateInToday($0.scheduledFor) &&
            !nearbySessionIDs.contains($0.id) &&
            !activeSessionIDs.contains($0.id) &&
            sessionStartDate(for: $0) >= Calendar.current.startOfDay(for: .now)
        }
    }

    var historySessions: [SessionModel] {
        sessions.filter {
            !Calendar.current.isDateInToday($0.scheduledFor) &&
            sessionStartDate(for: $0) < Calendar.current.startOfDay(for: .now)
        }
    }

    var nearbySessions: [SessionModel] {
        sessions
            .filter { session in
                guard session.reminder > 0 else { return false }
                guard session.status == .scheduled || session.status == .postponed else {
                    return false
                }
                guard !activeSessionIDs.contains(session.id) else { return false }
                let remainingTime = sessionStartDate(for: session).timeIntervalSinceNow
                return remainingTime >= 0 &&
                    remainingTime <= TimeInterval(session.reminder * 60)
            }
            .sorted { sessionStartDate(for: $0) < sessionStartDate(for: $1) }
    }

    private var activeSessionIDs: Set<String> {
        Set(activeSessions.map(\.id))
    }

    private var nearbySessionIDs: Set<String> {
        Set(
            sessions
                .filter { session in
                    guard session.reminder > 0,
                          session.status == .scheduled || session.status == .postponed,
                          !activeSessionIDs.contains(session.id) else {
                        return false
                    }
                    let remainingTime = sessionStartDate(for: session).timeIntervalSinceNow
                    return remainingTime >= 0 &&
                        remainingTime <= TimeInterval(session.reminder * 60)
                }
                .map(\.id)
        )
    }

    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    func loadSessions() {
        do {
            sessions = try sessionRepository.loadAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func start(_ session: SessionModel) {
        guard !activeSessions.contains(where: { $0.id == session.id }) else { return }
        let durationSeconds = session.duration * 60
        activeSessions.append(ActiveSession(
            id: session.id,
            title: session.type.rawValue.capitalized,
            endDate: Date().addingTimeInterval(TimeInterval(durationSeconds)),
            durationSeconds: durationSeconds,
            remainingDuration: durationSeconds
        ))
        updateStatus(.inProgress, for: session)
        startActiveSessionsTimer()
    }

    func stop(_ activeSession: ActiveSession) {
        activeSessions.removeAll { $0.id == activeSession.id }
        if let session = sessions.first(where: { $0.id == activeSession.id }) {
            updateStatus(.scheduled, for: session)
        }
        stopActiveSessionsTimerIfNeeded()
    }

    func togglePause(_ activeSession: ActiveSession) {
        guard let index = activeSessions.firstIndex(where: { $0.id == activeSession.id }) else {
            return
        }

        if activeSessions[index].isPaused {
            activeSessions[index].endDate = Date().addingTimeInterval(
                TimeInterval(activeSessions[index].remainingDuration)
            )
            activeSessions[index].isPaused = false
        } else {
            activeSessions[index].remainingDuration =
                activeSessions[index].remainingSeconds(at: .now)
            activeSessions[index].isPaused = true
        }

        startActiveSessionsTimer()
    }

    private func startActiveSessionsTimer() {
        activeSessionsTimer?.invalidate()
        activeSessionsTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.updateActiveSessions()
        }
        updateActiveSessions()
    }

    private func updateActiveSessions() {
        let completedIDs = activeSessions.compactMap { activeSession -> String? in
            guard !activeSession.isPaused, activeSession.endDate <= .now else {
                return nil
            }
            return activeSession.id
        }

        activeSessions = activeSessions.filter { activeSession in
            activeSession.isPaused || activeSession.endDate > .now
        }
        completedIDs.forEach { id in
            guard let session = sessions.first(where: { $0.id == id }) else { return }
            updateStatus(.finished, for: session)
        }

        stopActiveSessionsTimerIfNeeded()
    }

    private func updateStatus(_ status: SessionStatus, for session: SessionModel) {
        guard session.status != status else { return }
        let updatedSession = session.withStatus(status)
        do {
            try sessionRepository.update(updatedSession)
            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                sessions[index] = updatedSession
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func stopActiveSessionsTimerIfNeeded() {
        guard activeSessions.isEmpty else { return }
        activeSessionsTimer?.invalidate()
        activeSessionsTimer = nil
    }

    private func sessionStartDate(for session: SessionModel) -> Date {
        let calendar = Calendar.current
        let day = calendar.dateComponents([.year, .month, .day], from: session.scheduledFor)
        let time = calendar.dateComponents([.hour, .minute], from: session.startTime)
        return calendar.date(
            from: DateComponents(
                year: day.year,
                month: day.month,
                day: day.day,
                hour: time.hour,
                minute: time.minute
            )
        ) ?? session.scheduledFor
    }

    isolated deinit {
        activeSessionsTimer?.invalidate()
    }
}

private extension SessionModel {
    func withStatus(_ status: SessionStatus) -> SessionModel {
        SessionModel(
            id: id,
            note: note,
            duration: duration,
            type: type,
            scheduledFor: scheduledFor,
            startTime: startTime,
            reminder: reminder,
            priority: priority,
            status: status
        )
    }
}

struct ActiveSession: Identifiable {
    let id: String
    let title: String
    var endDate: Date
    let durationSeconds: Int
    var remainingDuration: Int
    var isPaused = false

    func remainingSeconds(at date: Date) -> Int {
        if isPaused {
            return remainingDuration
        }
        return max(0, Int(ceil(endDate.timeIntervalSince(date))))
    }

    func progress(at date: Date) -> Double {
        guard durationSeconds > 0 else { return 0 }
        return min(
            max(Double(remainingSeconds(at: date)) / Double(durationSeconds), 0),
            1
        )
    }

    func timeString(at date: Date) -> String {
        let remaining = remainingSeconds(at: date)
        return String(format: "%02d:%02d", remaining / 60, remaining % 60)
    }
}
