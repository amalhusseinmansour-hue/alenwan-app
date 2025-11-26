# ⚠️ مشكلة الرفع إلى GitHub

## 📌 الحالة الحالية

```
المشروع:  alenwan (Flutter + Laravel)
الحساب الحالي:  BDCdevo
الريبو الهدف:  github.com/amalhusseinmansour-hue/alenwan
الخطأ:  Permission denied (403)
السبب:  حساب BDCdevo ليس له صلاحيات على الريبو
```

---

## ✅ الحل السريع

### استخدم Personal Access Token:

**الخطوة 1️⃣ - أنشئ رمز على GitHub:**
```
https://github.com/settings/tokens → Generate new token (classic)
اختر: repo + workflow
انسخ الرمز
```

**الخطوة 2️⃣ - رفع المشروع:**
```bash
cd C:\Users\HP\Desktop\flutter\alenwan

git remote remove origin
git remote add origin https://amalhusseinmansour:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git

git push -u origin main
```

**الخطوة 3️⃣ - تحقق:**
```
https://github.com/amalhusseinmansour-hue/alenwan
```

---

## 📝 البيانات المطلوبة

```
GitHub Username:  amalhusseinmansour
GitHub Repo:      amalhusseinmansour-hue/alenwan
Repository URL:   https://github.com/amalhusseinmansour-hue/alenwan.git
```

---

## 🎯 خيارات أخرى

1. **SSH** - استخدم SSH keys
2. **gh CLI** - الطريقة الرسمية من GitHub
3. **Personal Access Token** - ✅ الأسهل

---

**اختر الخيار وأكمل الرفع! 🚀**

تفاصيل كاملة في: `GITHUB_PUSH_GUIDE.md`
