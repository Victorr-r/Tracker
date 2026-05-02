import UIKit
import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
	func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate)
}

struct TrackerRecordStoreUpdate {
	let insertedIndexes: IndexSet
	let deletedIndexes: IndexSet
}

final class TrackerRecordStore: NSObject {
	private let context: NSManagedObjectContext
	private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
	
	weak var delegate: TrackerRecordStoreDelegate?
	private var insertedIndexes: IndexSet?
	private var deletedIndexes: IndexSet?
	
	convenience override init() {
		let context = TrackerStore.shared.context
		self.init(context: context)
	}
	
	init(context: NSManagedObjectContext) {
		self.context = context
		super.init()
		
		let fetchRequest = TrackerRecordCoreData.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: false)]
		
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
	
	var records: [TrackerRecord] {
		guard let objects = fetchedResultsController.fetchedObjects else { return [] }
		return objects.compactMap { object in
			guard let id = object.id, let date = object.date else { return nil }
			return TrackerRecord(id: id, date: date)
		}
	}
	
	func add(_ record: TrackerRecord) throws {
		let request = TrackerCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", record.id as CVarArg)
		
		guard let trackerCoreData = (try? context.fetch(request))?.first else {
			print("❌ Ошибка: Трекер с ID \(record.id) не найден")
			return
		}
		
		let recordCoreData = TrackerRecordCoreData(context: context)
		recordCoreData.id = record.id
		recordCoreData.date = record.date
		recordCoreData.tracker = trackerCoreData
		
		try context.save()
	}
	
	func remove(_ record: TrackerRecord) throws {
		let request = TrackerRecordCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@ AND date == %@",
										record.id as CVarArg,
										record.date as NSDate)
		
		if let recordToDelete = (try? context.fetch(request))?.first {
			context.delete(recordToDelete)
			try context.save()
		}
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexes = IndexSet()
		deletedIndexes = IndexSet()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.store(self, didUpdate: TrackerRecordStoreUpdate(
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
