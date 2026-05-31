import UIKit

final class StatisticCell: UITableViewCell {
	
	static let identifier = "StatisticCell"
	
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
		setupGradient()
	}
	
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Lifecycle
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if containerView.bounds.width == 0 {
			containerView.layoutIfNeeded()
		}
		
		gradientLayer.frame = containerView.bounds
		
		let halfWidth: CGFloat = 1.0 / 2.0
		let insetBounds = containerView.bounds.insetBy(dx: halfWidth, dy: halfWidth)
		let path = UIBezierPath(roundedRect: insetBounds, cornerRadius: 16 - halfWidth)
		
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		maskLayer.path = path.cgPath
		CATransaction.commit()
	}
	
	// MARK: - Setup Gradient
	private func setupGradient() {
		gradientLayer.colors = [
			UIColor(red: 0/255, green: 123/255, blue: 250/255, alpha: 1.0).cgColor,
			UIColor(red: 70/255, green: 230/255, blue: 157/255, alpha: 1.0).cgColor,
			UIColor(red: 253/255, green: 76/255, blue: 73/255, alpha: 1.0).cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
		
		// Настройка маски-обводки
		maskLayer.fillColor = UIColor.clear.cgColor // Внутри рамки ничего не красим
		maskLayer.strokeColor = UIColor.black.cgColor // Цвет линии (любой непрозрачный, он просто открывает видимость градиенту)
		maskLayer.lineWidth = 1.0 // Фиксированная толщина рамки по ТЗ
		
		// Применяем маску и добавляем слой в контейнер
		gradientLayer.mask = maskLayer
		containerView.layer.insertSublayer(gradientLayer, at: 0)
	}
	
	// MARK: - Configuration
	func configure(value: String, title: String) {
		valueLabel.text = value
		titleLabel.text = title
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
