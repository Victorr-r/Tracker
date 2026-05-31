import Foundation
import AppMetricaCore

final class AnalyticsService {
	static let shared = AnalyticsService()
	
	private init() {}
	
	enum EventType: String {
		case open = "open"
		case close = "close"
		case click = "click"
	}
	
	enum ScreenType: String {
		case main = "Main"
	}
	
	enum ItemType: String {
		case addTrack = "add_track"
		case track = "track"
		case filter = "filter"
		case edit = "edit"
		case delete = "delete"
	}
	
	func report(event: EventType, screen: ScreenType, item: ItemType? = nil) {
		var parameters: [AnyHashable: Any] = [
			"event": event.rawValue,
			"screen": screen.rawValue
		]
		
		if event == .click, let item = item {
			parameters["item"] = item.rawValue
		}
		
		AppMetrica.reportEvent(name: event.rawValue, parameters: parameters, onFailure: { error in
			print("❌ AppMetrica Error: \(error.localizedDescription)")
		})
		
		if event == .click, let item = item {
			print("📊 [ANALYTICS] -> event: \"\(event.rawValue)\", screen: \"\(screen.rawValue)\", item: \"\(item.rawValue)\"")
		} else {
			print("📊 [ANALYTICS] -> event: \"\(event.rawValue)\", screen: \"\(screen.rawValue)\"")
		}
	}
}
