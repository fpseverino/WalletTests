import Fluent
import Passes

struct CreatePassData: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PassData.FieldKeys.schemaName)
            .id()
            .field(PassData.FieldKeys.title, .string, .required)
            .field(
                PassData.FieldKeys.passID, .uuid, .required,
                .references(Pass.schema, .id, onDelete: .cascade)
            )
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PassData.FieldKeys.schemaName).delete()
    }
}

extension PassData {
    enum FieldKeys {
        static let schemaName = "pass_data"
        static let title = FieldKey(stringLiteral: "title")
        static let passID = FieldKey(stringLiteral: "pass_id")
    }
}
