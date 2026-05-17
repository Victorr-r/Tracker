import UIKit

final class OnboardingPageViewController: UIViewController {
	
	// MARK: - Properties
	private let imageName: String
	private let titleText: String
	
	// MARK: - UI Elements
	private let backgroundImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Init
	init(imageName: String, titleText: String) {
		self.imageName = imageName
		self.titleText = titleText
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		backgroundImageView.image = UIImage(named: imageName)
		titleLabel.text = titleText
		setupLayout()
	}
	
	// MARK: - Layout
	private func setupLayout() {
		view.addSubview(backgroundImageView)
		view.addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			
			titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
			
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
	}
}
