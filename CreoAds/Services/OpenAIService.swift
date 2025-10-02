// OpenAIService.swift
import Foundation
import UIKit

// Hata enum'unu biraz daha detaylandıralım ve GPT-4o odaklı yapalım
enum OpenAIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse(statusCode: Int)
    case dataDecodingError(Error)
    case imageEncodingFailed // Input görseli kodlarken hata
    case generatedContentMissing // Yanıtta beklenen içerik yok
    case invalidGeneratedURL // Yanıttaki içerik geçerli bir URL değil
    case imageDownloadFailed(Error) // Üretilen görseli indirirken hata
    case imageConversionError // İndirilen veriyi UIImage'a çevirirken hata
    case apiKeyMissing
    case apiError(String) // API'den gelen özel hata mesajı
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .requestFailed(let error):
            return "API request failed: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Received an invalid HTTP response: \(statusCode)."
        case .dataDecodingError(let error):
            return "Failed to decode the server response: \(error.localizedDescription)"
        case .imageEncodingFailed:
            return "Failed to encode the input image to base64."
        case .generatedContentMissing:
            return "Generated content (expected image URL) was not found in the API response."
        case .invalidGeneratedURL:
             return "The content received from the API was not a valid URL."
        case .imageDownloadFailed(let error):
            return "Failed to download the generated image: \(error.localizedDescription)"
        case .imageConversionError:
            return "Failed to convert downloaded data to an image."
        case .apiKeyMissing:
            return "OpenAI API Key is missing or invalid."
        case .apiError(let message):
            return "OpenAI API Error: \(message)"
        case .unknown: // <<< BU CASE İÇİN AÇIKLAMA EKLE
                    return "An unknown error occurred."
        }
    }
}

// OpenAI'nin standart hata yanıtı için yardımcı struct (Daha önce eklenmişti, kontrol et)
struct OpenAIAPIErrorResponse: Codable {
    let error: APIErrorDetail
    struct APIErrorDetail: Codable {
        let message: String
        let type: String?
        let param: String?
        let code: String?
    }
}


class OpenAIService { // Class olarak kullanalım

    // !!! DİKKAT: API Anahtarını GÜVENDE TUT !!!
    // Senin paylaştığın anahtarı kullanıyorum, GİT'E GÖNDERME!
    private let apiKey = "TestAPIKey" // <-- SENİN ANAHTARIN

    // Geliştirme sırasında gerçek API'yi kullanıp kullanmayacağımızı belirleyen bayrak
    private let useRealAPI = false // <-- GERÇEK TEST İÇİN 'true' YAP

    // --- GPT-4o Chat Completions için Yapılar (Senin kodundan alındı) ---
    struct ChatCompletionRequest: Codable {
        let model: String
        let messages: [Message]
        let max_tokens: Int? // Yanıt token limitini ayarlamak önemli olabilir

        struct Message: Codable {
            let role: String // "system", "user"
            let content: [Content] // GPT-4o için içerik dizisi

            struct Content: Codable {
                let type: String // "text" veya "image_url"
                let text: String?
                let image_url: ImageURL?

                struct ImageURL: Codable {
                    let url: String // "data:image/jpeg;base64,..." formatında olabilir
                }
            }
        }
    }

    struct ChatCompletionResponse: Codable {
        let choices: [Choice]
        // Diğer alanlar (usage vb.) eklenebilir
        struct Choice: Codable {
            let message: ResponseMessage // Yanıt mesajı
            // finish_reason vb. eklenebilir
            struct ResponseMessage: Codable {
                let role: String // "assistant"
                let content: String? // Modelin yanıtı (URL bekliyoruz?)
            }
        }
    }
    // --- GPT-4o Yapıları Sonu ---

    /// Helper: UIImage'ı base64 JPEG string'e çevirir (Senin kodundan)
    private func base64JPEG(from image: UIImage, quality: CGFloat = 0.7) -> String? { // Kaliteyi biraz artırdım
        guard let jpegData = image.jpegData(compressionQuality: quality) else { return nil }
        return jpegData.base64EncodedString()
    }

