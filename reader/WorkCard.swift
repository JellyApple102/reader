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
    @State var search_mode: Bool = false
    @Environment(\.modelContext) private var context

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
                    if search_mode {
                        await work_stub.load_for_search()
                    } else {
                        // create background task with own modelactor to fetch and load stub
                        let container = context.container
                        Task(priority: .high) {
                            let model_actor = BackgroundActor(modelContainer: container)
                            await model_actor.load_stub(work_id: work_stub.work_id)
                        }
                    }
                }
        } else {
            VStack {
                HStack {
                    VStack {
                        switch work_stub.rating {
                            case "Explicit": Image(systemName: "e.square.fill").foregroundStyle(.red)
                            case "Mature": Image(systemName: "m.square.fill").foregroundStyle(.orange)
                            case "Teen And Up Audiences": Image(systemName: "t.square.fill").foregroundStyle(.yellow)
                            case "General Audiences": Image(systemName: "g.square.fill").foregroundStyle(.green)
                            default: Image(systemName: "questionmark.square.fill").foregroundStyle(.placeholder)
                        }
                        
                        if let group = work_stub.tags["Category:"] {
                            switch group.tags.first {
                                case "F/F": Image(systemName: "circle.fill").foregroundStyle(.red)
                                case "F/M": Image(systemName: "circle.fill").foregroundStyle(.purple)
                                case "M/M": Image(systemName: "circle.fill").foregroundStyle(.blue)
                                case "Gen": Image(systemName: "circle.fill").foregroundStyle(.green)
                                case "Other": Image(systemName: "circle.fill").foregroundStyle(.brown)
                                default: Image(systemName: "questionmark.circle.fill").foregroundStyle(.placeholder)
                            }
                        } else if work_stub.tags["Categories:"] != nil {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(
                                    .angularGradient(colors: [.red, .blue, .green], center: .center, startAngle: .zero, endAngle: .degrees(360))
                                )
                        }
                        
                        if work_stub.tags["Archive Warnings:"] != nil {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                        } else if let group = work_stub.tags["Archive Warning:"] {
                            if group.tags.first == "Creator Chose Not To Use Archive Warnings" {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                            } else if group.tags.first == "No Archive Warnings Apply" {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.placeholder)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if !work_stub.is_restricted {
                            Text(work_stub.title)
                                .font(.title3)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            (
                                Text(work_stub.title)
                                    .font(.title3)
                                +
                                Text(" \(Image(systemName: "lock.fill"))")
                                    .font(.subheadline)
                                    .baselineOffset(2)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(work_stub.author).italic()
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Label(work_stub.stats.words, systemImage: "character")
                            .font(.caption)
                        Label(work_stub.stats.chapters, systemImage: "text.word.spacing")
                            .font(.caption)
                        Label {
                            Text(work_stub.stats.kudos)
                        } icon: {
                            Image(systemName: "heart.fill").foregroundStyle(.pink)
                        }
                        .font(.caption)
                    }
                }
            }
        }
    }
}
