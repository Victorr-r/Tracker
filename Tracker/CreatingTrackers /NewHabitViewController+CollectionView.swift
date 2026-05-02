import UIKit


// MARK: - UICollectionViewDataSource
extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		cell.backgroundColor = .clear
		cell.selectionStyle = .none
		cell.accessoryType = .disclosureIndicator
		
		cell.layer.masksToBounds = true
		cell.layer.cornerRadius = 16
		
		if indexPath.row == 0 {
			cell.textLabel?.text = "Категория"
			cell.detailTextLabel?.text = "Важное"
			cell.detailTextLabel?.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
			cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
			cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		} else {
			cell.textLabel?.text = "Расписание"
			
			if let scheduleText = formatScheduleText(self.schedule) {
				cell.detailTextLabel?.text = scheduleText
				cell.detailTextLabel?.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
				cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
			}
			cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			
			cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 1 {
			let scheduleVC = ScheduleViewController()
			scheduleVC.selectedDays = Set(self.schedule)
			scheduleVC.completion = { [weak self] updatedSchedule in
				guard let self = self else { return }
				self.schedule = updatedSchedule
				self.tableView.reloadData()
			}
			navigationController?.pushViewController(scheduleVC, animated: true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
