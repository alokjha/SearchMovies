//
//  ViewController.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    let client = MovieSearchClient()
    let disposeBag = DisposeBag()
    var movieModel = MovieModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    
    var latestMovieName: Observable<String> {
        return searchBar.rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureTableView()
        setUpBindings()
    }
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter Movie Name"
        definesPresentationContext = true
    }
    
    func configureTableView() {
        tableView.register(MovieTableViewCell.self)
        tableView.estimatedRowHeight = 187
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setUpBindings(){
    
        searchBar.rx.cancelButtonClicked
            .map{""}
            .bind(to: movieModel.searchText)
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .map{return self.searchBar.text!}
            .bind(to: movieModel.searchText)
            .disposed(by: disposeBag)
        
        movieModel.results.drive(tableView.rx.items(cellIdentifier: MovieTableViewCell.defaultReuseIdentifier, cellType: MovieTableViewCell.self)) { _, movie, cell in
            cell.setUp(movie: movie)
            }
            .disposed(by: disposeBag)
       
        tableView.rx.reachedBottom
            .map{ _ in ()}
            .bind(to: movieModel.newPageNeeded)
            .disposed(by: disposeBag)
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return self.contentOffset.y + self.frame.size.height + edgeOffset > self.contentSize.height
    }
}

extension Reactive where Base: UIScrollView {
    
    var reachedBottom: ControlEvent<Void> {
        let observable = contentOffset
            .flatMap { [weak base] contentOffset -> Observable<Void> in
                guard let scrollView = base else {
                    return Observable.empty()
                }
                
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
                let y = contentOffset.y + scrollView.contentInset.top
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                
                if y > threshold{
                    return Observable.just(())
                }
                else{
                    return Observable.empty()
                }
        }
        
        return ControlEvent(events: observable)
    }
}

