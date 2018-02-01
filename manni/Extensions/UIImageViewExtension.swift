//
//  UIImageViewExtension.swift
//  manni
//
//  Created by Philipp Matthes on 31.01.18.
//  Copyright © 2018 Philipp Matthes. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func downloadFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloadFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadFrom(url: url, contentMode: mode)
    }
}
