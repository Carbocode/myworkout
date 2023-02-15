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
}
