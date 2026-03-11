# iOS App Name Issue - Complete Guide

## 🎯 Problem Explanation

When you change the app name in Flutter and it doesn't reflect on the iOS simulator, it's because iOS caches the app information and there are multiple places where the app name is defined.

## 📱 Where App Names are Defined in iOS

### 1. **CFBundleDisplayName** (Most Important)
- **Location**: `ios/Runner/Info.plist`
- **Purpose**: This is the name that appears on the iOS home screen
- **Example**: `<string>AgriVision</string>`

### 2. **CFBundleName**
- **Location**: `ios/Runner/Info.plist`
- **Purpose**: Internal app name used by the system
- **Example**: `<string>AgriVision</string>`

### 3. **PRODUCT_NAME**
- **Location**: `ios/Runner.xcodeproj/project.pbxproj`
- **Purpose**: Xcode project product name
- **Example**: `PRODUCT_NAME = AgriVision`

### 4. **pubspec.yaml name**
- **Location**: `pubspec.yaml`
- **Purpose**: Flutter package name (affects internal references)
- **Example**: `name: agrivision`

## 🔧 Why the Name Doesn't Change

### Common Reasons:

1. **iOS Simulator Cache**: iOS simulator caches app metadata
2. **Build Cache**: Old build artifacts contain the old name
3. **Xcode Derived Data**: Xcode caches project information
4. **Multiple Definitions**: App name defined in multiple places with different values
5. **Bundle Identifier Conflicts**: Same bundle ID with different names

## ✅ Complete Solution (What Our Script Does)

### Step 1: Update Info.plist
```xml
<key>CFBundleDisplayName</key>
<string>AgriVision</string>
<key>CFBundleName</key>
<string>AgriVision</string>
```

### Step 2: Clean All Caches
```bash
flutter clean
rm -rf build/
rm -rf ios/build/
```

### Step 3: Clear Xcode Derived Data
```bash
# Remove derived data for this project
find ~/Library/Developer/Xcode/DerivedData -name "*agricultural*" -exec rm -rf {} +
```

### Step 4: Rebuild
```bash
flutter pub get
flutter run
```

## 🚀 Manual Fix (Alternative Method)

### Using Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" target in the navigator
3. Go to "General" tab
4. Change "Display Name" to "AgriVision"
5. Clean build folder: Product → Clean Build Folder (⌘⇧K)
6. Run: Product → Run (⌘R)

### Using Command Line:
```bash
# Navigate to mobile directory
cd mobile

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName AgriVision" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleName AgriVision" ios/Runner/Info.plist

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 🔍 Verification Steps

### Check Current Settings:
```bash
# Check Info.plist values
/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" ios/Runner/Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleName" ios/Runner/Info.plist
```

### Expected Output:
```
AgriVision
AgriVision
```

## 🛠 Troubleshooting

### If Name Still Doesn't Change:

1. **Delete App from Simulator**:
   - Long press the app icon
   - Tap "Delete App"
   - Confirm deletion
   - Rebuild and install

2. **Reset iOS Simulator**:
   - Device → Erase All Content and Settings
   - Rebuild and install

3. **Check Bundle Identifier**:
   - Make sure `PRODUCT_BUNDLE_IDENTIFIER` is unique
   - Change it if you've used it before with a different name

4. **Full Clean**:
   ```bash
   flutter clean
   rm -rf build/
   rm -rf ios/build/
   rm -rf ios/Pods/
   rm -rf ios/Podfile.lock
   cd ios && pod install
   cd .. && flutter run
   ```

## 📋 Prevention Tips

### For Future Projects:
1. Set the correct app name from the beginning
2. Use consistent naming across all configuration files
3. Always clean build cache when changing app metadata
4. Test on a fresh simulator after name changes

### Best Practices:
1. **Choose a final app name early** in development
2. **Use descriptive bundle identifiers** (com.yourcompany.appname)
3. **Document your app configuration** for team members
4. **Test on multiple simulators** to ensure consistency

## 🎯 Quick Commands Reference

### Check App Name:
```bash
./diagnose-ios-app.sh
```

### Fix and Launch:
```bash
./run-ios-app.sh
```

### Manual Fix:
```bash
cd mobile
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName YourAppName" ios/Runner/Info.plist
flutter clean && flutter run
```

## 📱 Current AgriVision Configuration

After running our fix script, your app should have:

- **Display Name**: AgriVision (shown on home screen)
- **Bundle Name**: AgriVision (internal system name)
- **Package Name**: agrivision (Flutter package name)
- **Bundle ID**: com.agrivision.app (unique identifier)

## ✅ Success Indicators

You'll know the fix worked when:
1. ✅ App shows "AgriVision" on iOS simulator home screen
2. ✅ App launches without name-related errors
3. ✅ Diagnostic script shows correct names
4. ✅ No build warnings about bundle identifiers

---

**Note**: The app name change will be visible immediately after installation. If you had the app installed before the fix, you may need to delete it from the simulator and reinstall for the name change to take effect.