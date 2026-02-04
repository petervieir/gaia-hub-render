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
const p = 'hub/package.json'
const j = JSON.parse(fs.readFileSync(p, 'utf8'))
delete j.type
fs.writeFileSync(p, JSON.stringify(j, null, 2))
NODE

ENV GAIA_PORT=3000
EXPOSE 3000

CMD ["node", "hub/lib/index.js"]
