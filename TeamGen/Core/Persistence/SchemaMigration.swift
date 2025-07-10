import Foundation
import SwiftData

// MARK: - Schema Versioning with Proper Model Finalization
enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    // Use static model array to prevent checksum issues
    static var models: [any PersistentModel.Type] {
        [PlayerV1.self]
    }

    @Model
    final class PlayerV1 {
        @Attribute(.unique) var id: UUID
        var name: String
        var rank: Int
        var isSelected: Bool
        var createdAt: Date
        var updatedAt: Date

        init(name: String, rank: Int) {
            self.id = UUID()
            self.name = name
            self.rank = min(max(rank, 1), 10)
            self.isSelected = false
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
}

enum SchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    // Use static model array to prevent checksum issues
    static var models: [any PersistentModel.Type] {
        [PlayerV2.self]
    }

    // Define V2 model explicitly to avoid conflicts
    @Model
    final class PlayerV2 {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date

        // Multi-dimensional skill attributes with proper defaults
        var technicalSkill: Int = 5
        var fitnessLevel: Int = 5
        var teamworkRating: Int = 5

        // Computed overall rank
        var overallRank: Double {
            Double(technicalSkill + fitnessLevel + teamworkRating) / 3.0
        }

        // Selection state with default
        var isSelected: Bool = false

        // Stats tracking with defaults
        var gamesPlayed: Int = 0
        var teamsJoined: Int = 0

        init(name: String, technicalSkill: Int = 5, fitnessLevel: Int = 5, teamworkRating: Int = 5) {
            self.id = UUID()
            self.name = name
            self.createdAt = Date()
            self.updatedAt = Date()
            self.technicalSkill = min(max(technicalSkill, 1), 10)
            self.fitnessLevel = min(max(fitnessLevel, 1), 10)
            self.teamworkRating = min(max(teamworkRating, 1), 10)
            self.isSelected = false
            self.gamesPlayed = 0
            self.teamsJoined = 0
        }
    }
}

enum SchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)

    // Use static model array to prevent checksum issues
    static var models: [any PersistentModel.Type] {
        [PlayerV3.self]
    }

    // Define V3 model with four-skill system
    @Model
    final class PlayerV3 {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date

        // Four-dimensional skill attributes with proper defaults
        var technicalSkill: Int = 5
        var agilityLevel: Int = 5
        var enduranceLevel: Int = 5
        var teamworkRating: Int = 5

        // Computed overall rank
        var overallRank: Double {
            Double(technicalSkill + agilityLevel + enduranceLevel + teamworkRating) / 4.0
        }

        // Selection state with default
        var isSelected: Bool = false

        // Stats tracking with defaults
        var gamesPlayed: Int = 0
        var teamsJoined: Int = 0

        init(name: String, technicalSkill: Int = 5, agilityLevel: Int = 5, enduranceLevel: Int = 5, teamworkRating: Int = 5) {
            self.id = UUID()
            self.name = name
            self.createdAt = Date()
            self.updatedAt = Date()
            self.technicalSkill = min(max(technicalSkill, 1), 10)
            self.agilityLevel = min(max(agilityLevel, 1), 10)
            self.enduranceLevel = min(max(enduranceLevel, 1), 10)
            self.teamworkRating = min(max(teamworkRating, 1), 10)
            self.isSelected = false
            self.gamesPlayed = 0
            self.teamsJoined = 0
        }
    }
}

// MARK: - Migration Plan with Lightweight Migration
enum PlayerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self, SchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2, migrateV2toV3]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SchemaV1.self,
        toVersion: SchemaV2.self
    )

    static let migrateV2toV3 = MigrationStage.custom(
        fromVersion: SchemaV2.self,
        toVersion: SchemaV3.self,
        willMigrate: { context in
            // Custom migration to split fitness into agility and endurance
            let players = try context.fetch(FetchDescriptor<SchemaV2.PlayerV2>())

            for player in players {
                // Create new V3 player with fitness split into agility and endurance
                let newPlayer = SchemaV3.PlayerV3(
                    name: player.name,
                    technicalSkill: player.technicalSkill,
                    agilityLevel: player.fitnessLevel, // Map fitness to agility
                    enduranceLevel: player.fitnessLevel, // Map fitness to endurance
                    teamworkRating: player.teamworkRating
                )

                // Preserve metadata
                newPlayer.id = player.id
                newPlayer.createdAt = player.createdAt
                newPlayer.updatedAt = player.updatedAt
                newPlayer.isSelected = player.isSelected
                newPlayer.gamesPlayed = player.gamesPlayed
                newPlayer.teamsJoined = player.teamsJoined

                context.insert(newPlayer)
            }
        },
        didMigrate: nil
    )
}

// MARK: - Extension for V2 Entity Conversion (Legacy Support)
extension SchemaV2.PlayerV2 {
    func toEntity() -> PlayerEntity {
        PlayerEntity(
            id: self.id,
            name: self.name,
            skills: PlayerSkills(
                technical: self.technicalSkill,
                agility: self.fitnessLevel, // Map fitness to agility for legacy support
                endurance: self.fitnessLevel, // Map fitness to endurance for legacy support
                teamwork: self.teamworkRating
            ),
            statistics: PlayerStatistics(
                gamesPlayed: self.gamesPlayed,
                teamsJoined: self.teamsJoined
            ),
            isSelected: self.isSelected
        )
    }

    func updateFromEntity(_ entity: PlayerEntity) {
        self.name = entity.name
        self.technicalSkill = entity.skills.technical
        self.fitnessLevel = (entity.skills.agility + entity.skills.endurance) / 2 // Average for legacy
        self.teamworkRating = entity.skills.teamwork
        self.isSelected = entity.isSelected
        self.gamesPlayed = entity.statistics.gamesPlayed
        self.teamsJoined = entity.statistics.teamsJoined
        self.updatedAt = Date()
    }
}

// MARK: - Extension for V3 Entity Conversion
extension SchemaV3.PlayerV3 {
    func toEntity() -> PlayerEntity {
        PlayerEntity(
            id: self.id,
            name: self.name,
            skills: PlayerSkills(
                technical: self.technicalSkill,
                agility: self.agilityLevel,
                endurance: self.enduranceLevel,
                teamwork: self.teamworkRating
            ),
            statistics: PlayerStatistics(
                gamesPlayed: self.gamesPlayed,
                teamsJoined: self.teamsJoined
            ),
            isSelected: self.isSelected
        )
    }

    func updateFromEntity(_ entity: PlayerEntity) {
        self.name = entity.name
        self.technicalSkill = entity.skills.technical
        self.agilityLevel = entity.skills.agility
        self.enduranceLevel = entity.skills.endurance
        self.teamworkRating = entity.skills.teamwork
        self.isSelected = entity.isSelected
        self.gamesPlayed = entity.statistics.gamesPlayed
        self.teamsJoined = entity.statistics.teamsJoined
        self.updatedAt = Date()
    }
}

// MARK: - Model Mapping Extensions for V3
extension SchemaV3.PlayerV3 {
    static func from(_ entity: PlayerEntity) -> SchemaV3.PlayerV3 {
        let player = SchemaV3.PlayerV3(
            name: entity.name,
            technicalSkill: entity.skills.technical,
            agilityLevel: entity.skills.agility,
            enduranceLevel: entity.skills.endurance,
            teamworkRating: entity.skills.teamwork
        )
        player.id = entity.id
        player.isSelected = entity.isSelected
        player.gamesPlayed = entity.statistics.gamesPlayed
        player.teamsJoined = entity.statistics.teamsJoined
        return player
    }
}