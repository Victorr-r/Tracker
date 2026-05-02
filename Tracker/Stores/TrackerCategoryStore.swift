import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
	case decodingError
}
protocol TrackerCategoryStoreDelegate: AnyObject {
	func store(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}

struct TrackerCategoryStoreUpdate {
	let insertedIndexes: IndexSet
	let deletedIndexes: IndexSet
}

final class TrackerCategoryStore: NSObject {
	private let context: NSManagedObjectContext
	
	private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
	
	weak var delegate: TrackerCategoryStoreDelegate?
	private var insertedIndexes: IndexSet?
	private var deletedIndexes: IndexSet?
	
	convenience override init() {
		let context = TrackerStore.shared.context
		self.init(context: context)
	}
	
	init(context: NSManagedObjectContext) {
		self.context = context
		super.init()
		
		let fetchRequest = TrackerCategoryCoreData.fetchRequest()
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
		]
		
		let controller = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		controller.delegate = self
		self.fetchedResultsController = controller
		
		try? controller.performFetch()
	}
	
	func makeCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
		guard let title = categoryCoreData.title else {
			throw TrackerCategoryStoreError.decodingError
		}
		
		let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
		let trackers = trackersCoreData.compactMap { try? TrackerStore.shared.tracker(from: $0) }
		
		return TrackerCategory(title: title, trackers: trackers)
	}
}

// MARK: - NSFetchedResultsControllerDelegate (Реализация слежки)
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexes = IndexSet()
		deletedIndexes = IndexSet()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.store(self, didUpdate: TrackerCategoryStoreUpdate(
			insertedIndexes: insertedIndexes ?? IndexSet(),
			deletedIndexes: deletedIndexes ?? IndexSet()
		))
		insertedIndexes = nil
		deletedIndexes = nil
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			if let indexPath = newIndexPath { insertedIndexes?.insert(indexPath.item) }
		case .delete:
			if let indexPath = indexPath { deletedIndexes?.insert(indexPath.item) }
		default: break
		}
	}
}
