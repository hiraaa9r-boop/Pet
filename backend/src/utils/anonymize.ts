import { createHash, randomBytes } from 'crypto'

/**
 * Mappa PII: campo → strategia di anonimizzazione
 * - drop: rimuove campo
 * - mask: maschera valore (es. email → a***@example.com)
 * - hash: hash SHA-256 del valore
 * - keep: mantiene valore originale (necessario per accounting/legal)
 */
export type PiiMap = Record<string, 'drop' | 'mask' | 'hash' | 'keep'>

/**
 * Anonimizza oggetto secondo regole PII
 * @param obj - Oggetto da anonimizzare
 * @param rules - Regole di anonimizzazione per campo
 * @returns Oggetto anonimizzato
 */
export function anonymize<T extends Record<string, any>>(obj: T, rules: PiiMap): T {
  const out: any = { ...obj }

  for (const [k, mode] of Object.entries(rules)) {
    if (!(k in out)) continue
    const val = out[k]

    switch (mode) {
      case 'drop':
        delete out[k]
        break
      case 'mask':
        out[k] = maskValue(val)
        break
      case 'hash':
        out[k] = sha256(String(val))
        break
      case 'keep':
      default:
        break
    }
  }

  return out
}

/**
 * Hash SHA-256 di stringa
 */
export function sha256(s: string): string {
  return createHash('sha256').update(s).digest('hex')
}

/**
 * Maschera valore (email: a***@dom, altro: primo+ultimo char)
 */
export function maskValue(v: any): string {
  if (typeof v !== 'string') return '***'

  // Email: a***@example.com
  if (v.includes('@')) {
    const [user, dom] = v.split('@')
    const maskedUser = user.length <= 1 ? '*' : user[0] + '***'
    return `${maskedUser}@${dom}`
  }

  // Altro: primo e ultimo carattere, resto ***
  if (v.length <= 2) return '**'
  return v[0] + '***' + v[v.length - 1]
}

/**
 * Genera ID pseudonimizzato per soft-delete (es. deleted_a1b2c3d4)
 */
export function pseudoId(prefix = 'deleted'): string {
  return `${prefix}_${randomBytes(8).toString('hex')}`
}
