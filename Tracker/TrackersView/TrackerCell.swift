import UIKit

// MARK: - TrackerCellDelegate
protocol TrackerCellDelegate: AnyObject {
	func completeTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
	
	// MARK: - Static Properties
	static let identifier = "TrackerCell"
	
	// MARK: - Properties
	weak var delegate: TrackerCellDelegate?
	private var trackerId: UUID?
	private var indexPath: IndexPath?
	
	// MARK: - UI Elements
	private let cardView: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 16
		view.layer.masksToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let emojiLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white.withAlphaComponent(0.3)
		label.layer.cornerRadius = 12
		label.layer.masksToBounds = true
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 16)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let daysLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = UIColor(named: "YP Black") ?? .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var doneButton: UIButton = {
		let button = UIButton(type: .custom)
		button.layer.cornerRadius = 17
		button.tintColor = .white
		button.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupViews()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Configuration
	func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int, indexPath: IndexPath) {
		self.trackerId = tracker.id
		self.indexPath = indexPath
		
		titleLabel.text = tracker.name
		emojiLabel.text = tracker.emoji
		cardView.backgroundColor = tracker.color
		doneButton.tintColor = UIColor(named: "YP White") ?? .systemBackground
		doneButton.backgroundColor = tracker.color
		
		updateCompletion(isCompleted: isCompleted, completedDays: completedDays)
	}
	
	// MARK: - Update Logic
	func updateCompletion(isCompleted: Bool, completedDays: Int) {
		daysLabel.text = formatDays(completedDays)
		
		let imageName = isCompleted ? "Ok Tracker" : "Plus Tracker"
		let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
		
		doneButton.setImage(image, for: .normal)
		doneButton.alpha = isCompleted ? 0.3 : 1.0
	}
	
	// MARK: - Logic
	private func formatDays(_ count: Int) -> String {
			let formatString = NSLocalizedString("numberOfDays", comment: "Счетчик количества дней выполнения трекера")
			
			return String.localizedStringWithFormat(formatString, count)
		}
	
	@objc private func didTapDoneButton() {
		guard let id = trackerId, let indexPath = indexPath else { return }
		delegate?.completeTracker(id: id, at: indexPath)
	}
	
	// MARK: - Layout
	private func setupViews() {
		contentView.addSubview(cardView)
		cardView.addSubview(emojiLabel)
		cardView.addSubview(titleLabel)
		contentView.addSubview(daysLabel)
		contentView.addSubview(doneButton)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			cardView.heightAnchor.constraint(equalToConstant: 90),
			
			emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
			emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
			emojiLabel.widthAnchor.constraint(equalToConstant: 24),
			emojiLabel.heightAnchor.constraint(equalToConstant: 24),
			
			titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
			titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
			titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
			
			doneButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
			doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
			doneButton.widthAnchor.constraint(equalToConstant: 34),
			doneButton.heightAnchor.constraint(equalToConstant: 34),
			
			daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
			daysLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
		])
	}
}
