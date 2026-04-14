import UIKit

final class ScheduleViewController: UIViewController {
	private let days = WeekDay.allCases
	var selectedDays: [WeekDay] = []
	var completion: (([WeekDay]) -> Void)?

	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.register(UITableViewCell.self, forCellReuseIdentifier: "dayCell")
		table.dataSource = self
		return table
	}()

	@objc private func doneButtonTapped() {
		completion?(selectedDays)
		navigationController?.popViewController(animated: true)
	}
}

extension ScheduleViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .default, reuseIdentifier: "dayCell")
		let day = days[indexPath.row]
		cell.textLabel?.text = day.rawValue
		
		let switchView = UISwitch()
		switchView.isOn = selectedDays.contains(day)
		switchView.tag = indexPath.row
		switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
		cell.accessoryView = switchView
		return cell
	}
	
	@objc private func switchChanged(_ sender: UISwitch) {
		let day = days[sender.tag]
		if sender.isOn { selectedDays.append(day) }
		else { selectedDays.removeAll { $0 == day } }
	}
}
