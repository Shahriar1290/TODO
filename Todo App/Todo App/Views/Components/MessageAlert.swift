import SwiftUI

extension View {
    func messageAlert(
        title: String = "Oops",
        message: Binding<String?>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        alert(
            title,
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { isShowing in
                    if !isShowing { message.wrappedValue = nil }
                }
            ),
            actions: {
                Button("OK") { onDismiss?() }
            },
            message: {
                Text(message.wrappedValue ?? "")
            }
        )
    }
}
