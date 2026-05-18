import UIKit

final class OnboardingViewController: UIPageViewController {
	
	// MARK: - Properties
	
	private lazy var pages: [UIViewController] = {
		let firstPage = OnboardingPageViewController(
			imageName: "Onboard1",
			titleText: "Отслеживайте только то, что хотите"
		)
		let secondPage = OnboardingPageViewController(
			imageName: "Onboard2",
			titleText: "Даже если это не литры воды и йога"
		)
		return [firstPage, secondPage]
	}()
	
	private lazy var pageControl: UIPageControl = {
		let pageControl = UIPageControl()
		pageControl.numberOfPages = pages.count
		pageControl.currentPage = 0
		pageControl.currentPageIndicatorTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		pageControl.pageIndicatorTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.3)
		pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		return pageControl
	}()
	
	private lazy var startButton: UIButton = {
		let button = UIButton(type: .system)
		button.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
		button.setTitle("Вот это технологии!", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	
	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dataSource = self
		delegate = self
		
		if let first = pages.first {
			setViewControllers([first], direction: .forward, animated: true, completion: nil)
		}
		
		setupLayout()
	}
	
	// MARK: - Layout
	private func setupLayout() {
		let controlStackView = UIStackView(arrangedSubviews: [pageControl, startButton])
		controlStackView.axis = .vertical
		controlStackView.spacing = 24
		controlStackView.alignment = .center
		controlStackView.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(controlStackView)
		
		NSLayoutConstraint.activate([
			controlStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -84),
			controlStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			controlStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			
			startButton.leadingAnchor.constraint(equalTo: controlStackView.leadingAnchor),
			startButton.trailingAnchor.constraint(equalTo: controlStackView.trailingAnchor),
			startButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}
	
	
	@objc private func didTapStartButton() {
		switchToMainScreen()
	}
	
	// MARK: - Navigation
	private func switchToMainScreen() {
		guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
			  let sceneDelegate = windowScene.delegate as? SceneDelegate else { return }
		
		sceneDelegate.switchToMainScreen()
	}
}

// MARK: - UIPageViewControllerDataSource (Зацикленный скролл)
extension OnboardingViewController: UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
		let previousIndex = viewControllerIndex - 1
		return previousIndex < 0 ? pages.last : pages[previousIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
		let nextIndex = viewControllerIndex + 1
		return nextIndex >= pages.count ? pages.first : pages[nextIndex]
	}
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed,
		   let currentViewController = pageViewController.viewControllers?.first,
		   let currentIndex = pages.firstIndex(of: currentViewController) {
			pageControl.currentPage = currentIndex
		}
	}
}
