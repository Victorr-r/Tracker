import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
	func didCreateTracker(_ tracker: Tracker)
}

final class NewHabitViewController: UIViewController {
	weak var delegate: TrackersViewControllerDelegate?
	private var schedule: [WeekDay] = []
	
	private let textField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите название трекера"
		tf.backgroundColor = UIColor(named: "YP Background")
		tf.layer.cornerRadius = 16
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		tf.leftViewMode = .always
		return tf
	}()

	private lazy var tableView: UITableView = {
		let table = UITableView()
		table.layer.cornerRadius = 16
		table.isScrollEnabled = false
		table.dataSource = self
		table.delegate = self
		return table
	}()
	
	private lazy var cancelButton: UIButton = {
		   let button = UIButton(type: .system)
		   button.setTitle("Отменить", for: .normal)
		   button.setTitleColor(.systemRed, for: .normal)
		   button.layer.borderWidth = 1
		   button.layer.borderColor = UIColor.systemRed.cgColor
		   button.layer.cornerRadius = 16
		   button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		   button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
		   return button
	   }()

	   private lazy var createButton: UIButton = {
		   let button = UIButton(type: .system)
		   button.setTitle("Создать", for: .normal)
		   button.backgroundColor = .black // По заданию она может быть серой, пока не заполнены поля
		   button.setTitleColor(.white, for: .normal)
		   button.layer.cornerRadius = 16
		   button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		   button.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
		   return button
	   }()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Новая привычка"
		view.backgroundColor = .white
		setupViews()
	}
	
	// MARK: - Actions
	  @objc private func didTapCancel() {
		  dismiss(animated: true)
	  }
	  
	@objc private func didTapCreate() {
		   guard let text = textField.text, !text.isEmpty else { return }
		   let newTracker = Tracker(id: UUID(), name: text, color: .systemBlue, emoji: "❤️", schedule: schedule)
		   delegate?.didCreateTracker(newTracker)
		   dismiss(animated: true)
	   }

	  // MARK: - Setup
	  private func setupViews() {
		  [textField, tableView].forEach {
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
			  tableView.heightAnchor.constraint(equalToConstant: 150)
		  ])
	  }
}

extension NewHabitViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2 // "Категория" и "Расписание"
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = UIColor(named: "YP Background")
		
		if indexPath.row == 0 {
			cell.textLabel?.text = "Категория"
		} else {
			cell.textLabel?.text = "Расписание"
		}
		
		return cell
	}
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 1 {
			let scheduleVC = ScheduleViewController()
			// Настройка делегата расписания
			navigationController?.pushViewController(scheduleVC, animated: true)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
