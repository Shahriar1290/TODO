import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var successMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    Text("Reset Password")
                        .font(.largeTitle.bold())
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 24)

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

                PrimaryButton(
                    title: "Send Reset Link",
                    isEnabled: AuthValidator.isValidEmail(email)
                ) {
                    Task {
                        let sent = await authVM.sendPasswordReset(email: email)
                        if sent {
                            successMessage = "If an account exists for \(email), a reset link is on its way. Check your inbox and spam folder."
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(title: "Check Your Email", message: $successMessage) {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack { ForgotPasswordView() }
        .environmentObject(AuthViewModel(startListening: false))
}
