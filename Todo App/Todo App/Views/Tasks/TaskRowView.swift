import SwiftUI

struct TaskRowView: View {
    let task: TodoTask
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                task.isCompleted
                ? "Mark \(task.title) as not completed"
                : "Mark \(task.title) as completed"
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)

                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.subheadline)
                        .strikethrough(task.isCompleted)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint("Double tap to edit")
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        TaskRowView(task: .sample, onToggle: {}, onTap: {})
        TaskRowView(task: .sampleCompleted, onToggle: {}, onTap: {})
    }
}
