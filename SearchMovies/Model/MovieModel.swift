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
    var params = ["page" : "1" , "api_key" : "2696829a81b1b5827d515ff121700838"]
    
    lazy var data: Driver<[Movie]> = {
        return self.searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest {
                self.getMovies(query: $0)
            }
            .asDriver(onErrorJustReturn: [])
    }()
    
    func getMovies(query : String) -> Observable<[Movie]>{
        
        print("query" ,query)
        
        if query.isEmpty {
            return Observable.just([])
        }
        
        params["query"] = query
        let searchRequest = SearchRequest( parameters : params)
        
        return client.send(apiRequest: searchRequest)
            .map { (movieResponse : MovieResponse) in
                movieResponse.results
            }
            .catchError({ (error) -> Observable<[Movie]> in
                print("error",error)
                return Observable.just([])
            })
            .observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
}
