import UIKit

extension UIColor {
	convenience init(hex: String) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		if hexSanitized.hasPrefix("#") { hexSanitized.remove(at: hexSanitized.startIndex) }
		
		var rgbValue: UInt64 = 0
		Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
		
		self.init(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: 1.0
		)
	}
}
