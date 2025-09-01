import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    var fullImageUrl: String?
    var image: UIImage?
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        loadFullImage()

    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    private func loadFullImage() {
        guard let fullImageUrl = fullImageUrl,
        let imageURL = URL(string: fullImageUrl)
        else { showError()
            return }
        
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: imageURL) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                self.image = imageResult.image
            case .failure:
                self.showError()
            }
        }
    }
    
    
    private func showError() {
        let alertController = UIAlertController(
            title: "Что-то пошло не так." ,
            message: " Попробовать ещё раз?",
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: "Не надо",
            style: .default)
        let alertActionTryAgain = UIAlertAction(
            title: "Попробовать снова",
            style: .default) { [weak self] _ in
                self?.loadFullImage()
            }
        
        
        alertController.addAction(alertAction)
        alertController.addAction(alertActionTryAgain)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { print("imageView is nil")
            return }
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(share, animated: true, completion: nil)
    }
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
        
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        if imageSize.width <= 0 || imageSize.height <= 0 { return }
        if visibleRectSize.width <= 0 || visibleRectSize.height <= 0 { return }
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(maxZoomScale, min(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}



extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
