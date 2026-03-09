# Daysie - Countdown App

A beautiful iOS countdown app built with SwiftUI, SwiftData, WidgetKit, and Google AdMob.

## Features

- Add countdown events with custom emoji, color, tags, and notes
- Working-days-only countdown mode
- Live second-by-second detail view
- Home Screen widget (small and medium sizes)
- Local push notifications (1 day before / 1 week before)
- Tag filtering and search
- Google AdMob banner and interstitial ads
- Pre-populated sample events on first launch

## Project Setup

### Requirements

- Xcode 16+
- iOS 16+ deployment target
- [xcodegen](https://github.com/yonaskolb/XcodeGen) installed (`brew install xcodegen`)

### Generate the Xcode Project

```bash
cd /path/to/Daysie
xcodegen generate
open Daysie.xcodeproj
```

### Google Mobile Ads SDK

The project uses the Google Mobile Ads SDK via Swift Package Manager. xcodegen adds the package reference automatically from:

```
https://github.com/googleads/swift-package-manager-google-mobile-ads
```

Version: 11.0.0+

When you open the project in Xcode, it will resolve the package automatically on first launch.

### Info.plist Requirements

The `Daysie/Info.plist` contains:

| Key | Purpose |
|-----|---------|
| `GADApplicationIdentifier` | Your AdMob App ID |
| `SKAdNetworkItems` | Required for AdMob attribution |
| `NSUserNotificationUsageDescription` | Permission prompt for notifications |
| `UIBackgroundModes` | Background fetch for widget updates |

## Replacing Test Ad Unit IDs with Real Ones

The project ships with Google's test ad unit IDs. Replace them before submitting to the App Store:

### 1. App ID (Info.plist)

```
Daysie/Info.plist → GADApplicationIdentifier
```

Replace `ca-app-pub-3940256099942544~1458002511` with your real AdMob App ID.

### 2. Banner Ad (BannerAdView.swift)

```swift
// Daysie/Views/BannerAdView.swift
let adUnitID: String = "ca-app-pub-3940256099942544/2934735716"
```

Replace with your real banner ad unit ID. This same string appears in both `BannerAdView` and `AdaptiveBannerAdView`.

### 3. Interstitial Ad (InterstitialAdHelper.swift)

```swift
// Daysie/Helpers/InterstitialAdHelper.swift
private let adUnitID = "ca-app-pub-3940256099942544/4411468910"
```

Replace with your real interstitial ad unit ID.

## Widget Setup

The `DaysieWidget` target shares the `CountdownEvent` model and `DateHelper` from the main app target. The widget reads from the same SwiftData store as the main app and refreshes daily at midnight.

To test the widget:
1. Run the main app once to populate sample data
2. Add the widget to your Home Screen from the widget gallery

## Notification Setup

Notifications are requested lazily — only when the user enables a reminder toggle in the Add/Edit Event sheet. No upfront permission prompt.

## Architecture

```
Daysie/
├── DaysieApp.swift          App entry point, AdMob init, sample data seeding
├── Models/
│   └── CountdownEvent.swift SwiftData model with RepeatOption + ReminderOption enums
├── Views/
│   ├── EventListView.swift  Main list with tag filter, search, sort toggle
│   ├── EventCardView.swift  Gradient card with days badge
│   ├── AddEditEventView.swift Form sheet for creating/editing events
│   ├── EventDetailView.swift Live countdown detail with share button
│   └── BannerAdView.swift   UIViewRepresentable wrappers for AdMob banners
├── ViewModels/
│   └── EventsViewModel.swift Filter, sort, and search logic
├── Helpers/
│   ├── DateHelper.swift     Days remaining, working days, time components
│   ├── NotificationHelper.swift Schedule/cancel UNUserNotification requests
│   └── InterstitialAdHelper.swift Load and show interstitial every 3 saves
└── Widget/
    └── CountdownWidget.swift WidgetKit provider + small/medium widget views
```
