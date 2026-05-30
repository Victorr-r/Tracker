import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
	func didSelectFilter(_ filter: FilterType)
}

final class FiltersViewController: UIViewController {
	
	// MARK: - Properties
	weak var delegate: FiltersViewControllerDelegate?
	private let filters = FilterType.allCases
	private var currentFilter: FilterType
	
	// MARK: - UI Elements
	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.layer.cornerRadius = 16
		table.backgroundColor = .systemGroupedBackground
		table.isScrollEnabled = false
		table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		table.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
		table.dataSource = self
		table.delegate = self
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	// MARK: - Init
	init(currentFilter: FilterType) {
		self.currentFilter = currentFilter
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) { fatalError() }
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(named: "YP White") ?? .systemBackground
		title = "Фильтры"
		
		setupUI()
	}
	
	private func setupUI() {
		view.addSubview(tableView)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.heightAnchor.constraint(equalToConstant: 300)
		])
	}
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filters.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
		let filter = filters[indexPath.row]
		
		cell.textLabel?.text = filter.rawValue
		cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
		cell.backgroundColor = .clear
		cell.selectionStyle = .none
		
		if filter == currentFilter && (filter == .completed || filter == .uncompleted) {
			cell.accessoryType = .checkmark
			cell.tintColor = .systemBlue
		} else {
			cell.accessoryType = .none
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedFilter = filters[indexPath.row]
		delegate?.didSelectFilter(selectedFilter)
		dismiss(animated: true)
	}
}
