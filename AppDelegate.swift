import Foundation
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}
