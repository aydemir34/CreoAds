import SwiftUI

struct DescriptionEditorArea: View {
    @Binding var adDescription: String
    let onFocusChanged: (Bool) -> Void
    @FocusState private var editorIsInternallyFocused: Bool
    
    let gradientRotation: Double
    let focusedBorderRotation: Double
    let rainbowColors: [Color]
    let dynamicGradientColors: [Color]
    
    private var isFocusedComputed: Bool {
        return editorIsInternallyFocused
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ad Description")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.leading, 5)
            
            ZStack {
                // TextEditor
                Group {
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $adDescription)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .focused($editorIsInternallyFocused)
                    } else {
                        TextEditor(text: $adDescription)
                            .padding(8)
                            .focused($editorIsInternallyFocused)
                    }
                }
                .background(Color.clear)
            }
            .frame(height: 120)
            .background(
                .ultraThinMaterial.opacity(isFocusedComputed ? 0.9 : 0.6),
                in: RoundedRectangle(cornerRadius: 10)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: isFocusedComputed ? rainbowColors : dynamicGradientColors),
                            center: .center,
                            angle: .degrees(isFocusedComputed ? focusedBorderRotation : gradientRotation)
                        ),
                        lineWidth: isFocusedComputed ? 2.5 : 2
                    )
            )
            .background(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: EditorFramePreferenceKey.self, value: geometryProxy.frame(in: .global))
                }
            )
        }
        .onChange(of: editorIsInternallyFocused) { newValue in
            print("DEBUG: DescriptionEditorArea - editorIsInternallyFocused: \(newValue)")
            onFocusChanged(newValue)
        }
    }
}
