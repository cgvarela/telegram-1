//
//  ImageObject.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ImageObject.h"

@interface ImageObject ()
@property (nonatomic,assign) long randomId;
@end

@implementation ImageObject


-(id)initWithLocation:(TLFileLocation *)location {
    if(self = [self initWithLocation:location placeHolder:nil sourceId:0 size:0]) {
        
    }
    return self;
}

-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:0 size:0]) {
        
    }
    return self;
}


-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId {
    if(self = [self initWithLocation:location placeHolder:placeHolder sourceId:sourceId size:0]) {
        
    }
    return self;
}

-(id)initWithLocation:(TLFileLocation *)location placeHolder:(NSImage *)placeHolder sourceId:(int)sourceId size:(int)size {
    if(self = [super init]) {
        _location = location;
        
        _randomId = rand_long();
        
        if([placeHolder isKindOfClass:[NSImage class]])
            _placeholder = placeHolder;
        _sourceId = sourceId;
        _size = size;
    }
    return self;
}

-(id)initWithLocation:(TLFileLocation *)location thumbData:(NSData *)thumbData size:(int)size  {
    if(self = [super init]) {
        _location = location;
        _thumbData = thumbData;
        _size = size;
    }
    return self;
}

-(void)initDownloadItem {
    
}

-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}


-(void)dealloc {
    [self.downloadItem removeEvent:self.downloadListener];
    self.downloadItem = nil;
}

-(NSString *)cacheKey {
    return self.location ? self.location.cacheKey : [NSString stringWithFormat:@"%ld",_randomId];
}

@end
