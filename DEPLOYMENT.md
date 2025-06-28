# Deploy Flutter Web App for Free

## Method 1: Vercel (Recommended - Easiest)

### Prerequisites:
- GitHub account
- Vercel account (free)

### Steps:
1. **Push your code to GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   git push -u origin main
   ```

2. **Deploy to Vercel:**
   - Go to [vercel.com](https://vercel.com)
   - Sign up/Login with GitHub
   - Click "New Project"
   - Import your GitHub repository
   - Vercel will automatically detect it's a Flutter project
   - Click "Deploy"

3. **Configure Build Settings (if needed):**
   - Build Command: `flutter build web`
   - Output Directory: `build/web`
   - Install Command: `flutter pub get`

## Method 2: Netlify (Alternative)

### Steps:
1. **Push to GitHub** (same as above)

2. **Deploy to Netlify:**
   - Go to [netlify.com](https://netlify.com)
   - Sign up/Login with GitHub
   - Click "New site from Git"
   - Choose your repository
   - Build command: `flutter build web`
   - Publish directory: `build/web`
   - Click "Deploy site"

## Method 3: GitHub Pages

### Steps:
1. **Push to GitHub** (same as above)

2. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: main
   - Folder: / (root)
   - Click "Save"

3. **Add GitHub Actions Workflow:**
   Create `.github/workflows/deploy.yml`:
   ```yaml
   name: Deploy to GitHub Pages
   on:
     push:
       branches: [ main ]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v2
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.8.1'
         - run: flutter pub get
         - run: flutter build web
         - name: Deploy
           uses: peaceiris/actions-gh-pages@v3
           with:
             github_token: ${{ secrets.GITHUB_TOKEN }}
             publish_dir: ./build/web
   ```

## Method 4: Firebase Hosting

### Steps:
1. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase:**
   ```bash
   firebase login
   ```

3. **Initialize Firebase:**
   ```bash
   firebase init hosting
   ```

4. **Configure:**
   - Public directory: `build/web`
   - Configure as single-page app: `Yes`
   - Set up automatic builds: `No`

5. **Deploy:**
   ```bash
   flutter build web
   firebase deploy
   ```

## Important Notes:

### Environment Variables:
Make sure to set your Supabase credentials as environment variables in your hosting platform:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anon key

### Update main.dart for Production:
Replace hardcoded credentials with environment variables:

```dart
await Supabase.initialize(
  url: const String.fromEnvironment('SUPABASE_URL'),
  anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
);
```

### Build Command:
Always run `flutter build web` before deploying.

## Recommended: Vercel
Vercel is the easiest option because:
- ✅ Automatic Flutter detection
- ✅ Free tier with generous limits
- ✅ Automatic deployments from GitHub
- ✅ Custom domains
- ✅ Great performance 