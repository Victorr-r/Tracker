import UIKit

final class SupplementaryView: UICollectionReusableView {
	static let identifier = "SupplementaryView"
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 19, weight: .bold)
		label.textColor = .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	required init?(coder: NSCoder) { fatalError() }
}
