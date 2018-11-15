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

    let kTablevHeaderHight: CGFloat = 300.0
    var headerView: UIView!
    
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
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: kTablevHeaderHight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTablevHeaderHight)
        updateHeaderView()        
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
    
    private func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTablevHeaderHight, width: tableView.bounds.width, height: kTablevHeaderHight)
        if tableView.contentOffset.y < -kTablevHeaderHight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        headerView.frame = headerRect
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        cell.textLabel?.text = self.data(for: indexPath)?.name
        cell.detailTextLabel?.text = self.data(for: indexPath)?.description
        return cell
    }
    
}
