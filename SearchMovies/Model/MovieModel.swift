//
//  MovieModel.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//


import RxSwift
import RxCocoa
import RxDataSources


enum Results {
    case movie(movie : Movie)
    case searchHistory(query: SearchQuery)
}


enum SectionOfCustomData: SectionModelType {
    

    typealias Item = Results
    
    case customDataSection(header: String, items: [Results])
    case stringSection(header: String, items: [Results])
    
    var items: [Results] {
        switch self {
        case .customDataSection(_, let items):
            return items

        case .stringSection(_, let items):
            return items
        }
    }

    public init(original: SectionOfCustomData, items: [Results]) {
        switch original {
        case .customDataSection(let header, _):
            self = .customDataSection(header: header, items: items)
        case .stringSection(let header, _):
            self = .stringSection(header: header, items: items)
        }
    }
    
    static func empty() -> SectionOfCustomData {
        return SectionOfCustomData.customDataSection(header: "", items: [])
    }
}

class MovieModel {

    let searchText = Variable("")
    let disposeBag = DisposeBag()
    let client = MovieSearchClient()
    let store = SearchQueryStore()
    var currentPage = 0
    var total_page = 0
    var params = ["page" : "1" , "api_key" : "2696829a81b1b5827d515ff121700838"]

    let newPageNeeded = PublishSubject<Void>()
    
    var movies : Variable<[Results]> = Variable([Results.searchHistory(query: SearchQuery(value: "", page: 0))])
    lazy var results : Driver<[Results]> = {
        return movies.asDriver()
    }()
    
    var data : Variable<[SectionOfCustomData]> = Variable([SectionOfCustomData.empty()])
    
    init() {
    
        let requestNeeded = searchText.asObservable()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { text in
                self.newPageNeeded.asObservable()
                    .startWith(())
                    .scan(SearchQuery(value: text, page: 0)) { request, _ in
                        return SearchQuery(value: text, page: request.page + 1)
                }.share(replay: 1)
           }.share(replay: 1)
        
        requestNeeded.subscribe(onNext: { query in
            self.requestMovies(withQuery: query)
        }).disposed(by: disposeBag)
    }
    
    func requestMovies(withQuery query : SearchQuery) {
        
        if query.value.isEmpty {
            
            var array : [Results] = []
            
            for query in store.allObjects() {
                let result = Results.searchHistory(query: query)
                array.append(result)
            }
            
            self.movies.value = array
            let obj = [SectionOfCustomData.stringSection(header: "", items:array)]
            self.data.value = obj
            return
        }
        
        if query.page == total_page {
            return
        }
        
        params["query"] = query.value
        params["page"] = String(query.page)
        
        let searchRequest = SearchRequest( parameters : params)
        
        client.send(apiRequest: searchRequest)
            .map { (movieResponse : MovieResponse) -> [Movie] in
                self.total_page = movieResponse.totalPages
                return movieResponse.results
            }.subscribe(onNext: { (movies) in
                
                let existingsValues = self.movies.value
                
                var existing : [Movie] = []
                
                for result in existingsValues {
                    
                    switch result {
                    case .movie(let movie) : existing.append(movie)
                    default : break
                    }
                }
                
                existing.append(contentsOf: movies)
                
                 var array : [Results] = []
                
                for movie in existing {
                    let result = Results.movie(movie: movie)
                    array.append(result)
                }
                
                self.movies.value = array
                self.store.save(query)
                
                var x = self.data.value[0]
                var items = x.items
                
                if query.page == 1 {
                    items.removeAll()
                }
                
                items.append(contentsOf: array)
                x = SectionOfCustomData.customDataSection(header: "", items: items)
                
                let new  = [x]
                self.data.value = new
                
            }, onError: { (error) in
                print("error",error)
            }).disposed(by: disposeBag)
    }
}
