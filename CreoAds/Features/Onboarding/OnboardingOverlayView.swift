import SwiftUI

struct OnboardingOverlayView: View {
    // Artık sildiğimiz Coordinator yerine, projemizin tek hakimi olan OnboardingService'i kullanıyoruz.
    @EnvironmentObject var coordinator: OnboardingCoordinator
    
    let imageFrame: CGRect
    let editorFrame: CGRect
    let actionFrame: CGRect
    
    var body: some View {
        let (currentFrame, tooltipText) = frameAndText(for: coordinator.currentStep)
        
        if let frame = currentFrame, let text = tooltipText, frame.size.width > 10 {
            
            // GeometryReader, overlay'in kendi yerel koordinat sistemini almamızı sağlar.
            // Bu, konumlandırmayı daha güvenilir hale getirir.
            GeometryReader { geometry in
                let localHighlightFrame = CGRect(
                    x: frame.minX - geometry.frame(in: .global).minX,
                    y: frame.minY - geometry.frame(in: .global).minY,
                    width: frame.width,
                    height: frame.height
                )
                
                ZStack {
                    overlayBoxes(for: localHighlightFrame, in: geometry.size)
                    TooltipView(text: text, highlightFrame: localHighlightFrame)
                }
                .ignoresSafeArea()
            }
            .transition(.opacity)
            .animation(.easeInOut, value: coordinator.currentStep)
            .allowsHitTesting(false)
        }
    }

    private func frameAndText(for step: OnboardingStep) -> (CGRect?, String?) {
        switch step {
        // Artık bu adımlar OnboardingStep enum'ında mevcut olduğu için hata vermeyecek.
        case .welcome:
            return (imageFrame, "1. Adım: Bir ürün fotoğrafı seçerek başlayın.")
        case .photoGuide:
            return (editorFrame, "2. Adım: Hayalinizdeki reklamı birkaç kelimeyle anlatın.")
        case .promptGuide:
            return (actionFrame, "3. Adım: 'Create Ad' butonuna basarak sihrin gerçekleşmesini izleyin.")
        case .styleGuide:
            return (nil, nil)
        }
    }
    
    @ViewBuilder
    private func overlayBoxes(for frame: CGRect, in size: CGSize) -> some View {
        // Üst Kutu
        Color.black.opacity(0.6)
            .frame(width: size.width, height: frame.minY)
            .position(x: size.width / 2, y: frame.minY / 2)
        // Alt Kutu
        Color.black.opacity(0.6)
            .frame(width: size.width, height: size.height - frame.maxY)
            .position(x: size.width / 2, y: frame.maxY + (size.height - frame.maxY) / 2)
        
        // Sol Kutu
        Color.black.opacity(0.6)
            .frame(width: frame.minX, height: frame.height)
            .position(x: frame.minX / 2, y: frame.midY)
        // Sağ Kutu
        Color.black.opacity(0.6)
            .frame(width: size.width - frame.maxX, height: frame.height)
            .position(x: frame.maxX + (size.width - frame.maxX) / 2, y: frame.midY)
    }
}


struct TooltipView: View {
    let text: String
    let highlightFrame: CGRect
    
    var body: some View {
        // GeometryReader, ebeveyn view'ın (TooltipView'ın yerleştirildiği ZStack)
        // boyutlarını ve güvenli alanını verir.
        GeometryReader { geometry in
            Text(text)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.3) ,radius: 10)
                .padding(.horizontal)
                .position(x: geometry.size.width / 2, y: positionY(in: geometry))
                .transition(.opacity.combined(with: .offset(y: offsetAmount(in: geometry))))
        }
    }
    
    // Metin kutusunun dikey konumunu hesaplayan fonksiyon
    private func positionY(in geometry: GeometryProxy) -> CGFloat {
        let safeAreaTop = geometry.safeAreaInsets.top
        let screenHeight = geometry.size.height
        
        // Eğer vurgulanan alan ekranın üst yarısındaysa, metni altına koy.
        if highlightFrame.midY < screenHeight / 2 {
            return highlightFrame.maxY + 60
        } else {
            // Değilse, üstüne koy ve güvenli alanın altına sarkmasını engelle
            let proposedY = highlightFrame.minY - 60
            return max(proposedY, safeAreaTop + 40) // Güvenli alanın 40 puan altında kalsın
        }
    }
    
    // Animasyon için offset miktarını hesaplayan fonksiyon
    private func offsetAmount(in geometry: GeometryProxy) -> CGFloat {
        if highlightFrame.midY < geometry.size.height / 2 {
            return 20
        } else {
            return -20
        }
    }
}
