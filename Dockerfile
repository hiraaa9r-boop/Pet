# Build TypeScript backend from /backend
FROM node:20 AS builder

# Cartella di lavoro per il backend
WORKDIR /usr/src/app/backend

# Copio i file di configurazione del backend
COPY backend/package*.json ./

# Installa tutte le dipendenze (anche dev)
RUN npm ci

# Copio tutto il codice del backend
COPY backend/. .

# Compila il progetto (deve esistere lo script "build" in package.json)
RUN npm run build

# ---------------- FASE RUNTIME ----------------
FROM node:20-slim

WORKDIR /usr/src/app/backend

# Copio solo la build compilata
COPY --from=builder /usr/src/app/backend/dist ./dist

# Copio package.json per installare solo le dipendenze di produzione
COPY backend/package*.json ./
RUN npm ci --omit=dev

# Porta usata da Cloud Run
ENV PORT=8080

# Se il file di ingresso è diverso da dist/index.js cambialo qui
CMD ["node", "dist/index.js"]
