# Todo App

A small iOS to-do app built with SwiftUI and Firebase. Sign up, add tasks, tick them off, edit or swipe to delete. That's pretty much it.

## What it does

- sign up / sign in / reset password with email (Firebase Auth)
- tasks sync live with Firestore, so changes show up right away
- every user only sees their own tasks
- add a title and an optional description, tap a task to edit it

## Running it

1. open `Todo App.xcodeproj` in Xcode
2. Xcode pulls the Firebase packages on its own, takes a minute the first time
3. pick a simulator and hit run (⌘R)

To run on a real phone, pick a team in the target's **Signing & Capabilities** tab first, otherwise the build fails with a signing error.

`GoogleService-Info.plist` is already in the project and points to the `todo-fbbcd` Firebase project. Swap that file out to use a different one.

## Firestore rules

The rules live in `firestore.rules`. Only signed-in users get access, and each user can only read or write under `users/{uid}/tasks` for their own uid.

To push them:

```
npx firebase-tools login
npx firebase-tools deploy --only firestore:rules --project todo-fbbcd
```

(the CLI wants a `firebase.json` next to the rules file, so run `npx firebase-tools init firestore` once if it complains)

Or copy-paste the file into Firebase console → Firestore → Rules and hit publish, works the same.

## How the code is laid out

- `Models` - the `TodoTask` struct
- `Services` - the actual Firebase calls (auth + tasks)
- `ViewModels` - state the screens use
- `Views` - the SwiftUI screens and a few reusable bits

Needs iOS 26.5+ and a recent Xcode.
