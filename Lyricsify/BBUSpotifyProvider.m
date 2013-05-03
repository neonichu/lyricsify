//
//  BBUSpotifyProvider.m
//  Claudio
//
//  Created by Boris Bügling on 13.01.13.
//  Copyright (c) 2013 Boris B√ºgling. All rights reserved.
//

#import "BeamMusicPlayerViewController.h"
#import "BBUSpotifyProvider.h"
#import "CocoaLibSpotify.h"

@interface BBUSpotifyProvider ()

@property (strong) SPPlaybackManager* playbackManager;

@end

#pragma mark -

@implementation BBUSpotifyProvider

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage* image = [(SPImage*)object image];
        if (!image) {
            return;
        }
        
        [object removeObserver:self forKeyPath:keyPath];
        
        BeamMusicPlayerReceivingBlock block = (__bridge BeamMusicPlayerReceivingBlock)(context);
        block(image, nil);
        Block_release(context);
    }
}

#pragma mark - BeamMusicPlayer data-source methods

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player albumForTrack:(NSUInteger)trackNumber {
    if (self.tracks.count == 0) {
        return nil;
    }
    
    SPTrack* track = self.tracks[trackNumber];
    return track.album.name;
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player artistForTrack:(NSUInteger)trackNumber {
    if (self.tracks.count == 0) {
        return nil;
    }
    
    SPTrack* track = self.tracks[trackNumber];
    return [track.artists[0] name];
}

-(void)musicPlayer:(BeamMusicPlayerViewController *)player artworkForTrack:(NSUInteger)trackNumber
    receivingBlock:(BeamMusicPlayerReceivingBlock)receivingBlock {
    
    if (self.tracks.count == 0) {
        return;
    }
    
    SPTrack* track = self.tracks[trackNumber];
    
    SPImage* albumCover = track.album.largeCover;
    if (albumCover.image) {
        receivingBlock(albumCover.image, nil);
        return;
    }
    
    [albumCover addObserver:self forKeyPath:@"image" options:0 context:Block_copy((__bridge void *)receivingBlock)];
}

-(CGFloat)musicPlayer:(BeamMusicPlayerViewController *)player lengthForTrack:(NSUInteger)trackNumber {
    if (self.tracks.count == 0) {
        return 0.0;
    }
    SPTrack* track = self.tracks[trackNumber];
    return track.duration;
}

-(NSString *)musicPlayer:(BeamMusicPlayerViewController *)player titleForTrack:(NSUInteger)trackNumber {
    if (self.tracks.count == 0) {
        return nil;
    }
    
    SPTrack* track = self.tracks[trackNumber];
    return track.name;
}

-(NSInteger)numberOfTracksInPlayer:(BeamMusicPlayerViewController *)player {
    return self.tracks.count;
}

#pragma mark - BeamMusicPlayer delegate methods

-(void)musicPlayerDidStartPlaying:(BeamMusicPlayerViewController *)player {
    if (!self.playbackManager) {
        self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    }
    
    SPTrack* track = self.tracks[player.currentTrack];
    [self.playbackManager playTrack:track callback:^(NSError *error) {
        if (!error) return;
        NSLog(@"Playback error: %@", error.localizedDescription);
    }];
}

@end
