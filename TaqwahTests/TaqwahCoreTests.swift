import XCTest
@testable import Taqwah

/// Unit tests for the pure prayer-time and tracker core logic.
final class TaqwahCoreTests: XCTestCase {

    private let calendar = Calendar.current

    override func setUp() {
        super.setUp()
        // Make adjustment-dependent logic deterministic.
        for name in ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"] {
            UserDefaults.standard.removeObject(forKey: "adjust_\(name)")
        }
    }

    // MARK: - Helpers

    private func makeDay(
        fajr: String = "05:00", sunrise: String = "06:30",
        dhuhr: String = "13:00", asr: String = "17:00",
        maghrib: String = "20:00", isha: String = "21:30"
    ) -> PrayerDay {
        PrayerDay(date: Date(), fajr: fajr, sunrise: sunrise,
                  dhuhr: dhuhr, asr: asr, maghrib: maghrib, isha: isha)
    }

    // MARK: - String.cleanTime

    func testCleanTimeStripsTimezoneSuffix() {
        XCTAssertEqual("05:12 (+05)".cleanTime(), "05:12")
        XCTAssertEqual("13:07".cleanTime(), "13:07")
        XCTAssertEqual("  20:23  ".cleanTime(), "20:23")
    }

    // MARK: - PrayerDay.event

    func testEventResolvesHourAndMinute() {
        let day = makeDay(dhuhr: "13:07")
        let event = day.event(for: "Dhuhr")
        XCTAssertNotNil(event)
        let comps = calendar.dateComponents([.hour, .minute], from: event!.date)
        XCTAssertEqual(comps.hour, 13)
        XCTAssertEqual(comps.minute, 7)
        XCTAssertEqual(event!.name, "Dhuhr")
    }

    func testEventAppliesMinuteAdjustment() {
        UserDefaults.standard.set(5, forKey: "adjust_Fajr")
        defer { UserDefaults.standard.removeObject(forKey: "adjust_Fajr") }

        let day = makeDay(fajr: "05:00")
        let event = day.event(for: "Fajr")
        let comps = calendar.dateComponents([.hour, .minute], from: event!.date)
        XCTAssertEqual(comps.hour, 5)
        XCTAssertEqual(comps.minute, 5, "5-minute adjustment should shift Fajr to 05:05")
    }

    func testEventNegativeAdjustmentCrossesHour() {
        UserDefaults.standard.set(-10, forKey: "adjust_Dhuhr")
        defer { UserDefaults.standard.removeObject(forKey: "adjust_Dhuhr") }

        let day = makeDay(dhuhr: "13:05")
        let comps = calendar.dateComponents([.hour, .minute], from: day.event(for: "Dhuhr")!.date)
        XCTAssertEqual(comps.hour, 12)
        XCTAssertEqual(comps.minute, 55)
    }

    func testEventUnknownNameReturnsNil() {
        XCTAssertNil(makeDay().event(for: "Tahajjud"))
    }

    // MARK: - displayTime

    func testDisplayTimeReflectsAdjustment() {
        UserDefaults.standard.set(3, forKey: "adjust_Isha")
        defer { UserDefaults.standard.removeObject(forKey: "adjust_Isha") }
        XCTAssertEqual(makeDay(isha: "21:30").displayTime(for: "Isha"), "21:33")
    }

    func testDisplayTimeWithoutAdjustmentIsRaw() {
        XCTAssertEqual(makeDay(maghrib: "20:00").displayTime(for: "Maghrib"), "20:00")
    }

    // MARK: - salahEvents vs timelineEvents

    func testSalahEventsExcludeSunriseAndAreSorted() {
        let events = makeDay().salahEvents()
        XCTAssertEqual(events.count, 5)
        XCTAssertFalse(events.contains { $0.name == "Sunrise" })
        XCTAssertEqual(events.map(\.name), ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"])
        for i in 1..<events.count {
            XCTAssertLessThan(events[i - 1].date, events[i].date)
        }
    }

    func testTimelineEventsIncludeSunriseInOrder() {
        let names = makeDay().timelineEvents().map(\.name)
        XCTAssertEqual(names, ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"])
    }

    func testTimelineSunriseFallsBetweenFajrAndDhuhr() {
        let events = makeDay().timelineEvents()
        let fajr = events.first { $0.name == "Fajr" }!.date
        let sunrise = events.first { $0.name == "Sunrise" }!.date
        let dhuhr = events.first { $0.name == "Dhuhr" }!.date
        XCTAssertTrue(fajr < sunrise && sunrise < dhuhr)
    }

    // MARK: - PrayerCompletion

    func testPrayerCompletionMosqueUsesEmoji() {
        XCTAssertEqual(PrayerCompletion.mosque.emoji, "🕌")
        XCTAssertNil(PrayerCompletion.alone.emoji)
        XCTAssertNil(PrayerCompletion.congregation.emoji)
    }

    func testPrayerCompletionAllCasesHaveLabels() {
        for type in PrayerCompletion.allCases {
            XCTAssertFalse(type.label.isEmpty)
            XCTAssertFalse(type.icon.isEmpty)
        }
    }

    func testPrayerCompletionRoundTripsRawValue() {
        for type in PrayerCompletion.allCases {
            XCTAssertEqual(PrayerCompletion(rawValue: type.rawValue), type)
        }
    }

    // MARK: - CalculationMethod provider mapping

    func testMuftyatUsesMuftyatProvider() {
        if case .muftyat = CalculationMethod.muftyatKZ.provider {} else {
            XCTFail("Muftiyat KZ should use the .muftyat provider")
        }
    }

    func testAladhanMethodCodes() {
        let expected: [CalculationMethod: Int] = [
            .mwl: 3, .ummAlQura: 4, .isna: 2, .egypt: 5, .karachi: 1
        ]
        for (method, code) in expected {
            guard case .aladhan(let m) = method.provider else {
                return XCTFail("\(method) should use the .aladhan provider")
            }
            XCTAssertEqual(m, code, "\(method) should map to Aladhan method \(code)")
        }
    }

    func testCalculationMethodCacheTokensAreUnique() {
        let tokens = CalculationMethod.allCases.map(\.cacheToken)
        XCTAssertEqual(Set(tokens).count, tokens.count, "cache tokens must be unique")
    }

    func testDefaultMethodIsMuftyat() {
        XCTAssertEqual(CalculationMethod.default, .muftyatKZ)
    }

    // MARK: - Muftyat decoding

    // MARK: - TodayFlow (worship-flow engine)

    /// Today at the given hour:minute.
    private func todayAt(_ hour: Int, _ minute: Int) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date())!
    }

    private var flowDay: PrayerDay {
        makeDay(fajr: "05:00", sunrise: "06:30", dhuhr: "13:00",
                asr: "17:00", maghrib: "20:00", isha: "21:30")
    }

    func testFlowBeforeFajrAtNight() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(3, 0), weekday: 4), .beforeFajr)
    }

    func testFlowAfterFajrShowsAfterPrayer() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(5, 10), weekday: 4),
                       .afterPrayer(prayer: "Fajr"))
    }

    func testFlowMorningAthkar() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(9, 0), weekday: 4), .morningAthkar)
    }

    func testFlowDaytimeGapBetweenDhuhrAndAsr() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(14, 30), weekday: 4), .daytime)
    }

    func testFlowEveningAthkar() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(18, 30), weekday: 4), .eveningAthkar)
    }

    func testFlowBeforeSleepAfterIsha() {
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(22, 30), weekday: 4), .beforeSleep)
    }

    func testFlowJummahOnFridayBeforeDhuhr() {
        // Friday (weekday 6), 11:00 is within 3h before Dhuhr (13:00).
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(11, 0), weekday: 6), .jummah)
    }

    func testFlowAfterPrayerWinsOverMorning() {
        // 13:05 is inside Dhuhr's after-prayer window, so it beats the daytime gap.
        XCTAssertEqual(TodayFlow.kind(for: flowDay, now: todayAt(13, 5), weekday: 4),
                       .afterPrayer(prayer: "Dhuhr"))
    }

    // MARK: - Muftyat decoding

    func testMuftyatResponseDecodesToPrayerDays() throws {
        let json = """
        {"result":[{"imsak":"06:46","fajr":"06:36","sunrise":"08:13","dhuhr":"12:23",
        "asr":"14:36","sunset":"16:18","maghrib":"16:23","isha":"18:00",
        "midnight":"00:18","Date":"2026-01-01"}]}
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MuftyatResponse.self, from: json)
        let days = decoded.toPrayerDays()
        XCTAssertEqual(days.count, 1)
        XCTAssertEqual(days[0].fajr, "06:36")
        XCTAssertEqual(days[0].isha, "18:00")
        let comps = calendar.dateComponents([.year, .month, .day], from: days[0].date)
        XCTAssertEqual(comps.year, 2026)
        XCTAssertEqual(comps.month, 1)
        XCTAssertEqual(comps.day, 1)
    }
}
