//
// SignUpView.swift
// NoteWorthy
//
// Created by Mohamed Fiyaz on 06/01/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SignUpView: View {
    @State private var Name: String = ""
    @State private var Email: String = ""
    @State private var Password: String = ""
    @State private var ConfirmPassword: String = ""
    @State private var isChecked = false
    @State private var showTerms = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isVerifyingEmail = false
    @State private var isPasswordVisible = false
    
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var appState: AppState
    
    private var isFormValid: Bool {
        !Email.isEmptyOrWhiteSpace && !Password.isEmptyOrWhiteSpace && !Name.isEmptyOrWhiteSpace && isChecked
    }
    
    private func isPasswordValid() -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: Password)
    }
    
    private func handleGoogleSignIn() async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first?.rootViewController else {
            alertMessage = "Unable to present Google Sign-In."
            showAlert = true
            return
        }
        
        do {
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                alertMessage = "Failed to get ID Token."
                showAlert = true
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = authResult.user
            
            alertMessage = "Signed in successfully as \(user.displayName ?? "User")."
            showAlert = true
            
            appState.routes = [.main]
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    private func loadTermsContent() -> String {
        if let rtfURL = Bundle.main.url(forResource: "Terms", withExtension: "rtf"),
           let attributedString = try? NSAttributedString(url: rtfURL, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            return attributedString.string
        }
        return "Terms and Conditions content could not be loaded."
    }
    
    
    private func signUp() async {
        if !isPasswordValid() {
            alertMessage = "Password must be at least 8 characters long, contain at least one letter, one number, and one special character."
            showAlert = true
            return
        }
        
        if !Email.isValidEmail {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        if Password != ConfirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        if !isChecked {
            alertMessage = "Please agree to the terms and conditions."
            showAlert = true
            return
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: Email, password: Password)
            
            try await result.user.sendEmailVerification()
            
            alertMessage = "A verification email has been sent. Please verify your email before proceeding."
            showAlert = true
            isVerifyingEmail = true
            
            while !result.user.isEmailVerified {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await result.user.reload()
            }
            
            try await model.updateDisplayName(for: result.user, displayName: Name)
            
            appState.routes = [.login]
            
        } catch {
            alertMessage = error.localizedDescription
            showAlert = true
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    appState.routes = [.login]
                }) {
                    Image(systemName: "arrow.backward.square")
                        .foregroundColor(Color.black)
                        .font(.system(size: 25))
                }
                Spacer()
                Text("NoteWorthy")
                    .font(.custom("PatrickHand-Regular", size: 36))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            Spacer()
            
            VStack {
                Text("Create Your Account")
                    .font(.system(size: 27, weight: .medium, design: .default))
                
                Text("Name")
                    .font(.system(size: 16, weight: .thin, design: .default))
                    .frame(width: 300, height: 50, alignment: .leading)
                TextField("Name", text: $Name)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(width: 288, height: 35)
                
                Text("Email")
                    .font(.system(size: 16, weight: .thin, design: .default))
                    .frame(width: 300, height: 50, alignment: .leading)
                TextField("Email", text: $Email)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(width: 288, height: 35)
                
                Text("Password")
                    .font(.system(size: 16, weight: .thin, design: .default))
                    .frame(width: 300, height: 50, alignment: .leading)
                
                SecureField("Password", text: $Password)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(width: 288, height: 35)
                    .textContentType(.none)
                
                Text("Confirm Password")
                    .font(.system(size: 16, weight: .thin, design: .default))
                    .frame(width: 300, height: 50, alignment: .leading)
                
                SecureField("Confirm Password", text: $ConfirmPassword)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .frame(width: 288, height: 35)
                    .textContentType(.none)
                    .padding(.bottom)
                
                HStack {
                    Button(action: {
                        isChecked.toggle()
                    }) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                            .font(.system(size: 24))
                    }
                    Text("I understood the")
                    Button(action: {
                        showTerms.toggle()
                    }) {
                        Text("Terms and Conditions")
                    }
                }
                
                Button(action: {
                    Task {
                        await signUp()
                    }
                }) {
                    Text("SIGN UP")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity)
                }
                .disabled(!isFormValid)
                .padding()
                .foregroundColor(Color.white)
                .frame(width: 300)
                .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                .cornerRadius(20)
                .frame(width: 300)
            }
            
            Button(action: {
                Task {
                    await handleGoogleSignIn()
                }
            }) {
                HStack {
                    Image("google_logo")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Continue with Google")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .frame(width: 300, height: 50)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .padding()
            
            HStack {
                Text("Have an account?")
                    .font(.system(size: 16, weight: .thin, design: .default))
                Button(action: {
                    appState.routes = [.login]
                }) {
                    Text("SIGN IN")
                        .font(.system(size: 16, weight: .regular, design: .default))
                }
            }
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(isVerifyingEmail ? "Verification Email Sent" : "Error"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        
        .sheet(isPresented: $showTerms) {
            VStack {
                Text("Terms and Conditions")
                    .font(.title)
                    .padding()
                
                ScrollView {
                    Text(loadTermsContent())
                        .padding()
                }
                
                Button(action: {
                    showTerms = false
                }) {
                    Text("Close")
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(Model())
        .environmentObject(AppState())
}
