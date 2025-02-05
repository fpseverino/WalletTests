import Fluent
import VaporWalletOrders
import FluentWalletOrders
import WalletOrders
import Vapor

final class OrderData: OrderDataModel, @unchecked Sendable {
    static let schema = OrderData.FieldKeys.schemaName

    static let typeIdentifier = Environment.get("ORDER_TYPE_IDENTIFIER")!

    @ID(key: .id)
    var id: UUID?

    @Field(key: OrderData.FieldKeys.title)
    var title: String

    @Parent(key: OrderData.FieldKeys.orderID)
    var order: Order

    init() {}

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }

    func toDTO() -> OrderDataDTO {
        .init(
            id: self.id,
            title: self.$title.value
        )
    }
}

extension OrderData {
    func orderJSON(on db: any Database) async throws -> any OrderJSON.Properties {
        try await OrderJSONData(data: self, order: self.$order.get(on: db))
    }

    func sourceFilesDirectoryPath(on db: any Database) async throws -> String {
        "\(FileManager.default.currentDirectoryPath)/Templates/Orders"
    }
}
