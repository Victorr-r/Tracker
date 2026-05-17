import Foundation

final class CategoriesViewModel: NSObject {
	
	private(set) var categories = Observable<[TrackerCategory]>([])
	
	private(set) var selectedCategory = Observable<TrackerCategory?>(nil)
	
	private let trackerCategoryStore: TrackerCategoryStore
	
	init(trackerCategoryStore: TrackerCategoryStore, selectedCategory: TrackerCategory?) {
		self.trackerCategoryStore = trackerCategoryStore
		super.init()
		
		self.trackerCategoryStore.delegate = self
		self.selectedCategory.value = selectedCategory
		loadCategories()
	}
	
	func loadCategories() {
		categories.value = trackerCategoryStore.categories
	}
	
	func selectCategory(at index: Int) {
		let category = categories.value[index]
		selectedCategory.value = category
	}
	
	func addCategory(named name: String) {
		try? trackerCategoryStore.addNewCategory(TrackerCategory(title: name, trackers: []))
	}
	
	func deleteCategory(at index: Int) {
		let categoryToDelete = categories.value[index]
		
		try? trackerCategoryStore.deleteCategory(with: categoryToDelete.title)
		
		if selectedCategory.value?.title == categoryToDelete.title {
			selectedCategory.value = nil
		}
	}
	
}

// MARK: - TrackerCategoryStoreDelegate
extension CategoriesViewModel: TrackerCategoryStoreDelegate {
	func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
		loadCategories()
	}
}


