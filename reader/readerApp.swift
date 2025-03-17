//
//  readerApp.swift
//  reader
//
//  Created by Jacob Carryer on 3/8/25.
//

import SwiftUI
import SwiftData
import SwiftSoup

@main
struct readerApp: App {
    var model_container: ModelContainer
    
    init() {
        do {
            /*
             specifying names for the configs seems to be required for this to work.
             fuck you apple
             https://developer.apple.com/forums/thread/764073
             */
            let stub_conf = ModelConfiguration("db1", schema: Schema([WorkStub.self]))
            let work_conf = ModelConfiguration("db2", schema: Schema([Work.self]), isStoredInMemoryOnly: true)
            
            model_container = try ModelContainer(
                for: WorkStub.self, Work.self,
                configurations: stub_conf, work_conf
            )
        } catch {
            fatalError("error creating model container")
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(model_container)
    }
}
