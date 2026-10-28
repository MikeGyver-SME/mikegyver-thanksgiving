import Foundation

/// Shared countdown logic for the Thanksgiving Countdown app + widget.
///
/// Rules Mike asked for:
/// - The countdown runs in America/Chicago and flips at midnight Central.
///   (Nov 1, 2026 is the fall-back day: clocks go back at 2 AM, so the
///   Nov 1 entry is 25 hours long. Calendar.startOfDay in the Chicago
///   time zone handles that; nothing here assumes 24-hour days.)
/// - Thanksgiving is the 4th Thursday of November (2026: Nov 26).
/// - From Nov 1 the tile counts to Thanksgiving. Before Nov 1 it counts
///   to Halloween (Oct 31), so the widget is sensible the week it is
///   installed; on a holiday itself it reads HAPPY <HOLIDAY>.
/// - After Thanksgiving it morphs to a Christmas countdown (Dec 25),
///   with Christmas artwork; after Christmas it rolls to next year's
///   Halloween, so the tile never goes stale.
public enum HolidayCountdown {

    public static let chicago = TimeZone(identifier: "America/Chicago")!

    public static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = chicago
        return cal
    }

    public struct Holiday {
        /// Uppercase label for the tile, e.g. "THANKSGIVING".
        public let name: String
        /// Title-case label, e.g. "Thanksgiving".
        public let shortName: String
        /// Start of day in America/Chicago.
        public let date: Date
        /// Asset-catalog image name for this holiday's background.
        public let backgroundImage: String
        /// Widget copies only (v1.0.6). The full 1152x2048 photo
        /// decodes to ~9.4MB and, scaledToFill into a square small
        /// tile, crops the top/bottom — in the Oct 28 CarPlay photo
        /// the pumpkins at the bottom were cut off. So the widget
        /// does NOT use the portrait photo at all: Small gets a
        /// 768x768 square and Medium a 1024x512 wide version, each
        /// built by fitting the whole portrait (fit-height) over a
        /// blurred, darkened copy of itself, so no subject is cropped
        /// in either family. The app keeps the full-res portrait
        /// for its full-screen view.
        public let smallBackgroundImage: String
        public let mediumBackgroundImage: String
        /// True when the artwork already has "MikeGyver Studio" baked
        /// in at the bottom (v1.0.7: Mike's own Thanksgiving/Christmas
        /// square images). The widget/app must NOT overlay a second
        /// credit, and the date must sit above the baked credit.
        public let bakedCredit: Bool
    }

    public static func thanksgiving(year: Int) -> Date {
        // 4th Thursday of November: first Thursday, plus 21 days.
        let nov1 = calendar.date(from: DateComponents(year: year, month: 11, day: 1))!
        let weekday = calendar.component(.weekday, from: nov1) // 1 = Sunday ... 5 = Thursday
        let daysToFirstThursday = (5 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysToFirstThursday + 21, to: nov1)!
    }

    public static func halloween(year: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: 10, day: 31))!
    }

    public static func christmas(year: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: 12, day: 25))!
    }

    /// The holiday the countdown points at for a given day (which must
    /// already be start-of-day in Chicago), plus whole days until it.
    /// daysUntil == 0 means today IS the holiday.
    public static func currentHoliday(on day: Date) -> (holiday: Holiday, daysUntil: Int) {
        let year = calendar.component(.year, from: day)
        let candidates = [
            Holiday(name: "HALLOWEEN", shortName: "Halloween",
                    date: halloween(year: year), backgroundImage: "HalloweenBG",
                    smallBackgroundImage: "HalloweenBGSmall",
                    mediumBackgroundImage: "HalloweenBGMedium",
                    bakedCredit: false),
            Holiday(name: "THANKSGIVING", shortName: "Thanksgiving",
                    date: thanksgiving(year: year), backgroundImage: "ThanksgivingBGPortrait",
                    smallBackgroundImage: "ThanksgivingBGSmall",
                    mediumBackgroundImage: "ThanksgivingBGMedium",
                    bakedCredit: true),
            Holiday(name: "CHRISTMAS", shortName: "Christmas",
                    date: christmas(year: year), backgroundImage: "ChristmasBGPortrait",
                    smallBackgroundImage: "ChristmasBGSmall",
                    mediumBackgroundImage: "ChristmasBGMedium",
                    bakedCredit: true),
        ]
        for holiday in candidates {
            let days = calendar.dateComponents([.day], from: day, to: holiday.date).day ?? 0
            if days >= 0 { return (holiday, days) }
        }
        let next = Holiday(name: "HALLOWEEN", shortName: "Halloween",
                           date: halloween(year: year + 1), backgroundImage: "HalloweenBG",
                           smallBackgroundImage: "HalloweenBGSmall",
                           mediumBackgroundImage: "HalloweenBGMedium",
                           bakedCredit: false)
        let days = calendar.dateComponents([.day], from: day, to: next.date).day ?? 0
        return (next, days)
    }

    public static func startOfToday() -> Date {
        calendar.startOfDay(for: Date())
    }

    /// "TUE 10-27-2026" — matches the Halloween tile's date line.
    public static func tileDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = chicago
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE MM-dd-yyyy"
        return formatter.string(from: date).uppercased()
    }

    /// "Thursday, November 26, 2026".
    public static func longDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = chicago
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
}
