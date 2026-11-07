//
//  DatabaseManager.swift
//  Finestra
//

import SwiftData

@MainActor
protocol DatabaseManagerProtocol {
    func fetch<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>
    ) throws -> Model?
    func fetchAll<Model: PersistentModel>(_ type: Model.Type) throws -> [Model]
    func add<Model: PersistentModel>(_ model: Model) throws
    func addAll<Model: PersistentModel>(_ models: [Model]) throws
    func remove<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>
    ) throws
    func removeAll<Model: PersistentModel>(_ type: Model.Type) throws
    func save() throws
    func update<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>,
        updates: (Model) -> Void
    ) throws
}

@MainActor
final class DatabaseManager: DatabaseManagerProtocol {
    private let modelContext: ModelContext

    init(
        modelTypes: [any PersistentModel.Type],
        configurations: [ModelConfiguration] = []
    ) throws {
        let schema = Schema(modelTypes)
        let container = try ModelContainer(for: schema, configurations: configurations)
        modelContext = ModelContext(container)
    }

    func fetch<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>
    ) throws -> Model? {
        try fetchAll(type).first { $0[keyPath: keyPath] == primaryKey }
    }

    func fetchAll<Model: PersistentModel>(_ type: Model.Type) throws -> [Model] {
        try modelContext.fetch(FetchDescriptor<Model>())
    }

    func add<Model: PersistentModel>(_ model: Model) throws {
        modelContext.insert(model)
        try modelContext.save()
    }

    func addAll<Model: PersistentModel>(_ models: [Model]) throws {
        models.forEach(modelContext.insert)
        try modelContext.save()
    }

    func remove<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>
    ) throws {
        if let model = try fetch(type, primaryKey: primaryKey, keyPath: keyPath) {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    func removeAll<Model: PersistentModel>(_ type: Model.Type) throws {
        try fetchAll(type).forEach(modelContext.delete)
        try modelContext.save()
    }

    func save() throws {
        try modelContext.save()
    }
    
    func update<Model: PersistentModel, Key: Equatable>(
        _ type: Model.Type,
        primaryKey: Key,
        keyPath: KeyPath<Model, Key>,
        updates: (Model) -> Void
    ) throws {
        guard let model = try fetch(
            type,
            primaryKey: primaryKey,
            keyPath: keyPath
        ) else {
            return
        }

        updates(model)
        try modelContext.save()
    }
}
