//
//  APIClient.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation
import RxSwift


enum APIClientError: Error {
    case CouldNotDownloadImage
    case Other(Error)
}

extension APIClientError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .CouldNotDownloadImage:
            return "Could not download image"
        case let .Other(error):
            return "\(error)"
        }
    }
}

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
                    observer.onError(APIClientError.Other(error!))
                    observer.onCompleted()
                    return
                }
                
                do {
                    let model: T = try JSONDecoder().decode(T.self, from: data ?? Data())
                    observer.onNext(model)
                } catch let error {
                    observer.onError(APIClientError.Other(error))
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


class  MovieSearchClient : APIClient {
    var baseURL: URL = URL(string: "https://api.themoviedb.org/3/")!
}

class ImageClient : APIClient {
    var baseURL: URL = URL(string: "https://image.tmdb.org/t/p/w92")!
    
    func downloadImage(imageRequest : ImageRequest) -> Observable<UIImage> {
        return Observable<UIImage>.create { [unowned self] observer in
            let request = imageRequest.request(with: self.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    observer.onError(APIClientError.Other(error!))
                    observer.onCompleted()
                    return
                }
                
                guard let data = data ,let image = UIImage(data:data) else {
                    observer.onError(APIClientError.CouldNotDownloadImage)
                    observer.onCompleted()
                    return
                }
                observer.onNext(image)
                observer.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}


