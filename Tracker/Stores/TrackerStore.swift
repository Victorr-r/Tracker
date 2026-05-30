import UIKit
import CoreData

struct TrackerStoreUpdate {
	let insertedIndexes: IndexSet
	let deletedIndexes: IndexSet
}

protocol TrackerStoreDelegate: AnyObject {
	func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate)
}

enum TrackerStoreError: Error {
	case decodingError
}

final class TrackerStore: NSObject {
	static let shared = TrackerStore()
	
	private let container: NSPersistentContainer
	private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
	
	weak var delegate: TrackerStoreDelegate?
	private var insertedIndexes: IndexSet?
	private var deletedIndexes: IndexSet?
	
	var context: NSManagedObjectContext {
		return container.viewContext
	}
	
	override init() {
		container = NSPersistentContainer(name: "Tracker")
		container.loadPersistentStores { (description, error) in
			if let error = error as NSError? {
				fatalError("Не удалось загрузить Core Data: \(error)")
			}
		}
		super.init()
		
		let fetchRequest = TrackerCoreData.fetchRequest()
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
		
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
	
	func saveContext() {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				fatalError("Ошибка сохранения: \(error)")
			}
		}
	}
	
	func addNewTracker(_ tracker: Tracker, to categoryTitle: String) {
		let trackerCoreData = TrackerCoreData(context: context)
		
		trackerCoreData.id = tracker.id
		trackerCoreData.name = tracker.name
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.color = tracker.color.toHexString()
		trackerCoreData.schedule = tracker.schedule?.map { $0.rawValue } as NSObject?
		
		
		let request = TrackerCategoryCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "title == %@", categoryTitle)
		
		do {
			let categories = try context.fetch(request)
			let categoryCoreData = categories.first ?? TrackerCategoryCoreData(context: context)
			categoryCoreData.title = categoryTitle
			
			trackerCoreData.category = categoryCoreData
			
			try context.save()
			print("✅ Core Data: Трекер успешно сохранен в категорию \(categoryTitle)")
		} catch {
			print("❌ Core Data Error: Не удалось сохранить трекер: \(error)")
		}
	}
	
	func updateTracker(_ updatedTracker: Tracker, to categoryTitle: String) {
		let request = TrackerCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", updatedTracker.id as CVarArg)
		
		do {
			let results = try context.fetch(request)
			guard let trackerCoreData = results.first else {
				print("❌ Core Data: Трекер для обновления не найден")
				return
			}
			
			trackerCoreData.name = updatedTracker.name
			trackerCoreData.emoji = updatedTracker.emoji
			trackerCoreData.color = updatedTracker.color.toHexString()
			trackerCoreData.schedule = updatedTracker.schedule?.map { $0.rawValue } as NSObject?
			
			let categoryRequest = TrackerCategoryCoreData.fetchRequest()
			categoryRequest.predicate = NSPredicate(format: "title == %@", categoryTitle)
			
			let categories = try context.fetch(categoryRequest)
			let categoryCoreData = categories.first ?? TrackerCategoryCoreData(context: context)
			categoryCoreData.title = categoryTitle
			
			trackerCoreData.category = categoryCoreData
			
			try context.save()
			print("✅ Core Data: Трекер \(updatedTracker.name) успешно обновлен")
		} catch {
			print("❌ Core Data Error: Не удалось обновить трекер: \(error)")
		}
	}
	
	func fetchCategories() -> [TrackerCategory] {
		let request = TrackerCategoryCoreData.fetchRequest()
		
		let categoriesCoreData = (try? context.fetch(request)) ?? []
		
		return categoriesCoreData.compactMap { categoryCoreData in
			let title = categoryCoreData.title ?? ""
			let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] ?? []
			
			let trackers = trackersCoreData.compactMap { trackerCoreData -> Tracker? in
				return try? self.tracker(from: trackerCoreData)
			}
			
			return TrackerCategory(title: title, trackers: trackers)
		}
	}
	
	func deleteTracker(with id: UUID) throws {
		let request = TrackerCoreData.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
		
		do {
			let results = try context.fetch(request)
			guard let trackerToDelete = results.first else {
				print("❌ Core Data: Трекер для удаления не найден в базе")
				return
			}
			
			context.delete(trackerToDelete)
			try context.save()
			print("✅ Core Data: Трекер успешно удален и контекст сохранен")
		} catch {
			print("❌ Core Data Error: Не удалось удалить трекер: \(error)")
			throw error
		}
	}
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexes = IndexSet()
		deletedIndexes = IndexSet()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.store(self, didUpdate: TrackerStoreUpdate(
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
	
	func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
		guard let id = trackerCoreData.id,
			  let name = trackerCoreData.name,
			  let emoji = trackerCoreData.emoji,
			  let colorHex = trackerCoreData.color else {
			throw TrackerStoreError.decodingError
		}
		let scheduleStrings = trackerCoreData.schedule as? [String] ?? []
		let schedule = scheduleStrings.compactMap { WeekDay(rawValue: $0) }
		
		return Tracker(
			id: id,
			name: name,
			color: UIColor(hex: colorHex),
			emoji: emoji,
			schedule: schedule
		)
	}
}
