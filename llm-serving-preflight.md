# LLM serving preflight

Generic environment checks before deploying a vLLM chat model on one authorized GPU. No internal infrastructure details are included.

## CUDA visibility

```bash
printenv CUDA_VISIBLE_DEVICES
```

An unset variable does not restrict CUDA visibility; an explicitly empty value hides CUDA devices.

## GPU availability

```bash
nvidia-smi --query-gpu=index,name,memory.total,memory.used,utilization.gpu --format=csv
```

Use only an idle GPU allocated to you.

## Storage and memory

```bash
df -h "$HOME"
quota -s
free -h
```

Allow sufficient approved storage for weights, dependencies and cache (roughly 80–100 GB for a 27B BF16 model).

## Python and packages

```bash
python --version
python -m pip show torch vllm transformers
```

## PyTorch CUDA visibility

```bash
python -c "import torch; print('CUDA:', torch.cuda.is_available()); print('GPUs:', torch.cuda.device_count()); print('CUDA version:', torch.version.cuda)"
```

## Model repository connectivity

```bash
curl -I --connect-timeout 10 https://huggingface.co
```

Use approved package and model repositories. Review these results before installing anything or starting a server.
