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
import RxDataSources

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
        tableView.register(UITableViewCell.self)
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
        
        
//        movieModel.results.drive(tableView.rx.items(cellIdentifier: MovieTableViewCell.defaultReuseIdentifier, cellType: MovieTableViewCell.self)) { _, movie, cell in
//            cell.setUp(movie: movie)
//            }
//            .disposed(by: disposeBag)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: { (dataSource, table, idxPath, _) in
            switch dataSource[idxPath] {
            case .movie(let movie):
                let cell : MovieTableViewCell = table.dequeueReusableCell(withIdentifier: MovieTableViewCell.defaultReuseIdentifier) as! MovieTableViewCell
                cell.setUp(movie: movie)
                cell.selectionStyle = .none
                return cell;

            case .searchHistory(let searchQuery) :
                let cell : UITableViewCell = table.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier)!
                cell.textLabel?.text = searchQuery.value
                cell.selectionStyle = .gray
                return cell

            }
         })
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
              let obj = dataSource[indexPath]
                
                switch obj {
                case .searchHistory(let query) :
                    self?.searchBar.text = query.value
                    self?.searchController.isActive = true
                    self?.movieModel.searchText.value = query.value
                    break
                default : break
                }
                
            }).disposed(by: disposeBag)
        
        movieModel.data.asObservable().bind(to: tableView.rx.items(dataSource: dataSource))
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

