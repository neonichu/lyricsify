//
//  BBULyricsSearch.h
//  Lyricsify
//
//  Created by Boris Bügling on 03.05.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBULyricsSearchDelegate <NSObject>

-(void)didFailToFindTrack;
-(void)didFindTrack:(NSString*)track byArtist:(NSString*)artist;

@end

#pragma mark -

@interface BBULyricsSearch : NSObject

@property (nonatomic, assign) id<BBULyricsSearchDelegate> delegate;

-(void)searchForText:(NSString*)text;

@end
