import Foundation

@objc(DaysValueTransformer)
final class DaysValueTransformer: NSSecureUnarchiveFromDataTransformer {
	
	override static var allowedTopLevelClasses: [AnyClass] {
		return [NSArray.self, NSNumber.self, NSString.self]
	}
	
	static func register() {
		let transformer = DaysValueTransformer()
		ValueTransformer.setValueTransformer(
			transformer,
			forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
		)
	}
}
