//
//  MovieModel.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//


import RxSwift
import RxCocoa

class MovieModel {

    let searchText = Variable("")
    let disposeBag = DisposeBag()
    let client = MovieSearchClient()
    var currentPage = 0
    var total_page = 0
    var params = ["page" : "1" , "api_key" : "2696829a81b1b5827d515ff121700838"]

    let newPageNeeded = PublishSubject<Void>()
    
    struct RequestPage {
        let query: String
        let page: Int
    }
    
    private var movies : Variable<[Movie]> = Variable([])
    lazy var results : Driver<[Movie]> = {
        return movies.asDriver()
    }()
    
    init() {
    
        let requestNeeded = searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { text in
                self.newPageNeeded.asObservable()
                    .startWith(())
                    .scan(RequestPage(query: text, page: 0)) { request, _ in
                        return RequestPage(query: text, page: request.page + 1)
                }.share(replay: 1)
           }.share(replay: 1)
        
        requestNeeded.subscribe(onNext: { page in
            print(page)
            self.requestMovies(request: page)
        }).disposed(by: disposeBag)
    }
    
    func requestMovies(request : RequestPage) {
        
        if request.query.isEmpty {
            self.movies.value = []
            return
        }
        
        if request.page == total_page {
            return
        }
        
        params["query"] = request.query
        params["page"] = String(request.page)
        
        let searchRequest = SearchRequest( parameters : params)
        
        client.send(apiRequest: searchRequest)
            .map { (movieResponse : MovieResponse) -> [Movie] in
                self.total_page = movieResponse.totalPages
                return movieResponse.results
            }.subscribe(onNext: { (movies) in
                self.movies.value.append(contentsOf: movies)
            }, onError: { (error) in
                print("error",error)
            }).disposed(by: disposeBag)
    }
}
