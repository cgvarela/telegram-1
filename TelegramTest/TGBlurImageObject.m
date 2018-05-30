//
//  TGBlurImageObject.m
//  Telegram
//
//  Created by keepcoder on 14/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGBlurImageObject.h"
#import "DownloadQueue.h"
@implementation TGBlurImageObject


-(void)initDownloadItem {
    
    if(self.thumbData == nil) {
        [super initDownloadItem];
    } else {
        
        weak();
        
        [TGImageObject.threadPool addTask:[[SThreadPoolTask alloc] initWithBlock:^(bool (^canceled)()) {
            
            strongWeak();

            
            @try {
                if(strongSelf == weakSelf) {
                    [strongSelf proccessAndDispatchData:strongSelf.thumbData];
                }

            } @catch (NSException *exception) {
                
            }
            
           
        }]];
    }
    
}


-(void)proccessAndDispatchData:(NSData *)data {
    NSImage *image = [[NSImage alloc] initWithData:data];
    
    if(image != nil && image.size.width > 0 && image.size.height > 0) {

        image = [ImageUtils blurImage:image blurRadius:25 frameSize:self.imageSize];
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(void)_didDownloadImage:(DownloadItem *)item {
    [self proccessAndDispatchData:item.result];
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"%@:blurred",[super cacheKey]];
}

@end
