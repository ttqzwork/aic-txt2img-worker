FROM runpod/worker-comfyui:5.5.1-base

# Install custom nodes using the supported worker-comfyui helper.
# Use repo URLs directly so RunPod's Git build accepts the Dockerfile shape.
RUN comfy-node-install https://github.com/XLabs-AI/x-flux-comfyui.git
RUN comfy-node-install https://github.com/Fannovel16/comfyui_controlnet_aux.git
RUN comfy-node-install https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git
RUN python -m pip install facenet-pytorch --no-deps

# Use shared volume for all models.
RUN rm -rf /comfyui/models/clip  && ln -s /runpod-volume/models/base/clip /comfyui/models/clip  && rm -rf /comfyui/models/diffusion_models  && ln -s /runpod-volume/models/base/diffusion_models /comfyui/models/diffusion_models  && rm -rf /comfyui/models/vae  && ln -s /runpod-volume/models/base/vae /comfyui/models/vae  && rm -rf /comfyui/models/loras  && ln -s /runpod-volume/models/lora /comfyui/models/loras  && mkdir -p /runpod-volume/models/pulid  && mkdir -p /runpod-volume/models/xlabs/controlnets  && mkdir -p /runpod-volume/models/xlabs/ipadapters  && mkdir -p /runpod-volume/models/clip_vision  && mkdir -p /runpod-volume/models/insightface/models/antelopev2  && rm -rf /comfyui/models/pulid  && ln -s /runpod-volume/models/pulid /comfyui/models/pulid  && rm -rf /comfyui/models/xlabs  && ln -s /runpod-volume/models/xlabs /comfyui/models/xlabs  && rm -rf /comfyui/models/clip_vision  && ln -s /runpod-volume/models/clip_vision /comfyui/models/clip_vision  && rm -rf /comfyui/models/insightface  && ln -s /runpod-volume/models/insightface /comfyui/models/insightface
