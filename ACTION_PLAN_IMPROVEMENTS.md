# 🎯 Action Plan - Miglioramenti MyPetCare

**Data**: 28 Gennaio 2025  
**Target**: Production-Ready in 6 settimane  
**Team Size**: 1 Full Stack Developer

---

## 📊 Executive Summary

```
Current Score:     78/100 🟢 BUONO
Target Score:      95/100 ⭐ EXCELLENT
Timeline:          6 settimane
Effort:            240 ore (full-time)
Priority Issues:   8 critici, 12 importanti
Investment:        ~$15,000 (labor cost)
ROI:               +$50,000/anno (bug prevention, downtime reduction)
```

---

## 🚨 Sprint 1: CRITICAL SECURITY (Settimana 1-2)

**Obiettivo**: Eliminare vulnerabilità security critiche  
**Durata**: 10 giorni lavorativi  
**Effort**: 80 ore

### **Task 1.1: Backend Input Validation** 🔴

**Priority**: CRITICAL  
**Effort**: 16 ore (2 giorni)  
**Assigned to**: Backend Developer

**Steps**:
1. **Install dependencies** (1h)
   ```bash
   cd backend
   npm install joi express-mongo-sanitize express-validator
   npm install --save-dev @types/joi
   ```

2. **Create validation middleware** (4h)
   ```bash
   mkdir -p src/middleware/validation
   touch src/middleware/validation/index.ts
   touch src/middleware/validation/booking.validation.ts
   touch src/middleware/validation/payment.validation.ts
   touch src/middleware/validation/user.validation.ts
   ```

3. **Implement schemas** (6h)
   - Booking validation (date, petId, serviceType)
   - Payment validation (amount, paymentMethod)
   - User validation (email, name, phone)
   - Common validation (pagination, filters)

4. **Add to routes** (3h)
   - Update all POST/PUT routes
   - Add validation middleware
   - Test con invalid payloads

5. **Add sanitization** (2h)
   - XSS protection
   - NoSQL injection protection
   - HTML entity encoding

**Acceptance Criteria**:
- ✅ All POST/PUT endpoints have validation
- ✅ Invalid requests return 400 with clear error
- ✅ XSS payloads are sanitized
- ✅ NoSQL injection attempts blocked

**Testing**:
```bash
# Test invalid booking
curl -X POST http://localhost:3000/api/bookings \
  -H "Content-Type: application/json" \
  -d '{"petId":"<script>alert(1)</script>","date":"invalid"}'
# Expected: 400 Bad Request
```

---

### **Task 1.2: Backend Test Suite Setup** 🔴

**Priority**: CRITICAL  
**Effort**: 24 ore (3 giorni)  
**Assigned to**: Backend Developer

**Steps**:
1. **Install testing framework** (2h)
   ```bash
   npm install --save-dev jest @types/jest ts-jest supertest @types/supertest
   npm install --save-dev @shelf/jest-mongodb
   ```

2. **Configure Jest** (2h)
   ```javascript
   // jest.config.js
   module.exports = {
     preset: 'ts-jest',
     testEnvironment: 'node',
     testMatch: ['**/__tests__/**/*.test.ts'],
     collectCoverageFrom: ['src/**/*.ts', '!src/**/*.d.ts'],
     coverageThreshold: {
       global: { branches: 70, functions: 70, lines: 70, statements: 70 }
     },
     setupFilesAfterEnv: ['<rootDir>/src/__tests__/setup.ts']
   };
   ```

3. **Create test utilities** (4h)
   ```bash
   mkdir -p src/__tests__/utils
   touch src/__tests__/setup.ts
   touch src/__tests__/utils/testHelpers.ts
   touch src/__tests__/utils/mockData.ts
   ```

4. **Write endpoint tests** (12h)
   - Authentication tests (login, register, verify)
   - Booking CRUD tests
   - Payment processing tests
   - Admin operations tests
   - Webhook handlers tests

5. **Setup CI integration** (2h)
   ```json
   // package.json
   {
     "scripts": {
       "test": "jest --coverage",
       "test:watch": "jest --watch",
       "test:ci": "jest --ci --coverage --maxWorkers=2"
     }
   }
   ```

