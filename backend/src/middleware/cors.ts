// backend/src/middleware/cors.ts
import cors, { CorsOptions } from 'cors';

// Puoi configurare altre origin via env:
// CORS_ALLOWED_ORIGINS=https://pet-care-9790d.web.app,https://pet-care-9790d.firebaseapp.com,http://localhost:5060
const envOrigins =
  (process.env.CORS_ALLOWED_ORIGINS || '')
    .split(',')
    .map(o => o.trim())
    .filter(Boolean);

const defaultOrigins = [
  'https://pet-care-9790d.web.app',
  'https://pet-care-9790d.firebaseapp.com',
  'http://localhost:5060',
];

const allowedOrigins = [...new Set([...defaultOrigins, ...envOrigins])];

const corsOptions: CorsOptions = {
  origin: (origin, callback) => {
    // Origin null = chiamate server-to-server, Postman, ecc. → ok
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }

    console.warn('[CORS] Origin NON consentita:', origin);
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400, // 24h cache del preflight
};

export const corsMiddleware = cors(corsOptions);
