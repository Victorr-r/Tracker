import Foundation

enum FilterType: String, CaseIterable {
	case all
	case today
	case completed
	case uncompleted
	
	var title: String {
		switch self {
		case .all:
			return NSLocalizedString("filter.all", comment: "Фильтр: Все трекеры")
		case .today:
			return NSLocalizedString("filter.today", comment: "Фильтр: Трекеры на сегодня")
		case .completed:
			return NSLocalizedString("filter.completed", comment: "Фильтр: Завершенные")
		case .uncompleted:
			return NSLocalizedString("filter.uncompleted", comment: "Фильтр: Незавершенные")
		}
	}
}
