//
//  PhotoPicker.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 05/05/2025.
//
import SwiftUI
import PhotosUI
    // --- Fotoğraf Seçici ---
    struct PhotoPicker: UIViewControllerRepresentable {
        @Binding var selectedUIImage: UIImage?
        
        func makeCoordinator() -> Coordinator { Coordinator(self) }
        
        func makeUIViewController(context: Context) -> PHPickerViewController {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = context.coordinator
            return picker
        }
        
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
        
        class Coordinator: NSObject, PHPickerViewControllerDelegate {
            let parent: PhotoPicker
            
            init(_ parent: PhotoPicker) {
                self.parent = parent
            }
            
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                picker.dismiss(animated: true)
                guard let provider = results.first?.itemProvider else { return }
                
                if provider.canLoadObject(ofClass: UIImage.self) {
                    provider.loadObject(ofClass: UIImage.self) { image, _ in
                        DispatchQueue.main.async {
                            self.parent.selectedUIImage = image as? UIImage
                        }
                    }
                }
            }
        }
    }
