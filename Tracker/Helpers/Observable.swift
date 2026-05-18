import Foundation

typealias Binding<T> = (T) -> Void

final class Observable<T> {
	var value: T {
		didSet {
			onChange?(value)
		}
	}
	
	private var onChange: Binding<T>?
	
	init(_ value: T) {
		self.value = value
	}
	
	func bind(action: @escaping Binding<T>) {
		self.onChange = action
	}
}
