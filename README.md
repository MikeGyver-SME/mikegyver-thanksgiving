# MG Holiday Countdown v1.0.7

An iOS app + WidgetKit extension in the style of Mike's Halloween tile:
a big **"N DAYS UNTIL <HOLIDAY>"** count over holiday artwork, with
today's weekday + date underneath and a MikeGyver Studio credit — the
same layout as the Halloween tile on his car display. The tile morphs
through the holidays on its own: Halloween, then Thanksgiving, then
Christmas, then next year's Halloween.

## What changed in v1.0.7 (Mike's own square images, smaller overlay)

v1.0.6 was better but not as polished as the original tile: the
blurred side bars made the artwork a narrow strip, and the overlay
text was still too big, covering the house. Mike supplied his own
square Thanksgiving and Christmas images, already sized so no edges
are lost, with "MikeGyver Studio" baked in at the bottom.

1. **Those images are now the Small backgrounds, direct.** No
   blurred bars, no crop: the 1206x1206 squares are downscaled to
   768x768 and used as-is. Medium (1024x512) and the app portrait
   (1152x2048) are blurred-fit versions of the same squares, so the
   full square is still visible there, with no edges lost.
2. **No duplicate credit.** Thanksgiving/Christmas now carry
   `bakedCredit: true`, so the widget and the app do NOT overlay a
   second "MikeGyver Studio". Halloween has no baked credit, so it
   keeps its 10pt overlay credit.
3. **Date lifted above the baked credit.** For baked holidays the
   small tile's bottom padding is 30 (medium 32) instead of 8/12,
   so the date sits on the path/snow above the baked credit,
   instead of colliding with it.
4. **Smaller overlay, per Mike.** Small: days 26 -> 20, until-name
   15 -> 13, date 12 -> 10pt. Medium: days 34 -> 28, until-name
   18 -> 15, date 15 -> 12, credit 12 -> 10pt (Halloween only).
   The until-name line still shrinks (minimumScaleFactor) instead
   of wrapping, so "UNTIL THANKSGIVING" fits the tile width.
   Verified with rendered small-tile mockups for Nov 1 and Nov 27
   before shipping.

Version/build bumped: v1.0.7, build 8.

## What changed in v1.0.6 (widget artwork no longer crops)

The Oct 28 CarPlay photo proved the v1.0.5 text fix, but the
pumpkins at the bottom were cut off — and the same would have
happened to Thanksgiving and Christmas. Cause: the widget was still
using the 768x1365 portrait photo, scaledToFill into a square small
tile (and a wide medium tile), so the system cropped the top and
bottom. The portrait is right for the app's full-screen view, wrong
for a tile.

Fix: the widget no longer uses the portrait photo at all. Each
holiday now has a Small 768x768 square and a Medium 1024x512 wide
background, at the tile's own aspect ratio, so scaledToFill crops
(almost) nothing. Each one is built by fitting the whole portrait
(fit-height) over a blurred, darkened copy of itself — so the moon,
house, and all the pumpkins, the turkey, corn, and candles, and the
star, tree, presents, and candy canes are all fully in frame, with
blurred side fill that matches the art instead of black bars. The
old portrait widget copies are retired. Verified with rendered
mockups for the Nov 1 Thanksgiving tile and the Nov 27 Christmas
tile before shipping.

Version/build bumped: v1.0.6, build 7.

## What changed in v1.0.5 (one-line compile fix for v1.0.4)

v1.0.4 failed in GitHub Actions with `CompileSwift normal arm64 …
ThanksgivingWidget.swift:78: error: value of type 'some View' has no
member 'containerBackgroundRemovable'` — and nothing else failed.
My mistake: `containerBackgroundRemovable` is a WidgetConfiguration
modifier (iOS 17), not a View modifier. It was on the view; it now
lives on the `StaticConfiguration` chain in
`ThanksgivingCountdownWidget`, after `supportedFamilies`, where it
belongs. The `containerBackground(for: .widget)` call on the view
itself was correct and is unchanged, as is the whole v1.0.4 clipping
fix (photo in containerBackground, 2-line small layout, ~79pt budget).
v1.0.4 never reached TestFlight, but it was already pushed and tagged,
so this is a new version/build rather than a re-tag: v1.0.5, build 6.

## What changed in v1.0.4 (CarPlay + phone small tile no longer clips)

This supersedes v1.0.3, which was built but never pushed/installed —
skip v1.0.3 and push this one instead. It includes everything in
v1.0.3 (MG Holiday Countdown name, Christmas morph, fixed push
script) plus the clipping fix below.

The Oct 28 photos proved v1.0.1's small tile was broken on both
surfaces, not just CarPlay: on CarPlay only "UNTIL HALLOWEEN"
survived, and on the phone "3 DAYS" was cut in half at the top and
"WED 10-28-2026" was cut in half at the bottom, with the credit gone
entirely. The pattern is top and bottom cropped equally, middle
surviving — the text was centred in a view taller than the tile.

