//
//  BBULyricsSearchViewController.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import "BBULyricsSearch.h"
#import "BBULyricsSearchViewController.h"
#import "BBUNotifications.h"
#import "BBUSpotifyPlayerController.h"
#import "MBProgressHUD.h"

@interface BBULyricsSearchViewController () <BBULyricsSearchDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextView* lyricsEntry;
@property (nonatomic, strong) BBUSpotifyPlayerController* playerController;
@property (nonatomic, strong) BBULyricsSearch* search;

@end

#pragma mark -

@implementation BBULyricsSearchViewController

-(id)init {
    self = [super init];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Type a lyrics snippet", nil);
        
        self.search = [BBULyricsSearch new];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kNothingFoundOnSpotifyNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          self.lyricsEntry.editable = YES;
                                                          self.lyricsEntry.text = @"";
                                                          [self.lyricsEntry becomeFirstResponder];
                                                      }];
    }
    return self;
}

-(void)searchForText:(NSString*)text {
    self.lyricsEntry.editable = NO;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.search.delegate = self;
    [self.search searchForText:text];
}

-(void)viewDidLoad {
    self.lyricsEntry = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 300.0)];
    self.lyricsEntry.delegate = self;
    self.lyricsEntry.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20.0];
    self.lyricsEntry.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:self.lyricsEntry];
    
    [self.lyricsEntry becomeFirstResponder];
}

#pragma mark - BBULyricsSearch delegate methods

-(void)didFailToFindTrack {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UIAlertView* alert = nil;
    
#if 0
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                       message:NSLocalizedString(@"No matching track found.", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles:nil];
#else
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                       message:NSLocalizedString(@"No track found, assuming you wanted Britney Spears.", nil)
                                      delegate:self
                             cancelButtonTitle:NSLocalizedString(@"OK", nil)
                             otherButtonTitles:nil];
#endif
    
    [alert show];
}

-(void)didFindTrack:(NSString *)track byArtist:(NSString *)artist {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString* query = [NSString stringWithFormat:@"%@ %@", artist, track];
    
    UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication]
                                                                      keyWindow].rootViewController;
    self.playerController = [BBUSpotifyPlayerController openSpotifyInNavController:navController query:query];
}

#pragma mark - UIAlertView delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self didFindTrack:@"baby one more time" byArtist:@"britney"];
}

#pragma mark - UITextView delegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self searchForText:textView.text];
        return NO;
    }
    return YES;
}

@end
