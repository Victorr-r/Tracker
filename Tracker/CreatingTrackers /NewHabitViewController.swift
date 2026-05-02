import UIKit

// MARK: - Delegate Protocol
protocol TrackersViewControllerDelegate: AnyObject {
	func didCreateTracker(_ tracker: Tracker)
}

final class NewHabitViewController: UIViewController {
	
	// MARK: - Properties
	weak var delegate: TrackersViewControllerDelegate?
	var schedule: [WeekDay] = []
	var category: String? = "Важное"
	var selectedEmoji: String?
	var selectedColor: UIColor?
	
	lazy var emojiCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
		
		cv.register(SupplementaryView.self,
					forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
					withReuseIdentifier: SupplementaryView.identifier)
		
		cv.isScrollEnabled = false
		cv.dataSource = self
		cv.delegate = self
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()
	
	lazy var colorCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
		
		cv.register(SupplementaryView.self,
					forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
					withReuseIdentifier: SupplementaryView.identifier)
		
		cv.isScrollEnabled = false
		cv.dataSource = self
		cv.delegate = self
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()
	
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
	
	private let errorLabel: UILabel = {
		let label = UILabel()
		label.text = "Ограничение 38 символов"
		label.textColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1.0)
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.textAlignment = .center
		label.isHidden = true
		return label
	}()
	
	lazy var tableView: UITableView = {
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
	
	private let scrollView: UIScrollView = {
		let scroll = UIScrollView()
		scroll.translatesAutoresizingMaskIntoConstraints = false
		return scroll
	}()
	
	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
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
	@objc func textFieldDidChange() {
		guard let text = textField.text else { return }
		
		let isOverLimit = text.count > 38
		
		errorLabel.isHidden = !isOverLimit
		
		let isTextValid = !text.isEmpty && !isOverLimit
		let isEmojiSelected = selectedEmoji != nil
		let isColorSelected = selectedColor != nil
		let isScheduleSelected = !schedule.isEmpty
		
		let isFormValid = isTextValid && isEmojiSelected && isColorSelected && isScheduleSelected
		
		createButton.isEnabled = isFormValid
		
		let activeColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		let inactiveColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
		
		createButton.backgroundColor = isFormValid ? activeColor : inactiveColor
		
		UIView.animate(withDuration: 0.2) {
			self.view.layoutIfNeeded()
		}
	}
	
	@objc private func didTapCancel() {
		dismiss(animated: true)
	}
	
	@objc private func didTapCreate() {
		guard let text = textField.text, !text.isEmpty,
			  let color = selectedColor,
			  let emoji = selectedEmoji
		else { return }
		
		let newTracker = Tracker(
			id: UUID(),
			name: text,
			color: color,
			emoji: emoji,
			schedule: schedule
		)
		
		let categoryTitle = "Важное"
		TrackerStore.shared.addNewTracker(newTracker, to: categoryTitle)
		
		delegate?.didCreateTracker(newTracker)
		
		self.view.window?.rootViewController?.dismiss(animated: true)
	}
	
	// MARK: - Private Methods
	private func setupViews() {
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		let textStackView = UIStackView(arrangedSubviews: [textField, errorLabel])
		textStackView.axis = .vertical
		textStackView.spacing = 8
		textStackView.translatesAutoresizingMaskIntoConstraints = false
		
		let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
		stackView.axis = .horizontal
		stackView.spacing = 8
		stackView.distribution = .fillEqually
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		[textStackView, tableView, emojiCollectionView, colorCollectionView, stackView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
		}
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			
			contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
			
			textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
			textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			
			textField.heightAnchor.constraint(equalToConstant: 75),
			errorLabel.heightAnchor.constraint(equalToConstant: 22),
			
			tableView.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			tableView.heightAnchor.constraint(equalToConstant: 150),
			
			emojiCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
			emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
			
			colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
			colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
			
			stackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
			stackView.heightAnchor.constraint(equalToConstant: 60),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
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
	
	func formatScheduleText(_ schedule: [WeekDay]) -> String? {
		if schedule.isEmpty { return nil }
		if schedule.count == 7 { return "Каждый день" }
		
		return schedule.sorted { $0.calendarNumber < $1.calendarNumber }.map { $0.shortName }.joined(separator: ", ")
	}
}