    // Ana fonksiyon: Metin prompt'u ve input görsel ile reklam görseli üretir (GPT-4o kullanarak)
    func generateAdvertisementImage(prompt: String, inputImage: UIImage) async throws -> UIImage {
        print("[OpenAIService] generateAdvertisementImage (GPT-4o) called.")
        print("[OpenAIService] Prompt: \(prompt)")

        // --- Kredi Koruması İçin Simülasyon Bloğu ---
        if !useRealAPI {
            print("[OpenAIService] Using SIMULATED response (useRealAPI is false).")
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 saniye bekle
            return await createSampleGeneratedImage() // Simüle edilmiş görsel
        }
        // --- Simülasyon Bloğu Sonu ---

        // --- GERÇEK GPT-4o API ÇAĞRISI ---
        print("[OpenAIService] Preparing REAL GPT-4o API call...")

        guard !apiKey.isEmpty, !apiKey.contains("YOUR_OPENAI_API_KEY") else { // Placeholder kontrolü
            print("[OpenAIService] API Key is missing or placeholder!")
            throw OpenAIError.apiKeyMissing
        }

        // 1. Input Görseli Base64'e Çevir
        guard let base64ImageString = base64JPEG(from: inputImage) else {
            print("[OpenAIService] Failed to encode input image to base64.")
            throw OpenAIError.imageEncodingFailed
        }
        let imageDataURL = "data:image/jpeg;base64,\(base64ImageString)"
        print("[OpenAIService] Input image encoded to base64 (length: \(imageDataURL.count)).")


        // 2. API Endpoint (Chat Completions)
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw OpenAIError.invalidURL // Bu aslında olmamalı
        }

        // 3. İstek Gövdesini (Payload) Oluşturma
        // System prompt'u görsel üretme görevini açıkça belirtmeli
        // ve yanıt formatını (URL?) istemeli.
        let systemMessage = ChatCompletionRequest.Message.Content(
            type: "text",
            text: """
            You are an expert advertisement designer.
            Generate a compelling visual advertisement based on the user's product image and description.
            The output should be a high-quality image.
            Respond ONLY with the URL of the generated image. Do not include any other text, explanation, or markdown formatting.
            """,
            image_url: nil
        )

        let userMessageContent: [ChatCompletionRequest.Message.Content] = [
            .init(type: "text", text: prompt, image_url: nil), // Kullanıcının açıklaması
            .init(type: "image_url", text: nil, image_url: .init(url: imageDataURL)) // Kullanıcının görseli (base64)
        ]

        let requestBody = ChatCompletionRequest(
            model: "gpt-4o", // En güncel modeli kullan
            messages: [
                .init(role: "system", content: [systemMessage]), // Sistem mesajı
                .init(role: "user", content: userMessageContent) // Kullanıcı mesajı (metin + görsel)
            ],
            max_tokens: 150 // Yanıt olarak sadece URL beklediğimiz için düşük tutabiliriz
                           // Eğer base64 dönerse artırmak gerekebilir.
        )

        // 4. URLRequest Hazırlığı
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120.0 // Görsel işleme ve üretme uzun sürebilir

        do {
            let encoder = JSONEncoder()
            // encoder.outputFormatting = .prettyPrinted // Debug için açılabilir
            request.httpBody = try encoder.encode(requestBody)
            // if let body = request.httpBody, let jsonString = String(data: body, encoding: .utf8) {
            //     print("[OpenAIService] Request Body JSON:\n\(jsonString)") // Debug için
            // }
        } catch {
            print("[OpenAIService] Error encoding GPT-4o request body: \(error)")
            throw OpenAIError.requestFailed(error) // Genellikle programlama hatası
        }

