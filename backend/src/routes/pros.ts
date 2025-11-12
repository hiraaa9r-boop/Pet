import { Router } from 'express'

import { createProSchema, updateProSchema } from '../schemas/pro'
import { getCache, setCache, invalidatePrefix } from '../utils/cache'
import { getDb } from '../utils/firebaseAdmin'
import { geoRadiusQuery, withGeohash, type LatLng } from '../utils/geo'

const db = getDb()

const router = Router()
const CACHE_TTL = 60 // 60 secondi

/**
 * GET /api/pros
 * Lista professionisti con cache ETag (60s TTL) e geosearch opzionale
 * Query params:
 * - lat, lng, radius: geosearch entro raggio (km)
 * - category: filtro per categoria
 * Headers: If-None-Match per validazione ETag
 */
router.get('/', async (req, res) => {
  try {
    const { lat, lng, radius, category } = req.query

    // Genera cache key unica per parametri
    const cacheKey = `pros:${lat || 'all'}:${lng || 'all'}:${radius || 'all'}:${category || 'all'}`

    // Controlla cache + ETag
    const cached = getCache(cacheKey)
    if (cached) {
      const clientETag = req.headers['if-none-match']
      if (clientETag === cached.etag) {
        return res.status(304).end() // Not Modified
      }
      // Cache hit, ETag diverso → ritorna dati
      res.setHeader('ETag', cached.etag)
      res.setHeader('Cache-Control', 'private, max-age=60')
      res.setHeader('Vary', 'If-None-Match')
      return res.json({ ok: true, data: cached.value })
    }

    // Cache miss → query Firestore
    let pros: any[] = []

    if (lat && lng && radius) {
      // Geosearch con raggio
      const center: LatLng = { lat: parseFloat(lat as string), lng: parseFloat(lng as string) }
      const radiusKm = parseFloat(radius as string)

      const prosRef = db.collection('pros')
      const extraWhere = category
        ? (q: FirebaseFirestore.Query) =>
            q.where('visible', '==', true).where('categories', 'array-contains', category)
        : (q: FirebaseFirestore.Query) => q.where('visible', '==', true)

      pros = await geoRadiusQuery(prosRef, center, radiusKm, extraWhere, 50)
    } else {
      // Query normale (no geo)
      let query: FirebaseFirestore.Query = db.collection('pros').where('visible', '==', true)
      if (category) query = query.where('categories', 'array-contains', category)

      const snap = await query.limit(50).get()
      pros = snap.docs.map((d) => ({ id: d.id, ...d.data() }))
    }

    // Salva in cache con ETag
    const entry = setCache(cacheKey, pros, CACHE_TTL)
    res.setHeader('ETag', entry.etag)
    res.setHeader('Cache-Control', 'private, max-age=60')
    res.setHeader('Vary', 'If-None-Match')

    res.json({ ok: true, data: pros })
  } catch (err: any) {
    res.status(500).json({ ok: false, message: err.message })
  }
})

/**
 * POST /api/pros
 * Crea nuovo PRO (con geohash automatico se geo presente)
 * Invalida cache pros:*
 */
router.post('/', async (req, res) => {
  try {
    const parsed = createProSchema.parse(req.body)

    // Aggiungi geohash se presente geo
    const data = parsed.geo ? withGeohash(parsed as any) : parsed

    const ref = await db.collection('pros').add({
      ...data,
      visible: true,
      createdAt: new Date().toISOString(),
    })

    // Invalida tutte le cache pros:*
    const invalidated = invalidatePrefix('pros:')
    console.log(`[CACHE] Invalidated ${invalidated} pros:* keys`)

    res.status(201).json({ ok: true, id: ref.id })
  } catch (err: any) {
    res.status(400).json({ ok: false, message: err.message })
  }
})

/**
 * PUT /api/pros/:id
 * Aggiorna PRO (ricalcola geohash se geo cambia)
 * Invalida cache pros:*
 */
router.put('/:id', async (req, res) => {
  try {
    const parsed = updateProSchema.parse(req.body)
    const data = parsed.geo ? withGeohash(parsed as any) : parsed

    await db.collection('pros').doc(req.params.id).update({
      ...data,
      updatedAt: new Date().toISOString(),
    })

    // Invalida cache
    const invalidated = invalidatePrefix('pros:')
    console.log(`[CACHE] Invalidated ${invalidated} pros:* keys`)

    res.json({ ok: true })
  } catch (err: any) {
    res.status(400).json({ ok: false, message: err.message })
  }
})

/**
 * DELETE /api/pros/:id
 * Soft-delete PRO (visible = false)
 * Invalida cache pros:*
 */
router.delete('/:id', async (req, res) => {
  try {
    await db.collection('pros').doc(req.params.id).update({
      visible: false,
      deletedAt: new Date().toISOString(),
    })

    // Invalida cache
    const invalidated = invalidatePrefix('pros:')
    console.log(`[CACHE] Invalidated ${invalidated} pros:* keys`)

    res.json({ ok: true })
  } catch (err: any) {
    res.status(500).json({ ok: false, message: err.message })
  }
})

export default router
