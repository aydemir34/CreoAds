//
//  OnboardingCompletionView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 12/09/2025.
//

import SwiftUI

// Bu View artık sadece görsel bir bileşen, herhangi bir servis bağımlılığı yok.
struct OnboardingCompletionView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Harika!")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Text("Artık yaratmaya hazırsınız.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

struct OnboardingCompletionView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCompletionView()
    }
}
