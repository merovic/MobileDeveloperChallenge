//
//  LoginView.swift
//  MobileDeveloperChallenge
//
//  Created by Amir Ahmed on 10/08/2024.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject private var keyboardObserver = KeyboardObserver()
    @StateObject private var viewModel = LoginViewModel()

    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height

            VStack(alignment: .center, spacing: dynamicSpacing(isLandscape: isLandscape)) {
                Spacer()

                if isLandscape {
                    HStack(alignment: .center, spacing: dynamicSpacing(isLandscape: isLandscape)) {
                        imageView(geometry: geometry, isLandscape: isLandscape)
                        fieldsView(geometry: geometry, isLandscape: isLandscape)
                    }
                } else {
                    imageView(geometry: geometry, isLandscape: isLandscape)
                    fieldsView(geometry: geometry, isLandscape: isLandscape)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeOut(duration: keyboardObserver.animationDuration), value: keyboardObserver.isKeyboardVisible)
        }
    }

    // Image View
    private func imageView(geometry: GeometryProxy, isLandscape: Bool) -> some View {
        Image("logosample")
            .resizable()
            .scaledToFit()
            .frame(width: dynamicImageSize(for: geometry.size, isLandscape: isLandscape))
            .padding(.bottom, dynamicBottomPadding(isLandscape: isLandscape))
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeOut(duration: keyboardObserver.animationDuration))
            .accessibilityLabel("Logo")
            .accessibilityHidden(keyboardObserver.isKeyboardVisible)
    }

    // Fields View (Email, Password, Button)
    private func fieldsView(geometry: GeometryProxy, isLandscape: Bool) -> some View {
        VStack(spacing: dynamicSpacing(isLandscape: isLandscape)) {
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .accessibilityLabel("Email address")
                .accessibilityHint("Enter your email address")

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .accessibilityLabel("Password")
                .accessibilityHint("Enter your password")

            Button(action: {
                viewModel.login()
            }) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: dynamicButtonWidth(for: geometry.size, isLandscape: isLandscape), height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .accessibilityLabel("Login button")
            .accessibilityHint("Tap to log in with the provided email and password")
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    // Helper function to calculate dynamic spacing
    private func dynamicSpacing(isLandscape: Bool) -> CGFloat {
        return isPad ? (isLandscape ? 30 : 40) : (isLandscape ? 15 : 20)
    }

    // Helper function to calculate dynamic bottom padding
    private func dynamicBottomPadding(isLandscape: Bool) -> CGFloat {
        return isPad ? (isLandscape ? 40 : 60) : (isLandscape ? 20 : 40)
    }

    // Helper function to calculate dynamic image size
    private func dynamicImageSize(for size: CGSize, isLandscape: Bool) -> CGFloat {
        let factor: CGFloat = isPad ? (isLandscape ? 0.3 : 0.5) : (isLandscape ? 0.4 : 0.7)
        return min(size.width * factor, isPad ? 300 : 200)
    }

    // Helper function to calculate dynamic button width
    private func dynamicButtonWidth(for size: CGSize, isLandscape: Bool) -> CGFloat {
        let factor: CGFloat = isPad ? (isLandscape ? 0.3 : 0.4) : (isLandscape ? 0.5 : 0.6)
        return min(size.width * factor, isPad ? 250 : 200)
    }
}

#Preview {
    LoginView()
}
