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
        
        searchBar.rx.text.orEmpty
            .bind(to: movieModel.searchText)
            .disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked
            .map{""}
            .bind(to: movieModel.searchText)
            .disposed(by: disposeBag)
        
        movieModel.data.drive(tableView.rx.items(cellIdentifier: MovieTableViewCell.defaultReuseIdentifier, cellType: MovieTableViewCell.self)) { _, movie, cell in
            cell.setUp(movie: movie)
            }
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

