//
//  TGPVDocumentObject.m
//  Telegram
//
//  Created by keepcoder on 06.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPVDocumentObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadDocumentItem.h"
#import "DownloadQueue.h"
@interface TGPVDocumentObject ()
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation TGPVDocumentObject

@synthesize supportDownloadListener = _supportDownloadListener;


-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder {
    if(self = [super initWithLocation:nil placeHolder:placeholder]) {
        _message = message;
        
       
        
    }
    
    return self;
}

-(void)initDownloadItem {
    
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:mediaFilePath(self.message)];
    
    if(image.size.width > 0 && image.size.height > 0) {
        
         self.imageSize = image.size;
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[PVCACHE]];
        
        [self.delegate didDownloadImage:image object:self];
        return;
    }
    
    
    
    if((self.downloadItem && (self.downloadItem.downloadState != DownloadStateCompleted && self.downloadItem.downloadState != DownloadStateCanceled && self.downloadItem.downloadState != DownloadStateWaitingStart)) || !self.message)
        return;//[_downloadItem cancel];
    
    
    self.downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.message];
    
    self.downloadListener = [[DownloadEventListener alloc] init];
    
    _supportDownloadListener = [[DownloadEventListener alloc] init];
    
    
    [self.downloadItem addEvent:self.supportDownloadListener];
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        
        [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
        
            strongWeak();
            @try {
                if(strongSelf == weakSelf) {
                    weakSelf.isLoaded = YES;
                    
                    [weakSelf _didDownloadImage:item];
                    weakSelf.downloadItem = nil;
                    weakSelf.downloadListener = nil;
                }
            } @catch (NSException *exception) {
                
            }
        }]];
         
        
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    [Notification perform:UPDATE_READ_CONTENTS data:@{KEY_MESSAGE_ID_LIST:@[@(self.message.n_id)]}];
    [self.downloadItem start];
    
}


-(void)_didDownloadImage:(DownloadItem *)item {
    
    NSError *error = nil;
    
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:item.path];
    
    if(!image)
        image = [NSImage imageWithWebP:item.path error:&error];
    
    
    if(image != nil) {
        
        image = renderedImage(image, image.size.width > 0 && image.size.height > 0 ? image.size : self.imageSize);
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[PVCACHE]];
    }
        
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}


-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"doc:%lu",_message.media.document.n_id];
}


@end
