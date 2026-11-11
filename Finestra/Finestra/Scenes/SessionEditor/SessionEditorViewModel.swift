//
//  SessionEditorViewModel.swift
//  Finestra
//

import Foundation
import Observation

@MainActor
@Observable
final class SessionEditorViewModel {
    private let session: SessionModel
    private let onSave: (SessionModel) -> Void

    var note: String
    var duration: Int
    var type: SessionType
    var scheduledFor: Date
    var startTime: Date
    var reminder: Int
    var priority: SessionPriority
    var status: SessionStatus

    init(
        session: SessionModel,
        onSave: @escaping (SessionModel) -> Void
    ) {
        self.session = session
        self.onSave = onSave
        note = session.note
        duration = session.duration
        type = session.type
        scheduledFor = session.scheduledFor
        startTime = session.startTime
        reminder = session.reminder
        priority = session.priority
        status = session.status
    }

    func save() {
        onSave(SessionModel(
            id: session.id,
            note: note,
            duration: duration,
            type: type,
            scheduledFor: scheduledFor,
            startTime: startTime,
            reminder: reminder,
            priority: priority,
            status: status
        ))
    }
}
