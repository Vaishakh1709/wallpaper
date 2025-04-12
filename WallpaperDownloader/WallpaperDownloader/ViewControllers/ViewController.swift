import UIKit
import SDWebImage

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let images = ["https://images.pexels.com/photos/1212487/pexels-photo-1212487.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2","https://images.pexels.com/photos/1535162/pexels-photo-1535162.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2","https://images.pexels.com/photos/19822276/pexels-photo-19822276/free-photo-of-view-on-the-moon-through-the-tree.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2","https://images.pexels.com/photos/31033287/pexels-photo-31033287/free-photo-of-vibrant-autumn-maple-tree-in-japanese-park.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            
            // Set up a flow layout if not set in storyboard
//            let flowLayout = UICollectionViewFlowLayout()
//            flowLayout.itemSize = CGSize(width: 200, height: 200)
//            flowLayout.minimumLineSpacing = 10
//            flowLayout.scrollDirection = .horizontal
//            flowLayout.minimumInteritemSpacing = 10
//            imageCollectionView.collectionViewLayout = flowLayout
            
            // Force layout update
            imageCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        // Reset the image view first to avoid showing previous images
        cell.imageView.image = nil
        
        let imageUrlString = images[indexPath.row]
        print("Loading image URL: \(imageUrlString) for cell at index \(indexPath.row)")
        
        if let imageUrl = URL(string: imageUrlString) {
            // Use completion handler to debug image loading
            cell.imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder")) { (image, error, cacheType, url) in
                if let error = error {
                    print("Error loading image at index \(indexPath.row): \(error.localizedDescription)")
                } else if let image = image {
                    print("Successfully loaded image at index \(indexPath.row)")
                }
            }
        } else {
            print("Invalid URL for index \(indexPath.row)")
        }
        
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextViewController = storyboard.instantiateViewController(withIdentifier: "SelectedImageViewController") as? SelectedImageViewController {
            let selectedImageURL = images[indexPath.row]
            nextViewController.imageURL = selectedImageURL
            nextViewController.modalPresentationStyle = .fullScreen
            present(nextViewController, animated: true, completion: nil)
        }
    }
}
