# Offline LLM serving checks

Use only approved shared environments and an authorized GPU. These examples omit corporate-specific environment names because this repository is public.

## Activate an existing LLM environment

```bash
conda env list
read -r -p 'Approved Conda environment: ' LLM_ENV
conda activate "$LLM_ENV"
which python
```

## Verify PyTorch and CUDA

```bash
# Replace 2 with your allocated GPU index.
CUDA_VISIBLE_DEVICES=2 python -c "import torch; print(torch.__version__); print(torch.version.cuda); print(torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"
```

## Find vLLM in existing named Conda environments

```bash
for env in $(conda env list | awk '/^[^#]/ && NF {print $1}'); do
    echo "Checking $env"
    conda list -n "$env" 2>/dev/null | grep -i '^vllm '
done
```

## Check local model cache

```bash
ls -lah "${HF_HUB_CACHE:-${HF_HOME:-$HOME/.cache/huggingface}/hub}"
echo "$HF_HOME"
echo "$HF_HUB_CACHE"
```

## Check existing Docker images

```bash
docker images
```

Only use Docker if authorized. Do not modify shared Conda environments or download packages through unapproved channels. Locate approved model weights and a compatible runtime before serving.
