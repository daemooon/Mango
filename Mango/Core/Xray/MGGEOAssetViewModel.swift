import Foundation

class MGGEOAssetViewModel: ObservableObject {
    
    struct Item: Identifiable {
        
        var id: String { self.url.lastPathComponent }
        
        let url: URL
        let date: Date
        
        init(url: URL, date: Date) {
            self.url = url
            self.date = date
        }
    }
    
    @Published var items: [Item] = []
    
    init() {}
    
    func reload() {
        self.items = self.fetchItemURLs()
    }
    
    private func fetchItemURLs() -> [Item] {
        do {
            let children = try FileManager.default.contentsOfDirectory(at: MGKernel.xray.assetDirectory, includingPropertiesForKeys: nil)
            return children.compactMap { url in
                guard url.pathExtension == "dat" else {
                    return nil
                }
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path(percentEncoded: false))
                    let creationDate = attributes[.creationDate] as? Date
                    let modificationDate = attributes[.modificationDate] as? Date
                    guard let date = (modificationDate ?? creationDate) else {
                        return nil
                    }
                    return Item(url: url, date: date)
                } catch {
                    return nil
                }
            }
        } catch {
            return []
        }
    }
    
    func importLocalFiles(urls: [URL]) throws {
        try urls.forEach { url in
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            let destinationURL = MGKernel.xray.assetDirectory.appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: destinationURL.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
        }
        reload()
    }
    
    func delete(item: Item) throws {
        do {
            try FileManager.default.removeItem(at: item.url)
        } catch {
            debugPrint(error.localizedDescription)
        }
        self.reload()
    }
}
