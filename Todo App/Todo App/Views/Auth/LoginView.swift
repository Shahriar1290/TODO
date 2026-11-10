import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""

    private var isFormValid: Bool {
        AuthValidator.isValidEmail(email) && AuthValidator.isValidPassword(password)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header

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
                    contentType: .password
                )
                if !password.isEmpty && !AuthValidator.isValidPassword(password) {
                    FieldHint(text: "Password must be at least 6 characters.")
                }

                NavigationLink("Forgot password?") {
                    ForgotPasswordView()
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .trailing)

                PrimaryButton(title: "Sign In", isEnabled: isFormValid) {
                    Task { await authVM.signIn(email: email, password: password) }
                }
                .padding(.top, 8)

                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    NavigationLink("Sign Up") {
                        SignUpView()
                    }
                    .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "checklist")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            Text("Welcome Back")
                .font(.largeTitle.bold())
            Text("Sign in to see your tasks")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 24)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { LoginView() }
        .environmentObject(AuthViewModel(startListening: false))
}
