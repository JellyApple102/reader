//
//  Toast.swift
//  reader
//
//  Created by Jacob Carryer on 3/18/25.
//

import Foundation
import SwiftUI

struct Toast: Equatable {
    let system_icon: String
    let message: String
    let color: Color
    
    init(system_icon: String, message: String, color: Color) {
        self.system_icon = system_icon
        self.message = message
        self.color = color
    }
}

struct ToastPreferenceKey: PreferenceKey {
    static var defaultValue: Toast? = nil
    
    static func reduce(value: inout Toast?, nextValue: () -> Toast?) {
        if let toast = nextValue() {
            value = toast
        }
    }
}

struct ToasterViewModifier: ViewModifier {
    @State var toast: Toast?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast {
                    ToastView(toast: toast)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    /*
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.toast = nil
                            }
                        }
                     */
                }
            }
            .animation(.easeInOut, value: toast)
            .onPreferenceChange(ToastPreferenceKey.self) {
                toast = $0
            }
    }
}

extension View {
    func toaster() -> some View {
        modifier(ToasterViewModifier())
    }
}

struct ToastView: View {
    let message: String
    let system_icon: String
    let color: Color
    
    init(toast: Toast) {
        self.message = toast.message
        self.system_icon = toast.system_icon
        self.color = toast.color
    }
    
    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: system_icon)
        }
        .padding()
        .background(color)
        .clipShape(Capsule(style: .circular))
    }
}
