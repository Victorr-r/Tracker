import UIKit

final class TrackerHeader: UICollectionReusableView {
	static let identifier = "TrackerHeader"
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 19, weight: .bold)
		label.textColor = UIColor(named: "YP Black") ?? .black
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(titleLabel)
		
		NSLayoutConstraint.activate([
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
