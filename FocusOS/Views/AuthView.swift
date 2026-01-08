import SwiftUI

struct AuthView: View {
    var onComplete: (Bool) -> Void
    
    @State private var isSignUp = true
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreeToTerms = false
    @State private var rememberMe = false
    @State private var isAppeared = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image("_")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Content Card
            VStack(spacing: 0) {
                // Top spacer to show background
                Spacer()
                    .frame(height: 100)
                
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text(isSignUp ? "Get Started!" : "Welcome!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                        
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    isSignUp.toggle()
                                }
                            }) {
                                Text(isSignUp ? "Login" : "Sign Up")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        if isSignUp {
                            CustomTextField(
                                icon: "person",
                                placeholder: "Enter Full Name",
                                text: $fullName,
                                label: "Full Name"
                            )
                        }
                        
                        CustomTextField(
                            icon: "envelope",
                            placeholder: "Enter Email Address",
                            text: $email,
                            label: "Email Address"
                        )
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        
                        CustomTextField(
                            icon: "lock",
                            placeholder: "Enter Password",
                            text: $password,
                            label: "Password",
                            isSecure: true
                        )
                        
                        if isSignUp {
                            HStack(spacing: 8) {
                                Button(action: {
                                    agreeToTerms.toggle()
                                }) {
                                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(agreeToTerms ? Color(red: 0.25, green: 0.45, blue: 0.85) : .gray)
                                }
                                
                                HStack(spacing: 4) {
                                    Text("I agree to")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Terms and Conditions")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                        } else {
                            HStack {
                                Button(action: {
                                    rememberMe.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                            .foregroundColor(rememberMe ? Color(red: 0.25, green: 0.45, blue: 0.85) : .gray)
                                        
                                        Text("Remember me")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Forgot password action
                                }) {
                                    Text("Forgot password?")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    
                    // Main Action Button
                    Button(action: {
                        Task {
                            isLoading = true
                            
                            // Sanitize inputs
                            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                            let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                            let cleanFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            do {
                                if isSignUp {
                                    try await SupabaseManager.shared.signUp(
                                        email: cleanEmail,
                                        password: cleanPassword,
                                        fullName: cleanFullName
                                    )
                                } else {
                                    try await SupabaseManager.shared.signIn(
                                        email: cleanEmail,
                                        password: cleanPassword
                                    )
                                }
                                onComplete(isSignUp)
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                            isLoading = false
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text(isSignUp ? "Sign Up" : "Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color(red: 0.25, green: 0.45, blue: 0.85))
                    .cornerRadius(12)
                    .disabled(isLoading || (isSignUp && !agreeToTerms))
                    .opacity((isLoading || (isSignUp && !agreeToTerms)) ? 0.6 : 1.0)
                    .alert("Authentication Error", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(errorMessage)
                    }
                    
                    // Social Login Section (Now on both screens)
                    VStack(spacing: 20) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.15))
                            Text(isSignUp ? "Or sign up with" : "Or log in with")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .padding(.horizontal, 10)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.15))
                        }
                        .padding(.vertical, 10)
                        
                        HStack(spacing: 16) {
                            SocialButton(icon: "apple.logo", text: "Apple", color: .black)
                            SocialButton(imagePath: "/Users/calvin/.gemini/antigravity/brain/d9e6cae9-a606-4f26-839f-153919a23c87/google_logo_1767811237808.png", text: "Google")
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 100,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 100
                    )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
                .offset(y: isAppeared ? 0 : UIScreen.main.bounds.height)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                isAppeared = true
            }
        }
    }
}

// MARK: - Custom TextField

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let label: String
    var isSecure: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Label on the border
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 4)
                .background(Color.white)
                .offset(x: 20, y: -27)
                .zIndex(1)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1.2)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1.2)
                    )
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Social Button

struct SocialButton: View {
    var icon: String? = nil
    var imagePath: String? = nil
    var text: String? = nil
    var color: Color = .black
    
    var body: some View {
        Button(action: {
            // Social auth action (mock)
        }) {
            HStack(spacing: 10) {
                Group {
                    if let imagePath = imagePath, let uiImage = UIImage(contentsOfFile: imagePath) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(color)
                    }
                }
                
                if let text = text {
                    Text(text)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(onComplete: { _ in })
    }
}
