import UIKit

final class StatisticCell: UITableViewCell {
	
	static let identifier = "TrackerCell"
	
	// MARK: - UI Elements
	private let containerView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 16
		view.clipsToBounds = true
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let valueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.textColor = UIColor(named: "YP Black") ?? .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = UIColor(named: "YP Black") ?? .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let gradientLayer = CAGradientLayer()
	private let maskLayer = CAShapeLayer()
	
	// MARK: - Init
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none
		
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Главное исправление: Отрисовка в draw(_:)
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		gradientLayer.frame = containerView.bounds
		
		gradientLayer.colors = [
			UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1.0).cgColor,
			UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1.0).cgColor,
			UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1.0).cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		
		let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 16)
		maskLayer.path = path.cgPath
		maskLayer.fillColor = nil
		maskLayer.strokeColor = UIColor.black.cgColor
		maskLayer.lineWidth = 1
		
		gradientLayer.mask = maskLayer
		
		if gradientLayer.superlayer == nil {
			containerView.layer.insertSublayer(gradientLayer, at: 0)
		}
	}
	
	// MARK: - Configuration
	func configure(value: String, title: String) {
		valueLabel.text = value
		titleLabel.text = title
		setNeedsDisplay()
	}
	
	// MARK: - Setup UI
	private func setupViews() {
		contentView.addSubview(containerView)
		containerView.addSubview(valueLabel)
		containerView.addSubview(titleLabel)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
			valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
			valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
			valueLabel.heightAnchor.constraint(equalToConstant: 41),
			
			titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
			titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
			titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
		])
	}
}
