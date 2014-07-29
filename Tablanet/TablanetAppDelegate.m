//
//  TablanetAppDelegate.m
//  Tablanet
//
//  Created by Valdrin on 07/12/12.
//  Copyright (c) 2012 Valdrin. All rights reserved.
//


@implementation UINavigationController (Rotation_IOS6)


-(BOOL) shouldAutorotate {
    return YES;
}

-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight; // or left if you prefer
}

@end

#import "TablanetAppDelegate.h"

#import "TablanetViewController.h"
#import "TablanetInAppPurchaseManager.h"

@implementation TablanetAppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //debug to disable purchase
    //comment this before submitting version to appstore
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isProUpgradePurchased"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
   
//    [[TablanetInAppPurchaseManager singleton] loadStore];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    TablanetViewController *multi = [[[TablanetViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:multi];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    }
    self.viewController = nav;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window{    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
