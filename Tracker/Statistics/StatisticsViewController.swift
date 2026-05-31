import UIKit

final class StatisticsViewController: UIViewController {
	
	// MARK: - Properties
	private let trackerRecordStore = TrackerRecordStore()
	private var completedTrackersCount: Int = 0
	
	// MARK: - UI Elements
	private let topNavView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Статистика"
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.textColor = UIColor(named: "YP Black") ?? .label
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let placeholderImageView = UIImageView(image: UIImage(named: "Error 3"))
	private let placeholderLabel = UILabel()
	
	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .clear
		table.separatorStyle = .none
		table.isScrollEnabled = false
		table.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.identifier)
		table.dataSource = self
		table.delegate = self
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupDelegates()
		loadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateStatistics()
		tableView.reloadData()
	}
	
	// MARK: - Setup UI
	private func setupUI() {
		view.backgroundColor = UIColor(named: "YP White") ?? .systemBackground
		navigationController?.setNavigationBarHidden(true, animated: false)
		
		setupLayout()
	}
	
	private func setupDelegates() {
		trackerRecordStore.delegate = self
	}
	
	private func loadData() {
		updateStatistics()
	}
	
	private func setupLayout() {
		placeholderLabel.text = "Анализировать пока нечего"
		placeholderLabel.textColor = UIColor { traitCollection in
			return traitCollection.userInterfaceStyle == .dark ? .white : UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		}
		placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
		placeholderLabel.textAlignment = .center
		
		view.addSubview(topNavView)
		topNavView.addSubview(titleLabel)
		view.addSubview(tableView)
		
		[placeholderImageView, placeholderLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			topNavView.topAnchor.constraint(equalTo: view.topAnchor),
			topNavView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			topNavView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			topNavView.heightAnchor.constraint(equalToConstant: 182),
			
			titleLabel.leadingAnchor.constraint(equalTo: topNavView.leadingAnchor, constant: 16),
			titleLabel.bottomAnchor.constraint(equalTo: topNavView.bottomAnchor, constant: -53),
			titleLabel.widthAnchor.constraint(equalToConstant: 254),
			titleLabel.heightAnchor.constraint(equalToConstant: 41),
			
			tableView.topAnchor.constraint(equalTo: topNavView.bottomAnchor, constant: 18),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.heightAnchor.constraint(equalToConstant: 408),
			
			placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
			
			placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
			placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderLabel.widthAnchor.constraint(equalToConstant: 343),
			placeholderLabel.heightAnchor.constraint(equalToConstant: 18)
		])
	}
	
	// MARK: - Logic
	private func updateStatistics() {
		completedTrackersCount = trackerRecordStore.records.count
		let hasData = completedTrackersCount > 0
		
		tableView.isHidden = !hasData
		
		placeholderImageView.isHidden = hasData
		placeholderLabel.isHidden = hasData
		
		titleLabel.isHidden = false
		
		if hasData {
			tableView.reloadData()
		}
	}
}

// MARK: - UITableViewDataSource & Delegate
extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 4
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 102
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticCell.identifier, for: indexPath) as? StatisticCell else {
			return UITableViewCell()
		}
		
		var value = "0"
		var title = ""
		
		switch indexPath.row {
		case 0:
			title = "Лучший период"
			value = "-"
		case 1:
			title = "Идеальные дни"
			value = "-"
		case 2:
			title = "Трекеров завершено"
			value = "\(completedTrackersCount)"
		case 3:
			title = "Среднее значение"
			value = "-"
		default:
			break
		}
		
		cell.configure(value: value, title: title)
		return cell
	}
}

// MARK: - TrackerRecordStoreDelegate
extension StatisticsViewController: TrackerRecordStoreDelegate {
	func store(_ store: TrackerRecordStore, didUpdate update: TrackerRecordStoreUpdate) {
		updateStatistics()
	}
}
