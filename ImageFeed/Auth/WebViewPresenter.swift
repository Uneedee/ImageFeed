import Foundation

// MARK: - Protocol

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
}

// MARK: - WebViewPresenter

final class WebViewPresenter: WebViewPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: - Initializer
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0)
        
    }
    
    // MARK: - Logic
    
    func didUpdateProgressValue(_ newValue: Double) {
            let newProgressValue = Float(newValue)
            view?.setProgressValue(newProgressValue)
            
            let shouldHideProgress = shouldHideProgress(for: newProgressValue)
            view?.setProgressHidden(shouldHideProgress)
        }
        
        func shouldHideProgress(for value: Float) -> Bool {
            abs(value - 1.0) <= 0.0001
        }
    
    
    

}
