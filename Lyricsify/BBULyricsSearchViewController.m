//
//  BBULyricsSearchViewController.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import "BBULyricsSearch.h"
#import "BBULyricsSearchViewController.h"
#import "BBUSpotifyPlayerViewController.h"
#import "MBProgressHUD.h"

@interface BBULyricsSearchViewController () <BBULyricsSearchDelegate, UITextViewDelegate>

@property (nonatomic, strong) BBULyricsSearch* search;

@end

#pragma mark -

@implementation BBULyricsSearchViewController

-(id)init {
    self = [super init];
    if (self) {
        self.search = [BBULyricsSearch new];
    }
    return self;
}

-(void)searchForText:(NSString*)text {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.search.delegate = self;
    [self.search searchForText:text];
}

-(void)viewDidLoad {
    UITextView* lyricsEntry = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                           self.view.frame.size.width,
                                                                           300.0)];
    lyricsEntry.delegate = self;
    lyricsEntry.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20.0];
    lyricsEntry.returnKeyType = UIReturnKeyGo;
    [self.view addSubview:lyricsEntry];
    
    [lyricsEntry becomeFirstResponder];
}

#pragma mark - BBULyricsSearch delegate methods

-(void)didFindTrack:(NSString *)track byArtist:(NSString *)artist {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString* query = [NSString stringWithFormat:@"%@ %@", artist, track];
    
    UINavigationController* navController = (UINavigationController*)[[UIApplication sharedApplication]
                                                                      keyWindow].rootViewController;
    [navController pushViewController:[BBUSpotifyPlayerViewController openSpotifyInNavController:navController query:query]
                             animated:YES];
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
