//
//  BBUSpotifyPlayerController.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "BBUNotifications.h"
#import "BBUSpotifyPlayerController.h"
#import "BBUSpotifyProvider.h"
#import "BeamMusicPlayerViewController.h"
#import "CocoaLibSpotify.h"
#import "MBProgressHUD.h"

static BOOL didInitializeSpotify = NO;

NSString* const kNothingFoundOnSpotifyNotification = @"NothingFoundOnSpotifyNotification";

static NSString* const kSpotifyCredentials  = @"kSpotifyCredentials";
static NSString* const kSpotifyUserName     = @"kSpotifyUserName";

@interface BBUSpotifyPlayerController () <SPLoginViewControllerDelegate, SPSessionDelegate>

@property (strong) BBUSpotifyProvider* provider;

@property (strong) SPSearch* currentSearch;
@property (strong) SPSession* session;

@end

#pragma mark -

@implementation BBUSpotifyPlayerController

+(BBUSpotifyPlayerController*)openSpotifyInNavController:(UINavigationController*)nav query:(NSString*)query {
    BBUSpotifyPlayerController* vc = [BBUSpotifyPlayerController new];
    __weak BBUSpotifyPlayerController* weakVC = vc;
    UIView* frontmostView = [[nav.viewControllers lastObject] view];
    
    [vc presentLoginInViewController:nav];
    vc.loginBlock = ^() {
        [MBProgressHUD showHUDAddedTo:frontmostView animated:YES];
        
        [weakVC searchWithQuery:query completionBlock:^(NSArray *results, NSError *error) {
            [MBProgressHUD hideHUDForView:frontmostView animated:YES];
            
            NSLog(@"Search completed.");
            
            if (results.count <= 0) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                                message:NSLocalizedString(@"Could not find anything on Spotify.",
                                                                                          nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNothingFoundOnSpotifyNotification
                                                                    object:nil
                                                                  userInfo:nil];
                return;
            }
            
            weakVC.provider = [BBUSpotifyProvider new];
            weakVC.provider.tracks = results;
            
            BeamMusicPlayerViewController* musicVC = [BeamMusicPlayerViewController new];
            __weak BeamMusicPlayerViewController* weakMusicVC = musicVC;
            
            musicVC.actionBlock = ^() {
                // Deprecated, but I don't care...
                if (![TWTweetComposeViewController canSendTweet]) {
                    return;
                }
                
                TWTweetComposeViewController* tweetVC = [TWTweetComposeViewController new];
                NSString* artist = [weakMusicVC.dataSource musicPlayer:weakMusicVC artistForTrack:weakMusicVC.currentTrack];
                NSString* track = [weakMusicVC.dataSource musicPlayer:weakMusicVC titleForTrack:weakMusicVC.currentTrack];
                [tweetVC setInitialText:[NSString stringWithFormat:@"Listening to %@ - %@ #lyricsify", artist, track]];
                
                [musicVC presentViewController:tweetVC animated:YES completion:NULL];
            };
            
            musicVC.backBlock = ^() {
                // OK, this is stupid beyond belief...
                [weakVC.session logout:^{
                    [weakMusicVC dismissViewControllerAnimated:YES completion:NULL];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNothingFoundOnSpotifyNotification
                                                                        object:nil
                                                                      userInfo:nil];
                }];
            };
            
            musicVC.dataSource = weakVC.provider;
            musicVC.delegate = weakVC.provider;
            musicVC.view.frame = [[[nav.viewControllers lastObject] view] bounds];
            [nav presentViewController:musicVC animated:YES completion:NULL];
            [musicVC reloadData];
        }];
    };
    return vc;
}

#pragma mark -

-(id)init {
    if (!didInitializeSpotify) {
        NSData* appKey = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"spotify_appkey" ofType:@"key"]];
        NSError* error;
        BOOL result = [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                                 userAgent:@"Lyricsify"
                                                             loadingPolicy:SPAsyncLoadingImmediate
                                                                     error:&error];
        
        if (!result) {
            NSLog(@"Could not initialize Spotify: %@", error.localizedDescription);
            return nil;
        }
        
        didInitializeSpotify = YES;
    }
    
    self = [super init];
    if (self) {
        self.session = [SPSession sharedSession];
        self.session.delegate = self;
    }
    return self;
}

#pragma mark -

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"tracks"]) {
        /*for (SPTrack* track in self.currentSearch.tracks) {
         NSLog(@"%@", track.name);
         }*/
        
        BBUSearchBlock searchBlock = (__bridge BBUSearchBlock)(context);
        searchBlock(self.currentSearch.tracks, nil);
        Block_release(context);
        
        [self.currentSearch removeObserver:self forKeyPath:keyPath];
        self.currentSearch = nil;
    }
}

-(void)presentLoginInViewController:(UIViewController*)parentViewController {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString* credentials = [[NSUserDefaults standardUserDefaults] objectForKey:kSpotifyCredentials];
    NSString* userName = [[NSUserDefaults standardUserDefaults] objectForKey:kSpotifyUserName];
    
    if (credentials && userName) {
        [self.session attemptLoginWithUserName:userName existingCredential:credentials];
        return;
    }
    
    SPLoginViewController* loginVC = [SPLoginViewController loginControllerForSession:self.session];
    loginVC.loginDelegate = self;
    [parentViewController presentViewController:loginVC animated:YES completion:NULL];
}

-(void)searchWithQuery:(NSString*)query completionBlock:(BBUSearchBlock)completionBlock {
    if (self.currentSearch) {
        return;
    }
    
    self.currentSearch = [SPSearch searchWithSearchQuery:query inSession:self.session];
    [self.currentSearch addObserver:self forKeyPath:@"tracks" options:0 context:Block_copy((__bridge void *)completionBlock)];
}

#pragma mark - SPLoginViewController delegate methods

-(void)loginViewController:(SPLoginViewController *)controller didCompleteSuccessfully:(BOOL)didLogin {
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - SPSession delegate methods

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    NSLog(@"Spotify error: %@", error.localizedDescription);
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:credential forKey:kSpotifyCredentials];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:kSpotifyUserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    if (self.loginBlock) {
        self.loginBlock();
    }
}

@end
