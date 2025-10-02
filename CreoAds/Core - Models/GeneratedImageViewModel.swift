import SwiftUI // Veya import Foundation yeterli olabilir
import UIKit  // UIImage için gerekli

// ViewModel'i Identifiable yap
class GeneratedImageViewModel: ObservableObject, Identifiable {
    // MARK: - Identifiable Conformance
    let id = UUID() // Benzersiz kimlik

    // MARK: - Published Properties
    @Published var generatedImage: UIImage
    @Published var originalPrompt: String
    // @Published var storageURL: URL? // İleride eklenebilir

    // MARK: - Initialization
    init(image: UIImage, prompt: String/*, storageURL: URL? = nil*/) {
        self.generatedImage = image
        self.originalPrompt = prompt
        // self.storageURL = storageURL
    }
}
