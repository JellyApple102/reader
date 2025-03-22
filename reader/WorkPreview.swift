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
    
    var body: some View {
        if let work_stub {
            if work_stub.stub_loaded {
                let sorted = work_stub.tags.sorted(by: {$0.value.sort_index < $1.value.sort_index})
                ScrollView {
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
                        }.padding()
                    }.padding([.horizontal, .bottom])
                }
            }
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
