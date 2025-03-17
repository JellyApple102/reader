//
//  HtmlConverter.swift
//  reader
//
//  Created by Jacob Carryer on 3/10/25.
//

import Foundation
import SwiftSoup

class HtmlConverter {
    var md = ""
    var after_modifier = false
    var modifier_size = 0
    
    init() {
        self.md = ""
    }
    
    func convert(n: Node) {
        // ignore empty nodes
        if n.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        
        if n.nodeName() == "#text" {
            // md += n.description
            if after_modifier {
                let r = n.description.range(of: "^\\s+", options: .regularExpression)
                if let r {
                    let ws = String(n.description[..<r.lowerBound])
                    let rest = String(n.description[r.upperBound...])
                    md.insert(contentsOf: ws, at: md.index(md.endIndex, offsetBy: -modifier_size))
                    md += rest
                } else {
                    md += n.description
                }
                after_modifier = false
            } else {
                md += n.description
            }
            
            return
        } else if n.nodeName() == "p" {
            md += "\n"
            // return
        } else if n.nodeName() == "em" {
            md += "*"
            after_modifier = true
            modifier_size = 1
            for node in n.getChildNodes() {
                convert(n: node)
            }
            let r = md.range(of: "\\s+$", options: .regularExpression)
            if let r {
                md.insert("*", at: r.lowerBound)
            } else {
                md += "*"
            }
            return
        } else if n.nodeName() == "strong" {
            md += "**"
            after_modifier = true
            modifier_size = 2
            for node in n.getChildNodes() {
                convert(n: node)
            }
            let r = md.range(of: "\\s+$", options: .regularExpression)
            if let r {
                md.insert(contentsOf: "**", at: r.lowerBound)
            } else {
                md += "**"
            }
            return
        } else if n.nodeName() == "br" {
            md += "\n"
            // return
        } else if n.nodeName() == "hr" {
            md += "\n\n---\n\n"
            // return
        } else if n.nodeName() == "a" || n.nodeName() == "u" {
            // Do nothing, for now??
        }
        
        for node in n.getChildNodes() {
            convert(n: node)
        }
    }
    
    func get_markdown(p: Element) -> String {
        md = ""
        convert(n: p)
        md = md.trimmingCharacters(in: .whitespacesAndNewlines)
        return md
    }
}
