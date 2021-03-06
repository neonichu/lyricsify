//
//  BBUSpotifyPlayerController.h
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BBULoginBlock)();
typedef void(^BBUSearchBlock)(NSArray* results, NSError* error);

@interface BBUSpotifyPlayerController : NSObject

@property (copy) BBULoginBlock loginBlock;

-(void)presentLoginInViewController:(UIViewController*)parentViewController;
-(void)searchWithQuery:(NSString*)query completionBlock:(BBUSearchBlock)completionBlock;

+(BBUSpotifyPlayerController*)openSpotifyInNavController:(UINavigationController*)nav query:(NSString*)query;

@end
