import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    private var passwordsMatch: Bool { password == confirmPassword }

    private var isFormValid: Bool {
        AuthValidator.isValidEmail(email)
        && AuthValidator.isValidPassword(password)
        && passwordsMatch
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.largeTitle.bold())
                    Text("Sign up to start organizing your tasks")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)
                .accessibilityElement(children: .combine)

                AuthTextField(
                    title: "Email",
                    systemImage: "envelope",
                    text: $email,
                    keyboard: .emailAddress,
                    contentType: .emailAddress
                )
                if !email.isEmpty && !AuthValidator.isValidEmail(email) {
                    FieldHint(text: "Enter a valid email address.")
                }

                AuthTextField(
                    title: "Password",
                    systemImage: "lock",
                    text: $password,
                    isSecure: true,
                    contentType: .newPassword
                )
                if !password.isEmpty && !AuthValidator.isValidPassword(password) {
                    FieldHint(text: "Password must be at least 6 characters.")
                }

                AuthTextField(
                    title: "Confirm Password",
                    systemImage: "lock.rotation",
                    text: $confirmPassword,
                    isSecure: true,
                    contentType: .newPassword
                )
                if !confirmPassword.isEmpty && !passwordsMatch {
                    FieldHint(text: "Passwords don't match.")
                }

                PrimaryButton(title: "Create Account", isEnabled: isFormValid) {
                    Task {
                        await authVM.signUp(
                            email: email,
                            password: password,
                            confirmPassword: confirmPassword
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SignUpView() }
        .environmentObject(AuthViewModel(startListening: false))
}
