import Foundation
import FirebaseAuth

final class AuthService {
    var currentUserId: String? { Auth.auth().currentUser?.uid }

    func addAuthStateListener(_ onChange: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in
            onChange(user)
        }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }

    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    static func friendlyMessage(for error: Error) -> String {
        let nsError = error as NSError

        guard nsError.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "That email address doesn't look right."
        case .wrongPassword, .invalidCredential, .userNotFound:
            // Firebase returns invalidCredential for both unknown user and wrong password.
            return "Incorrect email or password."
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .networkError:
            return "Network error. Check your internet connection and try again."
        case .tooManyRequests:
            return "Too many attempts. Please wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
