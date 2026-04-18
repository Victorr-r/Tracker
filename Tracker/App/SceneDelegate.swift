import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	
	var window: UIWindow?
	
	// MARK: - Scene Life Cycle
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let windowScene = (scene as? UIWindowScene) else { return }
		let window = UIWindow(windowScene: windowScene)
		self.window = window
		
		// MARK: - Controllers Setup
		let trackersVC = TrackersViewController()
		let trackersNav = UINavigationController(rootViewController: trackersVC)
		let statisticsVC = UIViewController()
		statisticsVC.view.backgroundColor = .systemBackground
		
		trackersNav.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab Bar Item"), tag: 0)
		statisticsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "Tab Bar Item2"), tag: 1)
		
		[trackersNav, statisticsVC].forEach {
			$0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
		}
		
		// MARK: - TabBar Configuration
		let tabBar = UITabBarController()
		
		if #available(iOS 18.0, *) {
			tabBar.tabBar.traitOverrides.horizontalSizeClass = .compact
		}
		
		tabBar.tabBar.itemPositioning = .centered
		tabBar.tabBar.itemSpacing = 114
		
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor(named: "YP White")
		appearance.shadowColor = .clear
		
		appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "YP Gray")
		appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "YP Blue")
		
		tabBar.tabBar.standardAppearance = appearance
		if #available(iOS 15.0, *) {
			tabBar.tabBar.scrollEdgeAppearance = appearance
		}
		
		let topBorder = CALayer()
		topBorder.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: 0.5)
		topBorder.backgroundColor = UIColor(named: "YP Gray")?.cgColor
		tabBar.tabBar.layer.addSublayer(topBorder)
		
		tabBar.tabBar.isTranslucent = false
		tabBar.tabBar.tintColor = UIColor(named: "YP Blue")
		tabBar.tabBar.unselectedItemTintColor = UIColor(named: "YP Gray")
		tabBar.viewControllers = [trackersNav, statisticsVC]
		
		// MARK: - Root Window
		window.rootViewController = tabBar
		window.makeKeyAndVisible()
	}
}
