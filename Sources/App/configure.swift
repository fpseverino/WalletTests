import Fluent
import FluentSQLiteDriver
import Orders
import Passes
import Vapor

public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)

    // MARK: - Passes

    let passesService = try PassesService<PassData>(
        app: app,
        pemWWDRCertificate: Environment.get("PEM_WWDR_CERTIFICATE")!,
        pemCertificate: Environment.get("PASS_PEM_CERTIFICATE")!,
        pemPrivateKey: Environment.get("PASS_PEM_PRIVATE_KEY")!,
        pemPrivateKeyPassword: Environment.get("PASS_PEM_PRIVATE_KEY_PASSWORD")!
    )

    app.databases.middleware.use(passesService, on: .sqlite)

    try app.register(collection: PassesController(passesService: passesService))

    PassesService<PassData>.register(migrations: app.migrations)
    app.migrations.add(CreatePassData())
    app.migrations.add(CreatePasses())

    // MARK: - Orders

    let ordersService = try OrdersService<OrderData>(
        app: app,
        pemWWDRCertificate: Environment.get("PEM_WWDR_CERTIFICATE")!,
        pemCertificate: Environment.get("ORDER_PEM_CERTIFICATE")!,
        pemPrivateKey: Environment.get("ORDER_PEM_PRIVATE_KEY")!,
        pemPrivateKeyPassword: Environment.get("ORDER_PEM_PRIVATE_KEY_PASSWORD")!
    )

    app.databases.middleware.use(ordersService, on: .sqlite)

    try app.register(collection: OrdersController(ordersService: ordersService))

    OrdersService<OrderData>.register(migrations: app.migrations)
    app.migrations.add(CreateOrderData())
    app.migrations.add(CreateOrders())

    try await app.autoMigrate()

    try routes(app)
}
