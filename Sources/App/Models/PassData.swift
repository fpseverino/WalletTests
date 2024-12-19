import Fluent
import Passes
import Vapor

final class PassData: PassDataModel, @unchecked Sendable {
    static let schema = PassData.FieldKeys.schemaName

    static let typeIdentifier = Environment.get("PASS_TYPE_IDENTIFIER")!

    @ID(key: .id)
    var id: UUID?

    @Field(key: PassData.FieldKeys.title)
    var title: String

    @Parent(key: PassData.FieldKeys.passID)
    var pass: Pass

    init() {}

    init(id: UUID? = nil, title: String) {
        self.id = id
        self.title = title
    }

    func toDTO() -> PassDataDTO {
        .init(
            id: self.id,
            title: self.$title.value
        )
    }
}

extension PassData {
    func passJSON(on db: any Database) async throws -> any PassJSON.Properties {
        try await PassJSONData(data: self, pass: self.$pass.get(on: db))
    }

    func template(on db: any Database) async throws -> String {
        "\(FileManager.default.currentDirectoryPath)/Templates/Passes/"
    }

    func personalizationJSON(on db: any Database) async throws -> PersonalizationJSON? {
        if self.title != "Personalize" { return nil }

        if try await self.$pass.get(on: db).$userPersonalization.get(on: db) == nil {
            return PersonalizationJSON(
                requiredPersonalizationFields: [.name, .postalCode, .emailAddress, .phoneNumber],
                description: "Hello, World!"
            )
        } else {
            return nil
        }
    }
}
