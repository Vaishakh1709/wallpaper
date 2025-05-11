import UIKit
import SDWebImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HorizontalCollectionTableViewCellDelegate, ViewAllImageCollectionViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    let images = [
        "https://images.pexels.com/photos/1212487/pexels-photo-1212487.jpeg",
        "https://images.pexels.com/photos/1535162/pexels-photo-1535162.jpeg",
        "https://images.pexels.com/photos/19822276/pexels-photo-19822276/free-photo-of-view-on-the-moon-through-the-tree.jpeg",
        "https://images.pexels.com/photos/31033287/pexels-photo-31033287/free-photo-of-vibrant-autumn-maple-tree-in-japanese-park.png","https://images.pexels.com/photos/5339610/pexels-photo-5339610.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load","https://images.pexels.com/photos/12342080/pexels-photo-12342080.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2","https://images.pexels.com/photos/2293372/pexels-photo-2293372.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    ]

    let numberOfRows = 5  // Number of horizontal rows you want to show

    
    override func viewDidLoad() {
            super.viewDidLoad()

            tableView.delegate = self
            tableView.dataSource = self

            tableView.register(UINib(nibName: "HorizontalCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "HorizontalCollectionTableViewCell")
            tableView.rowHeight = 220
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return images.count + 2
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalCollectionTableViewCell", for: indexPath) as! HorizontalCollectionTableViewCell
        cell.delegate = self
        cell.configure(with: images)  // Pass all images to each row
        return cell
    }
    
    
    
    func didSelectImage(with url: String) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nextVC = storyboard.instantiateViewController(withIdentifier: "SelectedImageViewController") as? SelectedImageViewController {
                nextVC.imageURL = url
                nextVC.modalPresentationStyle = .fullScreen
                present(nextVC, animated: true, completion: nil)
            }
        }

    func didTapSeeAllButton(with images: [String]) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let allImagesVC = storyboard.instantiateViewController(withIdentifier: "ViewAllImageCollectionViewController") as? ViewAllImageCollectionViewController {
            allImagesVC.imageURLs = images
            allImagesVC.delegate = self
            allImagesVC.modalPresentationStyle = .fullScreen
            present(allImagesVC, animated: true, completion: nil)
        }
    }

    }
