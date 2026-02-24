# StratumRecord - Your Game Strategy Companion

A beautifully designed iOS app for recording and managing game strategies.

## Features

### 📝 Record Strategies
- Create and save your own game strategies
- Select from predefined games or add custom games
- Categorize strategies by importance (High, Medium, Low)
- View all your saved strategies in a color-coded list
- Edit or delete existing strategies

### 🎮 Strategy Plaza
- Browse community-shared strategies
- Like and comment on strategies
- Publish your own strategies to the community
- Report inappropriate content
- Block users
- Share strategies with friends

### 💬 Strategy Details
- View full strategy details
- Read and post comments
- Comments are moderated (temporarily hidden for review)
- Report comments or strategies
- Block strategy authors

### ⚙️ Settings
- Clear cache
- View privacy policy
- Check version information
- Submit feedback
- Share the app with friends
- Rate the app

## Technical Details

### Architecture
- **UI Framework**: UIKit (programmatic UI, no storyboards)
- **Layout**: Masonry for Auto Layout
- **Networking**: AFNetworking (ready for future API integration)
- **Data Persistence**: NSUserDefaults with NSCoding
- **Design Pattern**: MVC (Model-View-Controller)

### Key Components

#### Models
- `SRStrategy` - Strategy data model with support for both personal and plaza strategies
- `SRComment` - Comment data model with review status
- `SRDataManager` - Singleton for data persistence and mock data

#### View Controllers
- `SRTabBarController` - Main tab bar with 3 tabs
- `SRRecordViewController` - Personal strategies list
- `SRPlazaViewController` - Community strategies feed
- `SRSettingsViewController` - App settings
- `SREditStrategyViewController` - Create/edit strategy
- `SRStrategyDetailViewController` - View strategy with comments

#### Custom Views
- `SRStrategyCell` - Personal strategy list cell
- `SRPlazaCell` - Community strategy card with user info and actions

### Color Scheme
- **Primary**: Teal (#26B5A8)
- **High Importance**: Red (#EF5350)
- **Medium Importance**: Orange (#FFA726)
- **Low Importance**: Blue (#42A5F5)

### Dependencies
- Masonry ~> 1.1.0 (Auto Layout)
- AFNetworking ~> 4.0 (HTTP networking)

## Building the App

1. Open `StratumRecord.xcworkspace` (NOT .xcodeproj)
2. Select a simulator or device
3. Press Cmd+R to build and run

## Project Structure

```
StratumRecord/
├── Models/
│   ├── SRStrategy (Strategy data model)
│   ├── SRComment (Comment data model)
│   ├── SRConstants (App constants and colors)
│   └── SRDataManager (Data persistence)
├── View Controllers/
│   ├── SRTabBarController (Main tab bar)
│   ├── SRRecordViewController (Personal strategies)
│   ├── SRPlazaViewController (Community plaza)
│   ├── SRSettingsViewController (Settings)
│   ├── SREditStrategyViewController (Create/edit)
│   └── SRStrategyDetailViewController (Strategy details)
├── Views/
│   ├── SRStrategyCell (Personal strategy cell)
│   └── SRPlazaCell (Community strategy cell)
└── App Delegate/
    ├── AppDelegate
    └── SceneDelegate
```

## Mock Data

The app includes mock plaza strategies for the following games:
- Apex Legends
- Counter-Strike 2
- Overwatch 2
- Fortnite
- Rocket League
- League of Legends

## Version

v1.0.0 - Initial Release

## Requirements

- iOS 12.0+
- Xcode 12.0+
- CocoaPods

## Notes

- No login system required
- All data is stored locally
- No network calls in current version (ready for future backend integration)
- Comments on published strategies are automatically marked for review