6. **Run tests & fix issues** (2h)

**Acceptance Criteria**:
- ✅ 70%+ code coverage
- ✅ All critical endpoints tested
- ✅ Tests run in CI pipeline
- ✅ Zero flaky tests

**Test Example**:
```typescript
// src/__tests__/routes/bookings.test.ts
import request from 'supertest';
import app from '../../app';
import { getTestToken } from '../utils/testHelpers';

describe('POST /api/bookings', () => {
  let authToken: string;

  beforeAll(async () => {
    authToken = await getTestToken();
  });

  it('should create booking with valid data', async () => {
    const response = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        petId: 'pet_test_123',
        veterinaryId: 'vet_test_456',
        date: '2025-03-01T10:00:00Z',
        serviceType: 'checkup',
        notes: 'Annual checkup'
      });

    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('bookingId');
    expect(response.body.status).toBe('pending');
  });

  it('should reject past date', async () => {
    const response = await request(app)
      .post('/api/bookings')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        petId: 'pet_test_123',
        veterinaryId: 'vet_test_456',
        date: '2020-01-01T10:00:00Z', // Past date
        serviceType: 'checkup'
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain('past');
  });

  it('should require authentication', async () => {
    const response = await request(app)
      .post('/api/bookings')
      .send({ petId: 'test', veterinaryId: 'test', date: '2025-03-01' });

    expect(response.status).toBe(401);
  });
});
```

---

### **Task 1.3: ESLint + Prettier Setup** 🔴

**Priority**: CRITICAL  
**Effort**: 8 ore (1 giorno)  
**Assigned to**: Backend Developer

**Steps**:
1. **Install linting tools** (1h)
   ```bash
   npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
   npm install --save-dev prettier eslint-config-prettier eslint-plugin-prettier
   npm install --save-dev husky lint-staged
   ```

2. **Configure ESLint** (2h)
   ```javascript
   // .eslintrc.json
   {
     "parser": "@typescript-eslint/parser",
     "extends": [
       "eslint:recommended",
       "plugin:@typescript-eslint/recommended",
       "prettier"
     ],
     "rules": {
       "no-console": ["warn", { "allow": ["warn", "error"] }],
       "@typescript-eslint/no-explicit-any": "error",
       "@typescript-eslint/explicit-function-return-type": "warn"
     }
   }
   ```

3. **Configure Prettier** (1h)
   ```json
   // .prettierrc
   {
     "semi": true,
     "trailingComma": "es5",
     "singleQuote": true,
     "printWidth": 100,
     "tabWidth": 2,
     "arrowParens": "avoid"
   }
   ```

4. **Setup Husky pre-commit hooks** (2h)
   ```bash
   npx husky init
   echo "npx lint-staged" > .husky/pre-commit
   ```

   ```json
   // package.json
   {
     "lint-staged": {
       "*.ts": [
         "eslint --fix",
         "prettier --write",
         "git add"
       ]
     }
   }
   ```

5. **Fix existing lint errors** (2h)
   ```bash
   npm run lint:fix
   ```

**Acceptance Criteria**:
- ✅ ESLint passes on all files
- ✅ Prettier formats consistently
- ✅ Pre-commit hooks block bad code
- ✅ CI runs linting checks

---

### **Task 1.4: Flutter Test Suite Setup** 🔴

**Priority**: CRITICAL  
**Effort**: 24 ore (3 giorni)  
**Assigned to**: Flutter Developer

**Steps**:
1. **Create test structure** (2h)
   ```bash
   mkdir -p test/{models,widgets,screens,services,utils}
   touch test/models/booking_test.dart
   touch test/models/pet_test.dart
   touch test/widgets/booking_card_test.dart
   touch test/screens/home_screen_test.dart
   touch test/services/api_service_test.dart
   ```

2. **Write model tests** (6h)
   - Booking model (fromJson, toJson, validation)
   - Pet model
   - User model
   - Payment model

3. **Write widget tests** (8h)
   - BookingCard widget
   - PetCard widget
   - PaymentButton widget
   - Custom form fields

