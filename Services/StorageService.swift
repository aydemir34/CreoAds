//
//  StorageService.swift
//  Own Advertiser
//
//  Created by Ömer F. Aydemir on 17/04/2025.
//


import Foundation
import FirebaseStorage
import UIKit // For UIImage

/// Enum defining potential errors during storage operations.
public enum StorageError: Error, LocalizedError {
    /// Failed to convert UIImage to Data.
    case imageDataConversionFailed
    /// Failed to upload the image data to Firebase Storage. Includes the underlying error.
    case uploadFailed(Error?)
    /// Failed to set metadata (though less common with putDataAsync which handles it).
    case metadataError // Kept for potential future use or different upload methods
    /// Failed to retrieve the download URL after uploading.
    case downloadURLNotFound
    /// Could not get user ID (if needed internally, though passed as param here).
    case couldNotGetUser

    public var errorDescription: String? {
        switch self {
        case .imageDataConversionFailed:
            return NSLocalizedString("Could not convert image to data format.", comment: "Storage Error")
        case .uploadFailed(let error):
            let baseMessage = NSLocalizedString("Image upload failed.", comment: "Storage Error")
            if let specificError = error?.localizedDescription {
                return "\(baseMessage) Reason: \(specificError)"
            } else {
                return baseMessage
            }
        case .metadataError:
            return NSLocalizedString("Failed to set image metadata during upload.", comment: "Storage Error")
        case .downloadURLNotFound:
            return NSLocalizedString("Could not retrieve the download URL for the uploaded image.", comment: "Storage Error")
        case .couldNotGetUser:
             return NSLocalizedString("Could not identify the current user for upload.", comment: "Storage Error")
        }
    }
}

/// Service class responsible for interacting with Firebase Storage.
final class StorageService {

    /// A reference to the Firebase Storage service.
    private let storage = Storage.storage()

    /// Uploads a given image to Firebase Storage under the specified user's folder.
    /// - Parameters:
    ///   - image: The `UIImage` to upload.
    ///   - userId: The unique identifier of the user uploading the image.
    /// - Returns: The public `URL` of the uploaded image in Firebase Storage.
    /// - Throws: A `StorageError` if any part of the process fails (conversion, upload, URL retrieval).
    public func uploadImage(image: UIImage, userId: String) async throws -> URL {
        // 1. Convert UIImage to Data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Failed to convert UIImage to JPEG data.")
            throw StorageError.imageDataConversionFailed
        }

        // 2. Create a unique file name
        let uniqueFileName = UUID().uuidString + ".jpg" // Ensure file extension

        // 3. Create a StorageReference
        // Points to a path like "user_uploads/{userId}/{uniqueFileName}.jpg"
        let storageRef = storage.reference().child("user_uploads").child(userId).child(uniqueFileName)

        // 4. Upload the image data using modern async/await
        print("Attempting to upload image to: \(storageRef.fullPath)")
        do {
            // The 'putDataAsync' method handles metadata implicitly for content type if possible.
            // You can optionally add custom metadata here if needed.
            // let metadata = StorageMetadata()
            // metadata.contentType = "image/jpeg" // Usually inferred correctly
            // _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            
            _ = try await storageRef.putDataAsync(imageData) // Simpler call if no custom metadata needed
            print("Image uploaded successfully.")
        } catch {
            print("Error: Image upload failed. \(error.localizedDescription)")
            throw StorageError.uploadFailed(error) // Pass the underlying error
        }

        // 5. Get the download URL
        do {
            let downloadURL = try await storageRef.downloadURL()
            print("Successfully retrieved download URL: \(downloadURL)")
            return downloadURL
        } catch {
            print("Error: Failed to get download URL. \(error.localizedDescription)")
            throw StorageError.downloadURLNotFound
        }
    }

    // --- Optional: Add functions for downloading or deleting images later ---
    // func downloadImage(from url: URL) async throws -> UIImage { ... }
    // func deleteImage(at path: String) async throws { ... }
}
