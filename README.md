# Thanksgiving Countdown v1.0.1

An iOS app + WidgetKit extension in the style of Mike's Halloween tile:
a big **"N DAYS UNTIL THANKSGIVING"** count over holiday artwork, with
today's weekday + date underneath and a MikeGyver Studio credit — the
same layout as the Halloween tile on his car display.

## What changed in v1.0.1 (CarPlay + TestFlight fixes)

v1.0.0 already had the one family CarPlay can show (systemSmall), so
no new entitlement or CarPlay app was needed — but it was not actually
CarPlay-ready, and re-uploading it would have failed:

1. **Small and Medium were the same layout.** "UNTIL THANKSGIVING" at
   18pt is wider than a small tile once padding is subtracted, so it
   could wrap or clip on the small tile, and worse on the smaller
   CarPlay rendering. The widget now branches on `widgetFamily`:
   the small tile (Home Screen + CarPlay) gets one line per fact,
   with `lineLimit(1)` + `minimumScaleFactor` on every line so text
   shrinks instead of wrapping. The medium tile keeps the v1.0.0
   layout, with the same guards added.
2. **Widget photos were full-res.** Both backgrounds were 1152x2048
   (~9.4MB decoded each) in the extension, against a roughly 30MB
   extension limit. The widget now uses 768px-wide JPEG copies
   (~4MB decoded, ~195KB each on disk); the app keeps the full-res
   photos for its full-screen view.
