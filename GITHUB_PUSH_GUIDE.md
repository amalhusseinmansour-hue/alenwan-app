# 🚀 تعليمات رفع Alenwan إلى GitHub

## المشكلة الحالية

```
الخطأ: Permission denied - BDCdevo ليس له صلاحيات على الريبو
الحل: تحديث الـ GitHub credentials
```

---

## ✅ الحل (اختر أحد الخيارات)

### الخيار 1️⃣ - استخدام Personal Access Token

#### الخطوة 1: إنشاء PAT على GitHub
```
1. اذهب إلى: https://github.com/settings/tokens
2. انقر: Generate new token (classic)
3. اختر الصلاحيات:
   ✅ repo (كامل الصلاحيات)
   ✅ workflow
4. انقر: Generate token
5. انسخ الرمز (سيظهر مرة واحدة فقط)
```

#### الخطوة 2: استخدم الرمز للرفع
```bash
cd C:\Users\HP\Desktop\flutter\alenwan

# استخدم الـ URL مع الرمز
git remote remove origin
git remote add origin https://YOUR_USERNAME:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git

# الآن رفع
git push -u origin main
```

**مثال:**
```bash
git remote add origin https://amalhusseinmansour:ghp_xxxxxxxxxxxxxx@github.com/amalhusseinmansour-hue/alenwan.git
git push -u origin main
```

---

### الخيار 2️⃣ - إعادة تعيين الـ Credentials

#### في Windows:
```
1. افتح: Control Panel → Credential Manager
2. ابحث عن: github.com
3. احذفها
4. عند محاولة الرفع، سيطلب منك البيانات الجديدة
```

#### أو استخدم PowerShell:
```powershell
# حذف الـ credentials المحفوظة
[Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] > $null
$vault = New-Object Windows.Security.Credentials.PasswordVault
$credentials = $vault.RetrieveAll() | Where-Object { $_.Resource -like "*github*" }
$credentials | ForEach-Object { $vault.Remove($_) }

# ثم جرب الرفع
cd C:\Users\HP\Desktop\flutter\alenwan
git push -u origin main
```

---

### الخيار 3️⃣ - استخدام gh CLI

#### التثبيت:
```bash
winget install GitHub.cli
# أو من: https://cli.github.com/
```

#### الاستخدام:
```bash
gh auth login
# اختر: GitHub.com
# اختر: HTTPS
# اختر: Y (Authenticate Git with your GitHub credentials)

# ثم الرفع
cd C:\Users\HP\Desktop\flutter\alenwan
git push -u origin main
```

---

### الخيار 4️⃣ - استخدام SSH

#### 1. إنشاء SSH Key
```bash
ssh-keygen -t ed25519 -C "amalhussein@example.com"
# أو
ssh-keygen -t rsa -b 4096 -C "amalhussein@example.com"
```

#### 2. إضافة المفتاح العام على GitHub
```
1. اذهب إلى: https://github.com/settings/ssh
2. انقر: New SSH key
3. الصق المفتاح العام (من ~/.ssh/id_ed25519.pub)
```

#### 3. اختبر الاتصال
```bash
ssh -T git@github.com
# يجب أن ترى: "Hi amalhusseinmansour-hue! You've successfully authenticated"
```

#### 4. حدث الـ remote
```bash
cd C:\Users\HP\Desktop\flutter\alenwan
git remote remove origin
git remote add origin git@github.com:amalhusseinmansour-hue/alenwan.git

# ثم رفع
git push -u origin main
```

---

## 🎯 الخطوات الموصى بة (الأسهل)

### استخدام Personal Access Token:

```bash
# 1. انسخ الرمز من GitHub (انظر الخطوة 1 أعلاه)

# 2. عيّن البيانات
cd C:\Users\HP\Desktop\flutter\alenwan

# 3. حدث الـ remote (استبدل YOUR_TOKEN)
git remote remove origin
git remote add origin https://amalhusseinmansour:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git

# 4. رفع المشروع
git push -u origin main

# 5. سيستغرق قليلاً... انتظر
```

---

## ✅ التحقق من النجاح

```bash
# تحقق من الـ remote
git remote -v

# يجب أن تظهر:
# origin  https://...@github.com/amalhusseinmansour-hue/alenwan.git (fetch)
# origin  https://...@github.com/amalhusseinmansour-hue/alenwan.git (push)

# ثم تحقق من GitHub:
# https://github.com/amalhusseinmansour-hue/alenwan
```

---

## 📊 معلومات المشروع

```
المشروع:    alenwan
الريبو:     https://github.com/amalhusseinmansour-hue/alenwan
الـ Branch: main
الحالة:     جاهز للرفع
```

---

## 🆘 إذا استمرت المشكلة

### تحقق من:
1. أن حسابك (amalhusseinmansour-hue) مالك الريبو
2. أن لديك صلاحيات push على الريبو
3. أن الرمز (PAT) لديه صلاحيات repo
4. أن الـ URL صحيح

### أو:
```bash
# اختبر الاتصال
git ls-remote https://github.com/amalhusseinmansour-hue/alenwan.git

# إذا فشل، جرب الأمر مع البيانات
git ls-remote https://YOUR_USERNAME:YOUR_TOKEN@github.com/amalhusseinmansour-hue/alenwan.git
```

---

**اختر الطريقة التي تفضلها وأكمل الرفع! 🚀**
