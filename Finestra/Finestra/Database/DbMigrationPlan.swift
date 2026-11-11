//
//  DbMigrationPlan.swift
//  Finestra
//
//  Created by Mohammadreza on 11/11/26.
//

import Foundation
import SwiftData

enum MigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
          [SchemaV1.self, SchemaV2.self]
      }

      static var stages: [MigrationStage] {
          [
              MigrationStage.lightweight(
                  fromVersion: SchemaV1.self,
                  toVersion: SchemaV2.self
              )
          ]
      }
}

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [SessionDatabaseModel.self, UserDatabaseModel.self]
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [SessionDatabaseModel.self, UserDatabaseModel.self]
    }
}
