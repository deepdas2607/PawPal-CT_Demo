//
//  ContentView.swift
//  PawPal - Root View Layer
//
//  Root router for PawPal.
//  Checks the backend SQLite database on launch:
//  - If no pet profile exists, routes to OnboardingView.
//  - If a pet profile exists, routes to DashboardView.
//  - If the server is offline, displays a friendly connection error with a retry button.
//

import SwiftUI

/// Root application view directing between onboarding, dashboard, and offline states.
struct ContentView: View {
    @State private var activePet: Pet? = nil
    @State private var isLoading: Bool = true
    @State private var connectionError: String? = nil
    
    var body: some View {
        Group {
            if isLoading {
                splashLoadingView
            } else if let error = connectionError {
                serverOfflineView(error)
            } else if activePet != nil {
                DashboardView()
            } else {
                OnboardingView { newPet in
                    self.activePet = newPet
                }
            }
        }
        .task {
            await checkInitialState()
        }
    }
    
    // MARK: - Startup Check
    
    /// Queries the backend API to determine if any pet profile exists.
    private func checkInitialState() async {
        isLoading = true
        connectionError = nil
        
        do {
            let pets = try await PetService.shared.fetchPets()
            if let firstPet = pets.first {
                self.activePet = firstPet
                CleverTapIdentity.restoreSession(pet: firstPet)
            } else {
                self.activePet = nil
            }
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.connectionError = error.localizedDescription
        }
    }
    
    // MARK: - Splash / Loading State
    
    private var splashLoadingView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            Text("PawPal")
                .font(.title2.bold())
            ProgressView("Connecting to backend...")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Server Offline State
    
    private func serverOfflineView(_ error: String) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "wifi.slash")
                    .font(.system(size: 38))
                    .foregroundColor(.red)
            }
            
            Text("Backend Server Offline")
                .font(.title3.bold())
            
            Text("PawPal connects to a local FastAPI backend with SQLite. Please make sure the backend is running.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Start the server in your terminal:")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                Text("./backend/start_backend.sh")
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.inputBackground)
                    .cornerRadius(6)
            }
            .padding(.horizontal, 24)
            
            Button(action: {
                Task { await checkInitialState() }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry Connection")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
