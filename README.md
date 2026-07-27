# Mira Studio

Mira Studio 是只在這台 Mac 上執行的原生應用。你可以用中文自然語言描述畫面；應用會建立固定的蜜菈身份與動漫寫實提示，只有按下「生成圖片」時才呼叫 RunPod Serverless。

## 隱私與費用

- RunPod API Key 儲存在 macOS 鑰匙圈，不寫入專案或輸出檔。
- Endpoint 設為 `workersMin: 0`、`workersMax: 1`；沒有工作時 GPU 歸零。
- 圖片回傳後存到 `~/Pictures/Mira Studio/`。
- 模型會烘焙在 Serverless Docker image；不需要 RunPod Network Volume 月租，但容器 registry 仍會保存 image。
- 冷啟動、載入模型與生成期間仍會計費。

## 建置 Mac App

```bash
./scripts/build_app.sh
open "dist/Mira Studio.app"
```

第一次使用時，點右下角齒輪填入 RunPod Serverless Endpoint ID 與 API Key。

## Serverless 部署摘要

1. 在 GitHub Actions 手動執行 `Build Mira Studio Serverless image`；它會以 `Serverless/Dockerfile` 建立私人 GHCR image。
2. 在 RunPod 建立 Serverless Template，使用該 image。
3. 建立 Queue-based Endpoint：Active workers `0`、Max workers `1`、Idle timeout `5` 秒、FlashBoot 開啟。
4. 優先使用 RTX 4090；若價格與供應可接受，再把 RTX 5090 加為候選。
5. 把 Endpoint ID 填入 Mira Studio。

`Serverless/Dockerfile` 目前固定 WAI‑Illustrious v17 checkpoint 及其 SHA-256。蜜菈角色 LoRA 尚未訓練，因此工作流程暫時使用文字身份錨點；LoRA 完成後需加入 Docker image 並在 workflow 增加 LoRA Loader。

GitHub Actions 只允許手動啟動，不會因為一般 push 自動建置大型模型 image。

## 成人內容界線

所有尺度模式都固定角色為 28 歲、完全虛構、自願且具完整自主能力。應用會阻擋未成年、真人換臉、公眾人物與非自願描述。
