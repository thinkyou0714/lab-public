# n8n Setup Notes

Source-Exempt: operational-doc

_LAB_PUBLIC / Last updated: 2026-03-07_

## Files

- `docker-compose.yml`: Public-safe compose template
- `.env.example`: Copy target for local values in the same directory

## First-time setup

1. Work from `infra/n8n`.
2. Copy `.env.example` to `.env` in this directory.
3. Set a strong `N8N_BASIC_AUTH_PASSWORD`.
4. Replace `WEBHOOK_URL` with the host URL used by your Tailscale or local setup.
5. Start with `docker compose up -d` from this directory.

## Backup

- Backup target: Docker volume `n8n_data`
- Recommended timing: before image updates, before host maintenance, and before risky workflow edits
- Minimum command example:

```powershell
docker run --rm -v n8n_data:/data -v ${PWD}:/backup alpine sh -c "tar czf /backup/n8n_data.tgz -C /data ."
```

## Restore

1. Stop the stack.
2. Restore the archive into `n8n_data`.
3. Start the stack again and verify workflow list and credentials.

## Safe update flow

1. Backup `n8n_data`.
2. Update `N8N_IMAGE` in `.env.example` and local `.env`.
3. Run `docker compose pull`.
4. Run `docker compose up -d`.
5. Verify login, workflows, and webhook delivery.