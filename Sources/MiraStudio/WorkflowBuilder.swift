import Foundation

struct WorkflowBuilder {
    func build(prompt: CompiledPrompt, canvas: CanvasPreset, seed: UInt64) throws -> [String: Any] {
        guard let data = WorkflowTemplate.json.data(using: .utf8),
              var workflow = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw StudioError.invalidWorkflow
        }

        try setInput(&workflow, node: "2", key: "text", value: prompt.positive)
        try setInput(&workflow, node: "3", key: "text", value: prompt.negative)
        try setInput(&workflow, node: "4", key: "width", value: canvas.size.width)
        try setInput(&workflow, node: "4", key: "height", value: canvas.size.height)
        try setInput(&workflow, node: "5", key: "seed", value: seed)
        return workflow
    }

    private func setInput(_ workflow: inout [String: Any], node: String, key: String, value: Any) throws {
        guard var nodeObject = workflow[node] as? [String: Any],
              var inputs = nodeObject["inputs"] as? [String: Any] else {
            throw StudioError.invalidWorkflow
        }
        inputs[key] = value
        nodeObject["inputs"] = inputs
        workflow[node] = nodeObject
    }
}
