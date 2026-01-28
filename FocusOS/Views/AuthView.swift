import SwiftUI
import AuthenticationServices
import Supabase

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
    @State private var showingTerms = false
    @State private var isNameInvalid = false
    @State private var isEmailInvalid = false
    @State private var isPasswordInvalid = false
    @State private var contentHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background Image
            Image("_")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Simple transparent glassy overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                GeometryReader { geometry in
                    ZStack {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 25) {
                                formContent
                            }
                            .padding(.top, 25)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 25)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(key: SizePreferenceKey.self, value: geo.size.height)
                                }
                            )
                        }
                    }
                    .frame(width: 450)
                    // Dynamic height: Content height but capped at 80% screen
                    // Dynamic height: Content height but capped at 90% screen to allow more space
                    .frame(height: contentHeight > 0 ? min(contentHeight, geometry.size.height * 0.9) : min(600, geometry.size.height * 0.9))
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 10)
                    // Center in the screen
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .opacity(isAppeared ? 1 : 0)
                    .scaleEffect(isAppeared ? 1 : 0.9)
                    .onPreferenceChange(SizePreferenceKey.self) { height in
                        withAnimation {
                            contentHeight = height
                        }
                    }
                }
            } else {
                // iPhone Layout: Bottom Sheet
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                // Top spacer to show background
                                Spacer()
                                    .frame(height: 100)
                                
                                VStack(spacing: 25) {
                                    formContent
                                }
                                .padding(.horizontal, 40)
                                .padding(.bottom, 50) // Padding for content
                                .frame(minHeight: geometry.size.height - 100, alignment: .top)
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
                            }
                        }
                        .background(
                            VStack {
                                Spacer().frame(height: 200) // 100pt spacer + 100pt curve radius
                                Color.white
                            }
                            .ignoresSafeArea(edges: .bottom)
                        )
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .offset(y: isAppeared ? 0 : UIScreen.main.bounds.height)
            }
        }
        .fullScreenCover(isPresented: $showingTerms) {
            TermsAndConditionsView(onAccept: {
                agreeToTerms = true
            })
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                isAppeared = true
            }
        }
    }
    
    // MARK: - Reusable Form Content
    
    @ViewBuilder
    private var formContent: some View {
        // Header
        VStack(spacing: 8) {
            Text(isSignUp ? "Get Started!" : "Welcome!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.25, green: 0.45, blue: 0.85))
            
            HStack(spacing: 4) {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                
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
        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : 40)
        
        // Form Fields
        VStack(spacing: 16) {
            if isSignUp {
                CustomTextField(
                    icon: "person",
                    placeholder: "Enter Full Name",
                    text: $fullName,
                    label: "Full Name",
                    isError: isNameInvalid
                )
            }
            
            CustomTextField(
                icon: "envelope",
                placeholder: "Enter Email Address",
                text: $email,
                label: "Email Address",
                isError: isEmailInvalid
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            
            CustomTextField(
                icon: "lock",
                placeholder: "Enter Password",
                text: $password,
                label: "Password",
                isSecure: true,
                isError: isPasswordInvalid
            )
            
            if isSignUp {
                HStack(spacing: 8) {
                    Button(action: {
                        agreeToTerms.toggle()
                    }) {
                        Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreeToTerms ? Color(red: 0.25, green: 0.45, blue: 0.85) : .gray)
                    }
                    
                    Text("I agree to")
                        .font(.caption)
                        .foregroundColor(Color.gray)
                    
                    Button(action: {
                        showingTerms = true
                    }) {
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
                                .foregroundColor(Color.gray)
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
                // Reset validation
                isNameInvalid = false
                isEmailInvalid = false
                isPasswordInvalid = false
                
                // Sanitize inputs
                let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // VALIDATION LOGIC
                var hasError = false
                
                if cleanEmail.isEmpty || !cleanEmail.contains("@") || !cleanEmail.contains(".") {
                    isEmailInvalid = true
                    errorMessage = "Please enter a valid email address."
                    hasError = true
                }
                
                if cleanPassword.count < 6 {
                    isPasswordInvalid = true
                    errorMessage = "Password must be at least 6 characters long."
                    hasError = true
                }
                
                if isSignUp && cleanFullName.isEmpty {
                    isNameInvalid = true
                    errorMessage = "Please enter your full name."
                    hasError = true
                }
                
                if hasError {
                    // Only show alert if there is an error, but fields turn red regardless
                    showError = true
                    isLoading = false
                    return
                }
                
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
        .alert("Authentication Issue", isPresented: $showError) {
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
                    .foregroundColor(Color.gray)
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.15))
            }
            .padding(.vertical, 10)
            
            HStack(spacing: 16) {
                SocialButton(icon: "apple.logo", text: "Apple", color: .black) {
                    handleOAuthSignIn(provider: .apple)
                }
                SocialButton(imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png", text: "Google") {
                    handleOAuthSignIn(provider: .google)
                }
            }
        }
        
    }
    
    // MARK: - OAuth Handler
    
    private func handleOAuthSignIn(provider: Provider) {
        Task {
            do {
                let url = try await SupabaseManager.shared.getOAuthURL(provider: provider)
                
                // Use ASWebAuthenticationSession for a native-feeling OAuth flow
                let session = ASWebAuthenticationSession(
                    url: url,
                    callbackURLScheme: "focusos"
                ) { callbackURL, error in
                    if let error = error {
                        print("AuthView: OAuth error - \(error.localizedDescription)")
                        return
                    }
                    
                    if callbackURL != nil {
                        Task {
                            // Supabase Swift handles the session storage automatically when it detects auth state changes
                            print("AuthView: OAuth session detected")
                            await MainActor.run {
                                onComplete(true)
                            }
                        }
                    }
                }
                
                session.presentationContextProvider = AuthPresentationContextProvider.shared
                session.start()
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// Helper for ASWebAuthenticationSession presentation
class AuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = AuthPresentationContextProvider()
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        return window ?? ASPresentationAnchor()
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Custom TextField

// MARK: - Custom TextField

// MARK: - Custom TextField

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    let label: String
    var isSecure: Bool = false
    var isError: Bool = false // New property for error state
    
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Label on the border
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(isError ? .red : .black) // Label turns red
                .padding(.horizontal, 4)
                .background(Color.white)
                .offset(x: 20, y: -27)
                .zIndex(1)
            
            HStack {
                if isSecure && !isPasswordVisible {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 15))
                        .foregroundColor(.black)
                }
                
                if isSecure {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isError ? Color.red : Color.gray.opacity(0.25), lineWidth: 1.2) // Border turns red
            )
        }
        .padding(.top, 10)
    }
}

// MARK: - Social Button

struct SocialButton: View {
    var icon: String? = nil
    var imageUrl: String? = nil
    var text: String? = nil
    var color: Color = .black
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Group {
                    if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            case .failure(_), .empty:
                                if let icon = icon {
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(color)
                                } else {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.blue)
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
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
