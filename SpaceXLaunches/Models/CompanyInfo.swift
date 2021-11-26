import Foundation

struct CompanyInfo: Decodable {
    let name: String
    let founder: String
    let founded: Int
    let employees: Int
    let launchSites: Int
    var valuation: Int
}
