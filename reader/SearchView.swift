//
//  SearchView.swift
//  reader
//
//  Created by Jacob Carryer on 3/16/25.
//

import Foundation
import SwiftUI
import SwiftSoup

struct SearchView: View {
    @State private var search_text: String = ""
    @State private var filter_search_sheet: Bool = false
    @State private var did_submit: Bool = false
    @State private var preview_sheet = false
    @State private var search_results: [WorkStub] = []
    @State private var active_work_stub: WorkStub? = nil
    @State private var toast: Toast?
    @State private var search_query: SearchQuery
    @State private var search_page: Int = 1
    @State private var last_search_type: String = "basic"
    @Environment(\.modelContext) private var context
    
    init() {
        self.search_query = SearchQuery()
    }
    
    func perform_search(advanced: Bool = false) {
        print("searching...")
        var url_str = ""
        
        if advanced {
            last_search_type = "advanced"
            url_str = search_query.build_search_url()
            url_str = [url_str, "page=\(search_page)"].joined(separator: "&")
        } else {
            last_search_type = "basic"
            url_str = "https://archiveofourown.org/works/search?page=\(search_page)&work_search[query]=\(search_text)"
        }
        let url = URL(string: url_str)!
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard let loaded_data = data else { return }
            guard let contents = String(data: loaded_data, encoding: .utf8) else { return }
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
            } else if status == 429 {
                print("search: too many requests")
                return
            } else {
                print("search: other status")
                return
            }
            
            do {
                let html = contents
                let doc: Document = try SwiftSoup.parse(html)
                
                let works = try doc.select("ol.work.index.group > li[role=article]")
                for work in works {
                    var id_attr = try work.attr("id")
                    id_attr.trimPrefix("work_")
                    let work_id = Int(id_attr)!
                    let stub = WorkStub(work_id: work_id)
                    search_results.append(stub)
                }
                search_page += 1
            } catch {
                print("error parsing search page")
            }
        }
        .resume()
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(search_results) {stub in
                    WorkCard(work_stub: stub)
                        .labelStyle(.titleAndIcon)
                        .swipeActions(edge: .leading) {
                            Button {
                                active_work_stub = stub
                                preview_sheet = true
                            } label: {
                                Label("Preview", systemImage: "tag.fill")
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.blue)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button() {
                                context.insert(stub)
                                try? context.save()
                                toast = Toast(system_icon: "bookmark.fill", message: "Added", color: .green)
                            } label: {
                                Label("Add", systemImage: "bookmark.fill")
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.green)
                        }
                }
                if search_page > 1 {
                    ProgressView()
                        .onAppear {
                            print("get next page")
                            if last_search_type == "advanced" {
                                perform_search(advanced: true)
                            } else if last_search_type == "basic" {
                                perform_search()
                            }
                        }
                }
            }
            .padding(.top)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { filter_search_sheet = true }) {
                        Label("Filters Search", systemImage: "slider.horizontal.3")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            .searchable(text: $search_text)
            .onSubmit(of: .search) {
                search_results = []
                search_page = 1
                perform_search()
            }
            .sheet(isPresented: $filter_search_sheet) {
                if did_submit {
                    did_submit = false
                    search_results = []
                    search_page = 1
                    perform_search(advanced: true)
                }
            } content: {
                SearchQueryView(search_query: $search_query, showing: $filter_search_sheet, did_submit: $did_submit)
            }
            .sheet(isPresented: $preview_sheet) {
                WorkPreview(work_stub: $active_work_stub)
            }
            .onChange(of: toast) {old, new in
                guard let t = new else { return }
                toast = t
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toast = nil
                }
            }
            .preference(key: ToastPreferenceKey.self, value: toast)
        }
    }
}

#Preview {
    SearchView()
        .toaster()
        .modelContainer(for: [
            WorkStub.self,
            Work.self
        ], inMemory: true)
        .preferredColorScheme(.dark)
}
