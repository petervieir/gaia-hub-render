FROM node:18-bullseye

RUN apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /gaia
RUN git clone --depth 1 --branch v2.9.0 https://github.com/stacks-archive/gaia.git . \
  && npm --prefix hub install \
  && npm --prefix hub run build \
  && node - <<'NODE'
const fs = require('fs')
const p = 'hub/lib/index.js'
const src = fs.readFileSync(p, 'utf8')
const lines = src.split('\n')
const insertAt = lines.findIndex(line => line.startsWith('import * as path from'))
if (insertAt === -1) {
  throw new Error('Unable to find path import in hub/lib/index.js')
}
lines.splice(
  insertAt + 1,
  0,
  "import { fileURLToPath } from 'url';",
  'const __filename = fileURLToPath(import.meta.url);',
  'const __dirname = path.dirname(__filename);'
)
fs.writeFileSync(p, lines.join('\n'))
NODE

# ;; Patch http.ts to add static file serving for disk driver
RUN node - <<'NODE'
const fs = require('fs')
const p = 'hub/lib/server/http.js'
const src = fs.readFileSync(p, 'utf8')
// Find the line with "return { app, server, driver, asyncMutex }"
const lines = src.split('\n')
const returnIdx = lines.findIndex(line => line.includes('return { app, server, driver'))
if (returnIdx === -1) {
  throw new Error('Unable to find return statement in http.js')
}
// Insert static file serving before the return
lines.splice(
  returnIdx,
  0,
  "  // Serve stored files for disk driver",
  "  if (process.env.GAIA_DRIVER === 'disk' && process.env.GAIA_DISK_STORAGE_ROOT_DIR) {",
  "    app.use(express.static(process.env.GAIA_DISK_STORAGE_ROOT_DIR));",
  "  }",
  ""
)
fs.writeFileSync(p, lines.join('\n'))
console.log('Patched http.js to serve static files')
NODE

# ;; Create storage directory for disk driver
RUN mkdir -p /gaia-storage && chmod 755 /gaia-storage

# ;; Configure Gaia hub with disk driver
ENV GAIA_PORT=3000
ENV GAIA_DRIVER=disk
ENV GAIA_DISK_STORAGE_ROOT_DIR=/gaia-storage
ENV GAIA_READ_URL=http://localhost:3000
ENV NODE_OPTIONS=--experimental-specifier-resolution=node

EXPOSE 3000

CMD ["node", "hub/lib/index.js"]
