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

ENV GAIA_PORT=3000
ENV NODE_OPTIONS=--experimental-specifier-resolution=node
EXPOSE 3000

CMD ["node", "hub/lib/index.js"]
