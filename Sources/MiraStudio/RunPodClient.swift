import Foundation

struct RunPodClient {
    func generate(endpointID: String, apiKey: String, workflow: [String: Any]) async throws -> URL {
        guard let url = URL(string: "https://api.runpod.ai/v2/\(endpointID)/runsync") else {
            throw StudioError.invalidResponse("Endpoint ID 格式不正確。")
        }

        let body: [String: Any] = [
            "input": ["workflow": workflow],
            "policy": ["executionTimeout": 900_000, "ttl": 1_800_000]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 950
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP 錯誤"
            throw StudioError.invalidResponse(message)
        }

        let envelope = try JSONDecoder().decode(RunPodEnvelope.self, from: data)
        guard envelope.status == "COMPLETED" else {
            throw StudioError.invalidResponse(envelope.error ?? envelope.status)
        }
        guard let image = envelope.output?.images?.first else {
            throw StudioError.noImage
        }

        let imageData: Data
        if image.type == "base64" {
            let raw = image.data.components(separatedBy: ",").last ?? image.data
            guard let decoded = Data(base64Encoded: raw) else { throw StudioError.noImage }
            imageData = decoded
        } else if image.type == "s3_url", let remoteURL = URL(string: image.data) {
            let (downloaded, _) = try await URLSession.shared.data(from: remoteURL)
            imageData = downloaded
        } else {
            throw StudioError.invalidResponse("不支援的圖片格式：\(image.type)")
        }

        let pictures = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask).first!
        let folder = pictures.appendingPathComponent("Mira Studio", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let filename = "mira-\(formatter.string(from: Date())).png"
        let outputURL = folder.appendingPathComponent(filename)
        try imageData.write(to: outputURL, options: .atomic)
        return outputURL
    }
}
