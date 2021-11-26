import Foundation
import UIKit

protocol NetworkManager: AnyObject {
    func fetchCompanyInfo(completed: @escaping (CompanyInfo?) -> Void)
    func fetchLaunchDetails(page: Int, completed: @escaping (Result<LaunchDocs?, LaunchError>) -> Void)
    func setAndCacheLaunchImage(urlString: String, completed: @escaping(UIImage) -> Void)
}

class ConcreteNetworkManager: NetworkManager {

    private let baseURL = "https://api.spacexdata.com/v4/"
    private let cache = NSCache<NSString, UIImage>()

    func fetchCompanyInfo(completed: @escaping (CompanyInfo?) -> Void) {
        guard let companyInfoURL = URL(string: baseURL + "company") else { return }

        let _ = URLSession.shared.dataTask(with: companyInfoURL) { data, response, error in
            if let _ = error { return }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }

            guard let data = data else { return }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let companyInfo = try decoder.decode(CompanyInfo.self, from: data)
                completed(companyInfo)
            } catch {}
        }.resume()
    }

    func fetchLaunchDetails(page: Int, completed: @escaping (Result<LaunchDocs?, LaunchError>) -> Void) {
        guard let launchesURL = URL(string: baseURL + "launches/query") else {
            completed(.failure(.invalidUrl))
            return
        }

        let requestBody: [String: Any] = [
            "options": [
                "page": page
            ]
        ]
        let encodedRequestBody = try? JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: launchesURL)
        request.httpMethod = "POST"
        request.httpBody = encodedRequestBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let _ = URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completed(.failure(.invalidResponse))
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.unableToComplete))
                return
            }

            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let launchDetails = try decoder.decode(LaunchDocs.self, from: data)
                completed(.success(launchDetails))
            } catch {
                completed(.failure(.invalidData))
            }
        }.resume()
    }

    func setAndCacheLaunchImage(urlString: String, completed: @escaping(UIImage) -> Void) {
        let cacheKey = NSString(string: urlString)

        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
        }

        guard let url = URL(string: urlString) else { return }

        let _ = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            if error != nil { return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }.resume()
    }
}
