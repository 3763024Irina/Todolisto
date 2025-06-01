import Foundation

struct TaskModel: Identifiable, Equatable {
    let id: UUID
    var title: String
    var detail: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?
}


extension TaskModel {
    init?(entity: TaskEntity) {
        guard let id = entity.taskID,
              let title = entity.title,
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt else {
            return nil
        }

        self.id = id
        self.title = title
        self.detail = entity.detail
        self.isCompleted = entity.isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = entity.deletedAt
    }
}
