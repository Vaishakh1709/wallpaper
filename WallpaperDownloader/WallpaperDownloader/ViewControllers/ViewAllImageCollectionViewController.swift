//
//  ViewAllImageCollectionViewController.swift
//  WallpaperDownloader
//
//  Created by Vaishakh V on 11/05/25.
//

import UIKit

protocol ViewAllImageCollectionViewControllerDelegate: AnyObject {
    func didSelectImage(with url: String)
}

class ViewAllImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate:ViewAllImageCollectionViewControllerDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!

    var imageURLs: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        if let imageUrl = URL(string: imageURLs[indexPath.row]) {
            cell.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10  // space between cells
        let availableWidth = collectionView.bounds.width - padding * 3  // 2 paddings + 1 between cells
        let widthPerItem = availableWidth / 2
        return CGSize(width: widthPerItem, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedUrl = imageURLs[indexPath.row]
//        delegate?.didSelectImage(with: selectedUrl)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "SelectedImageViewController") as? SelectedImageViewController {
            nextVC.imageURL = selectedUrl
            nextVC.modalPresentationStyle = .fullScreen
            present(nextVC, animated: true, completion: nil)
        }
    }

    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
}
