# 🔄 Migrating Runs from Xcode to VS Code

## Why Migrate to VS Code?

- ✅ Better terminal integration
- ✅ Git built-in with GUI
- ✅ Extensions for Swift
- ✅ Easier file management
- ✅ Cross-platform development

---

## Quick Migration (5 minutes)

### Step 1: Install VS Code Extensions

1. **Download VS Code**: https://code.visualstudio.com
2. **Install these extensions**:
   - **Swift** (by Swift Server Work Group)
   - **SwiftLint** (optional)
   - **GitLens** (for Git visualization)

### Step 2: Open Project in VS Code

```bash
# In Terminal:
cd ~/path/to/your/Runs/project
code .
```

Or:
1. Open VS Code
2. File → Open Folder
3. Select your Runs project folder

### Step 3: Project Structure

VS Code will show all your files in the sidebar:

```
Runs/
├── .git/                    # Git folder
├── Models/
│   ├── ModelsUser.swift
│   ├── ModelsCourt.swift
│   └── ...
├── Services/
├── Views/
├── Config/
├── Utilities/
├── Documentation/
│   ├── README.md
│   ├── SUPABASE_SETUP.md
│   └── ...
├── SUPABASE_SCHEMA.sql
├── push-to-github.sh
└── Runs.xcodeproj           # Xcode project (keep this!)
```

---

## Git in VS Code (Much Easier!)

### Visual Git Interface

1. **Click Source Control icon** (left sidebar) or press `Ctrl+Shift+G`
2. You'll see all your files listed
3. **Stage all files**: Click the `+` next to "Changes"
4. **Commit**: Enter message, click ✓
5. **Push**: Click "..." → Push

### First-Time Setup

1. **Initialize Git** (if not done):
   - View → Command Palette (`Cmd+Shift+P`)
   - Type: "Git: Initialize Repository"
   - Select your project folder

2. **Add Remote**:
   - Terminal → New Terminal
   - Run:
   ```bash
   git remote add origin https://github.com/AkshithVattem/runs.git
   ```

3. **Commit & Push**:
   - Source Control tab
   - Stage all (+ icon)
   - Enter message: "Complete Runs app"
   - Click ✓ to commit
   - Click "..." → Push → Push to origin/main

---

## Working with Swift in VS Code

### Building the App

**Note:** You'll still need Xcode for building/running iOS apps.

**Two options:**

#### Option A: Use Xcode for Building
- Edit code in VS Code
- Build/run in Xcode
- Best of both worlds!

#### Option B: Command Line Build
```bash
# Build from terminal
xcodebuild -project Runs.xcodeproj -scheme Runs -configuration Debug

# Clean build
xcodebuild clean -project Runs.xcodeproj -scheme Runs
```

### VS Code Terminal (Better than Xcode!)

```bash
# Built-in terminal: Ctrl + `
# Or: Terminal → New Terminal

# Now you can:
git status
git add .
git commit -m "Update features"
git push

# Run scripts
./push-to-github.sh

# Search files
grep -r "SupabaseConfig" .
```

---

## Recommended VS Code Setup

### Install Extensions

1. **Swift Language** - Syntax highlighting
   ```
   ext install sswg.swift-lang
   ```

2. **Better Comments** - Color-code your comments
   ```
   ext install aaron-bond.better-comments
   ```

3. **GitLens** - Supercharged Git
   ```
   ext install eamodio.gitlens
   ```

4. **Path Intellisense** - Autocomplete file paths
   ```
   ext install christian-kohler.path-intellisense
   ```

5. **Markdown All in One** - Preview docs
   ```
   ext install yzhang.markdown-all-in-one
   ```

### Settings (Optional)

Create `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.tabSize": 4,
  "files.exclude": {
    "**/.DS_Store": true,
    "**/DerivedData": true,
    "**/.build": true
  },
  "terminal.integrated.defaultProfile.osx": "zsh",
  "git.autofetch": true,
  "git.confirmSync": false
}
```

---

## Git Workflow in VS Code

### Visual Git Operations

1. **See Changes**:
   - Source Control tab shows all modified files
   - Click file to see diff

2. **Stage Changes**:
   - Hover over file → Click `+`
   - Or stage all: Click `+` next to "Changes"

3. **Commit**:
   - Enter commit message in text box
   - Click ✓ checkmark

4. **Push**:
   - Click "..." menu → Push
   - Or sync button (↻)

5. **View History**:
   - GitLens shows commit history
   - Right-click file → "View File History"

### No More Terminal Commands!

Instead of typing:
```bash
git add .
git commit -m "message"
git push
```

Just:
1. Click `+` on all files
2. Type message
3. Click ✓
4. Click sync ↻

---

## Migrate Your Files

### Reorganize File Structure (Optional)

In VS Code, you can easily reorganize:

**Before** (Flat):
```
ModelsUser.swift
ModelsCompanyourt.swift
ViewsMapMapView.swift
```

**After** (Organized):
```
Models/
  User.swift
  Court.swift
