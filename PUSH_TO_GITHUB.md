# 🚀 رفع التطبيق إلى GitHub

## الخطوات السريعة (3 دقائق):

### 1️⃣ احصل على Personal Access Token

1. اذهب إلى: https://github.com/settings/tokens
2. انقر: "Generate new token (classic)"
3. سمِّه: `alenwan-push`
4. اختر المدة: "No expiration"
5. اختر الصلاحيات:
   - ✅ repo (full control)
   - ✅ workflow
6. انقر: "Generate token"
7. **انسخ الرمز فوراً** (يظهر مرة واحدة فقط!)

### 2️⃣ استخدم السكريبت

**في PowerShell:**
```powershell
cd C:\Users\HP\Desktop\flutter\alenwan
.\github-push.ps1
```

عند الطلب، الصق الرمز الذي نسخته.

### 3️⃣ تحقق

اذهب إلى: https://github.com/amalhusseinmansour-hue/alenwan

---

## الطريقة اليدوية (إذا فشل السكريبت):

```powershell
cd C:\Users\HP\Desktop\flutter\alenwan

# استبدل YOUR_TOKEN بالرمز الفعلي
git remote set-url origin "https://amalhusseinmansour-hue:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git"

git push -u origin main
```

---

## 🔐 تنبيهات الأمان:

- ✅ استخدم الرمز فوراً ثم احذفه من السجل
- ✅ لا تضع الرمز في أي ملف
- ✅ لا تشارك الرمز مع أحد
- ✅ يمكن إعادة إنشاء الرموز في أي وقت

---

## المشاكل الشائعة:

### ❌ "Authentication failed"
**الحل:** تأكد من نسخ الرمز كاملاً بدون مسافات

### ❌ "Permission denied"
**الحل:** أعد إنشاء الرمز مع scopes الصحيحة (repo + workflow)

### ❌ "could not read Username"
**الحل:** استخدم الطريقة اليدوية وتأكد من URL الصحيح

---

## ✅ النتيجة المتوقعة:

```
Enumerating objects: 45, done.
Counting objects: 100% (45/45), done.
...
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

🎉 تم! التطبيق الآن على GitHub!
