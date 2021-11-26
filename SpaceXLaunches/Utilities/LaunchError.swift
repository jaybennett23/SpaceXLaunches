import Foundation

enum LaunchError: String, Error {
    case invalidUrl = "Invalid URL, please try again later."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case invalidResponse = "Invalid response from the server. Please try again."
    case invalidData = "The data received from the server was invalid. Please try again"
}
