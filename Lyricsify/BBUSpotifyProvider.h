//
//  BBUSpotifyProvider.h
//  Claudio
//
//  Created by Boris Bügling on 13.01.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BeamMusicPlayerDataSource.h"
#import "BeamMusicPlayerDelegate.h"

@interface BBUSpotifyProvider : NSObject <BeamMusicPlayerDataSource, BeamMusicPlayerDelegate>

@property (strong) NSArray* tracks;

@end
