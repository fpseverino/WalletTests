import FluentWalletOrders
import Vapor
import VaporWalletOrders
import WalletOrders

struct OrderJSONData: OrderJSON.Properties {
    let schemaVersion = OrderJSON.SchemaVersion.v1
    let orderTypeIdentifier = Environment.get("ORDER_TYPE_IDENTIFIER")!
    let orderIdentifier: String
    let orderType = OrderJSON.OrderType.ecommerce
    let orderNumber = "HM090772020864"
    let createdAt: String
    let updatedAt: String
    let status = OrderJSON.OrderStatus.open
    let merchant: MerchantData
    let orderManagementURL = Environment.get("WEBSITE_URL")!
    let authenticationToken: String

    private let webServiceURL = "\(Environment.get("WEBSITE_URL")!)/api/orders/"

    struct MerchantData: OrderJSON.Merchant {
        let merchantIdentifier = "com.example.pet-store"
        let displayName: String
        let url = Environment.get("WEBSITE_URL")!
        let logo = "pet_store_logo.png"
    }

    init(data: OrderData, order: Order) {
        self.orderIdentifier = order.id!.uuidString
        self.authenticationToken = order.authenticationToken
        self.merchant = MerchantData(displayName: data.title)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = .withInternetDateTime
        self.createdAt = dateFormatter.string(from: order.createdAt!)
        self.updatedAt = dateFormatter.string(from: order.updatedAt!)
    }
}
