//
//  CSV.swift
//  OnlineTuneCards
//
//  Created by Adin Ackerman on 4/14/23.
//

import Foundation

class Visitor: IteratorProtocol, Sequence {
    typealias Element = [String]
    
    let visitor: () -> Element?
    
    init(_ visitor: @escaping () -> Element?) {
        self.visitor = visitor
    }
    
    func next() -> Element? {
        visitor()
    }
}

class CSV {
    static let newline: String = "\r\n"
    static let comma: String = ","
    
    private let string: String
    private let lines: [String]
    private let width: Int
    private let height: Int
    
    private var rowIndex: Int = 0
    private var colIndex: Int = 0
    
    init(from string: String) {
        self.string = string
        self.lines = string.components(separatedBy: CSV.newline)
        
        self.height = lines.count
        self.width = lines.first!.components(separatedBy: CSV.comma).count
    }
    
    func rows() -> Visitor {
        self.rowIndex = 0
        
        return Visitor {
            guard self.rowIndex < self.height else { return nil }
            defer { self.rowIndex += 1 }
            
            return self.lines[self.rowIndex].components(separatedBy: CSV.comma)
        }
    }
    
    func columns() -> Visitor {
        self.colIndex = 0
        
        return Visitor {
            guard self.colIndex < self.width else { return nil }
            defer { self.colIndex += 1 }
            
            var column: [String] = []
            
            for line in self.lines {
                column.append(line.components(separatedBy: CSV.comma)[self.colIndex])
            }
            
            return column
        }
    }
}
