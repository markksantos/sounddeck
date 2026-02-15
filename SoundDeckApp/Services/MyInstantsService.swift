import Foundation
import os.log

/// API client for the MyInstants sound library.
/// Provides search, trending, popular, and recent sound browsing.
final class MyInstantsService {
    static let shared = MyInstantsService()

    private let logger = Logger(subsystem: "com.sounddeck.app", category: "MyInstantsService")
    private let baseURL = "https://myinstants-api.vercel.app"
    private let session: URLSession

    // MARK: - Sound Model

    struct Sound: Decodable, Identifiable, Hashable {
        let id: String
        let title: String
        let mp3: String
        let tags: [String]?

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Sound, rhs: Sound) -> Bool {
            lhs.id == rhs.id
        }
    }

    // MARK: - Errors

    enum ServiceError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case invalidResponse(Int)
        case decodingError(Error)
        case downloadFailed(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse(let code):
                return "Server returned status \(code)."
            case .decodingError(let error):
                return "Failed to parse response: \(error.localizedDescription)"
            case .downloadFailed(let error):
                return "Download failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Init

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Public API

    /// Search sounds by query string.
    func search(query: String) async throws -> [Sound] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw ServiceError.invalidURL
        }
        return try await fetchSounds(endpoint: "/search?q=\(encoded)")
    }

    /// Fetch trending sounds (US region).
    func trending() async throws -> [Sound] {
        return try await fetchSounds(endpoint: "/trending?q=us")
    }

    /// Fetch most popular / best sounds.
    func best() async throws -> [Sound] {
        return try await fetchSounds(endpoint: "/best")
    }

    /// Fetch recently uploaded sounds.
    func recent() async throws -> [Sound] {
        return try await fetchSounds(endpoint: "/recent")
    }

    /// Download an mp3 from a URL string to a local destination.
    func downloadSound(from urlString: String, to destination: URL) async throws {
        guard let url = URL(string: urlString) else {
            throw ServiceError.invalidURL
        }

        do {
            let (tempURL, response) = try await session.download(from: url)

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw ServiceError.invalidResponse(httpResponse.statusCode)
            }

            // Move from temp location to destination
            let fm = FileManager.default
            if fm.fileExists(atPath: destination.path) {
                try fm.removeItem(at: destination)
            }
            try fm.moveItem(at: tempURL, to: destination)

            logger.info("Downloaded sound to \(destination.lastPathComponent)")
        } catch let error as ServiceError {
            throw error
        } catch {
            throw ServiceError.downloadFailed(error)
        }
    }

    // MARK: - Private

    private func fetchSounds(endpoint: String) async throws -> [Sound] {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ServiceError.invalidURL
        }

        logger.info("Fetching: \(endpoint)")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(from: url)
        } catch {
            logger.error("Network error for \(endpoint): \(error.localizedDescription)")
            throw ServiceError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            logger.error("HTTP \(httpResponse.statusCode) for \(endpoint)")
            throw ServiceError.invalidResponse(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            let sounds = try decoder.decode([Sound].self, from: data)
            logger.info("Fetched \(sounds.count) sounds from \(endpoint)")
            return sounds
        } catch {
            logger.error("Decoding error for \(endpoint): \(error.localizedDescription)")
            throw ServiceError.decodingError(error)
        }
    }
}
