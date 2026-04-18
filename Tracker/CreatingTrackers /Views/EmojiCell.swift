import UIKit

final class EmojiCell: UICollectionViewCell {
	static let identifier = "EmojiCell"
	
	private let emojiLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 32)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.layer.cornerRadius = 16
		contentView.addSubview(emojiLabel)
		
		NSLayoutConstraint.activate([
			emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) { fatalError() }
	
	func configure(with emoji: String, isSelected: Bool) {
		emojiLabel.text = emoji
		contentView.backgroundColor = isSelected ? UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 1.0) : .clear
	}
}
