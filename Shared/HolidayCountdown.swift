import Foundation

/// Shared countdown logic for the MG Holiday Countdown app + widget.
///
/// Rules Mike asked for:
/// - The countdown runs in America/Chicago and flips at midnight Central.
///   (Nov 1, 2026 is the fall-back day: clocks go back at 2 AM, so the
///   Nov 1 entry is 25 hours long. Calendar.startOfDay in the Chicago
///   time zone handles that; nothing here assumes 24-hour days.)
/// - Thanksgiving is the 4th Thursday of November (2026: Nov 26).
/// - On an event itself the tile reads HAPPY <EVENT>.
/// - v1.0.9: the tile is no longer holidays-only. It cycles through
///   the whole year in chronological order: Colin's Birthday (Feb 7),
///   Shaira's Birthday (Feb 23), Independence Day (Jul 4), Clark's
///   Birthday (Jul 12), Halloween (Oct 31), Thanksgiving (4th Thu
///   Nov), Michael's Birthday (Dec 5), Christmas (Dec 25), New Year's
///   Day (Jan 1, added Oct 29, 2026 from Mike's uploaded image),
///   then back to Colin's Birthday next year. So after Thanksgiving
///   it counts to Michael's Birthday, not straight to Christmas,
///   after Christmas it counts to New Year's Day, not to Colin's
///   Birthday, and after New Year's Day it counts to Colin's.
///   Every event's artwork is Mike's own square image with
///   "MikeGyver Studio" baked in at the bottom, so the widget/app
///   never overlay a second credit, and the date sits above the
///   baked credit (bottom padding 30 small / 32 medium).
public enum HolidayCountdown {

    public static let chicago = TimeZone(identifier: "America/Chicago")!

