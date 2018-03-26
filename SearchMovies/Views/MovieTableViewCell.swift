//
//  MovieTableViewCell.swift
//  SearchMovies
//
//  Created by Alok Jha on 24/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit
import RxSwift

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        spinner.hidesWhenStopped = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(movie : Movie){
        self.title.text = movie.title
        self.overview.text = movie.overview
        self.releaseDate.text = movie.releaseDate
        
        if let url = movie.posterURL {
            
            self.poster.image = UIImage()
            self.spinner.startAnimating()
            
            let imageModel = ImageModel(imageName: url)
            
            imageModel.downloadedImage.subscribe(onNext: { image in
                self.poster.image = image
            }, onError: { error in
                print("error \(error)")
            }, onCompleted: {
                self.spinner.stopAnimating()
            })
            .disposed(by: disposeBag)

        }
        
    }
}

extension MovieTableViewCell : NibLoadableView {}