4. **Write screen tests** (6h)
   - HomeScreen navigation
   - BookingScreen form validation
   - PaymentScreen flow

5. **Setup mocks** (2h)
   ```dart
   // test/mocks/mock_api_service.dart
   import 'package:mockito/mockito.dart';
   import 'package:my_pet_care/services/api_service.dart';

   class MockApiService extends Mock implements ApiService {}
   ```

**Test Example**:
```dart
// test/models/booking_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pet_care/models/booking.dart';

void main() {
  group('Booking Model', () {
    test('should create booking from JSON', () {
      final json = {
        'id': 'booking123',
        'petId': 'pet456',
        'veterinaryId': 'vet789',
        'date': '2025-03-01T10:00:00Z',
        'status': 'pending',
        'serviceType': 'checkup',
        'createdAt': '2025-01-28T10:00:00Z'
      };

      final booking = Booking.fromJson(json);

      expect(booking.id, 'booking123');
      expect(booking.status, BookingStatus.pending);
      expect(booking.serviceType, ServiceType.checkup);
    });

    test('should serialize to JSON correctly', () {
      final booking = Booking(
        id: 'test',
        petId: 'pet123',
        veterinaryId: 'vet456',
        date: DateTime(2025, 3, 1, 10, 0),
        status: BookingStatus.confirmed,
        serviceType: ServiceType.grooming,
      );

      final json = booking.toJson();

      expect(json['id'], 'test');
      expect(json['status'], 'confirmed');
      expect(json['serviceType'], 'grooming');
    });

    test('should calculate if booking is today', () {
      final todayBooking = Booking(
        id: 'test',
        petId: 'pet',
        veterinaryId: 'vet',
        date: DateTime.now(),
        status: BookingStatus.pending,
        serviceType: ServiceType.checkup,
      );

      expect(todayBooking.isToday, true);
    });
  });
}

// test/widgets/booking_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_pet_care/widgets/booking_card.dart';
import 'package:my_pet_care/models/booking.dart';

void main() {
  testWidgets('BookingCard displays booking information', (WidgetTester tester) async {
    final booking = Booking(
      id: 'test',
      petId: 'pet123',
      veterinaryId: 'vet456',
      petName: 'Fluffy',
      veterinaryName: 'Dr. Smith',
      date: DateTime(2025, 3, 1, 10, 0),
      status: BookingStatus.pending,
      serviceType: ServiceType.checkup,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingCard(booking: booking),
        ),
      ),
    );

    expect(find.text('Fluffy'), findsOneWidget);
    expect(find.text('Dr. Smith'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Checkup'), findsOneWidget);
  });

  testWidgets('BookingCard shows correct status color', (WidgetTester tester) async {
    final confirmedBooking = Booking(
      id: 'test',
      petId: 'pet',
      veterinaryId: 'vet',
      date: DateTime.now(),
      status: BookingStatus.confirmed,
      serviceType: ServiceType.checkup,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingCard(booking: confirmedBooking),
        ),
      ),
    );

    final statusChip = tester.widget<Chip>(find.byType(Chip));
    expect(statusChip.backgroundColor, Colors.green);
  });
}
```

**Run tests**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

**Acceptance Criteria**:
- ✅ 60%+ code coverage
- ✅ All models tested
- ✅ Critical widgets tested
- ✅ Tests pass consistently

---

### **Task 1.5: Audit Logging System** 🟡

**Priority**: HIGH  
**Effort**: 8 ore (1 giorno)  
**Assigned to**: Backend Developer

