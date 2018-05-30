//
//  DownloadVideoItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "DownloadVideoItem.h"
#import "FileUtils.h"
#import <AVFoundation/AVFoundation.h>
@implementation DownloadVideoItem



-(id)initWithObject:(TL_localMessage *)object {
    if(self = [super initWithObject:object]) {
        self.isEncrypted = [object isKindOfClass:[TL_destructMessage class]];
        self.n_id = object.media.document.n_id;
        self.path = mediaFilePath(object);
        self.fileType = DownloadFileVideo;
        self.dc_id = object.media.document.dc_id;
        self.size = object.media.document.size;
    }
    return self;
}

-(void)setDownloadState:(DownloadState)downloadState {
    if(self.downloadState != DownloadStateCompleted && downloadState == DownloadStateCompleted) {
        
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:self.path]];
        
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = TRUE;
        CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
        
        
        TL_localMessage *msg = (TL_localMessage *)self.object;
        
        TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [msg.media.document attributeWithClass:[TL_documentAttributeVideo class]];
        
        NSSize size = NSMakeSize(video.w, video.h);
        
        __block NSImage *thumbImg;
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            
            if (result != AVAssetImageGeneratorSucceeded) {
                MTLog(@"couldn't generate thumbnail, error:%@", error);
            }
            
            thumbImg = [[NSImage alloc] initWithCGImage:im size:size];
            dispatch_semaphore_signal(sema);
        };

        
        CGSize maxSize = size;
        generator.maximumSize = maxSize;
        
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        TLFileLocation *location = msg.media.document.thumb.location;
        
        [TGCache removeCachedImage:msg.media.document.thumb.location.cacheKey];
        
        thumbImg = prettysize(thumbImg);
        
        [jpegNormalizedData(thumbImg) writeToFile:locationFilePath(location, @"jpg") atomically:YES];
        
        [Notification perform:UPDATE_MESSAGE data:@{KEY_MESSAGE:msg}];

    }
    [super setDownloadState:downloadState];
}


-(TLInputFileLocation *)input {
    TLMessage *message = [self object];
    if(self.isEncrypted)
        return [TL_inputEncryptedFileLocation createWithN_id:self.n_id access_hash:message.media.document.access_hash];
    return [TL_inputDocumentFileLocation createWithN_id:self.n_id access_hash:message.media.document.access_hash version:message.media.document.version];
}


@end
