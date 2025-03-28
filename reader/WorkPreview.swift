//
//  WorkPreview.swift
//  reader
//
//  Created by Jacob Carryer on 3/21/25.
//

import Foundation
import SwiftUI
import SwiftData
import Flow

struct WorkPreview: View {
    @Binding var work_stub: WorkStub?
    @State var show_summary: Bool = true
    @State var show_tags: Bool = true
    @State var series_sheet: Bool = false
    
    var body: some View {
        if let work_stub {
            if work_stub.stub_loaded {
                let sorted = work_stub.tags.sorted(by: {$0.value.sort_index < $1.value.sort_index})
                ScrollView {
                    HStack {
                        Text("Published: \(work_stub.stats.published)")
                        if !work_stub.stats.updated.isEmpty {
                            Text("Updated: \(work_stub.stats.updated)")
                        } else if !work_stub.stats.completed.isEmpty {
                            Text("Completed: \(work_stub.stats.completed)")
                        }
                    }.padding(.top)
                    DisclosureGroup("Summary", isExpanded: $show_summary) {
                        VStack(alignment: .leading) {
                            ForEach(work_stub.summary, id: \.self) {paragraph in
                                Text(.init(paragraph))
                            }
                        }.padding()
                    }.padding([.horizontal, .top])
                    DisclosureGroup("Tags:", isExpanded: $show_tags) {
                        VStack(alignment: .leading) {
                            ForEach(sorted, id: \.self.value.hashValue) {group in
                                Text(group.key).foregroundStyle(.secondary)
                                HFlow {
                                    ForEach(group.value.tags, id: \.self) {tag in
                                        Label(tag, systemImage: "tag")
                                            .font(.caption)
                                            .labelStyle(.titleOnly)
                                            .padding(5)
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                    .stroke(.gray, lineWidth: 1)
                                            }
                                    }
                                }
                            }
                            
                            if let series = work_stub.series {
                                Text("Series:").foregroundStyle(.secondary)
                                HStack {
                                    Text(series.prefix)
                                    Button(series.name) {
                                        series_sheet = true
                                    }
                                }
                            }
                        }.padding()
                    }.padding([.horizontal, .bottom])
                }
                .sheet(isPresented: $series_sheet) {
                    SeriesView(series_id: work_stub.series!.series_id, series_title: work_stub.series!.name)
                }
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
