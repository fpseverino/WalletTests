import Fluent
import VaporWalletPasses
import Vapor

struct PassesController: RouteCollection {
    let passesService: PassesService<PassData>

    func boot(routes: RoutesBuilder) throws {
        let passes = routes.grouped("passes")

        passes.get(use: self.index)
        passes.post(use: self.create)
        passes.group(":passID") { pass in
            pass.delete(use: self.delete)
            pass.put(use: self.update)
            pass.get(use: self.passHandler)
        }
        passes.get("all", use: self.passesHandler)
    }

    @Sendable
    func index(req: Request) async throws -> [PassDataDTO] {
        try await PassData.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> PassDataDTO {
        let passData = try req.content.decode(PassDataDTO.self).toModel()

        try await passData.save(on: req.db)
        return passData.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let passData = try await PassData.find(req.parameters.get("passID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await passData.delete(on: req.db)
        return .noContent
    }

    @Sendable
    func update(req: Request) async throws -> PassDataDTO {
        let passData = try req.content.decode(PassDataDTO.self).toModel()

        guard let pass = try await PassData.find(req.parameters.get("passID"), on: req.db) else {
            throw Abort(.notFound)
        }

        pass.title = passData.title
        try await pass.save(on: req.db)
        return pass.toDTO()
    }

    @Sendable
    func passHandler(req: Request) async throws -> Response {
        guard let pass = try await PassData.find(req.parameters.get("passID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let bundle = try await passesService.build(pass: pass, on: req.db)

        let body = Response.Body(data: bundle)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/vnd.apple.pkpass")
        headers.add(name: .contentDisposition, value: "attachment; filename=name.pkpass")
        headers.lastModified = try await HTTPHeaders.LastModified(pass.$pass.get(on: req.db).updatedAt ?? Date.distantPast)
        headers.add(name: .contentTransferEncoding, value: "binary")
        return Response(status: .ok, headers: headers, body: body)
    }

    @Sendable
    func passesHandler(req: Request) async throws -> Response {
        let passes = try await PassData.query(on: req.db).with(\.$pass).all()
        let bundle = try await passesService.build(passes: passes, on: req.db)

        let body = Response.Body(data: bundle)
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/vnd.apple.pkpasses")
        headers.add(name: .contentDisposition, value: "attachment; filename=name.pkpasses")
        headers.lastModified = HTTPHeaders.LastModified(Date())
        headers.add(name: .contentTransferEncoding, value: "binary")
        return Response(status: .ok, headers: headers, body: body)
    }
}
