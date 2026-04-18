import UIKit

// MARK: - Delegate Protocol
protocol TrackersViewControllerDelegate: AnyObject {
	func didCreateTracker(_ tracker: Tracker)
}

final class NewHabitViewController: UIViewController {
	
	// MARK: - Properties
	weak var delegate: TrackersViewControllerDelegate?
	private var schedule: [WeekDay] = []
	private var category: String? = "Важное"
	
	// MARK: - UI Elements
	private let textField: UITextField = {
		let tf = UITextField()
		let placeholderColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 0.7)
		tf.attributedPlaceholder = NSAttributedString(
			string: "Введите название трекера",
			attributes: [.foregroundColor: placeholderColor,
						 .font: UIFont.systemFont(ofSize: 17, weight: .regular)
			]
		)
		tf.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
		tf.layer.cornerRadius = 16
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		tf.leftViewMode = .always
		tf.clearButtonMode = .whileEditing
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.layer.cornerRadius = 16
		table.isScrollEnabled = false
		table.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
		table.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		table.dataSource = self
		table.delegate = self
		table.translatesAutoresizingMaskIntoConstraints = false
		return table
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle("Отменить", for: .normal)
		
		let figmaRed = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
		button.setTitleColor(figmaRed, for: .normal)
		
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = figmaRed.cgColor
		
		button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var createButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle("Создать", for: .normal)
		button.layer.cornerRadius = 16
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		
		let figmaGray = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
		button.backgroundColor = figmaGray
		button.setTitleColor(.white, for: .normal)
		
		button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupNavBar()
		setupViews()
		setupTextField()
		
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
	}
	
	// MARK: - Actions
	@objc private func textFieldDidChange() {
		let isNotEmpty = !(textField.text?.isEmpty ?? true)
		createButton.backgroundColor = isNotEmpty ? .black : .gray
	}
	
	@objc private func didTapCancel() {
		dismiss(animated: true)
	}
	
	@objc private func didTapCreate() {
		guard let text = textField.text, !text.isEmpty else { return }
		
		let newTracker = Tracker(
			id: UUID(),
			name: text,
			color: .systemBlue,
			emoji: "❤️",
			schedule: schedule
		)
		
		delegate?.didCreateTracker(newTracker)
		dismiss(animated: true)
	}
	
	// MARK: - Private Methods
	private func setupViews() {
		let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
		stackView.axis = .horizontal
		stackView.spacing = 8
		stackView.distribution = .fillEqually
		
		[textField, tableView, stackView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			textField.heightAnchor.constraint(equalToConstant: 75),
			
			tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.heightAnchor.constraint(equalToConstant: 150),
			
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34),
			stackView.heightAnchor.constraint(equalToConstant: 60)
		])
	}
	
	private func setupTextField() {
		textField.delegate = self
		
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
	}
	
	@objc private func hideKeyboard() {
		view.endEditing(true)
	}
	
	private func setupNavBar() {
		title = "Новая привычка"
		
		let titleAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 16, weight: .medium),
			.foregroundColor: UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		]
		
		navigationController?.navigationBar.titleTextAttributes = titleAttributes
	}
	
	private func formatScheduleText(_ schedule: [WeekDay]) -> String? {
		if schedule.isEmpty { return nil }
		if schedule.count == 7 { return "Каждый день" }
		
		return schedule.sorted { $0.calendarNumber < $1.calendarNumber }.map { $0.shortName }.joined(separator: ", ")
	}
}

// MARK: - TableView Extensions
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
				self?.schedule = updatedSchedule
				self?.tableView.reloadData()
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
