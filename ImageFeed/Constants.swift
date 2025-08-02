import UIKit

enum Constants {
    static let accessKey = "LOjCa6PZ0yOH3Zcha8aNYfu1CYDqUBeULQpHFmIJ3z0"
    static let secretKey = "ebw-B1m7a_q-5zxpctp5ZMQd2ll0TlgLhrkm8-c_yec"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
}

enum AuthConstants {
    static let authForFetchTokenURLString = "https://unsplash.com/oauth/token"
}

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

enum ProfileImageConstants {
    static let unsplashFetchProfileImageURLString = "https://api.unsplash.com/users/"
}

enum ProfileConstants {
    static let unsplashFetchProfileURLString = "https://api.unsplash.com/me"
}

enum ImageListUrl {
    // Поработать с именами
    static let unsplashFetchRequestMakeImageList = "https://api.unsplash.com/photos"
}
