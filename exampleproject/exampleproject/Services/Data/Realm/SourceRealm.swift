//
//  RLMSource.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/8/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//
import Foundation
import RealmSwift
import ObjectMapper
import Moya_ObjectMapper

class SourceRealm: Object {
    @objc dynamic var id: String!
    @objc dynamic var name: String!
    @objc dynamic var desc: String!
    @objc dynamic var url: String!
    @objc dynamic var category: String!
    @objc dynamic var language: String!
    @objc dynamic var country: String!
    
    required convenience init?(map: Map) {
        self.init()
        self.mapping(map: map)
    }
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    private enum Field: String {
        case Id             = "id"
        case Name           = "name"
        case Description    = "description"
        case Url            = "url"
        case Category       = "category"
        case Language       = "language"
        case Country        = "country"
    }
}

extension SourceRealm: Mappable {
    func mapping(map: Map) {
        self.id         <- map[Field.Id.rawValue]
        self.name       <- map[Field.Name.rawValue]
        self.desc       <- map[Field.Description.rawValue]
        self.url        <- map[Field.Url.rawValue]
        self.category   <- map[Field.Category.rawValue]
        self.language   <- map[Field.Language.rawValue]
        self.country    <- map[Field.Country.rawValue]
    }
}
