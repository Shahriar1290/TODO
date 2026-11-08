import SwiftUI

private struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.25).ignoresSafeArea()
                        ProgressView()
                            .controlSize(.large)
                            .padding(24)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Loading")
                }
            }
            .animation(.easeInOut(duration: 0.15), value: isLoading)
    }
}

extension View {
    func loadingOverlay(_ isLoading: Bool) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading))
    }
}

#Preview {
    Text("Content")
        .loadingOverlay(true)
}