**Steps**:
1. **Create audit log service** (3h)
   ```typescript
   // backend/src/services/audit.service.ts
   import { db } from '../utils/firestore';
   
   export enum AuditAction {
     USER_LOGIN = 'user_login',
     USER_REGISTER = 'user_register',
     BOOKING_CREATE = 'booking_create',
     BOOKING_CANCEL = 'booking_cancel',
     PAYMENT_PROCESS = 'payment_process',
     ADMIN_ACTION = 'admin_action',
     DATA_EXPORT = 'data_export',
     DATA_DELETE = 'data_delete'
   }

   export class AuditService {
     async log(params: {
       action: AuditAction;
       userId?: string;
       resourceId?: string;
       details?: any;
       ip?: string;
       userAgent?: string;
     }) {
       await db.collection('audit_logs').add({
         ...params,
         timestamp: new Date(),
         environment: process.env.NODE_ENV
       });
     }

     async getLogsByUser(userId: string, limit = 100) {
       const snapshot = await db.collection('audit_logs')
         .where('userId', '==', userId)
         .orderBy('timestamp', 'desc')
         .limit(limit)
         .get();

       return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
     }

     async getLogsByAction(action: AuditAction, startDate: Date, endDate: Date) {
       const snapshot = await db.collection('audit_logs')
         .where('action', '==', action)
         .where('timestamp', '>=', startDate)
         .where('timestamp', '<=', endDate)
         .get();

       return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
     }
   }

   export const auditService = new AuditService();
   ```

2. **Add audit middleware** (2h)
   ```typescript
   // backend/src/middleware/audit.ts
   import { auditService, AuditAction } from '../services/audit.service';

   export const auditMiddleware = (action: AuditAction) => {
     return async (req, res, next) => {
       res.on('finish', async () => {
         if (res.statusCode < 400) {
           await auditService.log({
             action,
             userId: req.user?.uid,
             resourceId: req.params.id || req.body.id,
             details: {
               method: req.method,
               path: req.path,
               statusCode: res.statusCode
             },
             ip: req.ip,
             userAgent: req.get('user-agent')
           });
         }
       });
       next();
     };
   };
   ```

3. **Integrate in routes** (2h)
   ```typescript
   // Example usage
   router.delete('/users/:id', 
     authenticate, 
     adminOnly,
     auditMiddleware(AuditAction.DATA_DELETE),
     deleteUser
   );
   ```

4. **Create admin audit log viewer** (1h)
   ```typescript
   router.get('/admin/audit-logs', authenticate, adminOnly, async (req, res) => {
     const { userId, action, startDate, endDate } = req.query;
     
     let logs;
     if (userId) {
       logs = await auditService.getLogsByUser(userId as string);
     } else if (action) {
       logs = await auditService.getLogsByAction(
         action as AuditAction,
         new Date(startDate as string),
         new Date(endDate as string)
       );
     }
     
     res.json({ logs });
   });
   ```

**Acceptance Criteria**:
- ✅ All critical actions logged
- ✅ Admin can view audit logs
- ✅ Logs include IP + user agent
- ✅ Logs retained for 1 year

---

## 🟡 Sprint 2: PERFORMANCE (Settimana 3-4)

**Obiettivo**: Migliorare performance del 40%  
**Durata**: 10 giorni lavorativi  
**Effort**: 80 ore

### **Task 2.1: Redis Caching Layer** 🟡

**Priority**: HIGH  
**Effort**: 24 ore (3 giorni)  
**Assigned to**: Backend Developer

**Steps**:
1. **Setup Cloud Memorystore (Redis)** (2h)
   ```bash
   gcloud redis instances create mypetcare-redis \
     --size=1 \
     --region=europe-west1 \
     --redis-version=redis_7_0 \
     --tier=basic
   
   # Get instance IP
   REDIS_HOST=$(gcloud redis instances describe mypetcare-redis \
     --region=europe-west1 \
     --format='value(host)')
   
   echo "REDIS_URL=redis://$REDIS_HOST:6379" >> backend/.env
   ```

2. **Install Redis client** (1h)
   ```bash
   npm install redis
   npm install --save-dev @types/redis
   ```

