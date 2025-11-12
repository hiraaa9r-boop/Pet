/**
 * Firebase Mock Setup for Isolated Testing
 * Prevents tests from touching real Firebase services
 * Enables 100% local test execution in CI/CD
 */

import { vi } from 'vitest'

/**
 * Mock Firestore Database
 * Simulates Firestore operations without actual database calls
 */
const createMockFirestore = () => {
  const mockDoc = {
    get: vi.fn(async () => ({
      exists: false,
      data: () => null,
      id: 'mock_doc_id',
    })),
    set: vi.fn(async () => ({})),
    update: vi.fn(async () => ({})),
    delete: vi.fn(async () => ({})),
  }

  const mockCollection = vi.fn(() => ({
    doc: vi.fn(() => mockDoc),
    add: vi.fn(async (data: any) => ({ id: 'mock_' + Date.now(), ...data })),
    where: vi.fn(() => mockCollection('mock')),
    orderBy: vi.fn(() => mockCollection('mock')),
    startAt: vi.fn(() => mockCollection('mock')),
    endAt: vi.fn(() => mockCollection('mock')),
    limit: vi.fn(() => mockCollection('mock')),
    get: vi.fn(async () => ({
      docs: [],
      empty: true,
      size: 0,
    })),
  }))

  return {
    collection: mockCollection,
    batch: vi.fn(() => ({
      set: vi.fn(),
      update: vi.fn(),
      delete: vi.fn(),
      commit: vi.fn(async () => ({})),
    })),
  }
}

/**
 * Mock Firebase Auth
 * Simulates authentication operations
 */
const createMockAuth = () => ({
  createUser: vi.fn(async (user: any) => ({
    uid: 'mock_uid_' + (user.email || 'anonymous'),
    email: user.email,
  })),
  verifyIdToken: vi.fn(async (token: string) => ({
    uid: 'mock_uid_from_token_' + token.substring(0, 8),
    email: 'mock@example.com',
  })),
  getUser: vi.fn(async (uid: string) => ({
    uid,
    email: 'mock@example.com',
  })),
  deleteUser: vi.fn(async () => ({})),
})

/**
 * Mock Firebase Storage
 * Simulates file storage operations
 */
const createMockBucket = () => ({
  file: vi.fn(() => ({
    save: vi.fn(async () => ({})),
    delete: vi.fn(async () => ({})),
    download: vi.fn(async () => [Buffer.from('mock file content')]),
    getSignedUrl: vi.fn(async () => ['https://mock-storage-url.com/file.pdf']),
  })),
  upload: vi.fn(async () => [{ metadata: { name: 'mock_file.pdf' } }]),
})

/**
 * Mock Firebase Admin SDK
 * Complete mock of all Firebase services
 */
vi.mock('../src/utils/firebaseAdmin', () => {
  const mockDb = createMockFirestore()
  const mockAuth = createMockAuth()
  const mockBucket = createMockBucket()

  return {
    getDb: vi.fn(() => mockDb),
    getAuth: vi.fn(() => mockAuth),
    getBucket: vi.fn(() => mockBucket),
    getAdminApp: vi.fn(() => ({
      firestore: () => mockDb,
      auth: () => mockAuth,
      storage: () => ({ bucket: () => mockBucket }),
    })),
  }
})

/**
 * Test environment configuration
 */
process.env.NODE_ENV = 'test'
process.env.FIREBASE_PROJECT_ID = 'mock-test-project'
process.env.FIREBASE_STORAGE_BUCKET = 'mock-test-bucket.appspot.com'
process.env.FRONTEND_URL = 'http://localhost:3000'
process.env.MAINTENANCE_MODE = 'false'

console.log('✅ Firebase mocked - Tests will run in isolation')
