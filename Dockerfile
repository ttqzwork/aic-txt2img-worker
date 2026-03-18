FROM runpod/worker-comfyui:5.5.1-base

RUN comfy-node-install https://github.com/XLabs-AI/x-flux-comfyui.git
RUN comfy-node-install https://github.com/Fannovel16/comfyui_controlnet_aux.git
RUN rm -rf /comfyui/custom_nodes/ComfyUI-PuLID-Flux \
           /comfyui/custom_nodes/ComfyUI_PuLID_Flux \
           /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll \
 && git clone --depth 1 https://github.com/lldacing/ComfyUI_PuLID_Flux_ll.git /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll \
 && python -m pip install -r /comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll/requirements.txt \
 && python -m pip install insightface==0.7.3 \
 && python -m pip install opencv-python-headless \
 && python -m pip install facenet-pytorch --no-deps

RUN python - <<'INNER'
import os, sys, traceback
sys.path.insert(0, '/comfyui/custom_nodes')
package_root='/comfyui/custom_nodes/ComfyUI_PuLID_Flux_ll'
print('custom_nodes:', sorted(os.listdir('/comfyui/custom_nodes')))
print('checking package root:', package_root, 'exists=', os.path.isdir(package_root))
try:
    import ComfyUI_PuLID_Flux_ll as mod
    pulid_nodes=sorted(k for k in mod.NODE_CLASS_MAPPINGS.keys() if 'PulidFlux' in k or k == 'ApplyPulidFlux')
    print('PuLID node keys:', pulid_nodes)
    required={'PulidFluxModelLoader','PulidFluxEvaClipLoader','PulidFluxFaceNetLoader','ApplyPulidFlux'}
    missing=required-set(mod.NODE_CLASS_MAPPINGS.keys())
    if missing:
        raise RuntimeError(f'Missing PuLID nodes: {sorted(missing)}')
    print('PuLID import validation ok')
except Exception as exc:
    print('PuLID import validation failed:', repr(exc))
    traceback.print_exc()
    raise
INNER

RUN rm -rf /comfyui/models/clip  && ln -s /runpod-volume/models/base/clip /comfyui/models/clip  && rm -rf /comfyui/models/diffusion_models  && ln -s /runpod-volume/models/base/diffusion_models /comfyui/models/diffusion_models  && rm -rf /comfyui/models/vae  && ln -s /runpod-volume/models/base/vae /comfyui/models/vae  && rm -rf /comfyui/models/loras  && ln -s /runpod-volume/models/lora /comfyui/models/loras  && mkdir -p /runpod-volume/models/pulid  && mkdir -p /runpod-volume/models/xlabs/controlnets  && mkdir -p /runpod-volume/models/xlabs/ipadapters  && mkdir -p /runpod-volume/models/clip_vision  && mkdir -p /runpod-volume/models/insightface/models/antelopev2  && rm -rf /comfyui/models/pulid  && ln -s /runpod-volume/models/pulid /comfyui/models/pulid  && rm -rf /comfyui/models/xlabs  && ln -s /runpod-volume/models/xlabs /comfyui/models/xlabs  && rm -rf /comfyui/models/clip_vision  && ln -s /runpod-volume/models/clip_vision /comfyui/models/clip_vision  && rm -rf /comfyui/models/insightface  && ln -s /runpod-volume/models/insightface /comfyui/models/insightface
