//
//  SessionRepository.swift
//  Finestra
//

import Foundation

@MainActor
protocol SessionRepositoryProtocol {
    func save(_ session: SessionModel) throws
    func loadAll() throws -> [SessionModel]
    func update(_ session: SessionModel) throws
    func delete(_ session: SessionModel) throws
}

@MainActor
final class SessionRepository: SessionRepositoryProtocol {
    private let databaseManager: DatabaseManagerProtocol

    init(databaseManager: DatabaseManagerProtocol) {
        self.databaseManager = databaseManager
    }

    func save(_ session: SessionModel) throws {
        let databaseModel = SessionDatabaseModel(
            id: session.id,
            note: session.note,
            duration: session.duration,
            type: session.type.rawValue,
            scheduledFor: session.scheduledFor,
            priority: session.priority.rawValue
        )
        try databaseManager.add(databaseModel)
    }

    func loadAll() throws -> [SessionModel] {
        try databaseManager
            .fetchAll(SessionDatabaseModel.self)
            .map(makeModel)
            .sorted { $0.scheduledFor  < $1.scheduledFor }
    }

    func update(_ session: SessionModel) throws {
        try databaseManager.update(
            SessionDatabaseModel.self,
            primaryKey: session.id,
            keyPath: \.id
        ) { databaseModel in
            databaseModel.note = session.note
            databaseModel.duration = session.duration
            databaseModel.type = session.type.rawValue
            databaseModel.scheduledFor = session.scheduledFor
            databaseModel.priority = session.priority.rawValue
        }
    }

    func delete(_ session: SessionModel) throws {
        try databaseManager.remove(
            SessionDatabaseModel.self,
            primaryKey: session.id,
            keyPath: \.id
        )
    }

    private func makeModel(from session: SessionDatabaseModel) -> SessionModel {
        SessionModel(
            id: session.id,
            note: session.note,
            duration: session.duration,
            type: SessionType(rawValue: session.type) ?? .custom,
            scheduledFor: session.scheduledFor,
            priority: SessionPriority(rawValue: session.priority) ?? .medium
        )
    }
}
