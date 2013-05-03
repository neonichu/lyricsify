//
//  BBUAppDelegate.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris Bügling. All rights reserved.
//

#import "BBUAppDelegate.h"
#import "BBULyricsSearchViewController.h"

@implementation BBUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[BBULyricsSearchViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
