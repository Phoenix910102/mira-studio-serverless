import Foundation

enum WorkflowTemplate {
    static let json = #"""
    {
      "1": {
        "class_type": "CheckpointLoaderSimple",
        "inputs": { "ckpt_name": "waiIllustriousSDXL_v170.safetensors" }
      },
      "2": {
        "class_type": "CLIPTextEncode",
        "inputs": { "clip": ["1", 1], "text": "__POSITIVE__" }
      },
      "3": {
        "class_type": "CLIPTextEncode",
        "inputs": { "clip": ["1", 1], "text": "__NEGATIVE__" }
      },
      "4": {
        "class_type": "EmptyLatentImage",
        "inputs": { "width": 1024, "height": 1536, "batch_size": 1 }
      },
      "5": {
        "class_type": "KSampler",
        "inputs": {
          "seed": 28072026,
          "steps": 28,
          "cfg": 6.0,
          "sampler_name": "euler_ancestral",
          "scheduler": "normal",
          "denoise": 1.0,
          "model": ["1", 0],
          "positive": ["2", 0],
          "negative": ["3", 0],
          "latent_image": ["4", 0]
        }
      },
      "6": {
        "class_type": "VAEDecode",
        "inputs": { "samples": ["5", 0], "vae": ["1", 2] }
      },
      "7": {
        "class_type": "SaveImage",
        "inputs": { "filename_prefix": "mira-studio", "images": ["6", 0] }
      }
    }
    """#
}
