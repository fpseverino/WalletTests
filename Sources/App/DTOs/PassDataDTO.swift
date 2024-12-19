import Fluent
import Vapor

struct PassDataDTO: Content {
    var id: UUID?
    var title: String?

    func toModel() -> PassData {
        let model = PassData()

        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}
