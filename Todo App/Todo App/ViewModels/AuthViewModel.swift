import Foundation
import FirebaseAuth
import Combine

enum AuthValidator {
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPassword(_ password: String) -> Bool {
        password.count >= 6
    }
}

@MainActor
final class AuthViewModel: ObservableObject {
    @Published private(set) var user: User?

    @Published private(set) var isCheckingAuth: Bool

    @Published var isLoading = false
    @Published var errorMessage: String?

    var isAuthenticated: Bool { user != nil }

    private let authService: AuthService
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init(authService: AuthService = AuthService(), startListening: Bool = true) {
        self.authService = authService
        self.isCheckingAuth = startListening

        guard startListening else { return }

        listenerHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                self?.user = user
                self?.isCheckingAuth = false
            }
        }
    }

    deinit {
        if let listenerHandle {
            authService.removeAuthStateListener(listenerHandle)
        }
    }

    func signUp(email: String, password: String, confirmPassword: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard AuthValidator.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard AuthValidator.isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signUp(email: email, password: password)
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
        }
    }

    func signIn(email: String, password: String) async {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard AuthValidator.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard AuthValidator.isValidPassword(password) else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
        }
    }

    func sendPasswordReset(email: String) async -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard AuthValidator.isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.sendPasswordReset(email: email)
            return true
        } catch {
            errorMessage = AuthService.friendlyMessage(for: error)
            return false
        }
    }
}
