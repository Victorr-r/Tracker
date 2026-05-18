import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
	func didSelectCategory(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
	
	// MARK: - Properties
	private let viewModel: CategoriesViewModel
	weak var delegate: CategoriesViewControllerDelegate?
	
	// MARK: - UI Elements
	private let tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
		tableView.layer.cornerRadius = 16
		tableView.layer.masksToBounds = true
		tableView.separatorStyle = .singleLine
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		tableView.tableFooterView = UIView()
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()
	
	private let placeholderImageView: UIImageView = {
		let imageView = UIImageView(image: UIImage(named: "Error"))
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let placeholderLabel: UILabel = {
		let label = UILabel()
		label.text = "Привычки и события можно\nобъединить по смыслу"
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		label.textAlignment = .center
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var addCategoryButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		button.setTitle("Добавить категорию", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(didTapAddCategoryButton), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Initialization
	init(viewModel: CategoriesViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		setupTableView()
		bindViewModel()
		updatePlaceholderState()
	}
	
	// MARK: - Private Methods
	private func setupUI() {
		title = "Категория"
		view.backgroundColor = .white
		navigationItem.hidesBackButton = true
		
		setupLayout()
	}
	
	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	private func bindViewModel() {
		viewModel.categories.bind { [weak self] categories in
			self?.tableView.reloadData()
			self?.updatePlaceholderState()
		}
		
		viewModel.selectedCategory.bind { [weak self] category in
			guard let self = self, let category = category else { return }
			self.delegate?.didSelectCategory(category)
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	private func updatePlaceholderState() {
		let isEmpty = viewModel.categories.value.isEmpty
		tableView.isHidden = isEmpty
		placeholderImageView.isHidden = !isEmpty
		placeholderLabel.isHidden = !isEmpty
	}
	
	private func setupLayout() {
		view.addSubview(tableView)
		view.addSubview(placeholderImageView)
		view.addSubview(placeholderLabel)
		view.addSubview(addCategoryButton)
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -24),
			
			placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
			placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
			
			placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
			placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			placeholderLabel.heightAnchor.constraint(equalToConstant: 36),
			
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
	
	// MARK: - Actions
	@objc private func didTapAddCategoryButton() {
		let newCategoryVC = NewCategoryViewController(viewModel: self.viewModel)
		
		navigationController?.pushViewController(newCategoryVC, animated: true)
	}
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.categories.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
		let category = viewModel.categories.value[indexPath.row]
		
		cell.textLabel?.text = category.title
		cell.backgroundColor = UIColor(red: 230/255, green: 232/255, blue: 235/255, alpha: 0.3)
		cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
		cell.selectionStyle = .none
		
		if category.title == viewModel.selectedCategory.value?.title {
			let checkmarkImage = UIImage(systemName: "checkmark")
			let checkmarkImageView = UIImageView(image: checkmarkImage)
			
			checkmarkImageView.tintColor = UIColor(red: 55/255, green: 114/255, blue: 231/255, alpha: 1.0)
			checkmarkImageView.contentMode = .scaleAspectFit
			checkmarkImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
			
			cell.accessoryView = checkmarkImageView
		} else {
			cell.accessoryView = nil
		}
		
		let isFirst = indexPath.row == 0
		let isLast = indexPath.row == viewModel.categories.value.count - 1
		
		if isFirst && isLast {
			cell.layer.cornerRadius = 16
			cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		} else if isFirst {
			cell.layer.cornerRadius = 16
			cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		} else if isLast {
			cell.layer.cornerRadius = 16
			cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		} else {
			cell.layer.cornerRadius = 0
		}
		
		return cell
	}
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		viewModel.selectCategory(at: indexPath.row)
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		
		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return nil }
			
			let deleteAction = UIAction(
				title: "Удалить",
				image: UIImage(systemName: "trash"),
				attributes: .destructive
			) { _ in
				self.viewModel.deleteCategory(at: indexPath.row)
			}
			
			return UIMenu(title: "", children: [deleteAction])
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 75
	}
}
