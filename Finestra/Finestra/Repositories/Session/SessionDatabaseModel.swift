//
//  SessionDatabaseModel.swift
//  Finestra
//

import SwiftData
import SwiftUI

@Model
final class SessionDatabaseModel {
    @Attribute(.unique) var id: String
    var note: String
    var duration: Int
    var type: String
    var scheduledFor: Date
    var startTime: Date?
    var reminder: Int = 10
    var priority: String
    var status: SessionStatus = SessionStatus.scheduled
    
    init(
        id: String,
        note: String,
        duration: Int,
        type: String,
        scheduledFor: Date,
        startTime: Date,
        reminder: Int,
        priority: String,
        status: SessionStatus
    ) {
        self.id = id
        self.note = note
        self.duration = duration
        self.type = type
        self.scheduledFor = scheduledFor
        self.reminder = reminder
        self.startTime = startTime
        self.priority = priority
        self.status = status
    }
}

struct SessionModel: Identifiable {
    let id: String
    let note: String
    let duration: Int
    let type: SessionType
    let scheduledFor: Date
    let startTime: Date
    let reminder: Int
    let priority: SessionPriority
    let status: SessionStatus
    
    init(
        id: String = UUID().uuidString,
        note: String,
        duration: Int,
        type: SessionType,
        scheduledFor: Date,
        startTime: Date,
        reminder: Int,
        priority: SessionPriority,
        status: SessionStatus
    ) {
        self.id = id
        self.note = note
        self.duration = duration
        self.type = type
        self.scheduledFor = scheduledFor
        self.startTime = startTime
        self.reminder = reminder
        self.priority = priority
        self.status = status
    }
}

enum SessionStatus: String, CaseIterable, Codable {
    case scheduled
    case postponed
    case inProgress
    case cancelled
    case completed
    
    var color: Color {
        switch self {
        case .scheduled:
                .gray
        case .postponed:
                .orange
        case .inProgress:
                .green
        case .cancelled:
                .red
        case .completed:
                .blue
        }
    }
}
