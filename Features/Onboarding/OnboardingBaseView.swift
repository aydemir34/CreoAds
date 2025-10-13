//
//  OnboardingBaseView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 29/09/2025.
//


import SwiftUI

struct OnboardingBaseView<Content: View>: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("CreoAds")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            // Progress
            ProgressView(value: coordinator.progress)
                .padding(.horizontal)
            
            Spacer()
            
            // Content
            content
            
            Spacer()
            
            // Navigation
            HStack {
                if coordinator.currentStep.rawValue > 0 {
                    Button("Geri") { coordinator.previous() }
                }
                
                Spacer()
                
                Button(coordinator.isLastStep ? "Başlayalım!" : "İleri") {
                    if coordinator.isLastStep {
                        coordinator.completeEducationalOnboarding()
                    } else {
                        coordinator.next()
                    }
                }
            }
            .padding()
        }
    }
}