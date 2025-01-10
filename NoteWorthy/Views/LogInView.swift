//
//  LogInView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 07/01/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct LogInView: View {
    @State private var Email: String = ""
    @State private var Password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @EnvironmentObject private var appState: AppState
    
    private var isFormValid: Bool {
        !Email.isEmptyOrWhiteSpace && !Password.isEmptyOrWhiteSpace
    }
    
    private func login() async {
        do {
            let _ = try await Auth.auth().signIn(withEmail: Email, password: Password)
            appState.routes = [.main]
        } catch let error as NSError {
            handleLoginError(error)
        }
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
    
    private func handleLoginError(_ error: NSError) {
        switch AuthErrorCode(rawValue: error.code) {
        case .invalidEmail, .userNotFound:
            alertMessage = "The email address is invalid or not found."
        case .networkError:
            alertMessage = "Network error occurred. Please check your connection and try again."
        default:
            alertMessage = "Either the email or password entered is incorrect."
        }
        showAlert = true
    }
    
    
    var body: some View {
        VStack {
            Text("NoteWorthy")
                .font(.custom("PatrickHand-Regular", size: 48))
            
            Text("Sign in to your account")
                .font(.system(size: 27))
                .frame(width: 300, height:50, alignment: .leading)
            
            Text("Email")
                .font(.system(size: 16, weight: .thin, design: .default))
                .frame(width: 300, height:50, alignment: .leading)
            TextField("Email", text: $Email)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(width: 288, height: 35)
            
            Text("Password")
                .font(.system(size: 16, weight: .thin, design: .default))
                .frame(width: 300, height:50, alignment: .leading)
            SecureField("Password", text: $Password)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .frame(width: 288, height: 35)
                .textContentType(.none)
                .padding(.bottom, 20)
            
            Button(action: {
                Task {
                    await login()
                }
            }) {
                Text("SIGN IN")
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
            
            Text("or sign in with")
                .font(.system(size: 16, weight: .ultraLight, design: .default))
            
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
                Text("Don't have an account?")
                    .font(.system(size: 16, weight: .thin, design: .default))
                Button("SIGN UP") {
                    appState.routes = [.signUp]
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    LogInView().environmentObject(AppState())
}
