//
//  APIClient.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation
import RxSwift


protocol APIClient : class {
    var baseURL : URL {get set}
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T>
}

extension APIClient {
    
    func send<T: Codable>(apiRequest: APIRequest) -> Observable<T> {
        return Observable<T>.create { [unowned self] observer in
            let request = apiRequest.request(with: self.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    observer.onError(APIError.Other(error!.localizedDescription))
                    observer.onCompleted()
                    return
                }
                
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(APIError.Other(error.localizedDescription))
                }
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}



