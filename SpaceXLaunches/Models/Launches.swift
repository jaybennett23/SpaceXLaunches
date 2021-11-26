import Foundation

struct LaunchDocs: Decodable, Hashable {
    let docs: [Launch]
}

struct Launch: Decodable, Hashable {
    //Adding this to make each launch object unique to optimize diffable datasource
    let ID = UUID()
    var links: LaunchLinks
    var name: String
    var rocket: String
    var success: Bool?
    var dateUtc: String
    var dateUnix: Double
}

struct LaunchLinks: Decodable, Hashable {
    var patch: LaunchPatch?
    var wikipedia: String?
}

struct LaunchPatch: Decodable, Hashable {
    var small: String?
}
