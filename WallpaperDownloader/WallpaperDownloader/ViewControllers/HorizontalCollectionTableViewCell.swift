import UIKit

protocol HorizontalCollectionTableViewCellDelegate: AnyObject {
    func didSelectImage(with url: String)
    func didTapSeeAllButton(with images: [String])
}

class HorizontalCollectionTableViewCell: UITableViewCell {

    weak var delegate: HorizontalCollectionTableViewCellDelegate?

    @IBOutlet weak var collectionView: UICollectionView!

    var images: [String] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }

    func configure(with images: [String]) {
        self.images = images
        collectionView.reloadData()
    }
}

extension HorizontalCollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Always return 5: 4 images + 1 banana cell
        return min(images.count, 4) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell

        if indexPath.row == 4 || indexPath.row >= images.count {
            // Banana image cell
            cell.imageView.image = UIImage(named: "more_arrow")
            cell.imageView.contentMode = .scaleAspectFit
        } else {
            let imageUrlString = images[indexPath.row]
            cell.imageView.image = nil
            if let imageUrl = URL(string: imageUrlString) {
                cell.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
            }
            cell.imageView.contentMode = .scaleAspectFill
        }

        cell.imageView.clipsToBounds = true
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 4 || indexPath.row >= images.count {
            delegate?.didTapSeeAllButton(with: images)
        } else {
            let selectedUrl = images[indexPath.row]
            delegate?.didSelectImage(with: selectedUrl)
        }
    }
}
