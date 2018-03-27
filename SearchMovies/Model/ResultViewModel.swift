//
//  ResultViewModel.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//


import RxSwift
import RxCocoa

class ResultViewModel {

    let searchText = Variable("")
    let disposeBag = DisposeBag()
    let client = MovieSearchClient()
    let store = SearchQueryStore()
    var currentPage = 0
    var total_page = 0
    var previousQuery = SearchQuery.init(value: "", page: -1)
    
    var params = ["api_key" : "2696829a81b1b5827d515ff121700838"]

    let newPageNeeded = PublishSubject<Void>()
    
    var results : Variable<[Result]> = Variable([])
    var searchState : Variable<SearchState> = Variable(SearchState.query)
    
    init() {
    
        let requestNeeded = searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { text in
                self.newPageNeeded.asObservable()
                    .startWith(())
                    .scan(SearchQuery(value: text, page: 0)) { request, _ in
                        return SearchQuery(value: text, page: request.page + 1)
                }
                .share(replay: 1)
           }.share(replay: 1)
        
        requestNeeded.subscribe(onNext: { query in
            self.requestMovies(withQuery: query)
        }).disposed(by: disposeBag)
    }
    
    func requestMovies(withQuery query : SearchQuery) {
        
        if query.value.isEmpty {
            
            var array : [Result] = []
            for query in store.allObjects() {
                let result = Result.searchHistory(query: query)
                array.append(result)
            }
            self.results.value = array
            self.searchState.value = array.count > 0 ? .query : .emptyResults
            return
        }
    
        if query == previousQuery && (query.page == total_page || query.page == previousQuery.page) {
            return
        }
        
        if query != previousQuery && query.page == 1 {
            self.results.value = []
            self.searchState.value = .emptyResults
        }
        
        previousQuery = query
       
        params["query"] = query.value
        params["page"] = String(query.page)
    
        let searchRequest = SearchRequest( parameters : params)
        
        client.send(apiRequest: searchRequest)
            .map { (movieResponse : MovieResponse) -> [Movie] in
                self.total_page = movieResponse.totalPages
                return movieResponse.results
            }.subscribe(onNext: { (movies) in
                
                var existingsValues = self.results.value
                for movie in movies {
                    let result = Result.movie(movie: movie)
                    existingsValues.append(result)
                }
                self.results.value = existingsValues
                self.searchState.value = existingsValues.count > 0 ? .searchResults : .emptyResults
                if existingsValues.count > 0 {
                     self.store.save(query)
                }
            }, onError: { (error) in
                print("error",error)
            }).disposed(by: disposeBag)
    }
}
