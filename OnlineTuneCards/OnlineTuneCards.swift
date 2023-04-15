//
//  main.swift
//  OnlineTuneCards
//
//  Created by Adin Ackerman on 4/14/23.
//

import Foundation

typealias TuneCard = [String: Any?]

@main
class OnlineTuneCards {
    static func main() async throws {
        let url = URL(string: "http://us-central1-mimetic-union-377520.cloudfunctions.net/float_package_tunes_via_http")!
        let csv = try await fetchCSV(from: url)
        
        let tunes = tunesFromCSV(csv)
        
        print(tunes)
    }
    
    static func fetchCSV(from url: URL) async throws -> String {
        let contents = try String(contentsOf: url)
        return contents
    }
    
    static func tunesFromCSV(_ string: String) -> [TuneCard] {
        var result: [TuneCard] = [TuneCard]()
        
        let csv = CSV(from: string)
        
        let fields = csv.columns().next()!
        
        for col in csv.columns().dropFirst() {
            result.append(TuneCard())
            
            for (field, value) in zip(fields, col) {
                result[result.count - 1][field] = parseValue(field: field, value: value)
            }
        }
        
        return result
    }
    
    private static func parseValue(field: String, value: String) -> Any? {
        if field.contains("double") {
            return Float(value)
        } else if field.contains("int") {
            return Int(value)
        } else if field.contains("bool") {
            return Bool(value)
        }
        
        return ["", "\r"].contains(value) ? nil : value
    }
}
