//
//  Work.swift
//  reader
//
//  Created by Jacob Carryer on 3/8/25.
//

import Foundation
import SwiftUI
import SwiftData
import SwiftSoup

struct WorkStats: Codable, Hashable {
    var published: String
    var completed: String
    var words: String
    var chapters: String
    var comments: String
    var kudos: String
    var bookmarks: String
    var hits: String
    
    init() {
        self.published = ""
        self.completed = ""
        self.words = ""
        self.chapters = ""
        self.comments = ""
        self.kudos = ""
        self.bookmarks = ""
        self.hits = ""
    }
}

@Model
class Work: Identifiable {
    var id = UUID()
    
    var work_id: Int
    var title: String
    var author: String
    var summary: [String]
    var notes: String // TODO: note parsing/presenting
    var chapters: [Chapter]
    var stats: WorkStats
    
    var work_loaded: Bool
    var auth_token: String
    var left_kudos: Bool
    
    init(work_stub: WorkStub) {
        self.work_id = work_stub.work_id
        self.title = work_stub.title
        self.author = work_stub.author
        self.summary = work_stub.summary
        self.notes = work_stub.notes
        self.chapters = []
        self.stats = work_stub.stats
        self.work_loaded = false
        self.auth_token = ""
        self.left_kudos = false
    }
    
    func load_async() {
        if (self.work_loaded) {
            return
        }
        
        let url_str = "https://archiveofourown.org/works/\(self.work_id)?view_adult=true&view_full_work=true"
        let url = URL(string: url_str)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let loaded_data = data else { return }
            guard let contents = String(data: loaded_data, encoding: .utf8) else { return }
            
            let converter = HtmlConverter()
            do {
                let html = contents
                let doc: Document = try SwiftSoup.parse(html)
                
                // get authenticity token
                if let token_element = try doc.select("meta[name=csrf-token]").first() {
                    let token = try token_element.attr("content")
                    self.auth_token = token
                }
                
                let chapters = try doc.select("#chapters > div.chapter")
                
                // parse differently if single chapter
                if chapters.count == 0 {
                    if let chapter = try doc.select("#chapters").first() {
                        var chap = Chapter.init()
                        
                        chap.title = "Chapter 1"
                        
                        let userstuff = try chapter.getElementsByClass("userstuff").first()
                        if let userstuff {
                            let paragraphs = userstuff.children()
                            for p in paragraphs {
                                let md = converter.get_markdown(p: p)
                                chap.paragraphs.append(md)
                            }
                        }
                        
                        self.chapters.append(chap)
                    }
                    
                    self.work_loaded = true
                    return
                }

                // build chapters
                for chapter in chapters {
                    var chap = Chapter.init()
                    
                    let chapter_preface_groups = try chapter.getElementsByClass("chapter preface group")
                   
                    let title = try chapter_preface_groups.get(0).getElementsByClass("title").first()?.text()
                    if let title {
                        chap.title = title
                    }
                    
                    let begin_notes_module = try chapter_preface_groups.get(0).getElementsByClass("notes module").first()
                    if let begin_notes_module {
                        let notes = try begin_notes_module.getElementsByClass("userstuff").first()
                        if let notes {
                            let notes_paragraphs = notes.children()
                            for p in notes_paragraphs {
                                let md = converter.get_markdown(p: p)
                                chap.begin_notes.append(md)
                            }
                        }
                    }
                    
                    if chapter_preface_groups.size() > 1 {
                        let end_notes_module = try chapter_preface_groups.get(1).getElementsByClass("end notes module").first()
                        if let end_notes_module {
                            let notes = try end_notes_module.getElementsByClass("userstuff").first()
                            if let notes {
                                let notes_paragraphs = notes.children()
                                for p in notes_paragraphs {
                                    let md = converter.get_markdown(p: p)
                                    chap.end_notes.append(md)
                                }
                            }
                        }
                    }
                    
                    let userstuff = try chapter.getElementsByClass("userstuff module").first()
                    if let userstuff {
                        try userstuff.getElementById("work")?.remove()
                        let paragraphs = userstuff.children()
                        for p in paragraphs {
                            let md = converter.get_markdown(p: p)
                            chap.paragraphs.append(md)
                        }
                    }
                    
                    self.chapters.append(chap)
                }
            } catch {
                print("url failure")
            }
            
            self.work_loaded = true
        }
        .resume()
    }
    
    func kudos(toast_binding: Binding<Toast?>) {
        if self.left_kudos {
            print("already left kudos")
            return
        }
        
        let url_str = "https://archiveofourown.org/kudos.js"
        let url = URL(string: url_str)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.setValue(self.auth_token, forHTTPHeaderField: "X-CSRF-Token")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("https://archiveofourown.org/works/\(self.work_id)", forHTTPHeaderField: "Referer")
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        let data_str = "authenticity_token=\(self.auth_token)&kudo%5Bcommentable_id%5D=\(self.work_id)&kudo%5Bcommentable_type%5D=Work"
        let data = data_str.data(using: .utf8)!
        request.httpBody = data
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
                // left kudos
                self.left_kudos = true
                toast_binding.wrappedValue = Toast(system_icon: "heart.fill", message: "you left kudos!", color: .pink)
            } else if status == 422 {
                // left kudos previously
                self.left_kudos = true
                toast_binding.wrappedValue = Toast(system_icon: "heart.fill", message: "you have already left kudos here!", color: .pink)
            } else if status == 429 {
                // too many requests
                toast_binding.wrappedValue = Toast(system_icon: "exclamationmark.triangle.fill", message: "too many requests!", color: .yellow)
            } else {
                // something else??
                print("kudos something else")
            }
        }
        .resume()
    }
}
