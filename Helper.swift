import UIKit

extension Bundle {
    
    func decode<T: Decodable>(_ type: T.Type, from url: URL) -> T {
        
        guard let temp = try? JSONDecoder().decode(T.self, from: Data("[]".utf8)) else {
            fatalError("Impossibile iniziallizare decoding")
        }
        
        do{
                
                let fileContent: Data = try Data(contentsOf: url)
                
                let loaded = try JSONDecoder().decode(T.self, from: fileContent)
                
                return loaded
        }catch{
            print(error)
        }
        
        print("Returned Empty Object")
        return temp
    }
    
    func `import`<T: Decodable>(_ type: T.Type, from url: URL) -> T {
        
        guard let temp = try? JSONDecoder().decode(T.self, from: Data("[]".utf8)) else {
            fatalError("Impossibile iniziallizare decoding")
        }
        
        do{
            if url.startAccessingSecurityScopedResource() {
                let fileContent = try Data(contentsOf: url)
                
                defer { url.stopAccessingSecurityScopedResource() }
                
                let loaded = try JSONDecoder().decode(T.self, from: fileContent)
                
                return loaded
            }
        }
        catch{
            print(error)
        }
        
        print("Imported Empty Object")
        return temp
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

        // The following condition copies the example file in our bundle to the correct location if it isnt present
        if !FileManager.default.fileExists(atPath: jsonURL.path) {
            do{
                try FileManager.default.copyItem(at: readURL, to: jsonURL)
            }catch{
                print(error)
            }
        }

        // returning the parsed data
        return readURL //TODO: Swiftchare con jsonURL per distribuzione
    }
}
