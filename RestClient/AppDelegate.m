//
//  AppDelegate.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "AppDelegate.h"

#import <AFNetworkActivityIndicatorManager.h>

#import "MainViewController.h"
#import "DetailViewController.h"
#import "NSJSONSerialization+File.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[RestClientData sharedData] loadData];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.tintColor = [UIColor rc_defaultTintColor];

    [[UISwitch appearance] setOnTintColor:[UIColor rc_defaultTintColor]];
    [[UISwitch appearance] setTintColor:[UIColor rc_defaultTintColor]];

    DetailViewController *detailController = [[DetailViewController alloc] init];
    UINavigationController *detailNavController = [[UINavigationController alloc] initWithRootViewController:detailController];

    MainViewController *mainController = [[MainViewController alloc] init];
    mainController.delegate = detailController;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainController];

    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.viewControllers = @[ self.navigationController, detailNavController ];
    self.splitViewController.delegate = detailController;

    [self.window setRootViewController:self.splitViewController];

    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if (url) {
        NSDictionary *dictionary = [NSJSONSerialization rc_JSONObjectWithContentsOfURL:url];
        DLog(@"Import JSON File!!");
        DLog(@"%@", dictionary);

        if (dictionary) {
            RCGroup *group = [[RCGroup alloc] initWithDictionary:dictionary];
            if (group) {
                [[RestClientData sharedData].groups addObject:group];
                NSDictionary *userInfo = userInfo = @{ kRCGroupKey : group };;
                [[NSNotificationCenter defaultCenter] postNotificationName:GroupDidUpdateNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            }
        }
    }

    return YES;
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
    [[RestClientData sharedData] saveData];
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
    [[RestClientData sharedData] saveData];;
}

#pragma mark - Private Methods

- (void)archiveRestClientData
{
    [NSKeyedArchiver archiveRootObject:[RestClientData sharedData]
                                toFile:pathInDocumentDirectory(kRestClientDataFile)];
}

@end
