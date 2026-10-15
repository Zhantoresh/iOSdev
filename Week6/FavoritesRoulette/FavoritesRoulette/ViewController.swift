//
//  ViewController.swift
//  FavoritesRoulette
//
//  Created by Жантөре Оразымбетов on 15.10.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var rouletteButton: UIButton!

    
    private var currentIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        posterImageView.layer.cornerRadius = 12
        posterImageView.clipsToBounds = true

       
        if let startIndex = Movie.favorites.indices.randomElement() {
            show(movieAt: startIndex)
        }
    }

    @IBAction func rouletteButtonTapped(_ sender: UIButton) {
        let candidates = Movie.favorites.indices.filter { $0 != currentIndex }
        guard let newIndex = candidates.randomElement() else { return }
        show(movieAt: newIndex)
    }

    private func show(movieAt index: Int) {
        let movie = Movie.favorites[index]
        currentIndex = index

        posterImageView.image = UIImage(named: movie.imageName)
        titleLabel.text = movie.title
        yearLabel.text = String(movie.year)
        descriptionLabel.text = movie.description
    }
}
