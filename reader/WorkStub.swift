//
//  WorkStub.swift
//  reader
//
//  Created by Jacob Carryer on 3/14/25.
//


import Foundation
import SwiftData
import SwiftSoup

struct TagGroup: Codable, Hashable {
    let sort_index: Int
    var tags: [String]
}

@Model
class WorkStub {
    @Attribute(.unique) var work_id: Int
    var title: String
    var author: String
    var rating: String
    var is_restricted: Bool
    var tags: Dictionary<String, TagGroup>
    var summary: [String]
    var notes: String
    var stats: WorkStats
    
    var stub_loaded = false
    var user_chapter: Int
    
    init(work_id: Int) {
        self.work_id = work_id
        self.title = "\(work_id)"
        self.author = ""
        self.rating = ""
        self.is_restricted = false
        self.tags = [:]
        self.summary = []
        self.notes = ""
        self.stats = WorkStats()
        self.user_chapter = 0
    }
    
    func reload() {
        // WorkCard view observes this change, then creates background task to load stub
        self.stub_loaded = false
    }
}

// needed to allow accessing stubs asyncronously from background threads
@ModelActor
actor BackgroundActor {
    func load_stub(work_id: Int) async {
        do {
            print("loading from background \(work_id)...")
            let fetch_desc = FetchDescriptor<WorkStub>(predicate: #Predicate { $0.work_id == work_id } )
            if let stub = try modelContext.fetch(fetch_desc).first {
                let url_str = "https://archiveofourown.org/works/\(work_id)?view_adult=true&view_full_work=true"
                let url = URL(string: url_str)!
                
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let contents = String(data: data, encoding: .utf8) else { return }
                
                let converter = HtmlConverter()
                let html = contents
                let doc: Document = try SwiftSoup.parse(html)
                
                // get high level work information
                let preface_group = try doc.getElementById("workskin")?.child(0)
                if let preface_group {
                    let title = try preface_group.getElementsByClass("title heading").first()?.text()
                    if let title {
                        stub.title = title
                    }
                    
                    let lock_img = try preface_group.select("img[title=Restricted]")
                    if lock_img.count > 0 {
                        stub.is_restricted = true
                    }
                    
                    let author = try preface_group.getElementsByClass("byline heading").first()?.text()
                    if let author {
                        stub.author = author
                    }
                    
                    let summary_module = try preface_group.getElementsByClass("summary module").first()
                    if let summary_module {
                        let summary = try summary_module.getElementsByClass("userstuff").first()
                        if let summary {
                            let summary_paragraphs = summary.children()
                            for p in summary_paragraphs {
                                let md = converter.get_markdown(p: p)
                                stub.summary.append(md)
                            }
                        }
                    }
                    
                    let notes = try preface_group.getElementsByClass("notes module").first()?.text()
                    if let notes {
                        stub.notes = notes
                    }
                }
                
                // get work metadata
                let metadata = try doc.select("dl.work.meta.group").first()
                if let metadata {
                    // rating
                    let rating_tag = try metadata.select("dd.rating.tags > ul.commas > li a.tag").first()
                    if let rating_tag {
                        // print(try rating_tag.outerHtml())
                        stub.rating = try rating_tag.text()
                    }
                    
                    // build tags dictionary
                    let exclude_groups = [/*"rating tags",*/ "series", "language", "collections", "stats"] // either done seperatly, weird formatting, or TODO: do this
                    let group_names = try metadata.select("> dt")
                    let tag_groups = try metadata.select("> dd")
                    // loop through keys (tag groups)
                    var i = 0
                    for group_name in group_names {
                        let cls = try group_name.attr("class")
                        let name = try group_name.text()
                        // exclude certain groups for reasons above
                        if exclude_groups.contains(cls) {
                            continue
                        }
                        i += 1
                        // create dictionary entry, append tags
                        let css_class = cls.components(separatedBy: .whitespaces).joined(separator: ".")
                        stub.tags[name] = TagGroup(sort_index: i, tags: [])
                        if let tags = try tag_groups.select(".\(css_class)").first()?.select("a.tag") {
                            // print(tags)
                            for tag in tags {
                                let tag_name = try tag.text()
                                stub.tags[name]?.tags.append(tag_name)
                            }
                        }
                    }
                   
                    // stats block
                    let stats = try metadata.select("dd.stats").first()
                    if let stats {
                        stub.stats.words = try stats.select("dd.words").first()?.text() ?? ""
                        stub.stats.chapters = try stats.select("dd.chapters").first()?.text() ?? ""
                        stub.stats.kudos = try stats.select("dd.kudos").first()?.text() ?? ""
                        stub.stats.published = try stats.select("dd.published").first?.text() ?? ""
                        
                        if let status_label = try stats.select("dt.status").first {
                            let status_type = try status_label.text()
                            let status = try stats.select("dd.status").first()?.text() ?? ""
                            if status_type == "Updated:" {
                                stub.stats.updated = status
                            } else if status_type == "Completed:" {
                                stub.stats.completed = status
                            }
                        }
                    }
                }
                
                stub.stub_loaded = true
                try modelContext.save() // background contexts are not autosave enabled
            }
        } catch {
            print(error)
        }
    }
}
