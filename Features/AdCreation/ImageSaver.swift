//
//  ImageSaver.swift
//  CreoAds
//
//  Created by Ömer F. Aydemir on 05/05/2025.
//
import UIKit

// --- Görsel Kaydedici ---
    class ImageSaver: NSObject {
        var successHandler: (() -> Void)?
        var errorHandler: ((Error) -> Void)?
        
        func writeToPhotoAlbum(image: UIImage, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
            self.successHandler = onSuccess
            self.errorHandler = onError
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }
        
        @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                print("[ImageSaver] Error saving image: \(error.localizedDescription)")
                errorHandler?(error)
            } else {
                print("[ImageSaver] Image saved successfully.")
                successHandler?()
            }
            // Handler'ları temizle
            self.successHandler = nil
            self.errorHandler = nil
        }
    }