    public static var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = chicago
        return cal
    }

    public struct Holiday {
        /// Uppercase label for the tile, e.g. "THANKSGIVING".
        /// Birthday names are long ("MICHAEL'S BIRTHDAY", 18 chars):
        /// the small tile's until-name line is lineLimit(1) +
        /// minimumScaleFactor(0.6), so it shrinks to fit instead of
        /// wrapping or clipping.
        public let name: String
        /// Title-case label, e.g. "Thanksgiving", "Michael's Birthday".
        public let shortName: String
        /// Start of day in America/Chicago.
        public let date: Date
        /// Asset-catalog image name for the app's full-screen view.
        public let backgroundImage: String
        /// Widget copies: Small is the 768x768 square direct (no crop,
        /// no blur bars); Medium is a 1024x512 blurred-fit version of
        /// the same square, so the full square is visible there too.
        public let smallBackgroundImage: String
        public let mediumBackgroundImage: String
        /// True when the artwork already has "MikeGyver Studio" baked
        /// in at the bottom. True for every event as of v1.0.9.
        public let bakedCredit: Bool
    }

    public static func thanksgiving(year: Int) -> Date {
        // 4th Thursday of November: first Thursday, plus 21 days.
        let nov1 = calendar.date(from: DateComponents(year: year, month: 11, day: 1))!
        let weekday = calendar.component(.weekday, from: nov1) // 1 = Sunday ... 5 = Thursday
        let daysToFirstThursday = (5 - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysToFirstThursday + 21, to: nov1)!
    }

    private static func fixedDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// All events for one calendar year, in chronological order.
    /// Image mapping, verified against Mike's Oct 28, 2026 uploads:
    /// Michael = winter guitar/telescope, Clark = summer lake,
    /// Colin = winter rockets/robot, Independence = fireworks/flags,
    /// Shaira = pink roses with the woman in the centre.
    /// New Year's Day (Oct 29, 2026 upload) = snowy cottage, fireworks,
    /// family walking up the path, "MikeGyver Studio" baked in.
    private static func events(year: Int) -> [Holiday] {
        [
            Holiday(name: "NEW YEAR'S DAY", shortName: "New Year's Day",
                    date: fixedDate(year: year, month: 1, day: 1),
                    backgroundImage: "NewYearsDayBGPortrait",
                    smallBackgroundImage: "NewYearsDayBGSmall",
                    mediumBackgroundImage: "NewYearsDayBGMedium",
                    bakedCredit: true),
            Holiday(name: "COLIN'S BIRTHDAY", shortName: "Colin's Birthday",
                    date: fixedDate(year: year, month: 2, day: 7),
                    backgroundImage: "ColinBirthdayBGPortrait",
                    smallBackgroundImage: "ColinBirthdayBGSmall",
                    mediumBackgroundImage: "ColinBirthdayBGMedium",
                    bakedCredit: true),
            Holiday(name: "SHAIRA'S BIRTHDAY", shortName: "Shaira's Birthday",
                    date: fixedDate(year: year, month: 2, day: 23),
                    backgroundImage: "ShairaBirthdayBGPortrait",
                    smallBackgroundImage: "ShairaBirthdayBGSmall",
                    mediumBackgroundImage: "ShairaBirthdayBGMedium",
                    bakedCredit: true),
            Holiday(name: "INDEPENDENCE DAY", shortName: "Independence Day",
                    date: fixedDate(year: year, month: 7, day: 4),
                    backgroundImage: "IndependenceDayBGPortrait",
                    smallBackgroundImage: "IndependenceDayBGSmall",
                    mediumBackgroundImage: "IndependenceDayBGMedium",
                    bakedCredit: true),
            Holiday(name: "CLARK'S BIRTHDAY", shortName: "Clark's Birthday",
                    date: fixedDate(year: year, month: 7, day: 12),
                    backgroundImage: "ClarkBirthdayBGPortrait",
                    smallBackgroundImage: "ClarkBirthdayBGSmall",
                    mediumBackgroundImage: "ClarkBirthdayBGMedium",
                    bakedCredit: true),
            Holiday(name: "HALLOWEEN", shortName: "Halloween",
                    date: fixedDate(year: year, month: 10, day: 31),
                    backgroundImage: "HalloweenBGPortrait",
                    smallBackgroundImage: "HalloweenBGSmall",
                    mediumBackgroundImage: "HalloweenBGMedium",
                    bakedCredit: true),
            Holiday(name: "THANKSGIVING", shortName: "Thanksgiving",
                    date: thanksgiving(year: year), backgroundImage: "ThanksgivingBGPortrait",
                    smallBackgroundImage: "ThanksgivingBGSmall",
                    mediumBackgroundImage: "ThanksgivingBGMedium",
                    bakedCredit: true),
            Holiday(name: "MICHAEL'S BIRTHDAY", shortName: "Michael's Birthday",
                    date: fixedDate(year: year, month: 12, day: 5),
                    backgroundImage: "MichaelBirthdayBGPortrait",
                    smallBackgroundImage: "MichaelBirthdayBGSmall",
                    mediumBackgroundImage: "MichaelBirthdayBGMedium",
                    bakedCredit: true),
            Holiday(name: "CHRISTMAS", shortName: "Christmas",
                    date: fixedDate(year: year, month: 12, day: 25),
                    backgroundImage: "ChristmasBGPortrait",
                    smallBackgroundImage: "ChristmasBGSmall",
                    mediumBackgroundImage: "ChristmasBGMedium",
                    bakedCredit: true),
        ]
    }

    /// The event the countdown points at for a given day (which must
    /// already be start-of-day in Chicago), plus whole days until it.
    /// daysUntil == 0 means today IS the event.
    /// Searches this year and next year, sorted by date, so the
    /// rollover after Christmas lands on New Year's Day (Jan 1),
    /// and after New Year's Day on Colin's Birthday (Feb 7),
    /// not on next Halloween.
    public static func currentHoliday(on day: Date) -> (holiday: Holiday, daysUntil: Int) {
        let year = calendar.component(.year, from: day)
        let candidates = (events(year: year) + events(year: year + 1))
            .sorted { $0.date < $1.date }
        for holiday in candidates {
            let days = calendar.dateComponents([.day], from: day, to: holiday.date).day ?? 0
            if days >= 0 { return (holiday, days) }
        }
        // Unreachable: next year's Christmas is always in candidates.
        let fallback = events(year: year + 1).last!
        let days = calendar.dateComponents([.day], from: day, to: fallback.date).day ?? 0
        return (fallback, days)
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
