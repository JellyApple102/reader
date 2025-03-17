//
//  SearchQuery.swift
//  reader
//
//  Created by Jacob Carryer on 3/18/25.
//

import Foundation

enum CompletionFilter: String, Identifiable, CaseIterable {
    var id: Self { self }
    case all = "All"
    case complete = "Complete"
    case in_progress = "In Progress"
}

enum CrossoverFilter: String, Identifiable, CaseIterable {
    var id: Self { self }
    case include = "Include"
    case exclude = "Exclude"
    case only = "Only"
}

enum Comparisons: String, Identifiable, CaseIterable {
    var id: Self { self }
    case equals = "equal"
    case less_than = "lessthan"
    case greater_than = "greaterthan"
    case range = "minus"
}

enum DatePeriod: String, Identifiable, CaseIterable {
    var id: Self { self }
    case years, weeks, months, days, hours
}

enum Ratings: String, Identifiable, CaseIterable {
    var id: Self { self }
    case all = "All"
    case not_rated = "Not Rated"
    case general = "General"
    case teen = "Teen"
    case mature = "Mature"
    case explicit = "Explicit"
}

struct Warnings {
    var chose_none = false
    var graphic_violence = false
    var major_death = false
    var none_apply = false
    var non_con = false
    var underage = false
}

enum WarningsIds: Int {
    case chose_none = 14
    case graphic_violence = 17
    case major_death = 18
    case none_apply = 16
    case non_con = 19
    case underage = 20
}

struct Categories {
    var ff = false
    var fm = false
    var gen = false
    var mm = false
    var multi = false
    var other = false
}

enum CategoriesIds: Int {
    case ff = 116
    case fm = 22
    case gen = 21
    case mm = 23
    case multi = 2246
    case other = 24
}

enum SortBy: String, Identifiable, CaseIterable {
    var id: Self { self }
    case best_match = "Best Match"
    case author = "Author"
    case title = "Title"
    case date_posted = "Date Posted"
    case date_updated = "Date Updated"
    case word_count = "Word Count"
    case hits = "Hits"
    case kudos = "Kudos"
    case comments = "Comments"
    case bookmarks = "Bookmarks"
}

enum SortDirection: String, Identifiable, CaseIterable {
    var id: Self { self }
    case descending = "Descending"
    case ascending = "Ascending"
}

