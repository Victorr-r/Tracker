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
			
			if let categoryTitle = self.category {
				cell.detailTextLabel?.text = categoryTitle
				cell.detailTextLabel?.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
				cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
			} else {
				cell.detailTextLabel?.text = nil
			}
			
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
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			let trackerCategoryStore = TrackerCategoryStore()
			let currentCategory = TrackerCategory(title: self.category ?? "Важное", trackers: [])
			let categoriesViewModel = CategoriesViewModel(
				trackerCategoryStore: trackerCategoryStore,
				selectedCategory: currentCategory
			)
			
			let categoriesVC = CategoriesViewController(viewModel: categoriesViewModel)
			categoriesVC.delegate = self
			
			navigationController?.pushViewController(categoriesVC, animated: true)
		}
		else if indexPath.row == 1 {
			let scheduleVC = ScheduleViewController()
			scheduleVC.selectedDays = Set(self.schedule)
			scheduleVC.completion = { [weak self] updatedSchedule in
				guard let self else { return }
				self.schedule = updatedSchedule
				self.tableView.reloadData()
			}
			navigationController?.pushViewController(scheduleVC, animated: true)
		}
	}
}

// MARK: - UITextFieldDelegate
extension NewHabitViewController {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentText = textField.text ?? ""
		
		guard let textRange = Range(range, in: currentText) else {
			return false
		}
		
		let updatedText = currentText.replacingCharacters(
			in: textRange,
			with: string
		)
		
		return updatedText.count <= 38
	}
}
