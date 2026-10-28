import SwiftUI

/// Full-screen version of the widget tile: the same countdown, big.
/// Refreshes on its own: a timer fires at the next Chicago midnight so
/// the day and date roll over without reopening the app.
struct ContentView: View {
    @State private var today = HolidayCountdown.startOfToday()

    private var holiday: HolidayCountdown.Holiday { HolidayCountdown.currentHoliday(on: today).holiday }
    private var daysUntil: Int { HolidayCountdown.currentHoliday(on: today).daysUntil }

    var body: some View {
        ZStack {
            Image(holiday.backgroundImage)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            LinearGradient(
                colors: [.black.opacity(0.55), .black.opacity(0.05), .black.opacity(0.55)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                Spacer()
                if daysUntil == 0 {
                    Text("HAPPY")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                    Text(holiday.name)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                } else {
                    Text("\(daysUntil) DAYS")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                    Text("UNTIL \(holiday.name)")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                }
                Spacer()
                Text(HolidayCountdown.tileDateString(for: today))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                // v1.0.7: Thanksgiving/Christmas artwork already has
                // "MikeGyver Studio" baked in — do not overlay a second
                // credit. Halloween has no baked credit, so keep it.
                if !holiday.bakedCredit {
                    Text("MikeGyver Studio")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .opacity(0.9)
                }
                Text(daysUntil == 0
                     ? HolidayCountdown.longDateString(for: today)
                     : "\(holiday.shortName) · \(HolidayCountdown.longDateString(for: holiday.date))")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .opacity(0.85)
                    .padding(.bottom, 24)
            }
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)
            .padding(.horizontal, 20)
        }
        .onAppear(perform: scheduleMidnightRefresh)
    }

    /// Recompute `today` at the next Chicago midnight, then re-arm.
    private func scheduleMidnightRefresh() {
        let cal = HolidayCountdown.calendar
        guard let nextMidnight = cal.date(byAdding: .day, value: 1, to: today) else { return }
        let delay = nextMidnight.timeIntervalSinceNow
        guard delay > 0 else { return }
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            today = HolidayCountdown.startOfToday()
            scheduleMidnightRefresh()
        }
    }
}
