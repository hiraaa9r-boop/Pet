/**
 * Internal Routes - Cache Management & Monitoring
 * Protected endpoints for DevOps, monitoring, and cache control
 * Should be restricted to internal traffic only in production
 */

import { Router } from 'express'
import { sweepCache, getStats, invalidatePrefix, invalidate } from '../utils/cache'

const router = Router()

/**
 * GET /api/internal/cache/stats
 * Returns cache metrics: hits, misses, entries, hit rate
 * Use for: Monitoring dashboards, DevOps health checks
 */
router.get('/internal/cache/stats', (_req, res) => {
  try {
    const stats = getStats()
    res.json({
      ok: true,
      cache: stats,
      timestamp: new Date().toISOString(),
    })
  } catch (error: any) {
    res.status(500).json({
      ok: false,
      message: 'Failed to retrieve cache stats',
      error: error.message,
    })
  }
})

/**
 * POST /api/internal/cache/sweep
 * Manually trigger cache sweep (remove expired entries)
 * Use for: Maintenance operations, memory optimization
 */
router.post('/internal/cache/sweep', (_req, res) => {
  try {
    const before = getStats()
    sweepCache()
    const after = getStats()

    const cleaned = before.entries - after.entries

    res.json({
      ok: true,
      message: 'Cache sweep completed',
      before: { entries: before.entries },
      after: { entries: after.entries },
      cleaned,
      timestamp: new Date().toISOString(),
    })
  } catch (error: any) {
    res.status(500).json({
      ok: false,
      message: 'Cache sweep failed',
      error: error.message,
    })
  }
})

/**
 * POST /api/internal/cache/invalidate?prefix=pros:
 * Invalidate cache entries by prefix
 * Use for: Manual cache busting, deployment updates
 * Query params:
 *  - prefix: Cache key prefix to invalidate (required)
 *  - key: Single key to invalidate (alternative to prefix)
 */
router.post('/internal/cache/invalidate', (req, res) => {
  try {
    const { prefix, key } = req.query

    if (!prefix && !key) {
      return res.status(400).json({
        ok: false,
        message: 'Either prefix or key parameter is required',
        examples: {
          prefix: '/api/internal/cache/invalidate?prefix=pros:',
          key: '/api/internal/cache/invalidate?key=pros:45.5:9.2:10:veterinari',
        },
      })
    }

    let invalidated = 0

    if (key) {
      const deleted = invalidate(key as string)
      invalidated = deleted ? 1 : 0
    } else if (prefix) {
      invalidated = invalidatePrefix(prefix as string)
    }

    res.json({
      ok: true,
      message: 'Cache invalidation completed',
      invalidated,
      prefix: prefix || undefined,
      key: key || undefined,
      timestamp: new Date().toISOString(),
    })
  } catch (error: any) {
    res.status(500).json({
      ok: false,
      message: 'Cache invalidation failed',
      error: error.message,
    })
  }
})

/**
 * GET /api/internal/health
 * Extended health check with cache stats
 * Use for: Load balancer health checks, monitoring
 */
router.get('/internal/health', (_req, res) => {
  const stats = getStats()
  res.json({
    ok: true,
    status: 'healthy',
    cache: stats,
    memory: {
      heapUsed: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + ' MB',
      heapTotal: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + ' MB',
    },
    uptime: Math.round(process.uptime()) + ' seconds',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  })
})

export default router
