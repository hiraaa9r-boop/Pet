/**
 * Cloud Function - Automatic Cache Invalidation
 * Triggers on any write to pros/{proId} collection
 * Automatically invalidates all pros:* cache entries
 */

import * as functions from 'firebase-functions'
import { invalidatePrefix } from '../../../src/utils/cache'

/**
 * Firestore trigger: onWrite for pros collection
 * Fires on: create, update, delete operations
 */
export const onProsWrite = functions.firestore
  .document('pros/{proId}')
  .onWrite(async (_change, context) => {
    try {
      const proId = context.params.proId
      const eventType = !_change.before.exists
        ? 'create'
        : !_change.after.exists
          ? 'delete'
          : 'update'

      // Invalidate all pros:* cache keys
      const invalidated = invalidatePrefix('pros:')

      console.log(
        `[CACHE] Auto-invalidation triggered`,
        JSON.stringify({
          eventType,
          proId,
          invalidatedKeys: invalidated,
          timestamp: new Date().toISOString(),
        })
      )

      return { ok: true, invalidated, eventType, proId }
    } catch (error: any) {
      console.error('[CACHE] Auto-invalidation error:', {
        error: error.message,
        stack: error.stack,
        proId: context.params.proId,
      })
      return { ok: false, error: error.message }
    }
  })
