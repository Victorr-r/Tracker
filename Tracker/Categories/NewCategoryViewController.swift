import UIKit

final class NewCategoryViewController: UIViewController {
	
	// MARK: - Properties
	var viewModel: CategoriesViewModel!
	
	// MARK: - UI Elements
	private let textField: UITextField = {
		let tf = UITextField()
		let placeholderColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
		tf.attributedPlaceholder = NSAttributedString(
			string: "Введите название категории",
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
	
	private lazy var readyButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
		button.setTitle("Готово", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.isEnabled = false
		button.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Новая категория"
		view.backgroundColor = .white
		navigationItem.hidesBackButton = true
		
		setupLayout()
		
		textField.delegate = self
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	// MARK: - Layout
	private func setupLayout() {
		view.addSubview(textField)
		view.addSubview(readyButton)
		
		NSLayoutConstraint.activate([
			textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
			textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			textField.heightAnchor.constraint(equalToConstant: 75),
			
			readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			readyButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
	
	// MARK: - Actions
	@objc private func textFieldDidChange() {
		guard let text = textField.text else { return }
		let isValid = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		
		readyButton.isEnabled = isValid
		readyButton.backgroundColor = isValid ? UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0) : UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
	}
	
	@objc private func didTapReadyButton() {
		guard let text = textField.text else { return }
		
		viewModel.addCategory(named: text)
		
		navigationController?.popViewController(animated: true)
	}
	
	@objc private func hideKeyboard() {
		view.endEditing(true)
	}
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
