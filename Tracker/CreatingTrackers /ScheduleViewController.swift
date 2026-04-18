import UIKit

final class ScheduleViewController: UIViewController {
	
	// MARK: - Properties
	private let days = WeekDay.allCases
	var selectedDays: Set<WeekDay> = []
	var completion: (([WeekDay]) -> Void)?
	
	// MARK: - UI Elements
	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
		table.layer.cornerRadius = 16
		table.isScrollEnabled = false
		table.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
		table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		table.dataSource = self
		table.delegate = self
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	private lazy var doneButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle("Готово", for: .normal)
		button.backgroundColor = UIColor(named: "YP Black") ?? .black
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 16
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		title = "Расписание"
		setupNavBar()
		setupLayout()
		
	}
	
	// MARK: - Actions
	@objc private func doneButtonTapped() {
		let sortedDays = WeekDay.allCases.filter { selectedDays.contains($0) }
		completion?(sortedDays)
		navigationController?.popViewController(animated: true)
	}
	
	// MARK: - Private Methods
	private func setupNavBar() {
		title = "Расписание"
		navigationItem.hidesBackButton = true
		let titleAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 16, weight: .medium),
			.foregroundColor: UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		]
		
		navigationController?.navigationBar.titleTextAttributes = titleAttributes
	}
	
	private func setupLayout() {
		[tableView, doneButton].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.heightAnchor.constraint(equalToConstant: 525),
			
			doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
			doneButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
		let day = days[indexPath.row]
		
		cell.textLabel?.text = day.rawValue
		cell.backgroundColor = .clear
		cell.selectionStyle = .none
		
		let switchView = UISwitch()
		switchView.onTintColor = .systemBlue
		switchView.isOn = selectedDays.contains(day)
		switchView.tag = indexPath.row
		switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
		
		cell.accessoryView = switchView
		
		if indexPath.row == days.count - 1 {
			cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
		} else {
			cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		}
		
		return cell
	}
	@objc private func switchChanged(_ sender: UISwitch) {
		let day = days[sender.tag]
		if sender.isOn {
			selectedDays.insert(day)
		} else {
			selectedDays.remove(day)
		}
	}
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
}
