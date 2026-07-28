FROM runpod/worker-comfyui:5.8.6-base

RUN comfy model download \
    --url https://huggingface.co/IbarakiDouji/WAI-NSFW-illustrious-SDXL/resolve/main/waiIllustriousSDXL_v170.safetensors \
    --relative-path models/checkpoints \
    --filename waiIllustriousSDXL_v170.safetensors \
    && echo "f116b0c78ff441467b0cdc8f1936e1ed18ea31e9997c7b132b1b8db533f0bd04  /comfyui/models/checkpoints/waiIllustriousSDXL_v170.safetensors" | sha256sum -c -

# 蜜菈 LoRA 完成後可加入：
# COPY models/mira_vesper_v1.safetensors /comfyui/models/loras/mira_vesper_v1.safetensors
