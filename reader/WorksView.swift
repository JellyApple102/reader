//
//  WorksView.swift
//  reader
//
//  Created by Jacob Carryer on 3/11/25.
//

import Foundation
import SwiftUI
import SwiftData

struct WorksView: View {
    @Query(sort: \WorkStub.title) private var work_stubs: [WorkStub]
    @Environment(\.modelContext) private var context
    
    @State private var tags_sheet = false
    @State private var summary_sheet = false
    @State private var active_work_stub: WorkStub? = nil
    @State private var show_removed = false
    @State private var toast: Toast?
    
    var body: some View {
        NavigationStack {
            List() {
                ForEach(work_stubs) {stub in
                    NavigationLink(
                        destination: {
                            WorkView(stub: stub)
                                .navigationTitle(stub.title)
                        },
                        label: {
                            WorkCard(work_stub: stub)
                                .labelStyle(.titleAndIcon)
                        })
                    .swipeActions(edge: .leading) {
                        Button {
                            active_work_stub = stub
                            tags_sheet = true
                        } label: {
                            Label("Tags", systemImage: "tag.fill")
                        }
                        .tint(.blue)
                        Button {
                            active_work_stub = stub
                            summary_sheet = true
                        } label: {
                            Label("Summary", systemImage: "list.dash")
                        }
                        .tint(.indigo)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            context.delete(stub)
                            toast = Toast(system_icon: "bookmark.slash.fill", message: "Removed", color: .red)
                        } label: {
                            Label("Remove", systemImage: "bookmark.slash.fill")
                        }
                        Button {
                            stub.reload()
                        } label: {
                            Label("Refresh", systemImage: "arrow.trianglehead.2.clockwise")
                        }
                        .tint(.cyan)
                    }
                    .labelStyle(.iconOnly)
                }
            }
            .preference(key: ToastPreferenceKey.self, value: toast)
            .navigationTitle("Works")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $tags_sheet) {
                TagsView(work_stub: $active_work_stub)
            }
            .sheet(isPresented: $summary_sheet) {
                SummaryView(work_stub: $active_work_stub)
            }
            .onChange(of: toast) {old, new in
                guard let t = new else { return }
                toast = t
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    toast = nil
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: WorkStub.self, Work.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true), ModelConfiguration(isStoredInMemoryOnly: true))
    let stub1 = WorkStub(work_id: 61921702)
    let stub2 = WorkStub(work_id: 39945543)
    let stub3 = WorkStub(work_id: 36468745)
    let context = container.mainContext
    context.insert(stub1)
    context.insert(stub2)
    context.insert(stub3)

    return WorksView()
        .toaster()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
