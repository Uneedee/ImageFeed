@testable import ImageFeed
import UIKit

final class imagesListServiceSpy: ImagesListServiceProtocol {
    
    var photos = [Photo]()
    
    func fetchPhotosNextPage() {
        photos.append(photos1)
        photos.append(photos2)
    }
    
    func changeLike(photoId: String, _ completion: @escaping (Result<Void, any Error>) -> Void) {

    }
    
   var photos1 = Photo(id: "1", size: .init(width: 100, height: 100), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
    var photos2 = Photo(id: "2", size: .init(width: 200, height: 200), createdAt: nil, welcomeDescription: nil, thumbImageURL: "", largeImageURL: "", isLiked: false)
}
