# 🗄️ Firestore Composite Indexes - Sprint 3 Geospatial Queries

## 📋 Required Indexes for Geospatial Search

Sprint 3 introduces geohash-based geospatial queries that require composite indexes in Firestore.

---

## 🎯 Index Requirements

### Why Composite Indexes?

Firestore requires composite indexes when:
1. Using `orderBy()` on a field other than the filter field
2. Combining `where()` clauses with `orderBy()`
3. Using array-contains with other filters

**Our geospatial queries use:**
- `.orderBy('geohash')` - Sort by geohash for bounding box queries
- `.where('visible', '==', true)` - Filter visible pros
- `.where('categories', 'array-contains', category)` - Filter by category

---

## 🔧 Required Indexes

### Index 1: Geosearch with Visibility Filter

**Use Case**: Find all visible pros within radius

```
Collection: pros
Fields:
  1. visible (Ascending)
  2. geohash (Ascending)
Query Scope: Collection
```

**Example Query:**
```typescript
db.collection('pros')
  .where('visible', '==', true)
  .orderBy('geohash')
  .startAt('u0n')
  .endAt('u0o')
```

---

### Index 2: Geosearch with Category Filter

**Use Case**: Find visible pros of specific category within radius

```
Collection: pros
Fields:
  1. visible (Ascending)
  2. categories (Array)
  3. geohash (Ascending)
Query Scope: Collection
```

**Example Query:**
```typescript
db.collection('pros')
  .where('visible', '==', true)
  .where('categories', 'array-contains', 'veterinari')
  .orderBy('geohash')
  .startAt('u0n')
  .endAt('u0o')
```

---

### Index 3: Basic Geosearch (Optional but Recommended)

**Use Case**: Admin queries or internal tools without visibility filter

```
Collection: pros
Fields:
  1. geohash (Ascending)
Query Scope: Collection
```

**Example Query:**
```typescript
db.collection('pros')
  .orderBy('geohash')
  .startAt('u0n')
  .endAt('u0o')
```

---

## 🚀 Index Creation Methods

### Method 1: Automatic (Recommended)

**Steps:**
1. Run a query that requires an index
2. Firestore will throw an error with a link
3. Click the link to auto-generate the index
4. Wait 2-5 minutes for index creation

**Example Error:**
```
The query requires an index. You can create it here:
https://console.firebase.google.com/v1/r/project/pet-care-9790d/firestore/indexes?create_composite=...
```

**Advantages:**
- ✅ Automatically generates correct configuration
- ✅ No manual JSON editing
- ✅ Immediate deployment

---

### Method 2: Firebase Console (Manual)

**Steps:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes** tab
4. Click **Create Index** button
5. Configure index fields as shown above
6. Click **Create**

**Field Configuration:**

**Index 1: Visible + Geohash**
| Field | Mode |
|-------|------|
| visible | Ascending |
| geohash | Ascending |

**Index 2: Visible + Categories + Geohash**
| Field | Mode |
|-------|------|
| visible | Ascending |
| categories | Array |
| geohash | Ascending |

**Index 3: Geohash Only**
| Field | Mode |
|-------|------|
| geohash | Ascending |

---

### Method 3: firestore.indexes.json (Deployment)

**File Location**: `/backend/firestore.indexes.json` or project root

**Configuration:**
```json
{
  "indexes": [
    {
      "collectionGroup": "pros",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "visible", "order": "ASCENDING" },
        { "fieldPath": "geohash", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "pros",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "visible", "order": "ASCENDING" },
        { "fieldPath": "categories", "arrayConfig": "CONTAINS" },
        { "fieldPath": "geohash", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "pros",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "geohash", "order": "ASCENDING" }
      ]
    }
  ]
}
```

**Deployment:**
```bash
# Deploy all Firestore indexes
firebase deploy --only firestore:indexes

# Deploy with rules
firebase deploy --only firestore:indexes,firestore:rules
```

**Advantages:**
- ✅ Version controlled
- ✅ Repeatable deployments
- ✅ Environment consistency

---

## ⏱️ Index Build Time

**Typical Build Times:**
- Empty collection: Instant
- < 1,000 documents: 1-2 minutes
- < 10,000 documents: 5-10 minutes
- < 100,000 documents: 30-60 minutes
- > 100,000 documents: Several hours

**During Index Creation:**
- ⚠️ Queries requiring the index will fail
- ⚠️ App should handle index errors gracefully
- ⚠️ Consider maintenance window for large collections

---

## 🧪 Verify Index Creation

### Method 1: Firebase Console

