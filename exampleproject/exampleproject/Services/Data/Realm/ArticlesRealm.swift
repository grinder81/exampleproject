//
//  ArticlesRealm.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/16/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import RealmSwift
import ObjectMapper
import Moya_ObjectMapper

class ArticlesRealm: Object {
    @objc dynamic var author: String?
    @objc dynamic var title: String?
    @objc dynamic var desc: String?
    @objc dynamic var url: String?
    @objc dynamic var urlToImage: String?
    @objc dynamic var publishedAt: Date?
    @objc dynamic var content: String?
    
    required convenience init?(map: Map) {
        self.init()
        self.mapping(map: map)
    }

    override static func primaryKey() -> String {
        return "title"
    }
    
    private enum Field: String {
        case author         = "author"
        case title          = "title"
        case desc           = "description"
        case url            = "url"
        case urlToImage     = "urlToImage"
        case publishedAt    = "publishedAt"
        case content        = "content"
    }
    
    fileprivate let utcDateTransform = TransformOf<Date, String>(fromJSON: { (value) -> Date? in
        guard let date = value else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: date)
    }) { (value) -> String? in
        guard let date = value else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: date)
    }
}


extension ArticlesRealm: Mappable {
    
    func mapping(map: Map) {
        self.author         <- map[Field.author.rawValue]
        self.title          <- map[Field.title.rawValue]
        self.desc           <- map[Field.desc.rawValue]
        self.url            <- map[Field.url.rawValue]
        self.urlToImage     <- map[Field.urlToImage.rawValue]
        self.content        <- map[Field.content.rawValue]
        self.publishedAt    <- (map[Field.publishedAt.rawValue], utcDateTransform)
    }
}
