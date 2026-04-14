import UIKit

protocol TrackerCellDelegate: AnyObject {
	func completeTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
	static let identifier = "TrackerCell"
	weak var delegate: TrackerCellDelegate?
	private var trackerId: UUID?
	private var indexPath: IndexPath?
	
	// MARK: - UI Elements
	private let cardImageView: UIImageView = {
			let imageView = UIImageView()
			imageView.image = UIImage(named: "Card Tracker")
			imageView.contentMode = .scaleAspectFill
			imageView.layer.cornerRadius = 16
			imageView.layer.masksToBounds = true
			imageView.translatesAutoresizingMaskIntoConstraints = false
			return imageView
		}()
	
	private let emojiLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = .white.withAlphaComponent(0.3)
		label.layer.cornerRadius = 12
		label.layer.masksToBounds = true
		label.textAlignment = .center
		label.font = .systemFont(ofSize: 12)
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
		
		   titleLabel.text = nil
		   emojiLabel.isHidden = true
		   daysLabel.text = formatDays(completedDays)
		   
		   cardImageView.image = UIImage(named: "Card Tracker")
		   
		   if isCompleted {
				  doneButton.setImage(UIImage(named: "Ok Tracker"), for: .normal)
				  doneButton.alpha = 0.3
			  } else {
				  doneButton.setImage(UIImage(named: "Plus Tracker"), for: .normal)
				  doneButton.alpha = 1.0
			  }
	   }
	
	private func formatDays(_ count: Int) -> String {
		let remainder10 = count % 10
		let remainder100 = count % 100
		if remainder10 == 1 && remainder100 != 11 {
			return "\(count) день"
		} else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
			return "\(count) дня"
		} else {
			return "\(count) дней"
		}
	}
	
	@objc private func didTapDoneButton() {
		guard let id = trackerId, let indexPath = indexPath else { return }
		   delegate?.completeTracker(id: id, at: indexPath)
	   }
	
	// MARK: - Setup
	private func setupViews() {
		contentView.addSubview(cardImageView)
		   cardImageView.addSubview(emojiLabel)
		   cardImageView.addSubview(titleLabel)
		contentView.addSubview(daysLabel)
		contentView.addSubview(doneButton)
	}
	
	private func setupConstraints() {
		NSLayoutConstraint.activate([
			cardImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
			   cardImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			   cardImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			   cardImageView.heightAnchor.constraint(equalToConstant: 90),
			
			emojiLabel.topAnchor.constraint(equalTo: cardImageView.topAnchor, constant: 12),
			emojiLabel.leadingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: 12),
			emojiLabel.widthAnchor.constraint(equalToConstant: 24),
			emojiLabel.heightAnchor.constraint(equalToConstant: 24),
			
			titleLabel.leadingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: 12),
			titleLabel.trailingAnchor.constraint(equalTo: cardImageView.trailingAnchor, constant: -12),
			titleLabel.bottomAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: -12),
			
			
			doneButton.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 8),
				  doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
				  doneButton.widthAnchor.constraint(equalToConstant: 34),
				  doneButton.heightAnchor.constraint(equalToConstant: 34),
				  
				  daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
				  daysLabel.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor)
			  ])
	}
}