        // 5. API İsteğini Gönderme ve Yanıtı Alma
        print("[OpenAIService] Sending request to GPT-4o API...")
        let data: Data
        let response: URLResponse
        do {
             (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            print("[OpenAIService] Network error during GPT-4o call: \(error)")
            throw OpenAIError.requestFailed(error)
        }

        // Yanıtı kontrol et (HTTP Status Code)
        guard let httpResponse = response as? HTTPURLResponse else {
            print("[OpenAIService] Invalid response type received.")
            throw OpenAIError.invalidResponse(statusCode: -1)
        }

        print("[OpenAIService] Received HTTP status: \(httpResponse.statusCode)")

        // Yanıt verisini JSON olarak çözümle
        let decoder = JSONDecoder()
        do {
            // Başarılı durum (200 OK)
            if httpResponse.statusCode == 200 {
                let decodedResponse = try decoder.decode(ChatCompletionResponse.self, from: data)

                // Yanıttan içeriği (beklenen URL) al
                guard let generatedContent = decodedResponse.choices.first?.message.content?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !generatedContent.isEmpty else {
                    print("[OpenAIService] Generated content is missing or empty in GPT-4o response.")
                    if let responseString = String(data: data, encoding: .utf8) { print("Raw Response: \(responseString)") } // Ham yanıtı logla
                    throw OpenAIError.generatedContentMissing
                }

                print("[OpenAIService] Received content from GPT-4o: \(generatedContent)")

                // İçeriğin geçerli bir URL olup olmadığını kontrol et
                guard let imageURL = URL(string: generatedContent),
                      (imageURL.scheme == "http" || imageURL.scheme == "https") else {
                    print("[OpenAIService] Received content is not a valid HTTP/HTTPS URL.")
                     // Belki base64 döndü? Veya başka bir format? Şimdilik hata verelim.
                     // TODO: Yanıt formatı URL değilse burayı güncellemek gerekebilir.
                    throw OpenAIError.invalidGeneratedURL
                }

                print("[OpenAIService] Generated image URL identified: \(imageURL)")

                // 6. Üretilen Görsel URL'sinden Görseli İndirme
                print("[OpenAIService] Downloading generated image...")
                let (imageData, _) = try await URLSession.shared.data(from: imageURL)

                // 7. Veriyi UIImage'a Dönüştürme
                guard let image = UIImage(data: imageData) else {
                    print("[OpenAIService] Failed to convert downloaded data to UIImage.")
                    throw OpenAIError.imageConversionError
                }

                print("[OpenAIService] Generated image successfully downloaded and converted.")
                return image

            } else {
                // Hatalı durum (200 dışında bir kod)
                if let errorResponse = try? decoder.decode(OpenAIAPIErrorResponse.self, from: data) {
                     print("[OpenAIService] GPT-4o API Error: \(errorResponse.error.message)")
                     throw OpenAIError.apiError(errorResponse.error.message)
                } else {
                     print("[OpenAIService] Received non-200 status code (\(httpResponse.statusCode)) but couldn't decode error response.")
                     if let responseString = String(data: data, encoding: .utf8) { print("Raw Response: \(responseString)") } // Ham yanıtı logla
                     throw OpenAIError.invalidResponse(statusCode: httpResponse.statusCode)
                }
            }
        } catch let error as OpenAIError {
             throw error // Kendi hatalarımızı tekrar fırlat
        } catch {
             print("[OpenAIService] Error decoding GPT-4o response: \(error)")
             if let responseString = String(data: data, encoding: .utf8) { print("Raw Response: \(responseString)") } // Ham yanıtı logla
             throw OpenAIError.dataDecodingError(error)
        }
        // --- GERÇEK GPT-4o API ÇAĞRISI SONU ---
    }


    // SİMÜLASYON AMAÇLI YARDIMCI FONKSİYON
    private func createSampleGeneratedImage() async -> UIImage {
        let size = CGSize(width: 1024, height: 1024) // GPT-4o/DALL-E boyutuna uygun
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.systemGreen.setFill() // Farklı bir renk
            ctx.fill(CGRect(origin: .zero, size: size))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white
            ]
            let string = "Generated Ad\n(GPT-4o Simulated)"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            attributedString.draw(with: CGRect(x: 0, y: size.height / 2 - 60, width: size.width, height: 120), options: .usesLineFragmentOrigin, context: nil)
        }
        return image
    }
}
