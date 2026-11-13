import Foundation
import FirebaseFirestore

enum TaskServiceError: LocalizedError {
    case emptyTitle
    case missingTaskId

    var errorDescription: String? {
        switch self {
        case .emptyTitle:     return "Please enter a title for your task."
        case .missingTaskId:  return "This task can't be updated because it has no ID."
        }
    }
}

final class TaskService {
    // lazy so previews never touch Firestore unless a method actually runs.
    private lazy var db = Firestore.firestore()

    private func tasksCollection(for userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("tasks")
    }

    func listenToTasks(
        userId: String,
        onChange: @escaping (Result<[TodoTask], Error>) -> Void
    ) -> ListenerRegistration {
        tasksCollection(for: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error {
                    onChange(.failure(error))
                    return
                }
                guard let snapshot else {
                    onChange(.success([]))
                    return
                }
                let tasks: [TodoTask] = snapshot.documents.compactMap { document in
                    try? document.data(as: TodoTask.self)
                }
                onChange(.success(tasks))
            }
    }

    func addTask(title: String, description: String, userId: String) async throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TaskServiceError.emptyTitle }

        let task = TodoTask(
            title: trimmed,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: false,
            userId: userId
        )
        _ = try tasksCollection(for: userId).addDocument(from: task)
    }

    func updateTask(_ task: TodoTask, userId: String) async throws {
        guard let taskId = task.id else { throw TaskServiceError.missingTaskId }

        let trimmed = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TaskServiceError.emptyTitle }

        try await tasksCollection(for: userId).document(taskId).updateData([
            "title": trimmed,
            "description": task.description.trimmingCharacters(in: .whitespacesAndNewlines),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func toggleCompletion(_ task: TodoTask, userId: String) async throws {
        guard let taskId = task.id else { throw TaskServiceError.missingTaskId }

        try await tasksCollection(for: userId).document(taskId).updateData([
            "isCompleted": !task.isCompleted,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func deleteTask(_ task: TodoTask, userId: String) async throws {
        guard let taskId = task.id else { throw TaskServiceError.missingTaskId }
        try await tasksCollection(for: userId).document(taskId).delete()
    }
}
