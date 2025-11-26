# إصلاح التعليقات في البث المباشر

## المشكلة
```
SQLSTATE[42S22]: Column not found: 'is_active'
```

## الحل

### الخيار 1: إضافة العمود المفقود
إذا كان العمود `is_active` مفقود من جدول `live_stream_comments`:

```sql
ALTER TABLE live_stream_comments 
ADD COLUMN is_active TINYINT(1) DEFAULT 1 AFTER text;
```

### الخيار 2: إزالة الشرط من الاستعلام
إذا كان الخطأ في Controller، ابحث عن الملف:
- `app/Http/Controllers/Api/LiveStreamController.php`

وابحث عن دالة `comments()` أو `getComments()`:

```php
// قبل (خطأ)
$comments = LiveStreamComment::where('live_stream_id', $id)
    ->where('is_active', 1)  // ← هذا السطر يسبب المشكلة
    ->orderBy('created_at', 'desc')
    ->get();

// بعد (صحيح)
$comments = LiveStreamComment::where('live_stream_id', $id)
    ->orderBy('created_at', 'desc')
    ->get();
```

### الخيار 3: إنشاء Migration جديدة
```bash
php artisan make:migration add_is_active_to_live_stream_comments
```

في الملف الجديد:
```php
public function up()
{
    Schema::table('live_stream_comments', function (Blueprint $table) {
        $table->boolean('is_active')->default(true)->after('text');
    });
}

public function down()
{
    Schema::table('live_stream_comments', function (Blueprint $table) {
        $table->dropColumn('is_active');
    });
}
```

ثم نفذ:
```bash
php artisan migrate
```

## التطبيق على السيرفر

```bash
# 1. اتصل بالسيرفر
ssh -p 65002 u996186400@46.202.180.189

# 2. انتقل إلى مجلد المشروع
cd domains/alenwan.app/public_html

# 3. ادخل إلى MySQL
mysql -u [username] -p [database]

# 4. نفذ الأمر SQL
ALTER TABLE live_stream_comments ADD COLUMN is_active TINYINT(1) DEFAULT 1;

# 5. اخرج من MySQL
exit

# 6. امسح الـ cache
php artisan cache:clear
php artisan config:clear
```

## الاختبار
بعد التطبيق، اختبر الـ endpoint:
```bash
curl -X GET "https://alenwan.app/api/live-streams/1/comments"
```

يجب أن يرجع:
```json
{
  "success": true,
  "comments": [...]
}
```
