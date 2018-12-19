//
//  AppDelegate.m
//  location
//
//  Created by 孙西纯 on 2018/12/18.
//  Copyright © 2018 孙西纯. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationCenter.h"

@interface AppDelegate () 

@property (nonatomic,assign) BOOL isLaunched;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        [[[LocationCenter defaultCenter] locationManager] startMonitoringLocation];
    }else {
        _isLaunched = YES;
        [self _application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    return YES;
}

- (void)_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    if (!_isLaunched) {
        _isLaunched = YES;
        [self _application:application didFinishLaunchingWithOptions:nil];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
