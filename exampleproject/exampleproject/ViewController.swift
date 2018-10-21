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

    @IBOutlet weak var tableView: UITableView!
    
    let bag = DisposeBag()
    
    let apiService  = GoogleNewsAPI()
    let dataService = RealmDataService.shared
    
    private let dataSource = BehaviorSubject<[Source?]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make network call
        apiService.getHeadlines(Articles.self)
            .subscribe()
            .disposed(by: bag)
        
        apiService.getSources(Source.self)
            .subscribe()
            .disposed(by: bag)

        dataService.observeAll(Source.self)
            .subscribe(self.dataSource)
            .disposed(by: bag)
        
        self.dataSource
            .filter{ $0.count > 0 }
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: bag)
    }

    fileprivate var dataCount: Int {
        if let count  = try? self.dataSource.value().count {
            return count
        }
        return 0
    }
    
    fileprivate func data(for indexPath: IndexPath) -> Source? {
        if let dataArray  = try? self.dataSource.value() {
            return dataArray[indexPath.row]
        }
        return nil
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        cell.textLabel?.text = self.data(for: indexPath)?.name
        return cell
    }
    
}
