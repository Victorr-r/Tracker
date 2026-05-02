import UIKit

// MARK: - UICollectionViewDataSource
extension NewHabitViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 18
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == emojiCollectionView {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
				return UICollectionViewCell()
			}
			let emoji = Resources.emojis[indexPath.row]
			cell.configure(with: emoji, isSelected: emoji == selectedEmoji)
			return cell
		} else {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
				return UICollectionViewCell()
			}
			let color = Resources.colors[indexPath.row]
			cell.configure(with: color, isSelected: color == selectedColor)
			return cell
		}
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryView.identifier, for: indexPath) as? SupplementaryView else {
			return UICollectionReusableView()
		}
		view.titleLabel.text = (collectionView == emojiCollectionView) ? "Emoji" : "Цвет"
		return view
	}
}

// MARK: - UICollectionViewDelegate
extension NewHabitViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == emojiCollectionView {
			let emoji = Resources.emojis[indexPath.row]
			if selectedEmoji == emoji {
				selectedEmoji = nil
			} else {
				selectedEmoji = emoji
			}
			emojiCollectionView.reloadData()
		} else {
			let color = Resources.colors[indexPath.row]
			if selectedColor == color {
				selectedColor = nil
			} else {
				selectedColor = color
			}
			colorCollectionView.reloadData()
		}
		
		textFieldDidChange()
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewHabitViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 52, height: 52)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 20)
	}
}
