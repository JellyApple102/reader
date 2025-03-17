//
//  ChapterView.swift
//  reader
//
//  Created by Jacob Carryer on 3/10/25.
//

import Foundation
import SwiftUI

struct ChapterView: View {
    let chapter: Chapter
    
    @Binding var begin_notes_open: Bool
    @Binding var end_notes_open: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(chapter.title)
                .multilineTextAlignment(.center)
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            
            if (chapter.begin_notes.count > 0) {
                DisclosureGroup("Notes:", isExpanded: $begin_notes_open) {
                    VStack(alignment: .leading) {
                        ForEach(chapter.begin_notes, id: \.self) {note in
                            Text(.init(note)).padding()
                        }
                    }
                }.padding()
            }
            
            ForEach(chapter.paragraphs, id: \.self) {paragraph in
                if (paragraph == "---") {
                    Divider().padding()
                } else {
                    Text(.init(paragraph)).padding()
                }
            }
            
            if (chapter.end_notes.count > 0) {
                DisclosureGroup("Notes:", isExpanded: $end_notes_open) {
                    VStack(alignment: .leading) {
                        ForEach(chapter.end_notes, id: \.self) {note in
                            Text(.init(note)).padding()
                        }
                    }
                }.padding()
            }
        }
    }
}

/*
 #Preview {
 let cerulean_url = URL(string: "https://archiveofourown.org/works/39945543?view_adult=true&view_full_work=true")!
 let work = build_work_from_url(url: cerulean_url, work_id: 39945543)
 WorkView(work: work).preferredColorScheme(.dark)
 }
 */
