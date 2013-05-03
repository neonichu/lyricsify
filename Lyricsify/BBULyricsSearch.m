//
//  BBULyricsSearch.m
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

#import "BBULyricsSearch.h"
#import "GTMNSString+URLArguments.h"

static NSString* const kLyricsSearch = @"http://www.elyrics.net//inc/google_cse.html?q=%@";
static NSString* const kSuffix = @"-lyrics.html";

@interface BBULyricsSearch () <UIWebViewDelegate>

@property (nonatomic, strong) NSTimer* extractionTimer;
@property (nonatomic, strong) UIWebView* internalWebView;
@property (nonatomic, strong) NSTimer* timeoutTimer;

@end

#pragma mark -

@implementation BBULyricsSearch

-(void)extractTrackInfo {
    // TODO: Table view with multiple tracks
    NSString* html = [self.internalWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName(\"gs-visibleUrl-long\")[0].innerHTML"];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<.*?>" options:0 error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:html options:0
                                                         range:NSMakeRange(0, [html length])
                                                  withTemplate:@""];
    
    NSArray* comps = [result componentsSeparatedByString:@"/"];
    
    if (comps.count != 5) {
        return;
    }
    
    NSCharacterSet* crap = [[NSCharacterSet letterCharacterSet] invertedSet];
    
    NSString* artist = comps[3];
    artist = [artist stringByTrimmingCharactersInSet:crap];
    
    NSString* track = comps[4];
    if (![track hasSuffix:kSuffix]) {
        return;
    }
    track = [track substringToIndex:track.length - kSuffix.length];
    track = [track stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    NSLog(@"Found track: '%@' by artist '%@'", track, artist);
    
    [self stopTimers];
    
    [self.delegate didFindTrack:track byArtist:artist];
}

-(id)init {
    self = [super init];
    if (self) {
        self.internalWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.internalWebView.delegate = self;
    }
    return self;
}

-(void)searchForText:(NSString *)text {
    NSString* term = [text gtm_stringByEscapingForURLArgument];
    
    NSURL* searchURL = [NSURL URLWithString:[NSString stringWithFormat:kLyricsSearch, term]];
    [self.internalWebView loadRequest:[NSURLRequest requestWithURL:searchURL]];
    
    self.extractionTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(extractTrackInfo)
                                                          userInfo:nil repeats:YES];
    
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(timeout)
                                                       userInfo:nil repeats:NO];
}

-(void)stopTimers {
    [self.extractionTimer invalidate];
    self.extractionTimer = nil;
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

-(void)timeout {
    [self stopTimers];
    
    [self.delegate didFailToFindTrack];
}

@end
