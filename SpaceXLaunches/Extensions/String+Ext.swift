import Foundation

extension String {
    func formatLaunchDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let formattedDateString = dateFormatter.date(from: self) else { return "Date error" }

        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: formattedDateString)
        return formattedDate
    }
}
