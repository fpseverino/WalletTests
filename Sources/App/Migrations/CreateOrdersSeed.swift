import Fluent
import Orders

struct CreateOrdersSeed: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await OrderData(title: "Order")
            .create(on: database)
    }

    func revert(on database: any Database) async throws {
        try await OrderData.query(on: database)
            .filter(\.$title == "Order")
            .delete()
    }
}
