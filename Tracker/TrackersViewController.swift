import UIKit

final class TrackersViewController: UIViewController {
	
	// MARK: - Properties
	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
	private var currentDate: Date = Date()
	private var visibleCategories: [TrackerCategory] = []
	private let trackerRecordStore = TrackerRecordStore()
	private var selectedFilter: FilterType = .all
	
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
	
	private lazy var filtersButton: UIButton = {
		var config = UIButton.Configuration.filled()
		
		config.title = NSLocalizedString("trackers.filtersButton", comment: "")
		config.baseForegroundColor = .white
		
		config.baseBackgroundColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
		config.background.cornerRadius = 16
		
		let button = UIButton(configuration: config, primaryAction: nil)
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
		
		button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AnalyticsService.shared.report(event: .open, screen: .main)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		AnalyticsService.shared.report(event: .close, screen: .main)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = TrackerColors.mainBackground
		collectionView.backgroundColor = TrackerColors.mainBackground
		
		setupNavBar()
		setupSearchController()
		setupCollectionView()
		setupFiltersButton()
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
		navigationItem.title = NSLocalizedString("trackers.title", comment: "")
		
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
		datePicker.locale = Locale.current
		
		let calendar = Calendar.current
		let minDate = calendar.date(byAdding: .year, value: -10, to: Date())
		let maxDate = calendar.date(byAdding: .year, value: 10, to: Date())
		datePicker.minimumDate = minDate
		datePicker.maximumDate = maxDate
		
		datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
		
		datePicker.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
		datePicker.overrideUserInterfaceStyle = .light
		datePicker.layer.cornerRadius = 8
		datePicker.clipsToBounds = true
		
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
		
		let searchElementColor = UIColor { traitCollection in
			switch traitCollection.userInterfaceStyle {
			case .dark:
				return UIColor(red: 235/255, green: 235/255, blue: 245/255, alpha: 1.0)
			default:
				return UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
			}
		}
		
		let searchPlaceholderText = NSLocalizedString("trackers.searchPlaceholder", comment: "")
		searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
			string: searchPlaceholderText,
			attributes: [.foregroundColor: searchElementColor]
		)
		
		searchController.searchBar.searchTextField.leftView?.tintColor = searchElementColor
		
		searchController.searchBar.searchTextField.textColor = UIColor { traitCollection in
			return traitCollection.userInterfaceStyle == .dark ? .white : .black
		}
		
