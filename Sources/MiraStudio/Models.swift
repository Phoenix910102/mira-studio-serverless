import Foundation

enum AdultLevel: String, CaseIterable, Identifiable {
    case glamour
    case adult
    case highAdult

    var id: String { rawValue }

    var label: String {
        switch self {
        case .glamour: return "精緻性感"
        case .adult: return "成人向"
        case .highAdult: return "高尺度成人"
        }
    }

    var ratingTag: String {
        switch self {
        case .glamour: return "sensitive"
        case .adult: return "nsfw"
        case .highAdult: return "explicit"
        }
    }
}

enum CanvasPreset: String, CaseIterable, Identifiable {
    case portrait
    case square
    case landscape

    var id: String { rawValue }

    var label: String {
        switch self {
        case .portrait: return "直式 2:3"
        case .square: return "方形 1:1"
        case .landscape: return "橫式 3:2"
        }
    }

    var size: (width: Int, height: Int) {
        switch self {
        case .portrait: return (1024, 1536)
        case .square: return (1024, 1024)
        case .landscape: return (1536, 1024)
        }
    }
}

struct CompiledPrompt {
    let positive: String
    let negative: String
}

struct RunPodEnvelope: Decodable {
    let id: String?
    let status: String
    let output: RunPodOutput?
    let error: String?
}

struct RunPodOutput: Decodable {
    let images: [RunPodImage]?
    let errors: [String]?
}

struct RunPodImage: Decodable {
    let filename: String
    let type: String
    let data: String
}

enum StudioError: LocalizedError {
    case missingSettings
    case blockedPrompt(String)
    case invalidWorkflow
    case invalidResponse(String)
    case noImage

    var errorDescription: String? {
        switch self {
        case .missingSettings:
            return "請先在設定中填入 RunPod Endpoint ID 與 API Key。"
        case .blockedPrompt(let reason):
            return "這個描述無法送出：\(reason)"
        case .invalidWorkflow:
            return "內建工作流程讀取失敗。"
        case .invalidResponse(let message):
            return "RunPod 回傳錯誤：\(message)"
        case .noImage:
            return "工作已完成，但沒有收到圖片。"
        }
    }
}
