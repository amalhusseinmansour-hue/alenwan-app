# دليل إصلاح مشاكل CRUD في Backend

## 🔴 المشكلة
جميع عمليات الحفظ (Create)، التحديث (Update)، والحذف (Delete) لا تعمل في لوحة التحكم Filament.

---

## 🔍 التشخيص

### الخطوة 1: فحص الأخطاء في Logs
```bash
ssh -p 65002 u996186400@46.202.180.189
cd domains/alenwan.app/public_html

# اقرأ آخر 50 سطر من log
tail -n 50 storage/logs/laravel.log

# أو راقب الأخطاء مباشرة
tail -f storage/logs/laravel.log
```

**ابحث عن:**
- `SQLSTATE` errors (مشاكل قاعدة بيانات)
- `Permission denied` (مشاكل صلاحيات)
- `CSRF token mismatch` (مشاكل CSRF)
- `Mass assignment` errors (مشاكل fillable)

---

### الخطوة 2: فحص صلاحيات الملفات
```bash
# تحقق من صلاحيات storage
ls -la storage/

# يجب أن تكون:
# drwxr-xr-x storage
# drwxr-xr-x storage/logs

# إذا كانت خاطئة، صححها:
chmod -R 755 storage
chmod -R 775 storage/logs
chmod -R 775 storage/framework
chmod -R 775 bootstrap/cache
```

---

### الخطوة 3: فحص قاعدة البيانات
```bash
# ادخل MySQL
mysql -u u996186400_alenwan -p u996186400_alenwan

# تحقق من الجداول
SHOW TABLES;

# تحقق من بنية جدول (مثال: movies)
DESCRIBE movies;

# تحقق من الصلاحيات
SHOW GRANTS;

# اخرج
exit
```

---

## 🛠️ الحلول الشائعة

### الحل 1: مشكلة CSRF Token
**السبب:** Laravel يتطلب CSRF token لجميع عمليات POST/PUT/DELETE

**الحل:**
```bash
# امسح الـ cache
php artisan config:clear
php artisan cache:clear
php artisan view:clear

# أعد تشغيل الـ config
php artisan config:cache
```

---

### الحل 2: مشكلة Mass Assignment
**السبب:** الحقول غير مضافة في `$fillable` في Model

**الحل:** تحقق من Models في `app/Models/`

مثال لـ `Movie.php`:
```php
protected $fillable = [
    'title',
    'description',
    'slug',
    'poster_url',
    'trailer_url',
    'video_url',
    'duration',
    'release_year',
    'rating',
    'views_count',
    'is_active',
    'is_premium',
    'is_featured',
    'director',
    'cast',
    'category_id',
];
```

**إذا كانت الحقول مفقودة:**
```bash
# عدّل الملف على السيرفر
nano app/Models/Movie.php

# أضف الحقول المفقودة في $fillable
# احفظ: Ctrl+O ثم Enter
# اخرج: Ctrl+X
```

---

### الحل 3: مشكلة Database Connection
**السبب:** الاتصال بقاعدة البيانات معطل

**الحل:**
```bash
# تحقق من .env
cat .env | grep DB_

# يجب أن تكون:
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=u996186400_alenwan
# DB_USERNAME=u996186400_alenwan
# DB_PASSWORD=[كلمة المرور]

# إذا كانت خاطئة، عدّلها:
nano .env

# ثم امسح الـ cache
php artisan config:clear
php artisan config:cache
```

---

### الحل 4: مشكلة Middleware
**السبب:** Middleware يمنع العمليات

**الحل:**
```bash
# تحقق من app/Http/Kernel.php
cat app/Http/Kernel.php | grep -A 10 "middleware"

# تأكد من وجود:
# \App\Http\Middleware\VerifyCsrfToken::class
# في $middlewareGroups['web']
```

---

### الحل 5: مشكلة Storage Link
**السبب:** الصور لا تُحفظ بسبب عدم وجود symbolic link

**الحل:**
```bash
# أنشئ storage link
php artisan storage:link

# تحقق من النتيجة
ls -la public/ | grep storage

# يجب أن ترى:
# lrwxrwxrwx storage -> ../storage/app/public
```

---

## 🧪 الاختبار

### اختبار 1: إنشاء فيلم جديد
1. افتح لوحة التحكم: `https://alenwan.app/admin`
2. اذهب إلى Movies → Create
3. املأ البيانات واحفظ
4. **المتوقع:** رسالة نجاح + إعادة توجيه للقائمة

**إذا فشل:**
- افتح terminal وشاهد `tail -f storage/logs/laravel.log`
- انسخ رسالة الخطأ

---

### اختبار 2: تحديث فيلم
1. افتح فيلم موجود
2. عدّل أي حقل
3. احفظ
4. **المتوقع:** رسالة نجاح

---

### اختبار 3: حذف فيلم
1. افتح فيلم
2. اضغط Delete
3. أكّد الحذف
4. **المتوقع:** حذف ناجح

---

## 📋 Checklist للتشخيص

```
[ ] فحصت storage/logs/laravel.log
[ ] تحققت من صلاحيات الملفات (755/775)
[ ] تحققت من اتصال قاعدة البيانات
[ ] تحققت من $fillable في Models
[ ] مسحت الـ cache (config, cache, view)
[ ] تحققت من CSRF middleware
[ ] أنشأت storage link
[ ] اختبرت Create/Update/Delete
```

---

## 🚨 الأخطاء الشائعة ورسائلها

### خطأ 1: "SQLSTATE[42S22]: Column not found"
**السبب:** عمود مفقود في قاعدة البيانات
**الحل:** نفّذ migrations:
```bash
php artisan migrate
```

---

### خطأ 2: "Add [column_name] to fillable property"
**السبب:** الحقل غير موجود في $fillable
**الحل:** أضف الحقل في Model

---

### خطأ 3: "CSRF token mismatch"
**السبب:** الـ session منتهية أو الـ cache قديم
**الحل:**
```bash
php artisan config:clear
php artisan cache:clear
```

---

### خطأ 4: "Permission denied"
**السبب:** صلاحيات الملفات خاطئة
**الحل:**
```bash
chmod -R 755 storage
chmod -R 775 storage/logs
```

---

### خطأ 5: "Connection refused"
**السبب:** قاعدة البيانات معطلة
**الحل:** تحقق من .env وأعد تشغيل MySQL

---

## 💡 نصائح إضافية

### 1. تفعيل Debug Mode (مؤقتاً)
```bash
# في .env
APP_DEBUG=true

# لا تنسَ إعادته إلى false بعد الانتهاء!
```

### 2. فحص Queue
```bash
# إذا كانت العمليات تستخدم queue
php artisan queue:work --once
```

### 3. إعادة تحميل Composer
```bash
composer dump-autoload
```

### 4. فحص PHP Version
```bash
php -v
# يجب أن تكون 8.1 أو أحدث
```

---

## 📞 إذا استمرت المشكلة

إذا جربت كل الحلول ولم تنجح:

1. **انسخ رسالة الخطأ من logs**
2. **التقط screenshot من الخطأ**
3. **شارك التفاصيل:**
   - نوع العملية (Create/Update/Delete)
   - Model المتأثر
   - رسالة الخطأ الكاملة

---

## ✅ بعد الإصلاح

```bash
# امسح جميع الـ caches
php artisan optimize:clear

# أعد بناء الـ cache
php artisan optimize

# اختبر جميع العمليات:
# - Create movie
# - Update movie
# - Delete movie
# - Create series
# - Update series
# - Delete series
```
