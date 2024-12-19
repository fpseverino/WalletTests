import Fluent
import Vapor

struct OrderDataDTO: Content {
    var id: UUID?
    var title: String?

    func toModel() -> OrderData {
        let model = OrderData()

        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}
