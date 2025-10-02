import SwiftUI

// Bir View'ın çerçevesini (frame) okumak için kullanılan PreferenceKey.
// Değer tipi olarak basit ve tutarlı bir şekilde [String: CGRect] kullanıyoruz.
struct FramePreferenceKey: PreferenceKey {
    typealias Value = [String: CGRect]
    static var defaultValue: Value = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Herhangi bir View'a .readFrame(...) modifier'ını ekleyen uzantı.
extension View {
    func readFrame(in coordinateSpace: CoordinateSpace, for key: String) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: [key: geometry.frame(in: coordinateSpace)])
            }
        )
    }
}
