//
//  Articles.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/16/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Foundation
import RealmSwift

struct Articles: Codable {
    let author: String
    let title: String
    let description: String
    let url: URL?
    let urlToImage: URL?
    let publishedAt: Date
    let content: String
}

extension Articles: Serializable {
    init?(jsonString: String) {
        guard let data = jsonString.data(using: .utf8), let article = try? JSONDecoder().decode(Articles.self, from: data) else {
            return nil
        }

        self.author         = article.author
        self.title          = article.title
        self.description    = article.description
        self.url            = article.url
        self.urlToImage     = article.urlToImage
        self.publishedAt    = article.publishedAt
        self.content        = article.content
    }
    
    init?(type: Object) {
        guard let article = type as? ArticlesRealm else {
            return nil
        }
        self.author         = article.author
        self.title          = article.title
        self.description    = article.description
        self.url            = URL(string: article.url)
        self.urlToImage     = URL(string: article.urlToImage)
        self.publishedAt    = article.publishedAt
        self.content        = article.content
    }
    
    typealias Element = ArticlesRealm
}