struct SearchQuery {
    func build_search_url() -> String {
        var queries: [String] = []
        
        if !query.isEmpty {
            queries.append("work_search[query]=\(query)")
        }
        if !title.isEmpty {
            queries.append("work_search[title]=\(title)")
        }
        if !creators.isEmpty {
            queries.append("work_search[creators]=\(creators)")
        }
        
        if date_count > 0 {
            var str = ""
            switch date_comparison {
                case .equals:
                    str = "\(date_count) \(date_period.rawValue)"
                case .less_than:
                    str = "< \(date_count) \(date_period.rawValue)"
                case .greater_than:
                    str = "> \(date_count) \(date_period.rawValue)"
                case .range:
                    str = "\(date_count)-\(date_count_secondary) \(date_period.rawValue)"
            }
            queries.append("work_search[revised_at]=\(str)")
        }
        
        switch complete {
            case .all:
                // do nothing
                print("default completion status")
            case .complete:
                queries.append("work_search[complete]=T")
            case .in_progress:
                queries.append("work_search[complete]=F")
        }
        
        switch crossover {
            case .include:
                // do nothing
                print("default crossover")
            case .exclude:
                queries.append("work_search[crossover]=F")
            case .only:
                queries.append("work_search[crossover]=T")
        }
        
        if single_chapter {
            queries.append("work_search[single_chapter]=1")
        }
        
        if word_count > 0 {
            var str = ""
            switch word_count_comparison {
                case .equals:
                    str = "\(word_count)"
                case .less_than:
                    str = "< \(word_count)"
                case .greater_than:
                    str = "> \(word_count)"
                case .range:
                    str = "\(word_count)-\(word_count_secondary)"
            }
            queries.append("work_search[word_count]=\(str)")
        }
        
        // TODO: proper language selection
        queries.append("work_search[language_id]=\(language_id)")
        
        if fandom_tags.count > 0 {
            let tag_str = fandom_tags.joined(separator: ",")
            queries.append("work_search[fandom_names]=\(tag_str)")
        }
        
        switch rating {
            case .all:
                print("all ratings")
            case .not_rated:
                queries.append("work_search[rating_ids]=9")
            case .general:
                queries.append("work_search[rating_ids]=10")
            case .teen:
                queries.append("work_search[rating_ids]=11")
            case .mature:
                queries.append("work_search[rating_ids]=12")
            case .explicit:
                queries.append("work_search[rating_ids]=13")
        }
        
        if warnings.chose_none { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.chose_none.rawValue)") }
        if warnings.graphic_violence { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.graphic_violence.rawValue)") }
        if warnings.major_death { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.major_death.rawValue)") }
        if warnings.none_apply { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.none_apply.rawValue)") }
        if warnings.non_con { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.non_con.rawValue)") }
        if warnings.underage { queries.append("work_search[archive_warning_ids][]=\(WarningsIds.underage.rawValue)") }
        
        if categories.ff { queries.append("work_search[category_ids]=\(CategoriesIds.ff)") }
        if categories.fm { queries.append("work_search[category_ids]=\(CategoriesIds.fm)") }
        if categories.gen { queries.append("work_search[category_ids]=\(CategoriesIds.gen)") }
        if categories.mm { queries.append("work_search[category_ids]=\(CategoriesIds.mm)") }
        if categories.multi { queries.append("work_search[category_ids]=\(CategoriesIds.multi)") }
        if categories.other { queries.append("work_search[category_ids]=\(CategoriesIds.other)") }
        
        if character_tags.count > 0 {
            let tag_str = character_tags.joined(separator: ",")
            queries.append("work_search[character_names]=\(tag_str)")
        }
        if relationship_tags.count > 0 {
            let tag_str = relationship_tags.joined(separator: ",")
            queries.append("work_search[relationship_names]=\(tag_str)")
        }
        if freeform_tags.count > 0 {
            let tag_str = freeform_tags.joined(separator: ",")
            queries.append("work_search[freeform_names]=\(tag_str)")
        }

        if hits > 0 {
            var str = ""
            switch hits_comparison {
                case .equals:
                    str = "\(hits)"
                case .less_than:
                    str = "< \(hits)"
                case .greater_than:
                    str = "> \(hits)"
                case .range:
                    str = "\(hits)-\(hits_secondary)"
            }
            queries.append("work_search[hits]=\(str)")
        }
        
        if kudos > 0 {
            var str = ""
            switch kudos_comparison {
                case .equals:
                    str = "\(kudos)"
                case .less_than:
                    str = "< \(kudos)"
                case .greater_than:
                    str = "> \(kudos)"
                case .range:
                    str = "\(kudos)-\(kudos_secondary)"
            }
            queries.append("work_search[kudos_count]=\(str)")
        }
        
        if comments > 0 {
            var str = ""
            switch comments_comparison {
                case .equals:
                    str = "\(comments)"
                case .less_than:
                    str = "< \(comments)"
                case .greater_than:
                    str = "> \(comments)"
                case .range:
                    str = "\(comments)=\(comments_secondary)"
            }
            queries.append("work_search[comments_count]=\(str)")
        }
        
        if bookmarks > 0 {
            var str = ""
            switch bookmarks_comparison {
                case .equals:
                    str = "\(bookmarks)"
                case .less_than:
                    str = "< \(bookmarks)"
                case .greater_than:
                    str = "> \(bookmarks)"
                case .range:
                    str = "\(bookmarks)-\(bookmarks_secondary)"
            }
            queries.append("work_search[bookmarks_count]=\(str)")
        }
        
        switch sort_column {
            case .best_match:
                queries.append("work_search[sort_column]=_score")
            case .author:
                queries.append("work_search[sort_column]=authors_to_sort_on")
            case .title:
                queries.append("work_search[sort_column]=title_to_sort_on")
            case .date_posted:
                queries.append("work_search[sort_column]=created_at")
            case .date_updated:
                queries.append("work_search[sort_column]=revised_at")
            case .word_count:
                queries.append("work_search[sort_column]=word_count")
            case .hits:
                queries.append("work_search[sort_column]=hits")
            case .kudos:
                queries.append("work_search[sort_column]=kudos_count")
            case .comments:
                queries.append("work_search[sort_column]=comments_count")
            case .bookmarks:
                queries.append("work_search[sort_column]=bookmarks_count")
        }
        
        switch sort_direction {
            case .descending:
                queries.append("work_search[sort_direction]=desc")
            case .ascending:
                queries.append("work_search[sort_direction]=asc")
        }

        // build final search url from queries
        let url_str = "https://archiveofourown.org/works/search?\(queries.joined(separator: "&"))"
        return url_str
    }
    
    var query: String = ""
    var title: String = ""
    var creators: String = ""
    
    // revised_at
    var date_comparison: Comparisons = .less_than
    var date_period: DatePeriod = .years
    var date_count: Int = 0
    var date_count_secondary: Int = 0
    
    var complete: CompletionFilter = .all
    var crossover: CrossoverFilter = .include
    var single_chapter: Bool = false
    
    var word_count_comparison: Comparisons = .greater_than
    var word_count: Int = 0
    var word_count_secondary: Int = 0
    
    var language_id: String = "en"
    
    var fandom_search: String = ""
    var fandom_tags: [String] = []
    
    var rating: Ratings = .all
    var warnings: Warnings = Warnings()
    var categories: Categories = Categories()
    
    var character_search: String = ""
    var character_tags: [String] = []
    
    var relationship_search: String = ""
    var relationship_tags: [String] = []
    
    var freeform_search: String = ""
    var freeform_tags: [String] = []
    
    var hits_comparison: Comparisons = .greater_than
    var hits: Int = 0
    var hits_secondary: Int = 0
    
    var kudos_comparison: Comparisons = .greater_than
    var kudos: Int = 0
    var kudos_secondary: Int = 0
    
    var comments_comparison: Comparisons = .greater_than
    var comments: Int = 0
    var comments_secondary: Int = 0
    
    var bookmarks_comparison: Comparisons = .greater_than
    var bookmarks: Int = 0
    var bookmarks_secondary: Int = 0
    
    var sort_column: SortBy = .best_match
    var sort_direction: SortDirection = .descending
}
