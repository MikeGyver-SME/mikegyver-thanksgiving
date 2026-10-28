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
        // The photo is content (in the ZStack), not the container
        // background, so CarPlay/StandBy background handling does not
        // strip it. The black containerBackground underneath is only
        // a fallback if the photo ever fails to load.
        ZStack {
            Image(entry.holiday.widgetBackgroundImage)
                .resizable()
                .scaledToFill()
            LinearGradient(
                colors: [.black.opacity(0.45), .black.opacity(0.0), .black.opacity(0.55)],
                startPoint: .top, endPoint: .bottom
            )
            if family == .systemSmall {
                smallView
            } else {
                mediumView
            }
        }
        .containerBackground(for: .widget) {
            Color.black
        }
        // On the iPhone, tapping the widget opens the app (via the
        // thanksgivingcountdown:// scheme registered in the app's
        // Info.plist). In CarPlay a tap cannot launch the app unless
        // the app is itself a CarPlay app, which this one is not —
        // there the tile is glance-only, by Apple's design.
        .widgetURL(URL(string: "thanksgivingcountdown://countdown"))
    }

    /// Small = the Home Screen small tile AND the CarPlay tile.
    /// CarPlay is the only widget surface in the car (systemSmall
    /// only, iOS 26+), and its tile can render smaller than the Home
    /// Screen one, so this layout is deliberately spare: one line per
    /// fact, every line capped at one line with a scale factor so it
    /// shrinks instead of wrapping or clipping. v1.0.0 used the
    /// medium layout for both sizes, and "UNTIL THANKSGIVING" at
    /// 18pt is wider than a small tile once padding is subtracted.
    private var smallView: some View {
        VStack(spacing: 1) {
            if entry.daysUntil == 0 {
                Text("HAPPY")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .lineLimit(1)
                Text(entry.holiday.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text("\(entry.daysUntil) DAYS")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("UNTIL")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .lineLimit(1)
                Text(entry.holiday.name)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Spacer()
            Text(entry.todayString)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("MikeGyver Studio")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .opacity(0.9)
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
        .padding(10)
    }

    /// Medium: the v1.0.0 layout, unchanged except for the same
    /// one-line + scale-factor guards so the subtitle cannot wrap.
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
            Spacer()
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
        .configurationDisplayName("Thanksgiving Countdown")
        .description("Days until Thanksgiving, with today's date. Flips at midnight Central.")
        // systemSmall is the family CarPlay shows (iOS 26+); systemMedium
        // stays Home-Screen-only by Apple's design, not by this list.
        // This widget IS suitable for the car, so CarPlay is NOT listed
        // in disfavoredLocations — listing it would group the widget
        // in Settings as "not optimized for CarPlay" and disable taps.
        .supportedFamilies([.systemSmall, .systemMedium])
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
