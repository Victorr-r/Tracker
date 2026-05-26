import UIKit

final class TrackersViewController: UIViewController {
	
	// MARK: - Properties
	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
	private var currentDate: Date = Date()
	private var visibleCategories: [TrackerCategory] = []
	private let trackerRecordStore = TrackerRecordStore()
	
	// MARK: - UI Elements
	private let placeholderImageView = UIImageView(image: UIImage(named: "Error"))
	private let placeholderLabel = UILabel()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
		cv.register(TrackerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeader.identifier)
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(named: "YP White") ?? .white
		
		setupNavBar()
		setupSearchController()
		setupCollectionView()
		setupPlaceholder()
		categories = TrackerStore.shared.fetchCategories()
		reloadVisibleCategories()
	}
	
	// MARK: - Setup UI
	
	private func setupCollectionView() {
		view.addSubview(collectionView)
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		collectionView.dataSource = self
		collectionView.delegate = self
	}
	
	private func setupNavBar() {
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Трекеры"
		
		let addButton = UIBarButtonItem(
			image: UIImage(named: "Add tracker"),
			style: .plain,
			target: self,
			action: #selector(didTapAddButton)
		)
		addButton.tintColor = UIColor(named: "YP Black") ?? .black
		navigationItem.leftBarButtonItem = addButton
		
		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		datePicker.preferredDatePickerStyle = .compact
		datePicker.locale = Locale(identifier: "ru_RU")
		
		let calendar = Calendar.current
		let minDate = calendar.date(byAdding: .year, value: -10, to: Date())
		let maxDate = calendar.date(byAdding: .year, value: 10, to: Date())
		datePicker.minimumDate = minDate
		datePicker.maximumDate = maxDate
		
		datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
		
		datePicker.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			datePicker.widthAnchor.constraint(equalToConstant: 100),
			datePicker.heightAnchor.constraint(equalToConstant: 34)
		])
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
	}
	
	private func setupSearchController() {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.searchResultsUpdater = self
		searchController.hidesNavigationBarDuringPresentation = false
		searchController.searchBar.placeholder = "Поиск"
		navigationItem.searchController = searchController
	}
	
	private func setupPlaceholder() {
		placeholderLabel.text = "Что будем отслеживать?"
		placeholderLabel.textColor = UIColor(red: 26/255, green: 24/255, blue: 34/255, alpha: 1.0)
		placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
		placeholderLabel.textAlignment = .center
		
		[placeholderImageView, placeholderLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
				   placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				   placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				   placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
				   placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
				   
				   placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
				   placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
				   placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
				   placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
			   ])
	}
	
	// MARK: - Logic
	private func reloadVisibleCategories() {
		self.completedTrackers = trackerRecordStore.records
		self.categories = TrackerStore.shared.fetchCategories()
		let calendar = Calendar.current
		let filterWeekday = calendar.component(.weekday, from: currentDate)
		let filterText = (navigationItem.searchController?.searchBar.text ?? "").lowercased()
		
		visibleCategories = categories.compactMap { category in
			let trackers = category.trackers.filter { tracker in
				let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
				let dateCondition = tracker.schedule?.contains { (weekday: WeekDay) in
					weekday.calendarNumber == filterWeekday
				} ?? false
				
				return textCondition && dateCondition
			}
			if trackers.isEmpty { return nil }
			return TrackerCategory(title: category.title, trackers: trackers)
		}
		
		collectionView.reloadData()
		reloadPlaceholder()
	}
	
	private func deleteTracker(at indexPath: IndexPath) {
		do {
			try TrackerStore.shared.deleteTracker(at: indexPath)
			reloadVisibleCategories()
		} catch {
			print("Ошибка удаления: \(error)")
		}
	}
	
	private func reloadPlaceholder() {
		if visibleCategories.isEmpty {
			placeholderImageView.isHidden = false
			placeholderLabel.isHidden = false
			
			placeholderImageView.image = UIImage(named: "Error")
			
			let isSearchActive = !(navigationItem.searchController?.searchBar.text?.isEmpty ?? true)
			if isSearchActive {
				placeholderImageView.image = UIImage(named: "Error 2")
				placeholderLabel.text = "Ничего не найдено"
			} else {
				placeholderImageView.image = UIImage(named: "Error")
				placeholderLabel.text = "Что будем отслеживать?"
			}
			
			view.bringSubviewToFront(placeholderImageView)
			view.bringSubviewToFront(placeholderLabel)
		} else {
			placeholderImageView.isHidden = true
			placeholderLabel.isHidden = true
		}
	}
	
	private func markTrackerAsCompleted(id: UUID) {
		let record = TrackerRecord(id: id, date: currentDate)
		try? trackerRecordStore.add(record)
		self.completedTrackers = trackerRecordStore.records
	}
	
	private func unmarkTrackerAsCompleted(id: UUID) {
		let record = TrackerRecord(id: id, date: currentDate)
		try? trackerRecordStore.remove(record)
		self.completedTrackers = trackerRecordStore.records
	}
	
	private func isTrackerCompletedToday(id: UUID) -> Bool {
		completedTrackers.contains { record in
			record.id == id && Calendar.current.isDate(record.date, inSameDayAs: currentDate)
		}
	}
	
	// MARK: - Actions
	@objc private func didTapAddButton() {
		let newHabitVC = NewHabitViewController()
		
		newHabitVC.delegate = self
		
		let navVC = UINavigationController(rootViewController: newHabitVC)
		present(navVC, animated: true)	}
	
	@objc private func dateChanged(_ picker: UIDatePicker) {
		currentDate = Calendar.current.startOfDay(for: picker.date)
		reloadVisibleCategories()
	}
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return visibleCategories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return visibleCategories[section].trackers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
			return UICollectionViewCell()
		}
		let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
		let isCompleted = isTrackerCompletedToday(id: tracker.id)
		let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
		
		cell.delegate = self
		cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays, indexPath: indexPath)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerHeader.identifier, for: indexPath) as? TrackerHeader else {
			return UICollectionReusableView()
		}
		header.titleLabel.text = visibleCategories[indexPath.section].title
		return header
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: collectionView.frame.width, height: 35)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let availableWidth = collectionView.frame.width - 16 * 2 - 9
		let cellWidth = availableWidth / 2
		return CGSize(width: cellWidth, height: 148)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 10, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
				self?.deleteTracker(at: indexPath)
			}
			
			return UIMenu(title: "", children: [deleteAction])
		}
	}
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		reloadVisibleCategories()
	}
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
	func completeTracker(id: UUID, at indexPath: IndexPath) {
		let calendar = Calendar.current
		if calendar.startOfDay(for: currentDate) > calendar.startOfDay(for: Date()) {
			return
		}
		
		if isTrackerCompletedToday(id: id) {
			unmarkTrackerAsCompleted(id: id)
		} else {
			markTrackerAsCompleted(id: id)
		}
		
		if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
			let isCompleted = isTrackerCompletedToday(id: id)
			let completedDays = completedTrackers.filter { $0.id == id }.count
			
			cell.updateCompletion(isCompleted: isCompleted, completedDays: completedDays)
		}
	}
}
// MARK: - TrackersViewControllerDelegate
extension TrackersViewController: TrackersViewControllerDelegate {
	func didCreateTracker(_ tracker: Tracker) {
		reloadVisibleCategories()
	}
}

extension TrackersViewController: TrackerStoreDelegate {
	func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
		reloadVisibleCategories()
	}
}
