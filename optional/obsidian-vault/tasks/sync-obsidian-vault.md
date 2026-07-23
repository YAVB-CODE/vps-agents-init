# Sincronizar Obsidian Vault con Git

## Metadatos

- id: sync-obsidian-vault
- tipo: accion
- schedule: "0 2 * * *"        # cron: todos los días a las 02:00
- zona_horaria: America/Bogota
- notificar: solo-si-falla     # opciones: siempre | solo-si-falla | nunca
- activa: false

## Descripción

Mantener sincronizado el vault de Obsidian (`VAULT_DIR`) con su repositorio git
remoto, para que la memoria persistente del agente no se pierda y quede
respaldada a diario.

Requiere el addon instalado: `optional/obsidian-vault/install.sh`.

## Procedimiento

1. Ir a `VAULT_DIR` (definido en el `.env` del agente).
2. Verificar si hay cambios sin commitear (`git status --porcelain`).
3. Si no hay cambios, terminar sin hacer nada.
4. Si hay cambios:
   - `git add -A`
   - Commit con mensaje del tipo `chore(vault): sync automático YYYY-MM-DD`.
   - `git pull --rebase` para integrar cambios remotos.
   - `git push`.
5. Registrar el resultado (archivos cambiados, hash del commit).

## Notificación

- Notificar únicamente si el push falla o si hay conflictos de merge que
  requieran intervención humana.

## Criterio de éxito

- El repositorio remoto del vault refleja el estado local.
- No quedan cambios sin commitear ni conflictos abiertos.
