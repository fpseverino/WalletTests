import Fluent
import VaporWalletPasses

struct CreatePassesSeed: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let passes = [
            PassData(title: "Personalize"),
            PassData(title: "Generic"),
        ]
        try await passes.create(on: database)
    }

    func revert(on database: any Database) async throws {
        try await PassData.query(on: database)
            .filter(\.$title == "Personalize")
            .delete()
        try await PassData.query(on: database)
            .filter(\.$title == "Generic")
            .delete()
    }
}
