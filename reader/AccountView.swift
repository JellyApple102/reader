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
    @State var username: String = ""
    @State var password: String = ""
    @State var loading: Bool = false
    @State var logged_in: Bool = false
    
    func login() async {
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
                return
            } else {
                print("login page: other status")
                return
            }
            guard let contents = String(data: data, encoding: .utf8) else { return }
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
                // let res = (response as! HTTPURLResponse)
                // let status = res.statusCode
                guard let loaded_data = data else { return }
                guard let contents = String(data: loaded_data, encoding: .utf8) else { return }
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
                        Form {
                            TextField("Username:", text: $username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            SecureField("Password:", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            Button("Log In") {
                                loading = true
                                Task {
                                    await login()
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                } else {
                    Text("logged in!")
                        .padding()
                    Button("reset") {
                        loading = false
                        logged_in = false
                    }
                    .padding()
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AccountView()
        .preferredColorScheme(.dark)
}
