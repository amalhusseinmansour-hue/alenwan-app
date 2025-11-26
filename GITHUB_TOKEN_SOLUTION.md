# 🔐 حل مشكلة Authentication - GitHub Personal Access Token

## ❌ الخطأ:
```
Invalid username or token. Password authentication is not supported
```

---

## ✅ الحل: استخدم Personal Access Token

### الخطوة 1️⃣ - أنشئ Personal Access Token على GitHub

1. اذهب إلى: **https://github.com/settings/tokens**
2. اضغط: **Generate new token (classic)**
3. في الحقول:
   - **Token name**: `alenwan-push`
   - **Expiration**: `No expiration` أو اختر مدة

4. في الصلاحيات (Scopes)، اختر:
   ```
   ✅ repo (full control of private repositories)
      ├── repo:status
      ├── repo_deployment
      ├── public_repo
      └── repo:invite
   
   ✅ workflow (Update GitHub Action workflows)
   ```

5. اضغط: **Generate token**
6. **انسخ الرمز فوراً** (سيختفي ولن تستطيع رؤيته مرة أخرى)

---

### الخطوة 2️⃣ - استخدم الرمز للرفع

انسخ هذا الأمر واستبدل `YOUR_TOKEN` بالرمز:

```bash
cd C:\Users\HP\Desktop\flutter\alenwan

git remote set-url origin "https://amalhusseinmansour-hue:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git"
```

**مثال الأمر الصحيح:**
```bash
git remote set-url origin "https://amalhusseinmansour-hue:ghp_1234567890abcdefghijklmnopqrstuvwxyz@github.com/amalhusseinmansour-hue/alenwan.git"
```

---

### الخطوة 3️⃣ - رفع المشروع

```bash
git push -u origin main
```

---

## 📝 خطوة بخطوة (نسخ ولصق):

1. **أنشئ الرمز:**
   - اذهب إلى: https://github.com/settings/tokens
   - انقر: Generate new token (classic)
   - اختر الصلاحيات: repo + workflow
   - انسخ الرمز

2. **حدث الـ URL:**
```bash
cd C:\Users\HP\Desktop\flutter\alenwan
git remote set-url origin "https://amalhusseinmansour-hue:ghp_PASTE_YOUR_TOKEN_HERE@github.com/amalhusseinmansour-hue/alenwan.git"
```

3. **رفع:**
```bash
git push -u origin main
```

---

## 🔍 تحقق من الـ URL:

```bash
git remote -v
```

يجب أن يظهر:
```
origin  https://amalhusseinmansour-hue:ghp_...@github.com/amalhusseinmansour-hue/alenwan.git (fetch)
origin  https://amalhusseinmansour-hue:ghp_...@github.com/amalhusseinmansour-hue/alenwan.git (push)
```

---

## ⚠️ ملاحظات مهمة:

- ✅ الرمز يظهر **مرة واحدة فقط** - انسخه فوراً
- ✅ لا تشارك الرمز مع أحد
- ✅ إذا فقدته، أنشئ رمز جديد
- ✅ لا تحفظ الرمز في الملفات الحساسة
- ✅ استخدم **repo + workflow** في الصلاحيات فقط

---

## ✅ بعد الرفع الناجح:

```bash
# تحقق من GitHub
https://github.com/amalhusseinmansour-hue/alenwan

# يجب أن ترى جميع الملفات
```

---

## 🆘 إذا حدث خطأ:

```bash
# تحقق من الـ remote
git remote -v

# إذا أخطأت الرمز:
git remote set-url origin "https://amalhusseinmansour-hue:NEW_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git"

# ثم حاول الرفع مرة أخرى
git push -u origin main
```

---

## 💡 الخيارات الأخرى:

### استخدام gh CLI (الأسهل):
```bash
# ثبت gh من: https://cli.github.com/
gh auth login

# اتبع الخطوات
# ثم رفع مباشرة
git push -u origin main
```

### استخدام SSH:
```bash
# أنشئ SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# أضفها على GitHub
https://github.com/settings/ssh

# اختبر الاتصال
ssh -T git@github.com

# حدث الـ remote
git remote set-url origin git@github.com:amalhusseinmansour-hue/alenwan.git

# رفع
git push -u origin main
```

---

**استخدم Personal Access Token - الطريقة الأسهل والأسرع! ✅**
