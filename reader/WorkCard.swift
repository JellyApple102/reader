//
//  WorkView.swift
//  reader
//
//  Created by Jacob Carryer on 3/11/25.
//

import Foundation
import SwiftUI

struct WorkCard: View {
    @State var work_stub: WorkStub
    
    func get_rating_image() -> Image {
        switch work_stub.rating {
            case "Explicit":
                return Image(systemName: "e.square.fill")
            case "Mature":
                return Image(systemName: "m.square.fill")
            case "Teen And Up Audiences":
                return Image(systemName: "t.square.fill")
            case "General Audiences":
                return Image(systemName: "g.square.fill")
            default:
                return Image(systemName: "questionmark.app.fill")
        }
    }
    
    var body: some View {
        if !work_stub.stub_loaded {
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
                .task {
                    work_stub.load_async()
                }
        } else {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(work_stub.title) \(get_rating_image())")
                            .font(.title3)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(work_stub.author).italic()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Label(work_stub.stats.words, systemImage: "character")
                            .font(.caption)
                        Label(work_stub.stats.chapters, systemImage: "text.word.spacing")
                            .font(.caption)
                        Label(work_stub.stats.kudos, systemImage: "heart.fill")
                            .font(.caption)
                    }
                }
            }
        }
    }
}
