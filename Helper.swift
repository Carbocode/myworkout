import UIKit

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from url: URL) -> T {
        
        guard let fileContent = try? Data(contentsOf: url) else {
            fatalError("Failed to load file")
        }

        guard let loaded = try? JSONDecoder().decode(T.self, from: fileContent) else {
            fatalError("Failed to decode file content")
        }

        return loaded
    }
    
    func `import`<T: Decodable>(_ type: T.Type, from url: URL) -> T {
        
        if url.startAccessingSecurityScopedResource() {
            guard let fileContent = try? Data(contentsOf: url) else {
                fatalError("Failed to load file")
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            guard let loaded = try? JSONDecoder().decode(T.self, from: fileContent) else {
                fatalError("Failed to decode file content")
            }
            
            return loaded
        }
        else{
            fatalError("Failed to import file")
        }
    }
    
    func encode<T: Encodable>(_ value: T) -> String{
        guard let loaded = try? JSONEncoder().encode(value) else {
            fatalError("Failed to encode.")
        }
        
        return String(decoding: loaded, as: UTF8.self)
    }
    
    static func load(_ filename: String) -> URL {
        let readURL = Bundle.main.url(forResource: filename, withExtension: "json")! //Example json file in our bundle
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! // Initializing the url for the location where we store our data in filemanager

        let jsonURL = documentDirectory // appending the file name to the url
            .appendingPathComponent(filename)
            .appendingPathExtension("json")
        print(jsonURL)

        // The following condition copies the example file in our bundle to the correct location if it isnt present
        if !FileManager.default.fileExists(atPath: jsonURL.path) {
            try? FileManager.default.copyItem(at: readURL, to: jsonURL)
        }

        // returning the parsed data
        return jsonURL
    }
}
