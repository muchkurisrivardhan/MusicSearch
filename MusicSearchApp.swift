import SwiftUI

// MARK: - Model

struct Track: Identifiable, Decodable {
    let id: String        // archive.org identifier
    let title: String
    let creator: String

    private enum Key: String, CodingKey { case identifier, title, creator }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        id = try c.decode(String.self, forKey: .identifier)
        title = Track.flat(c, .title) ?? "Untitled"
        creator = Track.flat(c, .creator) ?? "Unknown artist"
    }

    // ponytail: archive.org returns these as String, [String], or omits them entirely.
    private static func flat(_ c: KeyedDecodingContainer<Key>, _ key: Key) -> String? {
        if let s = try? c.decode(String.self, forKey: key) { return s }
        if let a = try? c.decode([String].self, forKey: key) { return a.joined(separator: ", ") }
        return nil
    }
}

// MARK: - Search

enum ArchiveSearch {
    private struct Envelope: Decodable {
        struct Response: Decodable { let docs: [Track] }
        let response: Response
    }

    static func run(_ query: String) async throws -> [Track] {
        var comps = URLComponents(string: "https://archive.org/advancedsearch.php")!
        comps.queryItems = [
            .init(name: "q", value: "\(query) AND mediatype:(audio)"),
            .init(name: "fl[]", value: "identifier"),
            .init(name: "fl[]", value: "title"),
            .init(name: "fl[]", value: "creator"),
            .init(name: "rows", value: "50"),
            .init(name: "output", value: "json"),
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        return try JSONDecoder().decode(Envelope.self, from: data).response.docs
    }
}

// MARK: - UI

struct ContentView: View {
    @State private var query = ""
    @State private var tracks: [Track] = []
    @State private var state: LoadState = .idle

    enum LoadState: Equatable { case idle, loading, failed(String) }

    var body: some View {
        NavigationStack {
            List(tracks) { track in
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title).font(.body)
                    Text(track.creator).font(.caption).foregroundStyle(.secondary)
                }
            }
            .overlay { overlay }
            .navigationTitle("Music")
            .searchable(text: $query, prompt: "Search songs")
            .onSubmit(of: .search) { Task { await search() } }
        }
    }

    @ViewBuilder private var overlay: some View {
        switch state {
        case .loading:
            ProgressView()
        case .failed(let message):
            ContentUnavailableView("Search failed", systemImage: "wifi.exclamationmark", description: Text(message))
        case .idle where tracks.isEmpty:
            ContentUnavailableView("Search for music", systemImage: "magnifyingglass")
        case .idle:
            EmptyView()
        }
    }

    private func search() async {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        state = .loading
        do {
            tracks = try await ArchiveSearch.run(q)
            state = .idle
        } catch {
            tracks = []
            state = .failed(error.localizedDescription)
        }
    }
}

@main
struct MusicSearchApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}
