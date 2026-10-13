# ELifeRPG dev environment

Independent Compose stacks on the shared external `eliferpg` network.

| Directory | Services | Needs |
| --- | --- | --- |
| `postgres/` | postgres (databases `keycloak`, `backend`, `npc`) | – |
| `keycloak/` | keycloak | postgres |
| `backend/` | backend, webapp | postgres, keycloak |
| `npc/` | npc-simulation | postgres, keycloak, backend |
| `reforger/` | bridge, gameserver (profile `gameserver`) | keycloak, backend |
| `telemetry/` | otel-collector, tempo, prometheus, loki, grafana | – |
| `watchtower/` | watchtower | – |

## Setup

```sh
docker network create eliferpg

for s in postgres keycloak backend npc reforger telemetry watchtower; do cp "$s/.env.example" "$s/.env"; done
# fill in every .env, then:
for s in postgres keycloak backend npc reforger telemetry watchtower; do (cd "$s" && docker compose up -d); done
```

Shared values must match: database passwords
(`postgres` ↔ `keycloak`/`backend`/`npc`), Keycloak client secrets (`keycloak` ↔
`backend`/`npc`/`reforger`), hostnames.

## Reverse proxy

| Hostname | Upstream | |
| --- | --- | --- |
| `PORTAL_HOST` | `127.0.0.1:3000` | |
| API | `127.0.0.1:5100` | WebSockets |
| `AUTH_HOST` | `127.0.0.1:8180` | `X-Forwarded-*` headers, large proxy buffers |
| `GRAFANA_HOST` | `127.0.0.1:3001` | WebSockets |

Services validate tokens against `https://${AUTH_HOST}`, so containers must reach it through the
proxy with a publicly trusted certificate.

## Notes

- The realm in `keycloak/import/` is imported on first start only.
- Watchtower updates every container labelled `com.centurylinklabs.watchtower.enable=true`.
- Register the gameserver after first start: `POST /api/game-servers`.
