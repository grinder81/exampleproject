//
//  Feature.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 11/14/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import Foundation

enum FeatureKey: String {
    case topHeadlines   = "newsapp.topheadlines"
    case profile        = "newsapp.profile"
}

protocol Featureable {
    associatedtype Action
    
    // That will return app states ONLY
    // where this feature is available
    var states: [AppState] { get }
    
    // Return list of actions current instance support
    // it. It will be populated by Feature flags
    var actions: [Action] { get }
    
    var key: FeatureKey { get }
}

struct TopHeadlines: Featureable {
    let supportedActions: [TopHeadlines.Action]
    
    init(actions: [TopHeadlines.Action]) {
        supportedActions = actions
    }
    
    enum Action {
        case usOnly
        case ukOnly
        case all
    }
    
    // That's statically binded which mean
    // we know what app state this feature is available
    var states: [AppState] {
        return [.loaded]
    }
    
    var actions: [TopHeadlines.Action] {
        return supportedActions
    }
    
    var key: FeatureKey {
        return .topHeadlines
    }
}
