import { createHash } from 'crypto'

/**
 * In-memory cache con ETag e TTL
 * Entry: { value, etag, expiresAt }
 */
type Entry<T = any> = { value: T; etag: string; expiresAt: number }
const store = new Map<string, Entry>()

/**
 * Genera weak ETag da payload (SHA-1 hash)
 */
export function makeEtag(payload: any): string {
  const json = typeof payload === 'string' ? payload : JSON.stringify(payload)
  return 'W/"' + createHash('sha1').update(json).digest('hex') + '"'
}

/**
 * Recupera entry dalla cache (null se scaduta o assente)
 */
export function getCache<T = any>(key: string): Entry<T> | null {
  const e = store.get(key)
  if (!e) return null
  if (Date.now() > e.expiresAt) {
    store.delete(key)
    return null
  }
  return e as Entry<T>
}

/**
 * Salva entry in cache con TTL (secondi)
 */
export function setCache<T = any>(key: string, value: T, ttlSec: number): Entry<T> {
  const etag = makeEtag(value)
  const entry = { value, etag, expiresAt: Date.now() + ttlSec * 1000 }
  store.set(key, entry)
  return entry
}

/**
 * Invalida singola chiave
 */
export function invalidate(key: string): boolean {
  return store.delete(key)
}

/**
 * Invalida tutte le chiavi che iniziano con prefix (es. "pros:")
 */
export function invalidatePrefix(prefix: string): number {
  let n = 0
  for (const k of store.keys()) {
    if (k.startsWith(prefix)) {
      store.delete(k)
      n++
    }
  }
  return n
}

/**
 * Sweep cache periodico (rimuove entry scadute)
 */
export function sweepCache() {
  const now = Date.now()
  for (const [k, v] of store.entries()) {
    if (v.expiresAt < now) store.delete(k)
  }
}