1. **Photo moved out of the content layout.** In v1.0.1 the portrait
   photo lived in a ZStack with the text, so it could drive the
   view's height beyond the tile. It now lives in
   `containerBackground`, which the system sizes to the tile, and
   the text VStack is sized to the tile on its own with an explicit
   `frame(maxWidth: .infinity, maxHeight: .infinity)`.
   `containerBackgroundRemovable(false)` is set explicitly, so
   CarPlay/StandBy do not strip the photo.
2. **Small layout made shorter.** The countdown is now two lines,
   not three: "3 DAYS" (26pt) over "UNTIL HALLOWEEN" (15pt, one line,
   shrinking instead of wrapping), instead of days / UNTIL / name on
   three lines. Date is 12pt, credit 10pt, padding 8. Height budget:
   ~79pt total, well under a small tile even after CarPlay's content
   margins. The medium tile keeps its layout, but gets the same
   containerBackground move, so the photo cannot drive its height
   either.
3. **Version/build bumped.** v1.0.4, build 5. TestFlight rejects a
   re-upload of a duplicate version/build pair.

## What changed in v1.0.3 (shorter display name)

Only the user-visible name changed — no code, artwork, or behavior
differences from v1.0.2:

1. **Display name shortened to MG Holiday Countdown.** The widget
   gallery name, both Info.plist display names (app icon label and
   extension), and the README now use the short form, so it fits
   better under the icon. Bundle IDs, the GitHub repo, and the
   TestFlight workflow name are unchanged. (v1.0.2 was tagged but
   never built for TestFlight, so MG is the first name testers
   will see.)
2. **Push script retry fixed.** The old try/catch around `git push`
   never fired in Windows PowerShell (a failing native command does
   not throw there), which silently left main on v1.0.1 while the
   v1.0.2 tag pushed. The script now checks `$LASTEXITCODE`
   explicitly after every push and stops with an error instead of
   tagging when main was not updated.
3. **Version/build bumped.** v1.0.3, build 4.

## What changed in v1.0.2 (Christmas morph + new name)

1. **Christmas joins the rotation.** After Thanksgiving Day the tile
   morphs into a Christmas countdown (Dec 25) with its own artwork —
   a watercolor village-square tree scene in the same painterly style
   as the Halloween and Thanksgiving tiles — instead of rolling
   straight to next year's Halloween. After Christmas it rolls to
   next year's Halloween as before. No new code paths: Christmas is
   just a third entry in the shared holiday list, so the count, the
   date line, and the artwork all flip together at midnight
   America/Chicago, exactly like the Halloween → Thanksgiving flip.
2. **New display name: MG Holiday Countdown.** The widget
   gallery name, the app icon label (both Info.plist display names),
   and the README now say so, since the app is no longer
   Thanksgiving-only. Bundle IDs (`studio.mikegyver.thanksgiving` /
   `.widget`), the GitHub repo, and the TestFlight workflow name are
   unchanged, so this is the same app record, not a new app. The
   App Store Connect listing name can be edited there directly, with
   no rebuild, if the record already exists under the old name.
3. **Christmas artwork in both sizes.** Full-res `ChristmasBG`
   (1152x2048 PNG) for the app's full-screen view, and a 768px-wide
   JPEG `ChristmasBGWidget` for the widget, keeping the extension
   well under its ~30MB decoded budget.
4. **Version/build bumped.** v1.0.2, build 3. TestFlight rejects a
   re-upload of a duplicate version/build pair, so v1.0.1 build 2
   could not simply be re-sent.

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
- After Thanksgiving Day the tile morphs to **Christmas, December 25**
  — 28 days out on Nov 27 — with Christmas artwork, then rolls to
  next year's Halloween after Christmas, so the tile never goes stale.
- The widget timeline is one entry per **midnight America/Chicago**,
  so the day and date flip at midnight Central on their own — no
  opening the app, no 24-hour timer drift. Nov 1, 2026 is the fall-back
  day (clocks go back at 2 AM); the timeline uses calendar start-of-day
  in Chicago, so that 25-hour day is handled correctly.
- Before Nov 1 the tile counts to Halloween (Oct 31) over Halloween
  artwork, so the widget is sensible the week it is installed. On the
  holiday itself it reads **HAPPY THANKSGIVING** (or HAPPY HALLOWEEN,
  or HAPPY CHRISTMAS).
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
   save `push-thanksgiving.ps1` and `thanksgiving-countdown-v1.0.7.zip`
   in `E:\Downloads`, and run the script. It pushes and tags `v1.0.7`.
   If you already pushed v1.0.2, this overlays the new files in the
   same repo folder and tags the new version — do not re-tag v1.0.2.
5. Actions tab → run the "Thanksgiving Countdown - Signed TestFlight"
   workflow **by hand** (workflow_dispatch — pushing a tag does not
   start it). When it goes green, install from TestFlight, then answer
   the export-compliance questionnaire: no encryption beyond the
   standard iOS kind, so the answer that clears Missing Compliance is
   the "none of the algorithms" option.
6. Long-press the Home Screen → + → MG Holiday Countdown → pick
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
   pick **MG Holiday Countdown** (Small).
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

`MARKETING_VERSION` 1.0.7, `CURRENT_PROJECT_VERSION` 8 in
`project.yml`. For the next release, bump `CURRENT_PROJECT_VERSION`
before re-tagging — TestFlight rejects a duplicate version/build pair.
