import UIKit

enum TrackerColors {
	static var mainBackground: UIColor {
		return .systemBackground
	}
	
	static var mainText: UIColor {
		return .label
	}
	
	static var placeholderText: UIColor {
		return UIColor { traitCollection in
			switch traitCollection.userInterfaceStyle {
			case .dark:
				return .white
			default:
				return .black
			}
		}
	}
	
	static var searchBackground: UIColor {
		return .systemGroupedBackground
	}
	static var searchFieldBackground: UIColor {
		return UIColor { traitCollection in
			switch traitCollection.userInterfaceStyle {
			case .dark:
				return UIColor.white.withAlphaComponent(0.12)
			default:
				return UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
			}
		}
	}
}
