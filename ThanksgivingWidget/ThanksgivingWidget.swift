import WidgetKit
import SwiftUI

struct CountdownEntry: TimelineEntry {
    let date: Date
    let holiday: HolidayCountdown.Holiday
    let daysUntil: Int

    var todayString: String { HolidayCountdown.tileDateString(for: date) }
}

/// One entry per Chicago midnight for the next 31 days, so the widget
/// flips at midnight Central (not on a 24-hour timer — Nov 1, 2026 is
/// the 25-hour fall-back day). WidgetKit asks for a fresh timeline
/// when the last entry passes.
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        entry(for: HolidayCountdown.startOfToday())
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(entry(for: HolidayCountdown.startOfToday()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let cal = HolidayCountdown.calendar
        var entries: [CountdownEntry] = []
        var day = HolidayCountdown.startOfToday()
        for _ in 0..<31 {
            entries.append(entry(for: day))
            guard let next = cal.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(for day: Date) -> CountdownEntry {
        let (holiday, daysUntil) = HolidayCountdown.currentHoliday(on: day)
        return CountdownEntry(date: day, holiday: holiday, daysUntil: daysUntil)
    }
}

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var entry: CountdownEntry

    var body: some View {
        // v1.0.4 fix for the Oct 28 CarPlay + phone photos: in v1.0.1
        // the portrait photo lived in a ZStack with the text, and on
        // both surfaces the text was centred in a view taller than
        // the tile, so the top (days) and bottom (date, credit) were
        // cropped equally — "UNTIL HALLOWEEN" survived in the middle,
        // "3 DAYS" and "WED 10-28-2026" did not. The photo must NOT
        // drive the content size. It now lives in containerBackground,
        // which the system sizes to the tile, and the text VStack is
        // sized to the tile on its own (frame maxWidth/maxHeight).
        // NOTE: containerBackgroundRemovable is NOT a View modifier —
        // putting it here was the v1.0.4 compile error ("some View has
        // no member"). It belongs on the WidgetConfiguration below.
        Group {
            if family == .systemSmall {
                smallView
            } else {
                mediumView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            ZStack {
                Image(entry.holiday.widgetBackgroundImage)
                    .resizable()
                    .scaledToFill()
                LinearGradient(
                    colors: [.black.opacity(0.45), .black.opacity(0.0), .black.opacity(0.55)],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
        // On the iPhone, tapping the widget opens the app (via the
        // thanksgivingcountdown:// scheme registered in the app's
        // Info.plist). In CarPlay a tap cannot launch the app unless
        // the app is itself a CarPlay app, which this one is not —
        // there the tile is glance-only, by Apple's design.
        .widgetURL(URL(string: "thanksgivingcountdown://countdown"))
    }

    /// Small = the Home Screen small tile AND the CarPlay tile.
    /// Height budget, v1.0.4: days 26 + until-name 15 + date 12 +
    /// credit 10 + padding 16 = ~79pt, well under a small tile even
    /// after CarPlay's content margins. v1.0.1 used three lines for
    /// the countdown (days / UNTIL / name) plus the same date and
    /// credit; this version collapses UNTIL + name to one line,
    /// shrinks every font, and drops padding 10 -> 8, so the date
    /// cannot be pushed off the bottom again. Every line is still
    /// lineLimit(1) + minimumScaleFactor, so a long name shrinks
    /// instead of wrapping.
    private var smallView: some View {
        VStack(spacing: 0) {
            if entry.daysUntil == 0 {
                Text("HAPPY")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .lineLimit(1)
                Text(entry.holiday.name)
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text("\(entry.daysUntil) DAYS")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("UNTIL \(entry.holiday.name)")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer(minLength: 0)
            Text(entry.todayString)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("MikeGyver Studio")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .opacity(0.9)
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
        .padding(8)
    }

    /// Medium: the v1.0.0 layout, unchanged except for the same
    /// one-line + scale-factor guards so the subtitle cannot wrap,
    /// and the same containerBackground move as the small tile, so
    /// the portrait photo cannot drive its height either.
    private var mediumView: some View {
        VStack(spacing: 2) {
            if entry.daysUntil == 0 {
                Text("HAPPY")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .lineLimit(1)
                Text(entry.holiday.name)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            } else {
                Text("\(entry.daysUntil) DAYS")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .lineLimit(1)
                Text("UNTIL \(entry.holiday.name)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
            Text(entry.todayString)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .lineLimit(1)
            Text("MikeGyver Studio")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .opacity(0.9)
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
        .padding(12)
    }
}

struct ThanksgivingCountdownWidget: Widget {
    let kind = "ThanksgivingCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("MG Holiday Countdown")
        .description("Days until the next holiday, with today's date. Flips at midnight Central.")
        // systemSmall is the family CarPlay shows (iOS 26+); systemMedium
        // stays Home-Screen-only by Apple's design, not by this list.
        // This widget IS suitable for the car, so CarPlay is NOT listed
        // in disfavoredLocations — listing it would group the widget
        // in Settings as "not optimized for CarPlay" and disable taps.
        .supportedFamilies([.systemSmall, .systemMedium])
        // v1.0.5: this is a WidgetConfiguration modifier, iOS 17 — it
        // must live here, not on the View. False means CarPlay/StandBy
        // do not strip the photo background.
        .containerBackgroundRemovable(false)
    }
}

/// WidgetKit entry point — the extension target has no __swift5_entry
/// without this @main bundle (standing rule from the Oct 18 WidgetKit
/// lesson: altool fails with 90896 otherwise).
@main
struct ThanksgivingWidgetBundle: WidgetBundle {
    var body: some Widget {
        ThanksgivingCountdownWidget()
    }
}