Views/
  Map/
    MapView.swift
```

**How to reorganize:**
1. Create folder: Right-click → New Folder
2. Drag files into folders
3. Update imports in Xcode if needed

---

## Best Workflow: Hybrid Approach

### Use Both Tools

**VS Code for:**
- ✅ Writing/editing code
- ✅ Git operations
- ✅ File management
- ✅ Documentation
- ✅ Terminal work
- ✅ Searching across files

**Xcode for:**
- ✅ Building the app
- ✅ Running on simulator/device
- ✅ Interface Builder
- ✅ Debugging
- ✅ Package management

### Workflow Example:

1. **Edit in VS Code**:
   - Open VS Code: `code .`
   - Edit Swift files
   - Commit changes visually

2. **Build in Xcode**:
   - Open Xcode project
   - Build & Run (⌘R)
   - Test features

3. **Push from VS Code**:
   - Back to VS Code
   - Source Control → Push

---

## GitHub Push from VS Code

### Super Easy Visual Method

1. **Open project in VS Code**
2. **Source Control tab** (left sidebar)
3. **Initialize repository** (if needed)
4. **Add remote**:
   - Terminal: `git remote add origin https://github.com/AkshithVattem/runs.git`
5. **Stage all files**: Click `+` next to "Changes"
6. **Commit**: Type message, press ✓
7. **Publish branch**: Click "Publish Branch" button
8. **Enter credentials** when prompted

Done! Way easier than command line.

---

## VS Code Git UI Screenshots Guide

### Visual Steps:

**Step 1:** Click Source Control icon (📋)
**Step 2:** See all changed files listed
**Step 3:** Click `+` to stage all
**Step 4:** Enter commit message in text box
**Step 5:** Click ✓ to commit
**Step 6:** Click sync (↻) or "..." → Push

---

## Troubleshooting

### "Swift support not working"

**Fix:**
- Install Swift extension
- Or just use VS Code for Git, Xcode for coding

### "Can't build in VS Code"

**Solution:**
- That's normal! Use Xcode to build iOS apps
- VS Code is great for editing + Git

### "File paths broken"

**Fix:**
If you reorganized files:
1. Open Xcode
2. Right-click file in Project Navigator
3. Show in Finder
4. Re-add to project if needed

---

## Quick Start: Git in VS Code

### If you haven't pushed yet:

1. Open VS Code in your project folder
2. Open terminal (Ctrl+`)
3. Run:
```bash
git init
git remote add origin https://github.com/AkshithVattem/runs.git
```
4. Go to Source Control tab
5. Stage all (+)
6. Commit (✓)
7. Click "Publish Branch"

**That's it!** Visual Git is so much easier.

---

## Recommended: Install GitHub Desktop

Even easier than VS Code Git:

1. **Download**: https://desktop.github.com
2. **File → Add Local Repository**
3. **Select your Runs folder**
4. **Fill in commit message**
5. **Click "Commit to main"**
6. **Click "Push origin"**

Super visual, no commands needed!

---

## Summary

### To Migrate:

✅ **Just open the project in VS Code**: `code .`
✅ **Keep using Xcode for building**
✅ **Use VS Code for Git & editing**

### Easiest Git Option:

1. **VS Code** - Built-in Git UI
2. **GitHub Desktop** - Even more visual
3. **Terminal** - If you prefer commands

### My Recommendation:

**Use all three!**
- **VS Code** - Main editor, Git operations, documentation
- **Xcode** - Building, running, debugging
- **GitHub Desktop** - Easiest Git operations

---

## Next Steps

1. ✅ Install VS Code
2. ✅ Open your project: `code .`
3. ✅ Install Swift extension
4. ✅ Use Source Control tab for Git
5. ✅ Push to GitHub visually
6. ✅ Keep using Xcode for builds

**Want me to create any VS Code config files for you?** I can make:
- `.vscode/settings.json` (workspace settings)
- `.vscode/tasks.json` (build tasks)
- `.vscode/launch.json` (debugging)

Just ask! 🚀
