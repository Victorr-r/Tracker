import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
	
	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
		
		setupAppMetrica()
		setupTransformers()
		
		return true
	}
	
	// MARK: - UISceneSession Lifecycle
	
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
	
	// MARK: - Private Methods
	
	private func setupAppMetrica() {
		if let configuration = AppMetricaConfiguration(apiKey: "6c1f6796-7fe3-400f-8076-10fb65578c74") {
			AppMetrica.activate(with: configuration)
		}
	}
	
	private func setupTransformers() {
		DaysValueTransformer.register()
	}
}
