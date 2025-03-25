//
//  AccountView.swift
//  reader
//
//  Created by Jacob Carryer on 3/22/25.
//

import Foundation
import SwiftUI
import SwiftSoup

struct AccountView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var loading: Bool = false
    @State private var did_precheck: Bool = false
    @Binding var logged_in: Bool
    
    func check() async {
        print("login check")
        loading = true
        let url_str = "https://archiveofourown.org/users/login"
        let url = URL(string: url_str)!
        
        do {
            // get auth token from login page
            let (data, response) = try await URLSession.shared.data(from: url)
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
            } else if status == 429 {
                print("login page: too many requests")
                loading = false
                return
            } else {
                print("login page: other status")
                loading = false
                return
            }
            guard let contents = String(data: data, encoding: .utf8) else { loading = false; return }
            let doc: Document = try SwiftSoup.parse(contents)
            
            let logged = try doc.select("body.logged-in")
            if logged.count > 0 {
                logged_in = true
            } else {
                logged_in = false
            }
            username = ""
            password = ""
            loading = false
        } catch {
            print(error)
        }
    }
    
    func login() async {
        loading = true
        let url_str = "https://archiveofourown.org/users/login"
        let url = URL(string: url_str)!
        var auth_token = ""
        
        do {
            // get auth token from login page
            let (data, response) = try await URLSession.shared.data(from: url)
            let status = (response as! HTTPURLResponse).statusCode
            
            if (200...299).contains(status) {
            } else if status == 429 {
                print("login page: too many requests")
                loading = false
                return
            } else {
                print("login page: other status")
                loading = false
                return
            }
            guard let contents = String(data: data, encoding: .utf8) else { loading = false; return }
            let doc: Document = try SwiftSoup.parse(contents)
            
            if let token_element = try doc.select("meta[name=csrf-token]").first() {
                let token = try token_element.attr("content")
                auth_token = token
            }
            
            var components = URLComponents(string: url_str)!
            components.queryItems = [
                URLQueryItem(name: "authenticity_token", value: auth_token),
                URLQueryItem(name: "user[login]", value: username),
                URLQueryItem(name: "user[password]", value: password),
            ]
            let new_url = components.url!
            
            var req = URLRequest(url: new_url)
            req.httpMethod = "POST"
            req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: req) { data, response, error in
                guard let loaded_data = data else { loading = false; return }
                guard let contents = String(data: loaded_data, encoding: .utf8) else { loading = false; return }
                do {
                    let doc: Document = try SwiftSoup.parse(contents)
                    let logged = try doc.select("body.logged-in")
                    if logged.count > 0 {
                        logged_in = true
                        username = ""
                        password = ""
                    }
                } catch {
                    print(error)
                }
                loading = false
            }
            .resume()
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if !logged_in {
                    if !loading {
                        GroupBox {
                            TextField("Username:", text: $username)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            SecureField("Password:", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            Button("Log In") {
                                loading = true
                                Task {
                                    await login()
                                }
                            }
                        } label: {
                            Label("Log In", systemImage: "person.crop.circle")
                        }
                        .padding()
                    } else {
                        GroupBox {
                            ProgressView()
                                .padding()
                        } label: {
                            Label("Log In", systemImage: "person.crop.circle")
                        }
                        .padding()
                    }
                } else {
                    GroupBox {
                        Text("Logged In!")
                            .padding()
                        Button("Log Out") {
                            Task {
                                await URLSession.shared.reset()
                                await check()
                            }
                        }
                    } label: {
                        Label("Log In", systemImage: "person.crop.circle")
                    }
                    .padding()
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                // want to check if session is still 'active', but only the first time
                // TODO: find clean way to move this check to app startup
                if !did_precheck {
                    await check()
                    did_precheck = true
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var logged_in = false
    AccountView(logged_in: $logged_in)
        .preferredColorScheme(.dark)
}
