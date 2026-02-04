FROM node:18-bullseye

RUN apt-get update \
  && apt-get install -y --no-install-recommends git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /gaia
RUN git clone --depth 1 --branch v2.9.0 https://github.com/stacks-archive/gaia.git .
RUN npm install
RUN npm run build

ENV GAIA_PORT=3000
EXPOSE 3000

CMD ["node", "lib/hub/server.js"]
