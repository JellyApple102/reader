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
    @State private var show_unread = true
    @State private var show_inprogress = true
    @State private var show_read = false
    
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
                Section(
                    isExpanded: $show_inprogress,
                    content: {
                        ForEach(work_stubs.filter({ $0.user_inprogress })) {stub in
                            WorkRow(
                                stub: stub,
                                active_work_stub: $active_work_stub,
                                preview_sheet: $preview_sheet,
                                toast: $toast
                            )
                        }
                    },
                    header: { Text("In Progress") }
                )
                Section(
                    isExpanded: $show_unread,
                    content: {
                        ForEach(work_stubs.filter({ $0.user_unread })) {stub in
                            WorkRow(
                                stub: stub,
                                active_work_stub: $active_work_stub,
                                preview_sheet: $preview_sheet,
                                toast: $toast
                            )
                        }
                    },
                    header: { Text("Unread") }
                )
                Section(
                    isExpanded: $show_read,
                    content: {
                        ForEach(work_stubs.filter({ $0.user_read })) {stub in
                            WorkRow(
                                stub: stub,
                                active_work_stub: $active_work_stub,
                                preview_sheet: $preview_sheet,
                                toast: $toast
                            )
                        }
                    },
                    header: { Text("Read") }
                )
            }
            .listStyle(.sidebar)
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
    stub1.user_inprogress = true
    stub1.user_unread = false
    
    stub2.stub_loaded = true
    
    stub3.stub_loaded = true
    stub3.user_read = true
    stub3.user_unread = false
    let context = container.mainContext
    context.insert(stub1)
    context.insert(stub2)
    context.insert(stub3)

    return WorksView()
        .toaster()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
