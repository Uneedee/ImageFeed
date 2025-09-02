import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var logoutButton: UIButton!
    private var animationLayers = Set<CALayer>()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        view.backgroundColor = .ypBlack
        guard let profile = ProfileService.shared.profile else { return }
        updateProfileDetails(with: profile)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
        addGradientToProfileImage()
        addGradientToAllLabels(labelName: nameLabel, size: CGSize(width: 223, height: 18))
        addGradientToAllLabels(labelName: loginNameLabel, size: CGSize(width: 89, height: 18))
        addGradientToAllLabels(labelName: descriptionLabel, size: CGSize(width: 67, height: 18))
        
        
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
                
                
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(named: "tab_profile_noactive"),
                                    options: [.processor(processor),
                                              .scaleFactor(UIScreen.main.scale)])
        DispatchQueue.main.async {
            self.removeGradientAnimation()
        }
        
        
    }
    
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не задано" : profile.name
        loginNameLabel.text = profile.loginName.isEmpty ? "Логин не задан" : profile.loginName
        descriptionLabel.text = profile.bio?.isEmpty == false ? profile.bio : ""
        
        
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        removeGradientAnimation()
    }
    
    private func addGradientToAllLabels(labelName: UILabel, size: CGSize) {
        let gradient = CAGradientLayer()
        
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 9
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        labelName.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "addGradientToAllLabels")
        
    }
    
    private func addGradientToProfileImage() {
        let gradient = CAGradientLayer()
        
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 35
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        avatarImageView.layer.addSublayer(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradient.add(gradientChangeAnimation, forKey: "addGradientToProfileImage")
        
    }
    
    private func removeGradientAnimation() {
        for layer in animationLayers {
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    private func setupAvatarImageView () {
        let profileImage = UIImage(named: "Userpick")
        avatarImageView = UIImageView(image: profileImage)
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.layer.masksToBounds = true
        avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
    }
    
    private func setupNameLabel() {
        nameLabel = UILabel()
        nameLabel.text = ""
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = .ypWhite
        nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }
    
    
    private func setupLoginNameLabel() {
        loginNameLabel = UILabel()
        loginNameLabel.text = ""
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.font = .systemFont(ofSize: 13)
        loginNameLabel.textColor = .ypGray
        loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        loginNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.text = ""
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true }
    
    private func setupLogoutButton() {
        guard let buttonImage = UIImage(named: "ExitButton") else { return }
        logoutButton = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(self.didTapLogoutButton))
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor).isActive = true
        logoutButton.tintColor = .ypRed
    }
    
    @objc func didTapLogoutButton() {
        let alertController = UIAlertController(
            title: "Пока, пока!" ,
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert)
        
        let alertActionNo = UIAlertAction(
            title: "Нет",
            style: .default)
        let alertActionYes = UIAlertAction(
            title: "Да",
            style: .default) { _ in
                ProfileLogoutService.shared.logout()
            }
        
        
        alertController.addAction(alertActionYes)
        alertController.addAction(alertActionNo)
        present(alertController, animated: true, completion: nil)

    }
    
    func clearData() {
        avatarImageView.image = nil
        nameLabel.text = ""
        loginNameLabel.text = ""
        descriptionLabel.text = ""
        animationLayers.removeAll()
    }
    
}

