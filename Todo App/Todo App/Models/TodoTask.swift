import Foundation
import FirebaseFirestore

struct TodoTask: Identifiable, Codable, Equatable {
    @DocumentID var id: String?

    var title: String

    var description: String

    var isCompleted: Bool

    @ServerTimestamp var createdAt: Date?

    @ServerTimestamp var updatedAt: Date?

    var userId: String

    init(
        id: String? = nil,
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        userId: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
    }
}

extension TodoTask {
    static let sample = TodoTask(
        id: "sample-1",
        title: "Buy groceries",
        description: "Milk, eggs, bread",
        isCompleted: false,
        createdAt: Date(),
        updatedAt: Date(),
        userId: "preview-user"
    )

    static let sampleCompleted = TodoTask(
        id: "sample-2",
        title: "Finish assignment",
        description: "",
        isCompleted: true,
        createdAt: Date(),
        updatedAt: Date(),
        userId: "preview-user"
    )
}
