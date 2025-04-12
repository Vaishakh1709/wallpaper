import UIKit
import SDWebImage
import Photos


class SelectedImageViewController: UIViewController {
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    var imageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadButton.layer.cornerRadius = 10
        
        if let urlString = imageURL, let url = URL(string: urlString) {
            selectedImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func downloadImageButtonAction(_ sender: Any) {
        guard let urlString = imageURL, let url = URL(string: urlString) else {
                    showAlert(title: "Error", message: "Invalid image URL")
                    return
                }
                
                // Show loading indicator
                let activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.center = view.center
                activityIndicator.startAnimating()
                view.addSubview(activityIndicator)
                
                // Download image using URLSession
                URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                    // Execute UI updates on main thread
                    DispatchQueue.main.async {
                        activityIndicator.removeFromSuperview()
                        
                        if let error = error {
                            self?.showAlert(title: "Download Failed", message: error.localizedDescription)
                            return
                        }
                        
                        guard let data = data, let image = UIImage(data: data) else {
                            self?.showAlert(title: "Error", message: "Could not create image from data")
                            return
                        }
                        
                        // Save image to photo library
                        self?.saveImageToPhotoLibrary(image)
                    }
                }.resume()
            }
            
            private func saveImageToPhotoLibrary(_ image: UIImage) {
                // Request permission to access photo library
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    switch status {
                    case .authorized:
                        // Save image
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    default:
                        DispatchQueue.main.async {
                            self?.showAlert(title: "Permission Denied", message: "Please allow access to your photo library in Settings to save images.")
                        }
                    }
                }
            }
            
            @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
                if let error = error {
                    showAlert(title: "Save Error", message: error.localizedDescription)
                } else {
                    showAlert(title: "Saved", message: "Image was saved to your photo library successfully")
                }
            }
            
            private func showAlert(title: String, message: String) {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
    

    }
    

