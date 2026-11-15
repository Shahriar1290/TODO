import SwiftUI

enum TaskSheet: Identifiable {
    case add
    case edit(TodoTask)

    var id: String {
        switch self {
        case .add:
            return "add"
        case .edit(let task):
            return "edit-\(task.id ?? "unknown")"
        }
    }
}

struct TaskListView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @StateObject private var viewModel: TaskViewModel
    @State private var activeSheet: TaskSheet?

    init(userId: String, viewModel: TaskViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TaskViewModel(userId: userId))
    }

    private var listErrorBinding: Binding<String?> {
        Binding(
            get: { activeSheet == nil ? viewModel.errorMessage : nil },
            set: { viewModel.errorMessage = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks…")
                } else if viewModel.tasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.stopListening()
                        authVM.signOut()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .accessibilityLabel("Sign out")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .add
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .add:
                    TaskFormView(mode: .add, viewModel: viewModel)
                case .edit(let task):
                    TaskFormView(mode: .edit(task), viewModel: viewModel)
                }
            }
            .messageAlert(message: listErrorBinding)
            .task { viewModel.startListening() }
            .onDisappear { viewModel.stopListening() }
        }
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(
                    task: task,
                    onToggle: { Task { await viewModel.toggleCompletion(task) } },
                    onTap: { activeSheet = .edit(task) }
                )
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await viewModel.deleteTask(task) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Tasks Yet", systemImage: "checklist")
        } description: {
            Text("Tap the + button to add your first task.")
        } actions: {
            Button("Add Task") { activeSheet = .add }
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview("With tasks") {
    TaskListView(
        userId: "preview",
        viewModel: TaskViewModel(userId: "preview", previewTasks: [.sample, .sampleCompleted])
    )
    .environmentObject(AuthViewModel(startListening: false))
}

#Preview("Empty") {
    TaskListView(
        userId: "preview",
        viewModel: TaskViewModel(userId: "preview", previewTasks: [])
    )
    .environmentObject(AuthViewModel(startListening: false))
}
