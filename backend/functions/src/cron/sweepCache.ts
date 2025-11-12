/**
 * Scheduled Job - Cache Sweep (TTL Cleanup)
 * Runs every 60 minutes via Cloud Scheduler
 * Removes expired cache entries to prevent memory leaks
 */

import * as functions from 'firebase-functions'
import { sweepCache, getStats } from '../../../src/utils/cache'

/**
 * Pub/Sub scheduled function: runs every 60 minutes
 * Alternative: Cloud Scheduler → HTTP GET to /api/internal/cache/sweep
 */
export const hourlySweepCache = functions.pubsub
  .schedule('every 60 minutes')
  .timeZone('Europe/Rome') // Adjust to your timezone
  .onRun(async (context) => {
    try {
      // Get stats before sweep
      const before = getStats()

      // Execute sweep
      sweepCache()

      // Get stats after sweep
      const after = getStats()

      const cleaned = before.entries - after.entries

      console.log(
        '[CACHE] Scheduled sweep executed',
        JSON.stringify({
          timestamp: context.timestamp,
          before: {
            entries: before.entries,
            hits: before.hits,
            misses: before.misses,
          },
          after: {
            entries: after.entries,
            hits: after.hits,
            misses: after.misses,
          },
          cleaned,
          hitRate: before.hits + before.misses > 0 ? (before.hits / (before.hits + before.misses) * 100).toFixed(2) + '%' : 'N/A',
        })
      )

      return { ok: true, cleaned, before, after }
    } catch (error: any) {
      console.error('[CACHE] Sweep error:', {
        error: error.message,
        stack: error.stack,
        timestamp: context.timestamp,
      })
      return { ok: false, error: error.message }
    }
  })
