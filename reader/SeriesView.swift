//
//  SeriesView.swift
//  reader
//
//  Created by Jacob Carryer on 3/28/25.
//

import Foundation
import SwiftUI
import SwiftSoup

struct SeriesView: View {
    let series_id: Int
    let series_title: String
    @State private var loading = true
    @State private var stubs: [WorkStub] = []
    @State private var toast: Toast?
    @State private var active_work_stub: WorkStub?
    @State private var preview_sheet: Bool = false
    @Environment(\.modelContext) private var context

    func load_series() async {
        let url_str = "https://archiveofourown.org/series/\(self.series_id)"
        let url = URL(string: url_str)!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { loading = false; return }
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
            } else if status == 429 {
                print("series: too many requests")
                loading = false
                return
            } else {
                print("series: other status")
                loading = false
                return
            }
            
            let doc: Document = try SwiftSoup.parse(html)
            
            let works = try doc.select("ul.series.work.index.group > li[role=article]")
            for work in works {
                var id_attr = try work.attr("id")
                id_attr.trimPrefix("work_")
                let work_id = Int(id_attr)!
                let stub = WorkStub(work_id: work_id)
                stubs.append(stub)
            }
        } catch {
            loading = false
            print(error)
        }
        
        loading = false
    }
    
    var body: some View {
        if !loading {
            VStack {
                Text(self.series_title)
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .preference(key: ToastPreferenceKey.self, value: toast)

                List {
                    ForEach(stubs) {stub in
                        WorkCard(work_stub: stub, search_mode: true)
                            .labelStyle(.titleAndIcon)
                            .onTapGesture {
                                active_work_stub = stub
                                preview_sheet = true
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
                }
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
            .toaster()
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
                .task {
                    await load_series()
                }
        }
    }
}