3. **Create cache service** (4h)
   ```typescript
   // backend/src/services/cache.service.ts
   import { createClient, RedisClientType } from 'redis';
   import { logger } from '../utils/logger';

   class CacheService {
     private client: RedisClientType;
     private connected = false;

     async connect() {
       this.client = createClient({
         url: process.env.REDIS_URL || 'redis://localhost:6379',
         socket: {
           connectTimeout: 5000,
           reconnectStrategy: (retries) => {
             if (retries > 10) {
               logger.error('Redis max retries reached');
               return new Error('Redis unavailable');
             }
             return Math.min(retries * 50, 500);
           }
         }
       });

       this.client.on('error', (err) => {
         logger.error('Redis error', err);
         this.connected = false;
       });

       this.client.on('connect', () => {
         logger.info('Redis connected');
         this.connected = true;
       });

       await this.client.connect();
     }

     async get<T>(key: string): Promise<T | null> {
       if (!this.connected) return null;
       
       try {
         const data = await this.client.get(key);
         return data ? JSON.parse(data) : null;
       } catch (error) {
         logger.error('Cache get error', error);
         return null;
       }
     }

     async set(key: string, value: any, ttl = 3600) {
       if (!this.connected) return;

       try {
         await this.client.setEx(key, ttl, JSON.stringify(value));
       } catch (error) {
         logger.error('Cache set error', error);
       }
     }

     async del(key: string) {
       if (!this.connected) return;

       try {
         await this.client.del(key);
       } catch (error) {
         logger.error('Cache delete error', error);
       }
     }

     async invalidatePattern(pattern: string) {
       if (!this.connected) return;

       try {
         const keys = await this.client.keys(pattern);
         if (keys.length > 0) {
           await this.client.del(keys);
         }
       } catch (error) {
         logger.error('Cache invalidate error', error);
       }
     }

     async mget(keys: string[]) {
       if (!this.connected) return [];

       try {
         const values = await this.client.mGet(keys);
         return values.map(v => v ? JSON.parse(v) : null);
       } catch (error) {
         logger.error('Cache mget error', error);
         return [];
       }
     }

     async disconnect() {
       if (this.client) {
         await this.client.quit();
       }
     }
   }

   export const cacheService = new CacheService();
   ```

4. **Create cache middleware** (3h)
   ```typescript
   // backend/src/middleware/cache.ts
   import { cacheService } from '../services/cache.service';
   import { logger } from '../utils/logger';

   export const cacheMiddleware = (ttl = 300) => {
     return async (req, res, next) => {
       // Only cache GET requests
       if (req.method !== 'GET') {
         return next();
       }

       // Generate cache key from URL + query params
       const cacheKey = `route:${req.path}:${JSON.stringify(req.query)}`;

       try {
         // Check cache
         const cachedData = await cacheService.get(cacheKey);
         
         if (cachedData) {
           logger.debug(`Cache HIT: ${cacheKey}`);
           res.setHeader('X-Cache', 'HIT');
           return res.json(cachedData);
         }

         logger.debug(`Cache MISS: ${cacheKey}`);
         res.setHeader('X-Cache', 'MISS');

         // Intercept res.json to cache response
         const originalJson = res.json.bind(res);
         res.json = (data) => {
           // Cache successful responses only
           if (res.statusCode < 400) {
             cacheService.set(cacheKey, data, ttl);
           }
           return originalJson(data);
         };

         next();
       } catch (error) {
         logger.error('Cache middleware error', error);
         next();
       }
     };
   };
   ```

5. **Integrate caching in routes** (6h)
   ```typescript
   // Cache veterinaries list (5 minutes)
   router.get('/veterinaries', cacheMiddleware(300), async (req, res) => {
     const veterinaries = await getVeterinaries();
     res.json(veterinaries);
   });

   // Cache user's bookings (1 minute - more dynamic)
   router.get('/bookings', authenticate, cacheMiddleware(60), async (req, res) => {
     const bookings = await getUserBookings(req.user.uid);
     res.json(bookings);
   });

   // Invalidate cache on updates
   router.post('/bookings', authenticate, async (req, res) => {
     const booking = await createBooking(req.body);
     
     // Invalidate user's bookings cache
     await cacheService.invalidatePattern(`route:/bookings:*${req.user.uid}*`);
     
     res.status(201).json(booking);
   });
   ```

6. **Add cache warming** (4h)
   ```typescript
   // backend/src/jobs/cache-warming.ts
   import { cacheService } from '../services/cache.service';
   import { db } from '../utils/firestore';

   export async function warmCache() {
     // Warm popular data
     const veterinaries = await db.collection('veterinaries')
       .where('active', '==', true)
       .get();
     
     await cacheService.set(
       'route:/veterinaries:{}',
       veterinaries.docs.map(doc => ({ id: doc.id, ...doc.data() })),
       600 // 10 minutes
     );

     logger.info('Cache warmed');
   }

   // Run on startup
   warmCache();
   ```

