"""Test Hugging Face configuration and small artifact downloads."""
from huggingface_hub import constants, hf_hub_download

print('Endpoint:', constants.ENDPOINT)

for repo, filename in [
    ('Qwen/Qwen3-14B', 'config.json'),
    ('hf-internal-testing/tiny-random-gpt2', 'pytorch_model.bin'),
]:
    print(f'\nTesting {repo}/{filename}')
    try:
        path = hf_hub_download(repo_id=repo, filename=filename, etag_timeout=10)
        print('SUCCESS:', path)
    except Exception as exc:
        print('FAILED:', type(exc).__name__, str(exc))
