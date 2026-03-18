FROM runpod/worker-comfyui:5.5.1-base

# Volume-first worker:
# - base models live on the shared network volume
# - LoRAs live on the shared network volume
# - the image only contains ComfyUI runtime and symlinked model paths
#
# Identity / pose runtime:
# - install custom nodes required by txt2img_identity_ref.json / img2img_identity_ref.json
# - keep the heavy weights on /runpod-volume/models/...
RUN git clone https://github.com/XLabs-AI/x-flux-comfyui.git /comfyui/custom_nodes/x-flux-comfyui  && git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git /comfyui/custom_nodes/comfyui_controlnet_aux  && git clone https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll  && cd /comfyui/custom_nodes/x-flux-comfyui  && python -m pip install -r requirements.txt  && cd /comfyui/custom_nodes/comfyui_controlnet_aux  && python -m pip install huggingface_hub opencv-python Pillow numpy  && cd /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll  && python -m pip install -r requirements.txt  && python -m pip install facenet-pytorch --no-deps

RUN rm -rf /comfyui/models/clip  && ln -s /runpod-volume/models/base/clip /comfyui/models/clip  && rm -rf /comfyui/models/diffusion_models  && ln -s /runpod-volume/models/base/diffusion_models /comfyui/models/diffusion_models  && rm -rf /comfyui/models/vae  && ln -s /runpod-volume/models/base/vae /comfyui/models/vae  && rm -rf /comfyui/models/loras  && ln -s /runpod-volume/models/lora /comfyui/models/loras  && mkdir -p /runpod-volume/models/pulid  && mkdir -p /runpod-volume/models/xlabs/controlnets  && mkdir -p /runpod-volume/models/xlabs/ipadapters  && mkdir -p /runpod-volume/models/clip_vision  && mkdir -p /runpod-volume/models/insightface/models/antelopev2  && rm -rf /comfyui/models/pulid  && ln -s /runpod-volume/models/pulid /comfyui/models/pulid  && rm -rf /comfyui/models/xlabs  && mkdir -p /comfyui/models  && ln -s /runpod-volume/models/xlabs /comfyui/models/xlabs  && rm -rf /comfyui/models/clip_vision  && ln -s /runpod-volume/models/clip_vision /comfyui/models/clip_vision  && rm -rf /comfyui/models/insightface  && ln -s /runpod-volume/models/insightface /comfyui/models/insightface
