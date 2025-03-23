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
    
    @State private var preview_sheet = false
    @State private var active_work_stub: WorkStub? = nil
    @State private var show_removed = false
    @State private var toast: Toast?
    
    func export_ids() {
        let work_ids = work_stubs.map { String($0.work_id) }
        let ids_str = work_ids.joined(separator: "\n")
        UIPasteboard.general.string = ids_str
        toast = Toast(system_icon: "square.and.arrow.up", message: "\(work_ids.count) Work Ids Copied", color: .orange)
    }
    
    func import_ids() {
        if let user_str = UIPasteboard.general.string {
            let id_strs = user_str.split(separator: /\s+/)
            let ids = id_strs.map { Int($0) }
            var inserted = 0
            for id in ids {
                if let id {
                    if work_stubs.filter({ $0.work_id == id }).count == 0 {
                        let stub = WorkStub(work_id: id)
                        context.insert(stub)
                        inserted += 1
                    }
                }
            }
            toast = Toast(system_icon: "square.and.arrow.down", message: "\(inserted) Works Imported", color: .orange)
        }
    }
    
    var body: some View {
        NavigationStack {
            List() {
                ForEach(work_stubs) {stub in
                    NavigationLink(
                        destination: {
                            WorkView(stub: stub)
                                .navigationTitle(stub.title)
                                .toolbar {
                                    if (stub.is_restricted) {
                                        ToolbarItem(placement: .topBarTrailing) {
                                            Image(systemName: "lock.fill")
                                        }
                                    }
                                }
                        },
                        label: {
                            WorkCard(work_stub: stub)
                                .labelStyle(.titleAndIcon)
                        })
                    .swipeActions(edge: .leading) {
                        Button {
                            active_work_stub = stub
                            preview_sheet = true
                        } label: {
                            Label("Preview", systemImage: "tag.fill")
                        }
                        .tint(.blue)
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
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button(action: export_ids) {
                            Label("Export Work Ids", systemImage: "square.and.arrow.up")
                        }
                        Button(action: import_ids) {
                            Label("Import Work Ids", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .preference(key: ToastPreferenceKey.self, value: toast)
            .navigationTitle("Works")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: WorkStub.self, Work.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true), ModelConfiguration(isStoredInMemoryOnly: true))
    let stub1 = WorkStub(work_id: 61921702)
    let stub2 = WorkStub(work_id: 39945543)
    let stub3 = WorkStub(work_id: 36468745)
    stub1.stub_loaded = true
    stub2.stub_loaded = true
    stub3.stub_loaded = true
    let context = container.mainContext
    context.insert(stub1)
    context.insert(stub2)
    context.insert(stub3)

    return WorksView()
        .toaster()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
