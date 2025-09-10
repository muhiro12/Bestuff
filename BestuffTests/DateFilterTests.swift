@testable import Bestuff
import Foundation
import Testing

struct DateFilterTests {
    @Test func today_includes_now_excludes_far_dates() {
        let now = Date()
        #expect(DateFilter.today.contains(now))
        #expect(DateFilter.today.contains(now.addingTimeInterval(60 * 60 * 24 * 2)) == false)
        #expect(DateFilter.today.contains(now.addingTimeInterval(-60 * 60 * 24 * 2)) == false)
    }

    @Test func thisWeek_includes_nearby_days_excludes_far_past() {
        let now = Date()
        #expect(DateFilter.thisWeek.contains(now))
        #expect(DateFilter.thisWeek.contains(now.addingTimeInterval(60 * 60 * 24 * 3)))
        #expect(DateFilter.thisWeek.contains(now.addingTimeInterval(-60 * 60 * 24 * 8)) == false)
    }

    @Test func thisMonth_includes_now_excludes_next_month_far() {
        let now = Date()
        #expect(DateFilter.thisMonth.contains(now))
        #expect(DateFilter.thisMonth.contains(now.addingTimeInterval(60 * 60 * 24 * 40)) == false)
    }
}