		searchController.searchBar.searchTextField.backgroundColor = TrackerColors.searchFieldBackground
		navigationItem.searchController = searchController
	}
	
	private func setupPlaceholder() {
		placeholderLabel.text = NSLocalizedString("trackers.placeholder.empty", comment: "")
		placeholderLabel.textColor = UIColor { traitCollection in
			switch traitCollection.userInterfaceStyle {
			case .dark:
				return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0)
			default:
				return UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
			}
		}
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
	
	private func setupFiltersButton() {
		view.addSubview(filtersButton)
		
		NSLayoutConstraint.activate([
			filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			filtersButton.widthAnchor.constraint(equalToConstant: 114),
			filtersButton.heightAnchor.constraint(equalToConstant: 50)
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
				let filteredTrackers = category.trackers.filter { tracker in
					shouldShow(tracker, weekday: filterWeekday, searchText: filterText)
				}
				
				if filteredTrackers.isEmpty { return nil }
				return TrackerCategory(title: category.title, trackers: filteredTrackers)
			}
			
			updateFiltersButtonState(weekday: filterWeekday)
			collectionView.reloadData()
			reloadPlaceholder()
		}
		
		private func shouldShow(_ tracker: Tracker, weekday: Int, searchText: String) -> Bool {
			let textCondition = searchText.isEmpty || tracker.name.lowercased().contains(searchText)
			
			let dateCondition = tracker.schedule?.contains { $0.calendarNumber == weekday } ?? false
			
			let isCompleted = isTrackerCompletedToday(id: tracker.id)
			var statusCondition = true
			
			if selectedFilter == .completed {
				statusCondition = isCompleted
			} else if selectedFilter == .uncompleted {
				statusCondition = !isCompleted
			}
			
			return textCondition && dateCondition && statusCondition
		}
		
		private func updateFiltersButtonState(weekday: Int) {
			let totalTrackersForDay = categories.flatMap { $0.trackers }.filter { tracker in
				return tracker.schedule?.contains { $0.calendarNumber == weekday } ?? false
			}
			filtersButton.isHidden = totalTrackersForDay.isEmpty
			
			if selectedFilter == .completed || selectedFilter == .uncompleted {
				filtersButton.setTitleColor(.systemRed, for: .normal)
			} else {
				filtersButton.setTitleColor(.white, for: .normal)
			}
		}
		
		private func deleteTracker(at indexPath: IndexPath) {
			let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
			
			do {
				try TrackerStore.shared.deleteTracker(with: tracker.id)
				reloadVisibleCategories()
			} catch {
				print("Ошибка удаления: \(error)")
			}
		}
		
		private func editTracker(at indexPath: IndexPath) {
			let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
			let categoryTitle = visibleCategories[indexPath.section].title
			
			let editHabitVC = NewHabitViewController()
			editHabitVC.trackerToEdit = tracker
			editHabitVC.category = categoryTitle
			editHabitVC.delegate = self
			
			let navVC = UINavigationController(rootViewController: editHabitVC)
			present(navVC, animated: true)
		}
		
		private func reloadPlaceholder() {
			if visibleCategories.isEmpty {
				placeholderImageView.isHidden = false
				placeholderLabel.isHidden = false
				
				let isSearchActive = !(navigationItem.searchController?.searchBar.text?.isEmpty ?? true)
				
				if isSearchActive || selectedFilter == .completed || selectedFilter == .uncompleted {
					placeholderImageView.image = UIImage(named: "Error 2")
					placeholderLabel.text = NSLocalizedString("trackers.placeholder.nothingFound", comment: "")
				} else {
					placeholderImageView.image = UIImage(named: "Error")
					placeholderLabel.text = NSLocalizedString("trackers.placeholder.empty", comment: "")
				}
				
				view.bringSubviewToFront(placeholderImageView)
				view.bringSubviewToFront(placeholderLabel)
			} else {
				placeholderImageView.isHidden = true
				placeholderLabel.isHidden = true
				
				view.bringSubviewToFront(filtersButton)
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
		AnalyticsService.shared.report(event: .click, screen: .main, item: .addTrack)
		let newHabitVC = NewHabitViewController()
		newHabitVC.delegate = self
		let navVC = UINavigationController(rootViewController: newHabitVC)
		present(navVC, animated: true)
	}
	
	@objc private func dateChanged(_ picker: UIDatePicker) {
		currentDate = Calendar.current.startOfDay(for: picker.date)
		reloadVisibleCategories()
	}
	
	@objc private func didTapFiltersButton() {
		AnalyticsService.shared.report(event: .click, screen: .main, item: .filter)
		let filtersVC = FiltersViewController(currentFilter: selectedFilter)
		filtersVC.delegate = self
		
		let navVC = UINavigationController(rootViewController: filtersVC)
		
		present(navVC, animated: true)
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
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			guard let self else { return UIMenu() }
			
			let editAction = UIAction(title: "Редактировать") { _ in
				AnalyticsService.shared.report(event: .click, screen: .main, item: .edit)
				
				self.editTracker(at: indexPath)
			}
			
			let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
				AnalyticsService.shared.report(event: .click, screen: .main, item: .delete)
				
				self.deleteTracker(at: indexPath)
			}
			
			return UIMenu(title: "", children: [editAction, deleteAction])
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
		AnalyticsService.shared.report(event: .click, screen: .main, item: .track)
		
		if isTrackerCompletedToday(id: id) {
			unmarkTrackerAsCompleted(id: id)
		} else {
			markTrackerAsCompleted(id: id)
		}
		
		reloadVisibleCategories()
	}
}
// MARK: - TrackersViewControllerDelegate
extension TrackersViewController: TrackersViewControllerDelegate {
	func didCreateTracker(_ tracker: Tracker) {
		reloadVisibleCategories()
	}
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
	func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
		reloadVisibleCategories()
	}
}

// MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
	func didSelectFilter(_ filter: FilterType) {
		self.selectedFilter = filter
		
		if filter == .today {
			currentDate = Calendar.current.startOfDay(for: Date())
			
			if let datePicker = navigationItem.rightBarButtonItem?.customView as? UIDatePicker {
				datePicker.date = currentDate
			}
			
			self.selectedFilter = .all
		}
		
		reloadVisibleCategories()
	}
}
