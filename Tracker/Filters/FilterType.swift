import Foundation

enum FilterType: String, CaseIterable {
	case all = "Все трекеры"
	case today = "Трекеры на сегодня"
	case completed = "Завершённые"
	case uncompleted = "Незавершённые"
}
