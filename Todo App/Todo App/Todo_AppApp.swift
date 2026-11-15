import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authVM)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isCheckingAuth {
                ProgressView("Loading…")
            } else if let uid = authVM.user?.uid {
                TaskListView(userId: uid)
                    .id(uid)
            } else {
                NavigationStack { LoginView() }
            }
        }
        .animation(.default, value: authVM.isAuthenticated)
        .loadingOverlay(authVM.isLoading)
        .messageAlert(message: $authVM.errorMessage)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel(startListening: false))
}
