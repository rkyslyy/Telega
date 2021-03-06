//
//  AppDelegate.swift
//  Telega
//
//  Created by Roman Kyslyy on 1/28/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
    if DataService.instance.token != nil {
      TelegaAPI.getInfoAboutSelf {
        TelegaAPI.establishConnection()
        NotificationCenter.default.post(
          name: CONTACTS_LOADED,
          object: nil,
          userInfo: nil) }
      let mainStoryboardIpad : UIStoryboard = UIStoryboard(
        name: "Main",
        bundle: nil)
      let initialViewControlleripad: UIViewController = mainStoryboardIpad
        .instantiateViewController(withIdentifier: "tabBar")
      self.window = UIWindow(frame: UIScreen.main.bounds)
      self.window?.rootViewController = initialViewControlleripad
      self.window?.makeKeyAndVisible()
    }
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    TelegaAPI.disconnect()
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    TelegaAPI.establishConnection()
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //        if DataService.instance.token != nil {
    //            TelegaAPI.instanse.updateInfoAboutSelf {  }
    //        }
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    TelegaAPI.disconnect()
  }
}

