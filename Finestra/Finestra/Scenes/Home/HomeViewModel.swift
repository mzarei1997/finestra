//
//  HomeViewModel.swift
//  Finestra
//
//  Created by Mohammadreza on 11/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let sessionRepository: SessionRepositoryProtocol
    private(set) var sessions: [SessionModel] = []
    private(set) var activeSessions: [ActiveSession] = []
    private(set) var errorMessage: String?
    
    var dates: Set<DateComponents> = []
    var priority: SessionPriority = .medium
    var sessionType: SessionType = .study
    var quickStartTimer: Int = 5
    var noteText: String = ""
    private(set) var quickStartRemainingSeconds: Int = 0
    private(set) var quickStartEndDate: Date?
    var duration: Int = 20
    var isDurationPickerPresented: Bool = false
    var isDatePickerPresented: Bool = false
    var isQuickStartTimerPresented: Bool = false
    var isQuickStartRunning: Bool { quickStartEndDate != nil }
    var quickStartProgress: Double {
        guard quickStartTimer > 0 else { return 0 }
        return min(
            max(Double(quickStartRemainingSeconds) / Double(quickStartTimer * 60), 0),
            1
        )
    }
    var formattedDates: [Date] {
        dates
             .compactMap { Calendar.current.date(from: $0) }
             .sorted()
    }
    
    private var quickStartTimerSource: Timer?

    init(sessionRepository: SessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
        loadSessions()
    }

    func saveNewSession() {
        guard !formattedDates.isEmpty else { return }

        do {
            try formattedDates.forEach { date in
                let session = SessionModel(
                    note: noteText,
                    duration: duration,
                    type: sessionType,
                    scheduledFor: date,
                    startTime: Date.now,
                    reminder: 10,
                    priority: priority
                )
                try sessionRepository.save(session)
            }
            loadSessions()
            dates.removeAll()
            noteText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func quickStart() {
        guard !isQuickStartRunning, quickStartTimer > 0 else { return }
        
        let endDate = Date().addingTimeInterval(TimeInterval(quickStartTimer * 60))
        quickStartRemainingSeconds = quickStartTimer * 60
        quickStartEndDate = endDate
        activeSessions.append(ActiveSession(
            id: "quick-start",
            title: "Quick session",
            endDate: endDate,
            durationSeconds: quickStartTimer * 60
        ))
        isQuickStartTimerPresented = false
        startQuickStartTimer()
    }

    func stopQuickStart() {
        guard isQuickStartRunning else { return }
        quickStartEndDate = nil
        quickStartRemainingSeconds = 0
        activeSessions.removeAll { $0.id == "quick-start" }
        if activeSessions.isEmpty {
            quickStartTimerSource?.invalidate()
            quickStartTimerSource = nil
        }
    }

    func start(_ session: SessionModel) {
        guard !activeSessions.contains(where: { $0.id == session.id }) else { return }
        let durationSeconds = session.duration * 60
        activeSessions.append(ActiveSession(
            id: session.id,
            title: session.type.rawValue.capitalized,
            endDate: Date().addingTimeInterval(TimeInterval(durationSeconds)),
            durationSeconds: durationSeconds
        ))
        startQuickStartTimer()
    }

    func stop(_ activeSession: ActiveSession) {
        activeSessions.removeAll { $0.id == activeSession.id }
        if activeSession.id == "quick-start" {
            stopQuickStart()
        } else if activeSessions.isEmpty {
            quickStartTimerSource?.invalidate()
            quickStartTimerSource = nil
        }
    }

    func loadSessions() {
        do {
            sessions = try sessionRepository.loadAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func startQuickStartTimer() {
        quickStartTimerSource?.invalidate()
        quickStartTimerSource = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.updateActiveSessions()
        }
        updateActiveSessions()
    }

    private func updateActiveSessions() {
        activeSessions = activeSessions.compactMap { activeSession in
            guard activeSession.endDate > .now else { return nil }
            return activeSession
        }

        if let endDate = quickStartEndDate {
            quickStartRemainingSeconds = max(0, Int(ceil(endDate.timeIntervalSinceNow)))
        }
        if quickStartEndDate != nil, !activeSessions.contains(where: { $0.id == "quick-start" }) {
            stopQuickStart()
        } else if activeSessions.isEmpty {
            quickStartTimerSource?.invalidate()
            quickStartTimerSource = nil
        }
    }

    var quickStartTimeString: String {
        let minutes = quickStartRemainingSeconds / 60
        let seconds = quickStartRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var todaysSessions: [SessionModel] {
        sessions.filter { Calendar.current.isDateInToday($0.scheduledFor) }
    }
}

struct ActiveSession: Identifiable {
    let id: String
    let title: String
    let endDate: Date
    let durationSeconds: Int

    func remainingSeconds(at date: Date) -> Int {
        max(0, Int(ceil(endDate.timeIntervalSince(date))))
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
