FROM runpod/worker-comfyui:5.5.1-base

RUN comfy-node-install https://github.com/XLabs-AI/x-flux-comfyui.git
RUN comfy-node-install https://github.com/Fannovel16/comfyui_controlnet_aux.git
RUN apt-get update && apt-get install -y --no-install-recommends g++ python3-dev && rm -rf /var/lib/apt/lists/*
RUN rm -rf /comfyui/custom_nodes/ComfyUI-PuLID-Flux \
           /comfyui/custom_nodes/ComfyUI_PuLID_Flux \
           /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll \
 && git clone --depth 1 https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll \
 && grep -v '^insightface$' /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll/requirements.txt > /tmp/pulid-requirements.txt \
 && python -m pip install -r /tmp/pulid-requirements.txt \
 && python -m pip install insightface==0.7.3 \
 && python -m pip install facenet-pytorch --no-deps

RUN python - <<'INNER'
import os

package_root = '/comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll'
required_files = [
    '__init__.py',
    'pulidflux.py',
    'face_restoration_helper.py',
    'requirements.txt',
]

print('custom_nodes:', sorted(os.listdir('/comfyui/custom_nodes')))
print('checking package root:', package_root, 'exists=', os.path.isdir(package_root))
missing = [name for name in required_files if not os.path.exists(os.path.join(package_root, name))]
if missing:
    raise RuntimeError(f'Missing PuLID files: {missing}')
print('PuLID static validation ok')
INNER

RUN rm -rf /comfyui/models/clip  && ln -s /runpod-volume/models/base/clip /comfyui/models/clip  && rm -rf /comfyui/models/diffusion_models  && ln -s /runpod-volume/models/base/diffusion_models /comfyui/models/diffusion_models  && rm -rf /comfyui/models/vae  && ln -s /runpod-volume/models/base/vae /comfyui/models/vae  && rm -rf /comfyui/models/loras  && ln -s /runpod-volume/models/lora /comfyui/models/loras  && mkdir -p /runpod-volume/models/pulid  && mkdir -p /runpod-volume/models/xlabs/controlnets  && mkdir -p /runpod-volume/models/xlabs/ipadapters  && mkdir -p /runpod-volume/models/clip_vision  && mkdir -p /runpod-volume/models/insightface/models/antelopev2  && rm -rf /comfyui/models/pulid  && ln -s /runpod-volume/models/pulid /comfyui/models/pulid  && rm -rf /comfyui/models/xlabs  && ln -s /runpod-volume/models/xlabs /comfyui/models/xlabs  && rm -rf /comfyui/models/clip_vision  && ln -s /runpod-volume/models/clip_vision /comfyui/models/clip_vision  && rm -rf /comfyui/models/insightface  && ln -s /runpod-volume/models/insightface /comfyui/models/insightface
