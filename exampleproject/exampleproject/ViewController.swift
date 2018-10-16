//
//  ViewController.swift
//  exampleproject
//
//  Created by MD AL MAMUN (LCL) on 10/7/18.
//  Copyright © 2018 Loblaw. All rights reserved.
//

import UIKit
import RxSwift
import Realm
import RealmSwift

class ViewController: UIViewController {

    let bag = DisposeBag()
    
    let apiService  = GoogleNewsAPI()
    let dataService = RealmDataService.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make network call
        apiService.getSources(Source.self)
            .subscribe()
            .disposed(by: bag)

        // Observe the data and consume it
        
        dataService.observeFirst(Source.self)
            .subscribe(onNext: { (source) in
                print(source)
            })
            .disposed(by: bag)
        
        dataService.observeAll(Source.self)
            .subscribe(onNext: { (sources) in
                print("Loaded count: \(sources.count)")
            })
            .disposed(by: bag)
    }


}

