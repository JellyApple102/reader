//
//  SummaryView.swift
//  reader
//
//  Created by Jacob Carryer on 3/13/25.
//

import Foundation
import SwiftUI

struct SummaryView: View {
    @Binding var work_stub: WorkStub?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Summary:")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                if let work_stub {
                    ForEach(work_stub.summary, id: \.self) {paragraph in
                        Text(.init(paragraph)).padding()
                    }
                }
            }
        }
    }
}
