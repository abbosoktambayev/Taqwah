import Foundation

func todayStringForAPI() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
}
