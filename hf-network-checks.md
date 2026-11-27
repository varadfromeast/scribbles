# Hugging Face network checks

Run these read-only diagnostics from the GPU server.

```bash
# Check whether proxy variables are configured (names only, not credentials)
env | cut -d= -f1 | grep -i proxy

# DNS resolution
getent hosts huggingface.co
getent ahostsv4 huggingface.co

# Test IPv4 HTTPS connectivity
curl -4 -I --connect-timeout 5 --max-time 10 https://huggingface.co

# Test IPv6 HTTPS connectivity
curl -6 -I --connect-timeout 5 --max-time 10 https://huggingface.co
```

If both HTTPS tests time out, investigate network routing or outbound firewall restrictions with the infrastructure team. DNS resolution alone does not establish HTTPS connectivity.

Approved options: internal Hugging Face model mirror, corporate HTTPS proxy, firewall allowlisting, or approved offline model artifact import. Model weights are only needed locally for offline inference; permanent internet access is not required.
