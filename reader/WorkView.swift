//
//  WorkView.swift
//  reader
//
//  Created by Jacob Carryer on 3/11/25.
//

import Foundation
import SwiftUI
import SwiftData

struct NextButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct WorkView: View {
    @State var work: Work?
    @Query private var all_works: [Work]
    @Environment(\.modelContext) private var context
    var work_stub: WorkStub

    let sidebar_width: CGFloat = 250
    var chapter_view_id = UUID()
    
    // internal state
    @State private var offset: CGFloat = 0
    @State private var percent: CGFloat = 0
    @State private var last_offset: CGFloat = 0
    @State private var current_chapter: Int
    @State private var toast: Toast?
    
    // Pass bindings to these to ChapterView
    @State var begin_notes_open = false
    @State var end_notes_open = false
    
    func change_chapter(new_chapter: Int) {
        current_chapter = new_chapter
        work_stub.user_chapter = new_chapter
    }
    
    init(stub: WorkStub) {
        self.work_stub = stub
        self.current_chapter = stub.user_chapter
    }
    
    var body: some View {
        if let work {
            if !work.work_loaded {
                ProgressView()
                    .task {
                        // TODO: load in background properly (like stubs)??
                        work.load_async()
                    }
            } else {
                GeometryReader { geo in
                    let size = geo.size
                    ZStack(alignment: .leading) {
                        // Wrap ChapterView in scrolling elements to have access to proxy
                        ScrollViewReader {scroll_proxy in
                            ScrollView {
                                VStack {
                                    ChapterView(
                                        chapter: work.chapters[current_chapter],
                                        begin_notes_open: $begin_notes_open,
                                        end_notes_open: $end_notes_open
                                    )
                                    .id(chapter_view_id)
                                    
                                    // TODO: extras (kudos functionality, comments)
                                    Divider().padding(.horizontal)
                                    
                                    HStack {
                                        Button(action: { change_chapter(new_chapter: current_chapter - 1) }) {
                                            Label("Prev Chapter", systemImage: "chevron.left")
                                        }
                                        .disabled(current_chapter == 0)
                                        Spacer()
                                        Button {
                                            work.kudos(toast_binding: $toast)
                                        } label: {
                                            Label {
                                                Text("kudos")
                                            } icon: {
                                                Image(systemName: work.left_kudos ? "heart.fill" : "heart")
                                                    .foregroundStyle(.pink)
                                            }
                                        }
                                        .contentTransition(.symbolEffect(.replace))
                                        .animation(.linear, value: work.left_kudos)
                                        Spacer()
                                        Button(action: { change_chapter(new_chapter: current_chapter + 1) }) {
                                            Label("Next Chapter", systemImage: "chevron.right")
                                                .labelStyle(NextButtonLabelStyle())
                                        }
                                        .disabled(current_chapter == work.chapters.count - 1)
                                    }
                                    .padding()
                                    
                                    Text("Comments and other shit...").padding()
                                }
                            }
                            .onChange(of: current_chapter) {
                                // reset chapter view when changing chapters
                                begin_notes_open = false
                                end_notes_open = false
                                withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                                    scroll_proxy.scrollTo(chapter_view_id, anchor: .top)
                                    offset = 0
                                    last_offset = 0
                                    percent = 0
                                }
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
                        
                        // Fade in based on sidebar progress
                        Rectangle()
                            .foregroundStyle(.black)
                            .opacity(0.6 * percent)
                            .ignoresSafeArea()
                            .onTapGesture { // must tap outside of sidebar to close
                                withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                                    offset = 0
                                    last_offset = offset
                                    percent = 0
                                }
                            }
                        
                        // Sidebar list with chapters
                        List() {
                            Section(header: Text("Chapters")) {
                                ForEach(Array(work.chapters.enumerated()), id: \.offset) {i, chapter in
                                    Text(chapter.title)
                                        .onTapGesture {
                                            // prevent page reset if tap current chapter
                                            if current_chapter != i {
                                                change_chapter(new_chapter: i)
                                            }
                                            withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                                                offset = 0
                                                last_offset = 0
                                                percent = 0
                                            }
                                        }
                                }
                            }
                        }
                        .listStyle(.sidebar)
                        .frame(width: sidebar_width)
                        .offset(x: size.width + offset)
                    }
                    .gesture(
                        // gesture for open/close sidebar
                        DragGesture(minimumDistance: 70)
                            .onChanged() {change in
                                let translation = change.translation.width + last_offset
                                offset = min(max(translation, -sidebar_width), 0)
                                percent = abs(offset) / sidebar_width
                            }
                            .onEnded() {end in
                                let velocity = end.translation.width / 3
                                withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                                    if (abs(velocity + offset)) > (sidebar_width / 3) {
                                        offset = -sidebar_width
                                        percent = 1
                                    } else {
                                        offset = 0
                                        percent = 0
                                    }
                                }
                                last_offset = offset
                            },
                        isEnabled: percent != 1 // only enable gesture when sidebar is not fully open
                    )
                }
            }
        } else {
            // look for matching Work in memory, create it if not exists
            ProgressView()
                .task {
                    let filtered = all_works.filter({ $0.work_id == work_stub.work_id }).first
                    if let filtered {
                        work = filtered
                    } else {
                        let w = Work(work_stub: work_stub)
                        context.insert(w)
                        work = w
                    }
                }
        }
    }
}

#Preview {
    let stub = WorkStub(work_id: 36468745)
    // stub.load_async()
    // let work = Work(work_id: 39945543)
    return WorkView(stub: stub)
        .toaster()
        .modelContainer(for: WorkStub.self, inMemory: true)
        .modelContainer(for: Work.self, inMemory: true)
        .preferredColorScheme(.dark)
}
