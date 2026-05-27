import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	// MARK: - Properties
	var window: UIWindow?
	
	// MARK: - Scene Life Cycle
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		self.window = window
		
		let onboardingVC = OnboardingViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: nil
		)
		
		window.rootViewController = onboardingVC
		window.makeKeyAndVisible()
	}
	
	// MARK: - Public Methods
	func switchToMainScreen() {
		guard let window = window else { return }
		
		let tabBarController = makeTabBarController()
		window.rootViewController = tabBarController
		
		performCrossDissolveTransition(for: window)
	}
	
	// MARK: - Private Factory Methods
	private func makeTabBarController() -> UITabBarController {
		let tabBar = UITabBarController()
		
		let trackersNav = makeTrackersNavigationController()
		let statisticsVC = makeStatisticsViewController()
		
		tabBar.viewControllers = [trackersNav, statisticsVC]
		
		if #available(iOS 18.0, *) {
			tabBar.tabBar.traitOverrides.horizontalSizeClass = .compact
		}
		tabBar.tabBar.itemPositioning = .centered
		tabBar.tabBar.itemSpacing = 114
		tabBar.tabBar.isTranslucent = false
		tabBar.tabBar.tintColor = UIColor(named: "YP Blue")
		tabBar.tabBar.unselectedItemTintColor = UIColor(named: "YP Gray")
		
		setupTabBarAppearance(tabBar.tabBar)
		addTopBorder(to: tabBar.tabBar)
		
		return tabBar
	}
	
	private func makeTrackersNavigationController() -> UINavigationController {
		let trackersVC = TrackersViewController()
		let trackersNav = UINavigationController(rootViewController: trackersVC)
		
		trackersNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab Bar Item"), tag: 0)
		trackersNav.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
		
		return trackersNav
	}
	
	private func makeStatisticsViewController() -> UIViewController {
		let statisticsVC = UIViewController()
		statisticsVC.view.backgroundColor = .systemBackground
		
		statisticsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab Bar Item2"), tag: 1)
		statisticsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
		
		return statisticsVC
	}
	
	private func makeTabBarAppearance() -> UITabBarAppearance {
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor(named: "YP White")
		appearance.shadowColor = .clear
		
		appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "YP Gray")
		appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "YP Blue")
		
		return appearance
	}
	
	// MARK: - Private Setup
	private func setupTabBarAppearance(_ tabBar: UITabBar) {
		let appearance = makeTabBarAppearance()
		tabBar.standardAppearance = appearance
		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = appearance
		}
	}
	
	private func addTopBorder(to tabBar: UITabBar) {
		guard let windowWidth = window?.frame.width else { return }
		
		let topBorder = CALayer()
		topBorder.frame = CGRect(x: 0, y: 0, width: windowWidth, height: 0.5)
		topBorder.backgroundColor = UIColor(named: "YP Gray")?.cgColor
		tabBar.layer.addSublayer(topBorder)
	}
	
	// MARK: - Private Helpers
	private func performCrossDissolveTransition(for window: UIWindow) {
		UIView.transition(
			with: window,
			duration: 0.3,
			options: .transitionCrossDissolve,
			animations: nil,
			completion: nil
		)
	}
}
