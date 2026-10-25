//
//  OnboardingFlow.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import SwiftUI
import PhotosUI
import AuthenticationServices

/// Complete onboarding flow: Sign In → Profile Creation → Location Permission → Home
struct OnboardingFlow: View {
    @Environment(AuthService.self) private var authService
    @Environment(LocationService.self) private var locationService
    
    @State private var currentStep: OnboardingStep = .signIn
    @State private var hasCompletedOnboarding = false
    
    enum OnboardingStep {
        case signIn
        case createProfile
        case requestLocation
        case complete
    }
    
    var body: some View {
        Group {
            switch currentStep {
            case .signIn:
                SignInOnboardingView {
                    currentStep = .createProfile
                }
                
            case .createProfile:
                ProfileCreationView {
                    currentStep = .requestLocation
                }
                
            case .requestLocation:
                LocationPermissionView {
                    currentStep = .complete
                    hasCompletedOnboarding = true
                }
                
            case .complete:
                MainTabView()
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        ))
        .animation(.easeInOut, value: currentStep)
    }
}

// MARK: - Step 1: Sign In with Google

struct SignInOnboardingView: View {
    let onComplete: () -> Void
    
    @Environment(AuthService.self) private var authService
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.orange.opacity(0.2), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo
                VStack(spacing: 20) {
                    // Use your logo image here
                    Image(systemName: "basketball.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(.orange)
                    
                    Text("runs")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                
                VStack(spacing: 12) {
                    Text("Find pickup games")
                        .font(.title2)
                    Text("Check who's at the court before you go")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Sign In Buttons
                VStack(spacing: 16) {
                    // Google Sign In
                    Button {
                        Task {
                            await signInWithGoogle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title2)
                            Text("Continue with Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }
                    
                    // Apple Sign In
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    private func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }
        
        // TODO: Implement Google Sign In
        // For now, proceed to profile creation
        onComplete()
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success:
            onComplete()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Step 2: Create Profile

struct ProfileCreationView: View {
    let onComplete: () -> Void
    
    @Environment(AuthService.self) private var authService
    @State private var displayName = ""
    @State private var heightFeet = 6
    @State private var heightInches = 0
    @State private var selectedPosition: PlayerPosition = .pointGuard
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var isLoading = false
    
    var isFormValid: Bool {
        !displayName.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Your Profile")
                            .font(.title.bold())
                        Text("This is what other players will see")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Profile Photo
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                if let profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.title)
                                        Text("Add Photo")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.orange)
                                }
                            }
                        }
                        .onChange(of: selectedPhoto) { _, newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = Image(uiImage: uiImage)
                                }
                            }
                        }
                    }
                    
                    // Form Fields
                    VStack(spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.headline)
                            TextField("Your name", text: $displayName)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)
                        }
                        
                        // Height
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Height")
                                .font(.headline)
                            HStack {
                                Picker("Feet", selection: $heightFeet) {
                                    ForEach(4...7, id: \.self) { feet in
                                        Text("\(feet) ft").tag(feet)
                                    }
                                }
                                .pickerStyle(.wheel)
                                
                                Picker("Inches", selection: $heightInches) {
                                    ForEach(0...11, id: \.self) { inches in
                                        Text("\(inches) in").tag(inches)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                            .frame(height: 120)
                        }
                        
                        // Position
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Position")
                                .font(.headline)
                            Picker("Position", selection: $selectedPosition) {
                                ForEach(PlayerPosition.allCases, id: \.self) { position in
                                    Text(position.rawValue).tag(position)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Continue Button
                    Button {
                        Task {
                            await saveProfile()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isFormValid ? Color.orange : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .disabled(!isFormValid || isLoading)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    private func saveProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        let totalInches = (heightFeet * 12) + heightInches
        
        do {
            try await authService.updateProfile(
                displayName: displayName,
                heightInches: totalInches,
                positions: [selectedPosition.rawValue]
            )
            
            // TODO: Upload profile photo to Supabase Storage
            
            onComplete()
        } catch {
            print("Error saving profile: \(error)")
        }
    }
}

// MARK: - Step 3: Request Location Permission

struct LocationPermissionView: View {
    let onComplete: () -> Void
    
    @Environment(LocationService.self) private var locationService
    @State private var hasRequestedPermission = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "location.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
            }
            
            // Text
            VStack(spacing: 16) {
                Text("Enable Location")
                    .font(.title.bold())
                
                Text("We need your location to:\n• Show nearby courts\n• Verify check-ins\n• Help you find games")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button {
                    requestLocation()
                } label: {
                    Text("Allow Location")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    // Skip for now
                    onComplete()
                } label: {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
        .onChange(of: locationService.authorizationStatus) { _, newStatus in
            if hasRequestedPermission && 
               (newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
    
    private func requestLocation() {
        hasRequestedPermission = true
        locationService.requestAuthorization()
    }
}

#Preview("Sign In") {
    SignInOnboardingView {}
        .environment(AuthService())
}

#Preview("Create Profile") {
    ProfileCreationView {}
        .environment(AuthService())
}

#Preview("Location Permission") {
    LocationPermissionView {}
        .environment(LocationService())
}
