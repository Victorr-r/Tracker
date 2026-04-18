import UIKit

final class TrackerHeader: UICollectionReusableView {
	
	// MARK: - Static Properties
	static let identifier = "TrackerHeader"
	
	// MARK: - UI Elements
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 19, weight: .bold)
		label.textColor = UIColor(named: "YP Black") ?? .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Setup Methods
	private func setupViews() {
		addSubview(titleLabel)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
		])
	}
}
