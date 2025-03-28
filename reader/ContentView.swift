//
//  ContentView.swift
//  reader
//
//  Created by Jacob Carryer on 3/8/25.
//

import SwiftUI
import SwiftData
import SwiftSoup

struct ContentView: View {
    @State private var selected_tab = 1
    @State private var logged_in: Bool = false
    
    init() {
        let tab_app = UITabBarAppearance()
        tab_app.configureWithTransparentBackground()
        tab_app.backgroundEffect = .init(style: .systemMaterial)
        UITabBar.appearance().standardAppearance = tab_app
        UITabBar.appearance().scrollEdgeAppearance = tab_app
        
        let nav_app = UINavigationBarAppearance()
        nav_app.configureWithTransparentBackground()
        nav_app.backgroundEffect = .init(style: .systemMaterial)
        UINavigationBar.appearance().standardAppearance = nav_app
        UINavigationBar.appearance().scrollEdgeAppearance = nav_app
    }
    
    var body: some View {
        TabView(selection: $selected_tab) {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            WorksView()
                .tabItem {
                    Label("Works", systemImage: "book")
                }
                .tag(1)
            AccountView(logged_in: $logged_in)
                .tabItem {
                    if logged_in {
                        Label("Account", systemImage: "person.crop.circle.badge.checkmark")
                    } else {
                        Label("Account", systemImage: "person.crop.circle.badge.xmark")
                    }
                }
                .tag(2)
        }
        .toaster()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            WorkStub.self,
            Work.self
        ], inMemory: true)
        .preferredColorScheme(.dark)
}
