//
//  TagSearch.swift
//  reader
//
//  Created by Jacob Carryer on 3/20/25.
//

import Foundation
import SwiftUI
import Flow

struct TagResult: Codable, Hashable {
    var id: String
    var name: String
}

struct TagSearch: View {
    @Binding var selected_tags: [String]
    @Binding var search_text: String
    @State var search_results: [TagResult] = []
    let search_type: String
    
    func search_for_tags() {
        let url_str = "https://archiveofourown.org/autocomplete/\(search_type)?term=\(search_text)"
        let url = URL(string: url_str)!
        
        URLSession.shared.dataTask(with: url) {data, response, error in
            guard let loaded_data = data else { return }
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
            } else if status == 429 {
                print("tag search: too many requests")
                return
            } else {
                print("tag search: other status")
                return
            }
            
            search_results = []
            let decoder = JSONDecoder()
            do {
                search_results = try decoder.decode([TagResult].self, from: loaded_data)
            } catch {
                print("error parsing search results")
            }
        }
        .resume()
    }
    
    var body: some View {
        VStack {
            HFlow {
                ForEach(selected_tags.indices, id: \.self) { index in
                    Label(selected_tags[index], systemImage: "tag")
                        .font(.caption)
                        .labelStyle(.titleOnly)
                        .padding(5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .stroke(.gray, lineWidth: 1)
                        }
                        .onTapGesture {
                            selected_tags.remove(at: index)
                        }
                }
            }
            .padding(.top)
            
            List {
                ForEach(search_results, id: \.self) { tag in
                    Text(tag.name)
                        .onTapGesture {
                            selected_tags.append(tag.name)
                        }
                }
            }
            .searchable(text: $search_text, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                search_for_tags()
            }
        }
    }
}

#Preview {
    @Previewable @State var tags: [String] = ["sample tag"]
    @Previewable @State var text: String = ""
    @Previewable @State var results: [TagResult] = [TagResult(id: "1", name: "tag 1"), TagResult(id: "2", name: "tag 2")]
    
    NavigationStack {
        TagSearch(selected_tags: $tags, search_text: $text, search_results: results, search_type: "character")
    }
    .preferredColorScheme(.dark)
}
