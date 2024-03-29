//
//  CachedAsyncImage.swift
//  ServicesVk
//
//  Created by Elizaveta Osipova on 3/28/24.
//

import SwiftUI

struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL
    let placeholder: Placeholder
    let errorImage: Image

    init(url: URL, @ViewBuilder placeholder: () -> Placeholder, errorImage: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder()
        self.errorImage = errorImage
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fill)
            case .failure:
                errorImage.resizable().aspectRatio(contentMode: .fill)
            @unknown default:
                placeholder
            }
        }
    }
}
