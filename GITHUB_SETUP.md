# GitHub Setup & APK Build Guide

## 📦 Automatic APK Building with GitHub Actions

This project is configured to automatically build APK files using GitHub Actions whenever you push code.

## 🚀 Setup Instructions

### 1. Create GitHub Repository

Go to [GitHub](https://github.com/new) and create a new repository:
- **Name**: `calculator-vault` (or your preferred name)
- **Visibility**: Private (recommended for safety app)
- **Don't** initialize with README (we already have one)

### 2. Push Your Code

```bash
cd /home/ch4lkp0wd3r/cyber-sheild-india/calculator_vault

# Add all files
git add .

# Commit
git commit -m "Initial commit: Calculator Vault with forensic features"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/calculator-vault.git

# Push to GitHub
git push -u origin master
```

### 3. GitHub Actions Will Automatically:

✅ Install Flutter SDK  
✅ Get all dependencies  
✅ Analyze code for errors  
✅ Build release APK  
✅ Upload APK as artifact  

### 4. Download Your APK

After pushing, go to:
1. Your GitHub repository
2. Click "Actions" tab
3. Click on the latest workflow run
4. Scroll down to "Artifacts"
5. Download `calculator-vault-apk`
6. Extract the ZIP to get `app-release.apk`

## 📱 Installing the APK

### On Your Android Device:

1. **Transfer APK** to your phone via:
   - USB cable
   - Email
   - Cloud storage (Google Drive, etc.)

2. **Enable Unknown Sources**:
   - Settings → Security → Unknown Sources (enable)
   - Or: Settings → Apps → Special Access → Install Unknown Apps

3. **Install**:
   - Open the APK file
   - Tap "Install"
   - Grant permissions when prompted

## 🏷️ Creating Releases (Optional)

To create a downloadable release:

```bash
# Create and push a tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

GitHub Actions will automatically create a release with the APK attached!

## 🔧 Troubleshooting

### Build Fails?
- Check the "Actions" tab for error logs
- Ensure all dependencies are in `pubspec.yaml`
- Verify Android permissions in `AndroidManifest.xml`

### APK Won't Install?
- Enable "Install from Unknown Sources"
- Check if you have enough storage
- Try uninstalling any previous version first

## 📊 Build Status

Once set up, you'll see a build status badge. Add this to your README:

```markdown
![Build Status](https://github.com/YOUR_USERNAME/calculator-vault/workflows/Build%20APK/badge.svg)
```

## 🔐 Security Notes

- Keep repository **private** for safety apps
- Don't commit signing keys or passwords
- The APK will be unsigned (for testing)
- For production, set up proper signing in GitHub Secrets

## 📝 Next Steps

1. Push code to GitHub
2. Wait for build to complete (~5 minutes)
3. Download APK from Actions artifacts
4. Test on Android device
5. Share with trusted contacts only

---

**Need help?** Check GitHub Actions logs or open an issue in your repository.
