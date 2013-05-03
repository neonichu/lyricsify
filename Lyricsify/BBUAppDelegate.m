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
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:100.0/255.0
                                                               green:183.0/255.0
                                                                blue:183.0/255.0
                                                               alpha:1.0]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{ NSFontAttributeName: @"AvenirNext-Medium" }];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc]
                                      initWithRootViewController:[BBULyricsSearchViewController new]];
    [self.window makeKeyAndVisible];
    
    // FIXME: hack, hack, hack
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return YES;
}

@end
