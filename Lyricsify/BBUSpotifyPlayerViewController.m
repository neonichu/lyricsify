//
//  BBUSpotifyPlayerViewController.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import "BBUSpotifyPlayerViewController.h"
#import "BBUSpotifyProvider.h"
#import "BeamMusicPlayerViewController.h"
#import "CocoaLibSpotify.h"

static NSString* const kSpotifyCredentials  = @"kSpotifyCredentials";
static NSString* const kSpotifyUserName     = @"kSpotifyUserName";

@interface BBUSpotifyPlayerViewController () <SPLoginViewControllerDelegate, SPSessionDelegate>

@property (strong) BBUSpotifyProvider* provider;

@property (strong) SPSearch* currentSearch;
@property (strong) SPSession* session;

@end

#pragma mark -

@implementation BBUSpotifyPlayerViewController

+(BBUSpotifyPlayerViewController*)openSpotifyInNavController:(UINavigationController*)nav query:(NSString*)query {
    BBUSpotifyPlayerViewController* vc = [BBUSpotifyPlayerViewController new];
    __weak BBUSpotifyPlayerViewController* weakVC = vc;
    [vc presentLoginInViewController:nav];
    vc.loginBlock = ^() {
        [weakVC searchWithQuery:query completionBlock:^(NSArray *results, NSError *error) {
            NSLog(@"Search completed.");
            
            weakVC.provider = [BBUSpotifyProvider new];
            weakVC.provider.tracks = results;
            
            BeamMusicPlayerViewController* musicVC = [BeamMusicPlayerViewController new];
            musicVC.dataSource = weakVC.provider;
            musicVC.delegate = weakVC.provider;
            musicVC.view.frame = weakVC.view.bounds;
            [nav presentViewController:musicVC animated:YES completion:NULL];
            [musicVC reloadData];
        }];
    };
    return vc;
}

#pragma mark -

-(id)init {
    // FIXME: Only initialize once
    NSData* appKey = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"spotify_appkey" ofType:@"key"]];
    NSError* error;
    BOOL result = [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                             userAgent:@"Claudio"
                                                         loadingPolicy:SPAsyncLoadingImmediate
                                                                 error:&error];
    
    if (!result) {
        NSLog(@"Could not initialize Spotify: %@", error.localizedDescription);
        return nil;
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
