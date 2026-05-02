import UIKit

struct Resources {
	static let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "☀️"]
	static let colors: [UIColor] = [
		"#FD4C49", "#FFAD17", "#33CF82", "#007BFA", "#5084F4", "#832CF1",
		"#F6C48B", "#B872FF", "#E662E1", "#AD56DA", "#FF99CC", "#F9D4D4",
		"#ADCBFF", "#869AFF", "#46E69D", "#35347C", "#D085FF", "#89A067"
	].map { UIColor(hex: $0) }
}
