//
//  WorkRow.swift
//  reader
//
//  Created by Jacob Carryer on 3/24/25.
//

import Foundation
import SwiftUI

struct WorkRow: View {
    @Environment(\.modelContext) private var context
    @State var stub: WorkStub
    @Binding var active_work_stub: WorkStub?
    @Binding var preview_sheet: Bool
    @Binding var toast: Toast?
    
    @ViewBuilder
    func user_status_actions() -> some View {
        switch stub.user_progress {
            case .unread:
                Button {
                    stub.user_progress = .in_progress
                } label: {
                    Label("Mark In Progress", systemImage: "book.fill")
                }
                .tint(.indigo)
                Button {
                    stub.user_progress = .read
                } label: {
                    Label("Mark Read", systemImage: "checkmark")
                }
                .tint(.purple)
            case .in_progress:
                Button {
                    stub.user_progress = .unread
                } label: {
                    Label("Mark Unread", systemImage: "xmark")
                }
                .tint(.indigo)
                Button {
                    stub.user_progress = .read
                } label: {
                    Label("Mark Read", systemImage: "checkmark")
                }
                .tint(.purple)
            case .read:
                Button {
                    stub.user_progress = .unread
                } label: {
                    Label("Mark Unread", systemImage: "xmark")
                }
                .tint(.indigo)
                Button {
                    stub.user_progress = .in_progress
                } label: {
                    Label("Mark In Progress", systemImage: "book.fill")
                }
                .tint(.purple)
        }
    }
    
    var body: some View {
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
                    .onAppear {
                        if stub.user_progress == .unread {
                            stub.user_progress = .in_progress
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
            
            user_status_actions()
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
