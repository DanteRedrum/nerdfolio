# Phase 8 Complete

## What Was Built

Local LLM running on nf-ai-ubuntu with Open WebUI frontend.
Accessible at http://ai.nerdfolio from anywhere on the internal network.

## Stack

| Component | Detail |
|---|---|
| VM | nf-ai-ubuntu — 192.168.100.30 |
| Ollama | Latest — CPU only |
| Model | mistral:7b — 4.4GB |
| Frontend | Open WebUI via Docker |

## Access

http://ai.nerdfolio

## Why Mistral 7B

Best balance of quality and performance for CPU-only inference.
Larger models (13B+) would be too slow without GPU passthrough.
mistral:7b gives coherent, useful responses at acceptable speed.

## Future State

When a dedicated host with GPU passthrough is added:
- Move Ollama to a machine with GPU access
- Run larger models — llama3:70b, mixtral:8x7b
- Explore local RAG against the Nerdfolio repo
- Context-aware assistant that knows the full environment
- FiveM/Qbox script assistance with codebase context

## Ansible

```bash
# Install Ollama and pull model
ansible-playbook -i inventory/hosts.ini playbooks/install-ollama.yml

# Pull a different model
ssh daniel@192.168.100.30
ollama pull MODEL_NAME

# List available models
ollama list

# Test a model
ollama run mistral:7b "your prompt here"
```

## Up Next

Final Phase — The Golden Image. Full teardown and rebuild from the repo alone.
