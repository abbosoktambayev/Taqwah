import WidgetKit
import SwiftUI

@main
struct TaqwahWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextPrayerWidget()
        PrayerTimesWidget()
    }
}
