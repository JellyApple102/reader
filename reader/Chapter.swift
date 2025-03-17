//
//  Chapter.swift
//  reader
//
//  Created by Jacob Carryer on 3/8/25.
//

import Foundation
import SwiftData
import SwiftSoup

struct Chapter: Identifiable, Codable, Hashable {
    var id = UUID()
    
    var title: String
    var begin_notes: [String]
    var end_notes: [String]
    var paragraphs: [String]
    
    init() {
        self.title = ""
        self.begin_notes = []
        self.end_notes = []
        self.paragraphs = []
    }
}
