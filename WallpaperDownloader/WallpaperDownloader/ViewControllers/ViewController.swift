import UIKit
import SDWebImage

// Updated for 2025 Hugging Face Inference Providers
private let hfToken = ""

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HorizontalCollectionTableViewCellDelegate, ViewAllImageCollectionViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var aiPromt: UITextField!
    @IBOutlet weak var generateButton: UIButton!
    
    private var activityIndicator: UIActivityIndicatorView!
    private var currentGenerationTask: URLSessionDataTask?
    
    let images = [
        "https://images.pexels.com/photos/1212487/pexels-photo-1212487.jpeg",
        "https://images.pexels.com/photos/1535162/pexels-photo-1535162.jpeg",
        "https://images.pexels.com/photos/19822276/pexels-photo-19822276/free-photo-of-view-on-the-moon-through-the-tree.jpeg",
        "https://images.pexels.com/photos/31033287/pexels-photo-31033287/free-photo-of-vibrant-autumn-maple-tree-in-japanese-park.png",
        "https://images.pexels.com/photos/5339610/pexels-photo-5339610.jpeg?auto=compress&cs=tinysrgb&w=1200&lazy=load",
        "https://images.pexels.com/photos/12342080/pexels-photo-12342080.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "https://images.pexels.com/photos/2293372/pexels-photo-2293372.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
        "https://images.pexels.com/photos/16873765/pexels-photo-16873765/free-photo-of-close-up-of-a-dandelion.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
    ]

    let numberOfRows = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        // Setup activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        aiPromt.placeholder = "Enter your image description..."
        aiPromt.borderStyle = .roundedRect
        aiPromt.returnKeyType = .done
        aiPromt.delegate = self
        
        if generateButton != nil {
            generateButton.layer.cornerRadius = 8
            generateButton.backgroundColor = UIColor.systemBlue
            generateButton.setTitleColor(.white, for: .normal)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "HorizontalCollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "HorizontalCollectionTableViewCell")
        tableView.rowHeight = 220
    }

    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalCollectionTableViewCell", for: indexPath) as! HorizontalCollectionTableViewCell
        cell.delegate = self
        cell.configure(with: images)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    // MARK: - Delegate Methods
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

    @IBAction func generateButtonAction(_ sender: Any) {
        guard let promptText = aiPromt.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !promptText.isEmpty else {
            showAlert(title: "Error", message: "Please enter a description for the image")
            return
        }
        
        guard promptText.count <= 1000 else {
            showAlert(title: "Error", message: "Description too long. Please keep it under 1000 characters.")
            return
        }
        
        if currentGenerationTask != nil {
            cancelGeneration()
            return
        }
        
        generateImage(prompt: promptText)
    }
    
    private func generateImage(prompt: String) {
        // Working models
        let workingModels = [
            ("black-forest-labs/FLUX.1-schnell", "fal"),
            ("stabilityai/stable-diffusion-xl-base-1.0", "hf-inference"),
            ("stabilityai/stable-diffusion-3.5-large", "fal"),
            ("runwayml/stable-diffusion-v1-5", "hf-inference")
        ]
        
        tryGenerateWithModels(prompt: prompt, models: workingModels, currentIndex: 0)
    }
    
    private func tryGenerateWithModels(prompt: String, models: [(String, String)], currentIndex: Int) {
        guard currentIndex < models.count else {
            setLoadingState(false)
            showAlert(title: "Service Unavailable", message: "AI image generation service is currently unavailable. Please try again later.")
            return
        }
        
        setLoadingState(true)
        
        let (modelName, provider) = models[currentIndex]
        let urlString: String
        
        // Different URLs for different providers
        switch provider {
        case "fal":
            urlString = "https://router.huggingface.co/fal/text-to-image"
        case "hf-inference":
            urlString = "https://api-inference.huggingface.co/models/\(modelName)"
        default:
            urlString = "https://router.huggingface.co/\(provider)/text-to-image"
        }
        
        guard let url = URL(string: urlString) else {
            tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(huggingFaceToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60.0
        
        // Different request bodies for different providers
        let requestBody: [String: Any]
        
        if provider == "fal" {
            requestBody = [
                "model": modelName,
                "prompt": prompt,
                "num_inference_steps": 4,
                "guidance_scale": 1.0,
                "width": 512,
                "height": 512
            ]
        } else {
            // HF Inference format
            requestBody = [
                "inputs": prompt,
                "options": [
                    "wait_for_model": true,
                    "use_cache": false
                ]
            ]
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
            return
        }
        
        print("Trying: \(modelName) with provider: \(provider)")
        
        currentGenerationTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.currentGenerationTask = nil
                
                if let error = error as NSError?, error.code == NSURLErrorCancelled {
                    return
                }
                
                if let error = error {
                    print("Error with \(modelName): \(error.localizedDescription)")
                    self?.tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
                    return
                }
                
                print("Response code for \(modelName): \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                case 200:
                    self?.setLoadingState(false)
                    if provider == "fal" {
                        self?.handleFalResponse(data: data, prompt: prompt)
                    } else {
                        self?.handleHFResponse(data: data, prompt: prompt)
                    }
                    
                case 503:
                    print("Model \(modelName) loading, waiting...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                        self?.tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex)
                    }
                    
                case 429:
                    print("Rate limited, trying next model")
                    self?.tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
                    
                default:
                    print("Failed with status: \(httpResponse.statusCode)")
                    self?.tryGenerateWithModels(prompt: prompt, models: models, currentIndex: currentIndex + 1)
                }
            }
        }
        
        currentGenerationTask?.resume()
    }
    
    private func handleFalResponse(data: Data?, prompt: String) {
        guard let data = data else {
            showAlert(title: "Error", message: "No data received")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let images = json["images"] as? [[String: Any]],
                   let firstImage = images.first,
                   let imageUrl = firstImage["url"] as? String {
                    // Download the image from URL
                    downloadAndPresentImage(from: imageUrl)
                    return
                }
                
                if let error = json["error"] as? String {
                    showAlert(title: "API Error", message: error)
                    return
                }
            }
        } catch {
            print("Failed to parse FAL response: \(error)")
        }
        
        showAlert(title: "Error", message: "Failed to parse response")
    }
    
    private func handleHFResponse(data: Data?, prompt: String) {
        guard let data = data, !data.isEmpty else {
            showAlert(title: "Error", message: "No image data received")
            return
        }
        
        // Check if response contains JSON error
        if let jsonString = String(data: data, encoding: .utf8),
           jsonString.contains("error") || jsonString.contains("loading") {
            print("API returned: \(jsonString)")
            showAlert(title: "Model Loading", message: "The AI model is loading. Please try again in a few seconds.")
            return
        }
        
        // Verify it's valid image data
        guard UIImage(data: data) != nil else {
            showAlert(title: "Error", message: "Failed to create image from received data")
            return
        }
        
        // Success!
        aiPromt.text = ""
        presentGeneratedImage(data: data)
    }
    
    private func downloadAndPresentImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "Error", message: "Invalid image URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to download image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, UIImage(data: data) != nil else {
                    self?.showAlert(title: "Error", message: "Invalid image data")
                    return
                }
                
                self?.aiPromt.text = ""
                self?.presentGeneratedImage(data: data)
            }
        }.resume()
    }
    
    private func presentGeneratedImage(data: Data) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let nextVC = storyboard.instantiateViewController(withIdentifier: "SelectedImageViewController") as? SelectedImageViewController {
            nextVC.imageData = data
            nextVC.modalPresentationStyle = .fullScreen
            present(nextVC, animated: true, completion: nil)
        }
    }
    
    private func cancelGeneration() {
        currentGenerationTask?.cancel()
        currentGenerationTask = nil
        setLoadingState(false)
    }
    
    private func setLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
            generateButton?.setTitle("Cancel", for: .normal)
            generateButton?.backgroundColor = UIColor.systemRed
            aiPromt.isUserInteractionEnabled = false
            tableView.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            generateButton?.setTitle("Generate", for: .normal)
            generateButton?.backgroundColor = UIColor.systemBlue
            aiPromt.isUserInteractionEnabled = true
            tableView.isUserInteractionEnabled = true
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == aiPromt {
            generateButtonAction(textField)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 1000
    }
}
