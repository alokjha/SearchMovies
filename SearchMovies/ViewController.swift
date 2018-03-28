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

    let disposeBag = DisposeBag()
    var resultViewModel = ResultViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
        
    var results : [Result] = []
    var searchState : SearchState = SearchState.query
    
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
        searchBar.autocapitalizationType = .none
        definesPresentationContext = true
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MovieTableViewCell.self)
        tableView.register(UITableViewCell.self)
        tableView.estimatedRowHeight = 186
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func setUpBindings(){
    
        searchBar.rx.cancelButtonClicked
            .map{""}
            .bind(to: resultViewModel.searchText)
            .disposed(by: disposeBag)

        searchBar.rx.searchButtonClicked
            .map{return self.searchBar.text!}
            .bind(to: resultViewModel.searchText)
            .disposed(by: disposeBag)
        
        let movieObservable = resultViewModel.results.asObservable()
        let stateObservable = resultViewModel.searchState.asObservable()
        
        Observable.zip(stateObservable,movieObservable)
            .bind { (state , results)  in
                
                if self.searchState != state || state == .emptyResults {
                     self.results.removeAll()
                }
                self.searchState = state
                self.results.append(contentsOf: results)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
        }.disposed(by: disposeBag)
        
        resultViewModel.errorMessage.bind { (error) in
            let alertController = UIAlertController(title: "Alert", message: error.debugDescription, preferredStyle: .alert)
            self.present(alertController, animated: true, completion: nil)
            let actionOk = UIAlertAction(title: "OK", style: .default,
                                         handler: { action in alertController.dismiss(animated: true, completion: nil) })
            
            alertController.addAction(actionOk)
            
        }.disposed(by: disposeBag)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = results[indexPath.row]
        
        switch result {
        case .movie(let movie):
            let cell : MovieTableViewCell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.defaultReuseIdentifier) as! MovieTableViewCell
            cell.setUp(movie: movie)
            cell.selectionStyle = .none
            return cell
        case .searchHistory(let searchQuery):
            let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier)!
            cell.textLabel?.text = searchQuery.value
            cell.selectionStyle = .gray
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.searchState == .searchResults && self.results.count > 0 {
            if indexPath.row == self.results.count - 2 {
                resultViewModel.loadNextPage()
            }
        }
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let obj = results[indexPath.row]
        
        switch obj {
        case .searchHistory(let query) :
            self.searchBar.text = query.value
            self.searchController.isActive = true
            self.resultViewModel.searchText.value = query.value
            break
        default : break
        }
    }
}


