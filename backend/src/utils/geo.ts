import { geohashForLocation, geohashQueryBounds, distanceBetween } from 'geofire-common'

/**
 * Tipo LatLng per coordinate geografiche
 */
export type LatLng = { lat: number; lng: number }

/**
 * Aggiunge campo geohash a oggetto con geo: { lat, lng }
 */
export function withGeohash<T extends { geo: LatLng }>(obj: T) {
  const { lat, lng } = obj.geo
  return { ...obj, geohash: geohashForLocation([lat, lng]) }
}

/**
 * Query geospaziale con raggio (km) su collezione Firestore
 * Usa geohash bounding boxes + Haversine filtering
 * @param colRef - CollectionReference Firestore
 * @param center - Centro della ricerca { lat, lng }
 * @param radiusKm - Raggio in kilometri
 * @param extraWhere - Query aggiuntive (es. .where('visible', '==', true))
 * @param limit - Numero massimo di risultati (default 50)
 * @returns Array di documenti con distanceKm, ordinati per distanza
 */
export async function geoRadiusQuery(
  colRef: FirebaseFirestore.CollectionReference,
  center: LatLng,
  radiusKm: number,
  extraWhere?: (q: FirebaseFirestore.Query) => FirebaseFirestore.Query,
  limit = 50
) {
  const centerArr: [number, number] = [center.lat, center.lng]
  const bounds = geohashQueryBounds(centerArr, radiusKm * 1000) // metri

  const snapshots: FirebaseFirestore.QuerySnapshot[] = []

  // Esegui query parallele per ogni bounding box
  for (const b of bounds) {
    let q: FirebaseFirestore.Query = colRef.orderBy('geohash').startAt(b[0]).endAt(b[1])
    if (extraWhere) q = extraWhere(q)
    snapshots.push(await q.limit(limit).get())
  }

  // Raccogli documenti unici e filtra per distanza Haversine
  const docs: any[] = []
  const seen = new Set<string>()

  for (const snap of snapshots) {
    for (const d of snap.docs) {
      if (seen.has(d.id)) continue
      seen.add(d.id)

      const data = d.data() as any
      if (!data?.geo) continue

      const dist = distanceBetween(centerArr, [data.geo.lat, data.geo.lng])
      if (dist <= radiusKm) {
        docs.push({ id: d.id, distanceKm: dist, ...data })
      }
    }
  }

  // Ordina per distanza crescente
  docs.sort((a, b) => a.distanceKm - b.distanceKm)
  return docs.slice(0, limit)
}