7. **Performance testing** (4h)
   - Load test pre/post caching
   - Measure response times
   - Monitor cache hit rate

**Expected Results**:
- 📊 Response time: 800ms → 150ms (-81%)
- 📊 Cache hit rate: 70%+ per endpoint frequenti
- 📊 Database queries: -60%

---

### **Task 2.2: Response Compression** 🟡

**Priority**: HIGH  
**Effort**: 4 ore (0.5 giorni)  
**Assigned to**: Backend Developer

(Content similar to previous sections - implementation of compression middleware)

---

## 🟢 Sprint 3: CI/CD & COMPLIANCE (Settimana 5-6)

**Obiettivo**: Automated deployment + GDPR ready  
**Durata**: 10 giorni lavorativi  
**Effort**: 80 ore

### **Task 3.1: GitHub Actions CI/CD** 🟢

(Content for CI/CD setup - workflow files, automation)

### **Task 3.2: GDPR Compliance** 🟢

(Content for GDPR endpoints - data export, deletion)

---

## 📊 Progress Tracking

### **Week 1-2 Checklist**
- [ ] Input validation implemented (16h)
- [ ] Backend tests (70% coverage) (24h)
- [ ] ESLint + Prettier setup (8h)
- [ ] Flutter tests (60% coverage) (24h)
- [ ] Audit logging system (8h)

**Sprint 1 Total**: 80h

### **Week 3-4 Checklist**
- [ ] Redis caching layer (24h)
- [ ] Response compression (4h)
- [ ] Cloud Monitoring alerts (16h)
- [ ] Performance optimization (16h)
- [ ] Load testing (8h)
- [ ] CDN setup (12h)

**Sprint 2 Total**: 80h

### **Week 5-6 Checklist**
- [ ] GitHub Actions CI/CD (20h)
- [ ] GDPR endpoints (16h)
- [ ] Privacy policy integration (8h)
- [ ] Documentation updates (12h)
- [ ] Final QA testing (16h)
- [ ] Production deployment (8h)

**Sprint 3 Total**: 80h

---

## 💰 Investment & ROI

### **Cost Breakdown**

| Item | Hours | Rate ($/h) | Cost |
|------|-------|-----------|------|
| Backend Dev | 120h | $60 | $7,200 |
| Flutter Dev | 80h | $60 | $4,800 |
| DevOps | 40h | $70 | $2,800 |
| **TOTAL** | **240h** | - | **$14,800** |

### **ROI Calculation**

**Benefits Year 1**:
- 🐛 Bug prevention: $15,000 (based on 5 critical bugs avoided @ $3k each)
- ⏱️ Downtime reduction: $10,000 (based on 99.9% uptime vs 99%)
- 🚀 Developer productivity: $8,000 (20% faster development)
- 🔒 Security incidents avoided: $25,000 (1 incident @ $25k)
- 📊 Performance improvements: $7,000 (better conversion rate)

**Total Benefits**: $65,000/year  
**Investment**: $14,800  
**Net ROI**: $50,200 (+339%)

---

## ✅ Success Criteria

### **Technical Metrics**
- ✅ Test coverage: 70%+ backend, 60%+ Flutter
- ✅ Performance: -40% response time
- ✅ Security: 95/100 score
- ✅ Uptime: 99.9%+
- ✅ Zero critical vulnerabilities

### **Process Metrics**
- ✅ CI/CD pipeline: <10 min deploy
- ✅ Automated tests: 100% pass rate
- ✅ Code reviews: <24h turnaround
- ✅ Documentation: 100% coverage

### **Business Metrics**
- ✅ User satisfaction: >4.5/5
- ✅ Crash rate: <0.1%
- ✅ Load time: <2s
- ✅ API latency: <200ms (p95)

---

**Document Version**: 1.0  
**Last Updated**: 28 Gennaio 2025  
**Status**: READY FOR EXECUTION  
**Approval**: Pending stakeholder review
