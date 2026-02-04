# Gaia Hub for Render

This repo packages the Gaia hub (Stacks storage) as a Docker-based Render
service with CORS enabled for the Memory Card Game frontend.

## Deploy on Render

1. Create a new Render Web Service from this repo.
2. Render will read `render.yaml` and build from the Dockerfile.
3. After the service is live, update the following env vars in Render to
   match your service URL:
   - `GAIA_HUB_URL` = `https://<your-render-service>.onrender.com`
   - `GAIA_DOMAIN_NAME` = `<your-render-service>.onrender.com`

## Test

```
curl -i https://<your-render-service>.onrender.com/hub_info
```

Expected: HTTP 200 with JSON containing `challenge_text`, `read_url_prefix`,
`latest_auth_version`.

## CORS

This repo sets:

- `GAIA_ENABLE_CORS=true`
- `GAIA_CORS_ORIGIN=https://memory-card-game-xi-navy.vercel.app`

If you deploy another frontend, update `GAIA_CORS_ORIGIN`.
