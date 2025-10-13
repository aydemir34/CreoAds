// HeaderInfoView.swift
import SwiftUI

struct HeaderInfoView: View {
    // Bu View'a sadece kredi bilgisi lazım, doğrudan geçelim
    let credits: Int

    var body: some View {
        Text("Remaining Credits: \(credits)")
            .font(.headline)
            .padding(.top)
            // İleride buraya başka bilgiler de eklenebilir (örn: profil ikonu)
    }
}

// Preview ekleyebiliriz (isteğe bağlı ama faydalı)
#Preview {
    HeaderInfoView(credits: 10)
        .padding()
}





// MARK: Creater
//  HeaderInfoView.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 04/05/2025.
//

