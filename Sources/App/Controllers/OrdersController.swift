import Fluent
import Orders
import Vapor

struct OrdersController: RouteCollection {
    let ordersService: OrdersService<OrderData>

    func boot(routes: RoutesBuilder) throws {
        let orders = routes.grouped("orders")

        orders.get(use: self.index)
        orders.post(use: self.create)
        orders.group(":orderID") { order in
            order.delete(use: self.delete)
            order.put(use: self.update)
            order.get(use: self.orderHandler)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [OrderDataDTO] {
        try await OrderData.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> OrderDataDTO {
        let orderData = try req.content.decode(OrderDataDTO.self).toModel()

        try await orderData.save(on: req.db)
        return orderData.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let orderData = try await OrderData.find(req.parameters.get("orderID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await orderData.delete(on: req.db)
        return .noContent
    }

    @Sendable
    func update(req: Request) async throws -> OrderDataDTO {
        let orderData = try req.content.decode(OrderDataDTO.self).toModel()

        guard let order = try await OrderData.find(req.parameters.get("orderID"), on: req.db) else {
            throw Abort(.notFound)
        }

        order.title = orderData.title
        try await order.save(on: req.db)
        return order.toDTO()
    }

    @Sendable
    func orderHandler(req: Request) async throws -> Response {
        guard let order = try await OrderData.find(req.parameters.get("orderID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let bundle = try await ordersService.build(order: order, on: req.db)

        let body = Response.Body(data: bundle)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/vnd.apple.order")
        headers.add(name: .contentDisposition, value: "attachment; filename=name.order")
        headers.lastModified = try await HTTPHeaders.LastModified(order.$order.get(on: req.db).updatedAt ?? Date.distantPast)
        headers.add(name: .contentTransferEncoding, value: "binary")
        return Response(status: .ok, headers: headers, body: body)
    }
}
