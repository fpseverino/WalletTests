import Fluent
import Orders

struct CreateOrderData: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(OrderData.FieldKeys.schemaName)
            .id()
            .field(OrderData.FieldKeys.title, .string, .required)
            .field(
                OrderData.FieldKeys.orderID, .uuid, .required,
                .references(Order.schema, .id, onDelete: .cascade)
            )
            .unique(on: OrderData.FieldKeys.orderID)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(OrderData.FieldKeys.schemaName).delete()
    }
}

extension OrderData {
    enum FieldKeys {
        static let schemaName = "order_data"
        static let title = FieldKey(stringLiteral: "title")
        static let orderID = FieldKey(stringLiteral: "order_id")
    }
}
