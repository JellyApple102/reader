//
//  TagsView.swift
//  reader
//
//  Created by Jacob Carryer on 3/16/25.
//

import Foundation
import SwiftUI
import Flow

struct TagsView: View {
    @Binding var work_stub: WorkStub?

    var body: some View {
        if let work_stub {
            let sorted = work_stub.tags.sorted(by: {$0.value.sort_index < $1.value.sort_index})
            List {
                ForEach(sorted, id: \.self.value.hashValue) {group in
                    Section(
                        header: Text(group.key),
                        content: {
                            HFlow {
                                ForEach(group.value.tags, id: \.self) {tag in
                                    Label(tag, systemImage: "tag")
                                        .font(.caption)
                                        .labelStyle(.titleOnly)
                                        .padding(5)
                                        // .background(.red)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                .stroke(.gray, lineWidth: 1)
                                        }
                                }
                            }
                        }
                    )
                }
            }
            .listStyle(.inset)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
