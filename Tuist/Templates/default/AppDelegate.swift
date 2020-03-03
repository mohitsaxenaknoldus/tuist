import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let appDelegateContent = Content {
    let name = try getAttribute(for: "name")
    let platformValue = try getAttribute(for: "platform")
    let platform = try Platform.getFromAttributes()

    var appContent: String
    if platform == .macOS {
        appContent = """
        import Cocoa
        import \(name)Kit
        
        @NSApplicationMain
        class AppDelegate: NSObject, NSApplicationDelegate {
        
            @IBOutlet weak var window: NSWindow!
        
            func applicationDidFinishLaunching(_ aNotification: Notification) {
                // Insert code here to initialize your application
            }
        
            func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
            }
        
        }
        """
    } else {
        appContent = """
        import UIKit
        import \(name)Kit
        
        @UIApplicationMain
        class AppDelegate: UIResponder, UIApplicationDelegate {
        
            var window: UIWindow?
        
            func application(
                _ application: UIApplication,
                didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
            ) -> Bool {
                window = UIWindow(frame: UIScreen.main.bounds)
                let viewController = UIViewController()
                viewController.view.backgroundColor = .white
                window?.rootViewController = viewController
                window?.makeKeyAndVisible()
                return true
            }
        
        }
        """
    }

    return appContent
}
