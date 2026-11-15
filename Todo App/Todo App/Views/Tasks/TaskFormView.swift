import SwiftUI

struct TaskFormView: View {
    enum Mode {
        case add
        case edit(TodoTask)

        var navigationTitle: String {
            switch self {
            case .add:  return "New Task"
            case .edit: return "Edit Task"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: TaskViewModel
    private let mode: Mode

    @State private var title: String
    @State private var taskDescription: String
    @State private var isSaving = false
    @FocusState private var titleIsFocused: Bool

    private var canSave: Bool {
        !isSaving && !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(mode: Mode, viewModel: TaskViewModel) {
        self.mode = mode
        _viewModel = ObservedObject(wrappedValue: viewModel)

        switch mode {
        case .add:
            _title = State(initialValue: "")
            _taskDescription = State(initialValue: "")
        case .edit(let task):
            _title = State(initialValue: task.title)
            _taskDescription = State(initialValue: task.description)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("What needs to be done?", text: $title)
                        .focused($titleIsFocused)
                        .submitLabel(.done)
                        .accessibilityLabel("Task title")
                }

                Section("Description (optional)") {
                    ZStack(alignment: .topLeading) {
                        if taskDescription.isEmpty {
                            Text("Add some details…")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .accessibilityHidden(true)
                        }
                        TextEditor(text: $taskDescription)
                            .frame(minHeight: 120)
                            .accessibilityLabel("Task description")
                    }
                }
            }
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if case .add = mode { titleIsFocused = true }
            }
            .interactiveDismissDisabled(isSaving)
            .messageAlert(message: $viewModel.errorMessage)
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }

        let succeeded: Bool
        switch mode {
        case .add:
            succeeded = await viewModel.addTask(title: title, description: taskDescription)
        case .edit(let original):
            var updated = original
            updated.title = title
            updated.description = taskDescription
            succeeded = await viewModel.updateTask(updated)
        }

        if succeeded { dismiss() }
    }
}

#Preview("Add") {
    TaskFormView(
        mode: .add,
        viewModel: TaskViewModel(userId: "preview", previewTasks: [])
    )
}

#Preview("Edit") {
    TaskFormView(
        mode: .edit(.sample),
        viewModel: TaskViewModel(userId: "preview", previewTasks: [.sample])
    )
}