1. Go to **Firestore Database** → **Indexes**
2. Check **Status** column
   - 🟢 **Enabled**: Index is ready
   - 🟡 **Creating**: Index is building
   - 🔴 **Error**: Index creation failed

### Method 2: Test Query

```typescript
// Test geospatial query
const testQuery = async () => {
  try {
    const pros = await db.collection('pros')
      .where('visible', '==', true)
      .orderBy('geohash')
      .startAt('u0n')
      .endAt('u0o')
      .limit(10)
      .get()

    console.log('✅ Index working:', pros.size, 'results')
  } catch (error: any) {
    if (error.code === 9) {
      console.error('❌ Index required:', error.message)
      // Error message includes index creation link
    } else {
      console.error('❌ Query error:', error.message)
    }
  }
}
```

---

## 📊 Index Statistics

**Index Storage Cost:**
- Each index entry: ~1-2 KB
- Total index size: (# documents) × (# indexes) × (entry size)
- Example: 10,000 pros × 3 indexes × 1.5 KB = ~45 MB

**Query Performance:**
- Index lookup: O(log n) complexity
- Bounding box scan: O(m) where m = results in box
- **10-100x faster** than full collection scans

---

## 🚨 Common Issues & Solutions

### Issue 1: Index Creation Failed

**Symptoms:**
- Status shows "Error" in Firebase Console
- Query still fails with index required error

**Solutions:**
1. Delete failed index
2. Recreate with correct field types
3. Verify field names match exactly (case-sensitive)
4. Check query scope (Collection vs Collection Group)

---

### Issue 2: Query Still Fails After Index Creation

**Symptoms:**
- Index shows "Enabled" but query fails
- Error: "The query requires an index"

**Possible Causes:**
1. **Wrong query scope**: Collection vs Collection Group
2. **Field order mismatch**: Index fields must match query order
3. **Cache issue**: Wait 1-2 minutes and retry
4. **Multiple inequality filters**: Firestore limitation

**Verification:**
```typescript
// Ensure query matches index exactly
// ❌ WRONG: filters in different order
.where('categories', 'array-contains', 'veterinari')
.where('visible', '==', true)
.orderBy('geohash')

// ✅ CORRECT: matches index field order
.where('visible', '==', true)
.where('categories', 'array-contains', 'veterinari')
.orderBy('geohash')
```

---

### Issue 3: Index Build Taking Too Long

**Symptoms:**
- Status stuck on "Creating" for hours
- Large collection (>100k documents)

**Solutions:**
1. **Wait patiently**: Large indexes take time
2. **Check Firestore quota**: Ensure not hitting limits
3. **Contact Firebase support**: For unusually long builds
4. **Temporary workaround**: Use simpler queries until index completes

---

## 🔍 Index Maintenance

### When to Rebuild Indexes

**Reasons to Rebuild:**
- ✅ Field types changed
- ✅ Query patterns changed
- ✅ Performance degradation
- ✅ Index corruption suspected

**Rebuild Process:**
1. Delete old index
2. Create new index with updated configuration
3. Wait for index build
4. Test queries
5. Monitor performance

### Index Monitoring

**Metrics to Track:**
- Query latency (should be <200ms)
- Index size (check Firebase Console)
- Query failures (index missing errors)
- Index build time (for future reference)

---

## 📚 Additional Resources

### Firebase Documentation
- [Composite Indexes](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Index Best Practices](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Query Limitations](https://firebase.google.com/docs/firestore/query-data/queries#query_limitations)

### Geospatial Queries
- [GeoQueries for Firestore](https://firebase.google.com/docs/firestore/solutions/geoqueries)
- [geofire-common Library](https://github.com/firebase/geofire-js)
- [Geohash Algorithm](https://en.wikipedia.org/wiki/Geohash)

---

## ✅ Deployment Checklist

Before deploying Sprint 3 to production:

- [ ] Create Index 1 (visible + geohash)
- [ ] Create Index 2 (visible + categories + geohash)
- [ ] Create Index 3 (geohash only) - optional
- [ ] Wait for all indexes to show "Enabled" status
- [ ] Test geospatial query without filters
- [ ] Test geospatial query with category filter
- [ ] Test geospatial query with radius parameter
- [ ] Monitor query performance (should be <200ms)
- [ ] Verify cache integration works correctly
- [ ] Check index statistics in Firebase Console

---

**Index Creation Status**: ⏳ **PENDING**

**Action Required**: Create indexes using one of the methods above before deploying Sprint 3 features.

**Estimated Setup Time**: 5-10 minutes (manual) + 2-5 minutes (index build)

---

*These indexes are critical for Sprint 3 geospatial features. Without them, all geospatial queries will fail.*
