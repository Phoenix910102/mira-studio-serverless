import Foundation

struct PromptCompiler {
    private let blockedTerms = [
        "未成年", "兒童", "小孩", "幼女", "蘿莉", "學生妹", "校服", "強迫", "不情願",
        "昏迷", "偷拍", "真人換臉", "名人", "公眾人物", "barely legal", "underage",
        "child", "teen", "teenager", "loli", "schoolgirl", "non-consensual", "rape",
        "celebrity", "real person", "deepfake"
    ]

    private let keywordTags: [(String, String)] = [
        ("全身", "full body"), ("半身", "waist-up portrait"), ("近景", "close-up portrait"),
        ("正面", "front view"), ("側面", "side view"), ("背面", "back view"),
        ("站", "standing"), ("坐", "sitting"), ("躺", "reclining"),
        ("臥室", "luxury bedroom"), ("浴室", "luxury bathroom"), ("夜景", "city lights at night"),
        ("酒吧", "upscale bar"), ("飯店", "luxury hotel suite"), ("攝影棚", "studio backdrop"),
        ("露肩", "off-shoulder outfit"), ("低胸", "deep neckline"), ("高衩", "high side slit"),
        ("絲襪", "sheer black stockings"), ("長靴", "thigh-high boots"), ("晚禮服", "evening gown"),
        ("內衣", "luxury fantasy lingerie"), ("絲綢", "silk fabric"), ("皮革", "black leather"),
        ("害羞", "slightly bashful expression"), ("微笑", "warm smile"),
        ("自信", "confident adult expression"), ("誘惑", "alluring adult gaze"),
        ("柔光", "soft cinematic lighting"), ("逆光", "dramatic rim light"),
        ("寫實", "semi-realistic rendering"), ("日系", "Japanese fantasy character art")
    ]

    func compile(_ naturalLanguage: String, level: AdultLevel) throws -> CompiledPrompt {
        let normalized = naturalLanguage.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = normalized.lowercased()

        if let term = blockedTerms.first(where: { lowered.contains($0.lowercased()) }) {
            throw StudioError.blockedPrompt("包含受限制內容「\(term)」。僅支援明確成年、虛構且自願的角色。")
        }

        let translatedTags = keywordTags
            .filter { normalized.contains($0.0) }
            .map(\.1)

        let identity = [
            "1girl", "original character", level.ratingTag, "solo",
            "clearly adult woman", "28 years old", "mature feminine face",
            "tall mature adult proportions", "elegant curvy adult figure",
            "fully fictional", "confident autonomous adult woman",
            "long wavy deep burgundy hair", "center part", "golden almond-shaped eyes",
            "two short smooth black obsidian succubus horns close to the hairline",
            "tiny golden five-point star-shaped magical mark below her left eye",
            "Mira Vesper"
        ]

        let style = [
            "semi-realistic anime", "2.5D painterly anime rendering",
            "realistic adult facial proportions", "detailed individual hair strands",
            "dimensional natural skin shading", "physically believable fabric and metal",
            "high-end Japanese fantasy RPG character key art", "cinematic lighting",
            "masterpiece", "best quality", "amazing quality", "absurdres"
        ]

        var positiveParts = identity + translatedTags
        if !normalized.isEmpty {
            positiveParts.append("scene requested by the user: \(normalized)")
        }
        positiveParts += style

        var negative = [
            "child", "teenager", "underage", "young-looking", "baby face",
            "childish proportions", "loli", "school uniform", "school setting",
            "real person", "celebrity", "public figure", "deepfake", "non-consensual",
            "violence", "injury", "unconscious", "intoxicated", "age regression",
            "large horns", "oversized horns", "extra horns", "golden horns",
            "multiple people", "multiple faces", "extra limbs", "bad hands",
            "bad anatomy", "low quality", "worst quality", "blurry", "text",
            "watermark", "signature", "censor bar", "mosaic censor"
        ]

        if level == .glamour {
            negative += ["nudity", "nipples", "areola", "explicit sexual content"]
        } else if level == .adult {
            negative += ["explicit sexual act"]
        }

        return CompiledPrompt(
            positive: positiveParts.joined(separator: ", "),
            negative: negative.joined(separator: ", ")
        )
    }
}