3. **Tapping the widget did nothing useful.** The widget now sets a
   `widgetURL` (`thanksgivingcountdown://countdown`, scheme
   registered in the app's Info.plist), so a tap on the iPhone opens
   the app. In CarPlay a tap cannot launch the app unless the app is
   itself a CarPlay app — there the tile is glance-only, by Apple's
   design, not a bug in this build.
4. **CarPlay is explicitly NOT disfavored.** Listing CarPlay in
   `disfavoredLocations` would group the widget in Settings as "not
   optimized for CarPlay" and disable interaction. It is not listed.
5. **Version/build bumped.** v1.0.1, build 2. TestFlight rejects a
   re-upload of a duplicate version/build pair, so v1.0.0 build 1
   could not simply be re-sent.
6. **Push-script wording fixed.** The v1.0.0 script said "the
   TestFlight workflow should start now" after pushing a tag, but the
   workflow is `workflow_dispatch` (manual) — pushing a tag starts
   nothing. The script now says to run it by hand from the Actions tab.

What did NOT change, because it was already right: the `@main`
WidgetBundle (without it App Store Connect rejects the upload with
90896), `ITSAppUsesNonExemptEncryption = false` (so the build does
not sit at Missing Compliance), the Chicago-midnight timeline, and
the holiday math.

## How the dates work

- Thanksgiving is the **4th Thursday of November**: 2026 → **Thursday,
  November 26**. Starting **Saturday, November 1** the tile reads
  **25 DAYS UNTIL THANKSGIVING** and ticks down one day at a time.
- The widget timeline is one entry per **midnight America/Chicago**,
  so the day and date flip at midnight Central on their own — no
  opening the app, no 24-hour timer drift. Nov 1, 2026 is the fall-back
  day (clocks go back at 2 AM); the timeline uses calendar start-of-day
  in Chicago, so that 25-hour day is handled correctly.
- Before Nov 1 the tile counts to Halloween (Oct 31) over Halloween
  artwork, so the widget is sensible the week it is installed. On the
  holiday itself it reads **HAPPY THANKSGIVING** (or HAPPY HALLOWEEN).
  After Thanksgiving it rolls to next year's Halloween, so the tile
  never goes stale.
- The app itself shows the same countdown full-screen, plus the
  holiday's full date ("Thursday, November 26, 2026").

## Widget sizes

Small and Medium on the Home Screen. **CarPlay shows Small only**
(iOS 26+, on a car display that supports widgets) — Medium never
appears in the car, by Apple's design.

## 1. What is in here

- `ThanksgivingCountdown/` — the app (SwiftUI, full-screen countdown).
- `ThanksgivingWidget/` — the WidgetKit extension. Note the `@main`
  WidgetBundle in `ThanksgivingWidget.swift`: without it the appex has
  no `__swift5_entry` and App Store Connect rejects the build (90896).
- `Shared/` — the countdown math (`HolidayCountdown.swift`) and both
  background artworks, shared by app and widget. The widget reads the
  `*Widget` JPEG copies; the app reads the full-res PNGs.
- `project.yml` — XcodeGen spec (same shape as Launch Window).
  Bundle IDs: `studio.mikegyver.thanksgiving` (app) and
  `studio.mikegyver.thanksgiving.widget` (extension).

## 2. TestFlight (same signed pipeline as Launch Window / BusLink V2)

The workflow `.github/workflows/testflight.yml` is manual
(`workflow_dispatch`): it builds with XcodeGen, signs with a
distribution certificate + both provisioning profiles via fastlane,
and uploads to TestFlight with `pilot`. No code signing happens on
this machine — everything runs on the GitHub macOS runner.

## 3. First-time setup (do once)

1. Apple Developer portal → Identifiers → create two App IDs:
   `studio.mikegyver.thanksgiving` and
   `studio.mikegyver.thanksgiving.widget` (WidgetKit extension type
   for the second). No App Group is needed — the widget computes its
   own dates and shares no data with the app.
2. Before running the workflow, check the portal certificate list:
   Apple allows two Distribution certificates per team. If both slots
   are already taken, revoke only one, then re-run — keeping the other
   leaves its profiles untouched.
3. GitHub repo → Settings → Secrets and variables → Actions, add the
   same four secrets Launch Window / BusLink use: `ASC_KEY_ID`,
   `ASC_ISSUER_ID`, `ASC_KEY_P8`, `TEAM_ID`.
4. Create the empty repo `MikeGyver-SME/mikegyver-thanksgiving`,
   save `push-thanksgiving.ps1` and `thanksgiving-countdown-v1.0.1.zip`
   in `E:\Downloads`, and run the script. It pushes and tags `v1.0.1`.
   If you already pushed v1.0.0, this overlays the new files in the
   same repo folder and tags the new version — do not re-tag v1.0.0.
5. Actions tab → run the "Thanksgiving Countdown - Signed TestFlight"
   workflow **by hand** (workflow_dispatch — pushing a tag does not
   start it). When it goes green, install from TestFlight, then answer
   the export-compliance questionnaire: no encryption beyond the
   standard iOS kind, so the answer that clears Missing Compliance is
   the "none of the algorithms" option.
6. Long-press the Home Screen → + → Thanksgiving Countdown → pick
   Small or Medium. After an update, remove the widget and add it back
   before judging it — a fixed build can still show stale behavior
   until the widget is re-added.

## 4. Adding it to CarPlay (after TestFlight install)

Requirements, all three: iPhone on **iOS 26 or later**, a car display
that supports CarPlay widgets (not every CarPlay display does), and
the car parked — these settings are changed on the phone, not while
driving.

1. iPhone → **Settings → General → CarPlay → your car → Widgets**.
2. Turn on **Show Widgets** if it is off, tap **Add Widgets**, and
   pick **Thanksgiving Countdown** (Small).
3. Reconnect CarPlay (unplug/replug, or toggle wireless off and on).
   The tile appears in the dashboard widget stack, to the left of the
   dashboard.
4. If **Widgets is missing** from the CarPlay settings for your car,
   that means the phone is not on iOS 26+ or that display does not
   support CarPlay widgets — it is not a problem with this build.
   The Home Screen small widget still works on iOS 17+.
5. Expect glance-only in the car: the tile shows the count and today's
   date, but tapping it will not open the app in CarPlay (only a
   CarPlay app can be launched from there). On the iPhone, tapping
   the widget does open the app.

## 5. Versioning

`MARKETING_VERSION` 1.0.1, `CURRENT_PROJECT_VERSION` 2 in
`project.yml`. For the next release, bump `CURRENT_PROJECT_VERSION`
before re-tagging — TestFlight rejects a duplicate version/build pair.
