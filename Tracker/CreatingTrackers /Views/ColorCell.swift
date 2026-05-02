import UIKit

final class ColorCell: UICollectionViewCell {
	
	// MARK: - Public
	
	static let identifier = "ColorCell"
	
	// MARK: - Private UI
	
	private let colorView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 8
		view.layer.masksToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// MARK: - Init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	// MARK: - Functions
	
	func configure(with color: UIColor, isSelected: Bool) {
		colorView.backgroundColor = color
		contentView.layer.borderColor = isSelected
		? color.withAlphaComponent(0.3).cgColor
		: UIColor.clear.cgColor
	}
	
	
	// MARK: - Private Setup
	
	private func setupView() {
		contentView.addSubview(colorView)
		contentView.layer.cornerRadius = 8
		contentView.layer.borderWidth = 3
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			colorView.widthAnchor.constraint(equalToConstant: 40),
			colorView.heightAnchor.constraint(equalToConstant: 40)
		])
	}
}
