//
//  ErrorAlert.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import Foundation

struct ErrorAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
