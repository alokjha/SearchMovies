//
//  ImageClient.swift
//  SearchMovies
//
//  Created by Alok Jha on 28/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import RxSwift

class ImageClient : APIClient {
    var baseURL: URL = URL(string: "https://image.tmdb.org/t/p/w92")!
    
    func downloadImage(imageRequest : ImageRequest) -> Observable<UIImage> {
        return Observable<UIImage>.create { [unowned self] observer in
            let request = imageRequest.request(with: self.baseURL)
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    observer.onError(APIError.Other(error!.localizedDescription))
                    observer.onCompleted()
                    return
                }
                
                guard let data = data ,let image = UIImage(data:data) else {
                    observer.onError(APIError.CouldNotDownloadImage)
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
