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
        apiService.getSources()
            .subscribe()
            .disposed(by: bag)

        // Observe the data and consume it
        dataService.observeOne(Source.self)
            .debug()
            .subscribe(onNext: { (source) in
                print(source)
            })
            .disposed(by: bag)
        
        dataService.observeAll(Source.self)
            .debug()
            .subscribe(onNext: { (sources) in
                print("Loaded count: \(sources.count)")
            })
            .disposed(by: bag)
    }


}

