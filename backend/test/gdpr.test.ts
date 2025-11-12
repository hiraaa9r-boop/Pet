/**
 * GDPR Endpoints Smoke Tests
 * Basic validation for authentication and endpoint availability
 * Note: These tests verify the endpoint structure without Firebase initialization
 */

import express from 'express'
import request from 'supertest'
import { describe, it, expect } from 'vitest'

import { requireAuth } from '../src/middleware/requireAuth'
import { gdprLimiter } from '../src/middleware/rateLimit'

// Create a minimal test app to verify GDPR endpoint middleware chain
const testApp = express()
testApp.use(express.json())

// Mock GDPR data export endpoint
testApp.get('/api/user/data', requireAuth, gdprLimiter, (_req, res) => {
  res.json({ ok: true, data: { profile: {}, bookings: [], reviews: [], payments: [] } })
})

// Mock GDPR data deletion endpoint
testApp.delete('/api/user/delete', requireAuth, gdprLimiter, (_req, res) => {
  res.json({ ok: true, message: 'User data anonymized successfully', deletedDocs: 0 })
})

describe('GDPR Endpoints', () => {
  describe('GET /api/user/data', () => {
    it('should return 401 without authentication', async () => {
      const response = await request(testApp).get('/api/user/data')

      expect(response.status).toBe(401)
      expect(response.body.ok).toBe(false)
      expect(response.body.message).toBe('Unauthorized')
    })

    it('should return 200 with X-User-Id header (dev/test)', async () => {
      const response = await request(testApp)
        .get('/api/user/data')
        .set('X-User-Id', 'test_user_123')

      expect(response.status).toBe(200)
      expect(response.body.ok).toBe(true)
      expect(response.body.data).toBeDefined()
    })
  })

  describe('DELETE /api/user/delete', () => {
    it('should return 401 without authentication', async () => {
      const response = await request(testApp).delete('/api/user/delete')

      expect(response.status).toBe(401)
      expect(response.body.ok).toBe(false)
      expect(response.body.message).toBe('Unauthorized')
    })

    it('should return 200 with X-User-Id header (dev/test)', async () => {
      const response = await request(testApp)
        .delete('/api/user/delete')
        .set('X-User-Id', 'test_user_456')

      expect(response.status).toBe(200)
      expect(response.body.ok).toBe(true)
      expect(response.body.message).toContain('anonymized')
    })
  })
})
