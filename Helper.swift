import UIKit

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from file: TextFile) -> T {
        /*guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }*/

        let data = Data(file.text.utf8)

        guard let loaded = try? JSONDecoder().decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        return loaded
    }
    
    func encode<T: Encodable>(_ value: T) -> String{
        guard let loaded = try? JSONEncoder().encode(value) else {
            fatalError("Failed to encode.")
        }
        
        return String(decoding: loaded, as: UTF8.self)
        
        /*guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        
        do {
            try loaded.write(to: url)
        } catch {
            fatalError("Failed to load \(file) from bundle.")
        }*/
    }
    
    static func load(_ filename: String) -> String {
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
        return try! String(decoding:Data(contentsOf: jsonURL), as: UTF8.self)
    }
}
