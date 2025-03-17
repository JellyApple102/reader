//
//  SearchQueryView.swift
//  reader
//
//  Created by Jacob Carryer on 3/19/25.
//

import Foundation
import SwiftUI

struct SearchQueryView: View {
    @Binding var search_query: SearchQuery
    @Binding var showing: Bool
    @Binding var did_submit: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Work Info") {
                    TextField("Any field:", text: $search_query.query)
                    TextField("Title:", text: $search_query.title)
                    TextField("Author:", text: $search_query.creators)
                    HStack {
                        Text("Date:")
                        if search_query.date_comparison == .range {
                            TextField("", value: $search_query.date_count, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.date_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        TextField(
                            "",
                            value: search_query.date_comparison == .range
                                ? $search_query.date_count_secondary
                                : $search_query.date_count,
                            formatter: NumberFormatter()
                        )
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        Picker("", selection: $search_query.date_period) {
                            ForEach(DatePeriod.allCases) { period in
                                Text(period.rawValue)
                            }
                        }
                    }
                    Picker("Completion:", selection: $search_query.complete) {
                        ForEach(CompletionFilter.allCases) { completion in
                            Text(completion.rawValue)
                        }
                    }
                    Picker("Crossovers:", selection: $search_query.crossover) {
                        ForEach(CrossoverFilter.allCases) { crossover in
                            Text(crossover.rawValue)
                        }
                    }
                    Toggle("Single Chapter:", isOn: $search_query.single_chapter)
                    HStack {
                        Text("Word Count:")
                        Spacer()
                        if (search_query.word_count_comparison == .range) {
                            TextField("", value: $search_query.word_count, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.word_count_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        .frame(width: 50)
                        TextField(
                            "",
                            value: search_query.word_count_comparison == .range
                                ? $search_query.word_count_secondary
                                : $search_query.word_count,
                            formatter: NumberFormatter()
                        )
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    LabeledContent("Language", value: search_query.language_id)
                }
                Section("Work Tags") {
                    NavigationLink("Fandoms: (\(search_query.fandom_tags.count))") {
                        TagSearch(
                            selected_tags: $search_query.fandom_tags,
                            search_text: $search_query.fandom_search,
                            search_type: "fandom"
                        )
                        .navigationTitle("Fandoms:")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    Picker("Rating", selection: $search_query.rating) {
                        ForEach(Ratings.allCases) { rating in
                            Text(rating.rawValue)
                        }
                    }
                    DisclosureGroup("Warnings:") {
                        Toggle("Creator Chose Not To Use Archive Warnings", isOn: $search_query.warnings.chose_none)
                        Toggle("Graphic Depictions Of Violence", isOn: $search_query.warnings.graphic_violence)
                        Toggle("Major Character Death", isOn: $search_query.warnings.major_death)
                        Toggle("No Archive Warnings Apply", isOn: $search_query.warnings.none_apply)
                        Toggle("Rape/Non-Con", isOn: $search_query.warnings.non_con)
                        Toggle("Underage Sex", isOn: $search_query.warnings.underage)
                    }
                    DisclosureGroup("Categories:") {
                        Toggle("F/F", isOn: $search_query.categories.ff)
                        Toggle("F/M", isOn: $search_query.categories.fm)
                        Toggle("Gen", isOn: $search_query.categories.gen)
                        Toggle("M/M", isOn: $search_query.categories.mm)
                        Toggle("Multi", isOn: $search_query.categories.multi)
                        Toggle("Other", isOn: $search_query.categories.other)
                    }
                    NavigationLink("Characters: (\(search_query.character_tags.count))") {
                        TagSearch(
                            selected_tags: $search_query.character_tags,
                            search_text: $search_query.character_search,
                            search_type: "character"
                        )
                        .navigationTitle("Characters:")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Relationships: (\(search_query.relationship_tags.count))") {
                        TagSearch(
                            selected_tags: $search_query.relationship_tags,
                            search_text: $search_query.relationship_search,
                            search_type: "relationship"
                        )
                        .navigationTitle("Characters:")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    NavigationLink("Additional Tags: (\(search_query.freeform_tags.count))") {
                        TagSearch(
                            selected_tags: $search_query.freeform_tags,
                            search_text: $search_query.freeform_search,
                            search_type: "freeform"
                        )
                        .navigationTitle("Additional Tags:")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                Section("Work Stats") {
                    HStack {
                        Text("Hits:")
                        Spacer()
                        if search_query.hits_comparison == .range {
                            TextField("", value: $search_query.hits, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.hits_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        .frame(width: 50)
                        TextField(
                            "",
                            value: search_query.word_count_comparison == .range
                                ? $search_query.hits_secondary
                                : $search_query.hits,
                            formatter: NumberFormatter()
                        )
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kudos:")
                        Spacer()
                        if search_query.kudos_comparison == .range {
                            TextField("", value: $search_query.kudos, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.kudos_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        .frame(width: 50)
                        TextField(
                            "",
                            value: search_query.kudos_comparison == .range
                                ? $search_query.kudos_secondary
                                : $search_query.kudos,
                            formatter: NumberFormatter()
                        )
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Comments:")
                        Spacer()
                        if search_query.comments_comparison == .range {
                            TextField("", value: $search_query.comments, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.comments_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        .frame(width: 50)
                        TextField(
                            "",
                            value: search_query.comments_comparison == .range
                                ? $search_query.comments_secondary
                                : $search_query.comments,
                            formatter: NumberFormatter()
                        )
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Bookmarks:")
                        Spacer()
                        if search_query.bookmarks_comparison == .range {
                            TextField("", value: $search_query.bookmarks, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.trailing)
                        }
                        Picker("", selection: $search_query.bookmarks_comparison) {
                            ForEach(Comparisons.allCases) { comp in
                                Image(systemName: comp.rawValue)
                            }
                        }
                        .frame(width: 50)
                        TextField(
                            "",
                            value: search_query.bookmarks_comparison == .range
                                ? $search_query.bookmarks_secondary
                                : $search_query.bookmarks,
                            formatter: NumberFormatter()
                        )
                        .frame(width: 60)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                    }
                }
                Section("Search") {
                    Picker("Sort By:", selection: $search_query.sort_column) {
                        ForEach(SortBy.allCases) { sort in
                            Text(sort.rawValue)
                        }
                    }
                    Picker("Sort Direction:", selection: $search_query.sort_direction) {
                        ForEach(SortDirection.allCases) { dir in
                            Text(dir.rawValue)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    Button("Clear") {
                        search_query = SearchQuery()
                    }
                    .foregroundStyle(.red)
                    Button("Search") {
                        did_submit = true
                        showing = false
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var query = SearchQuery()
    @Previewable @State var show = true
    @Previewable @State var did_submit = false
    SearchQueryView(search_query: $query, showing: $show, did_submit: $did_submit)
        .preferredColorScheme(.dark)
}
