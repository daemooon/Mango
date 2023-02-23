import UIKit
import UserNotifications

extension MGConstant {
    fileprivate static let isAppHasLaunched = "IS_APP_HAS_LAUNCHED"
}

final class MPAppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !UserDefaults.standard.bool(forKey: MGConstant.isAppHasLaunched) {
            UserDefaults.shared.set(MPCTunnelMode.rule.rawValue, forKey: MGConstant.Clash.tunnelMode)
            UserDefaults.shared.set(MPCLogLevel.silent.rawValue, forKey: MGConstant.Clash.logLevel)
            UserDefaults.standard.set(MGConstant.Clash.defaultGeoIPDatabaseRemoteURLString, forKey: MGConstant.Clash.geoipDatabaseRemoteURLString)
            UserDefaults.standard.set(true, forKey: MGConstant.Clash.geoipDatabaseAutoUpdate)
            UserDefaults.standard.set(MGConstant.Clash.geoipDatabaseAutoUpdateInterval, forKey: MPCGEOIPAutoUpdateInterval.week.rawValue)
            UserDefaults.standard.setValue(true, forKey: MGConstant.isAppHasLaunched)
        }
        application.overrideUserInterfaceStyle()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { _, _ in })
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}

extension MPAppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
}

extension UIApplication {
    
    func overrideUserInterfaceStyle() {
        let current = UserDefaults.standard.string(forKey: MGConstant.theme).flatMap(MGAppearance.init(rawValue:)) ?? .system
        self.override(userInterfaceStyle: current.userInterfaceStyle)
    }
    
    private func override(userInterfaceStyle style: UIUserInterfaceStyle) {
        DispatchQueue.main.async {
            UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).compactMap({ $0.windows }).flatMap({ $0 }).forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}