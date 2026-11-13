import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TodoTask] = []

    @Published private(set) var isLoading = true

    @Published var errorMessage: String?

    private let userId: String
    private let service: TaskService
    private var listener: ListenerRegistration?
    private let isPreview: Bool

    init(
        userId: String,
        service: TaskService = TaskService(),
        previewTasks: [TodoTask]? = nil
    ) {
        self.userId = userId
        self.service = service
        self.isPreview = previewTasks != nil

        if let previewTasks {
            self.tasks = previewTasks
            self.isLoading = false
        }
    }

    deinit {
        listener?.remove()
    }

    func startListening() {
        guard !isPreview, listener == nil else { return }
        isLoading = true

        listener = service.listenToTasks(userId: userId) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false
                switch result {
                case .success(let tasks):
                    self.tasks = tasks
                case .failure(let error):
                    self.errorMessage = "Couldn't load your tasks. \(error.localizedDescription)"
                }
            }
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    func addTask(title: String, description: String) async -> Bool {
        guard validate(title: title) else { return false }
        do {
            try await service.addTask(title: title, description: description, userId: userId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateTask(_ task: TodoTask) async -> Bool {
        guard validate(title: task.title) else { return false }
        do {
            try await service.updateTask(task, userId: userId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func toggleCompletion(_ task: TodoTask) async {
        do {
            try await service.toggleCompletion(task, userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: TodoTask) async {
        do {
            try await service.deleteTask(task, userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func validate(title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            errorMessage = TaskServiceError.emptyTitle.errorDescription
            return false
        }
        return true
    }
}
