//
//  ServiceRowView.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import SwiftUI

struct ServiceRowView: View {
    let service: Service

    var body: some View {
        HStack {
            CachedAsyncImage(
                url: service.iconUrl,
                placeholder: { ProgressView() },
                errorImage: Image(systemName: "xmark.circle")
            )
            .frame(width: 50, height: 50)
            .cornerRadius(8)

            VStack(alignment: .leading) {
                Text(service.name).font(.headline)
                Text(service.description).font(.subheadline)
            }
        }
    }
}
