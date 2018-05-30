//
//  TGPVMediaBehavior.m
//  Telegram
//
//  Created by keepcoder on 11.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPVMediaBehavior.h"
#import "TGPhotoViewer.h"
#import "ChatHistoryController.h"
#import "PhotoHistoryFilter.h"
#import "MessageTableItem.h"
#import "PhotoVideoHistoryFilter.h"
#import "TGVideoViewerItem.h"
@interface TGPVMediaBehavior () <MessagesDelegate>
@end

@implementation TGPVMediaBehavior

@synthesize conversation = _conversation;
@synthesize user = _user;
@synthesize request = _request;
@synthesize state = _state;
@synthesize totalCount = _totalCount;

@synthesize controller = _controller;


-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object {
    
    if(self = [self initWithConversation:conversation commonItem:object filter:[PhotoVideoHistoryFilter class]]) {
        
    }
    
    return self;
}

-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object filter:(Class)filter {
    if(self = [super init]) {
        _conversation = conversation;
        _controller = [[ChatHistoryController alloc] initWithController:self historyFilter:filter];
        
        if(object != nil)
            [_controller addMessageWithoutSavingState:object.media];
    }
    
    return self;
}

-(void)addItems:(NSArray *)items {
    
}

-(void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force {
    
}

-(void)deleteItems:(NSArray *)items orMessageIds:(NSArray *)ids {
    
}

-(void)flushMessages {
    
}

-(void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
}

- (void)didAddIgnoredMessages:(NSArray *)items {
    
}

-(NSArray *)messageTableItemsFromMessages:(NSArray *)messages  {
    
    NSMutableArray *previewObjects = [NSMutableArray array];
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        PreviewObject *preview = [[PreviewObject alloc] initWithMsdId:obj.n_id media:obj peer_id:obj.peer_id];
        
        [previewObjects addObject:preview];
    }];
    
    return previewObjects;
}

-(void)jumpToLastMessages:(BOOL)force {
    
}

-(TL_conversation *)conversation {
    return _conversation;
}

-(void)updateLoading {
    
}

-(void)load:(long)max_id next:(BOOL)next limit:(int)limit callback:(void (^)(NSArray *))callback {
    
    [_controller request:next anotherSource:YES sync:NO selectHandler:^(NSArray *result, NSRange range,HistoryFilter *filter) {
        
        [ASQueue dispatchOnStageQueue:^{
            callback(result);
        }];
        
    }];
    
    
}

-(void)removeItems:(NSArray *)items {
    
}

-(void)addItems {
    
}

-(int)totalCount {
    return [_controller itemsCount];
}

-(void)clear {
    [_request cancelRequest];
    _controller = nil;
}

-(NSArray *)convertObjects:(NSArray *)list {
    NSMutableArray *converted = [[NSMutableArray alloc] init];
    
    [list enumerateObjectsUsingBlock:^(PreviewObject *obj, NSUInteger idx, BOOL *stop) {
        
        TL_localMessage *message = (TL_localMessage *)obj.media;
        
        if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            TLPhoto *photo = message.media.photo;
            
            
            TL_photoSize *photoSize = ((TL_photoSize *)[photo.sizes lastObject]);
            
            
            NSImage *thumb;
            
            if(photo.sizes.count > 0) {
                TL_photoCachedSize *cached = photo.sizes[0];
                thumb = [[NSImage alloc] initWithData:cached.bytes];
            }
           
            
            TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:photoSize.location placeHolder:obj.reservedObject ? obj.reservedObject : thumb sourceId:_conversation.peer_id size:photoSize.size];
            
            imgObj.imageSize = NSMakeSize([photoSize w], [photoSize h]);
            
            TGPhotoViewerItem *item = [[TGPhotoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
            
            [converted addObject:item];
        } else if([message.media isKindOfClass:[TL_messageMediaDocument class]]) {
            
            TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
            
            if(video) {
                TGPVImageObject *imgObj = [[TGPVImageObject alloc] initWithLocation:message.media.document.thumb.location thumbData:nil size:message.media.document.thumb.size];
             
                imgObj.imageSize = NSMakeSize(video.w, video.h);
                
                imgObj.imageProcessor = [ImageUtils b_processor];
                
                TGVideoViewerItem *item = [[TGVideoViewerItem alloc] initWithImageObject:imgObj previewObject:obj];
                
                [converted addObject:item];
            }
        }
        
    }];
    
    return converted;
}

-(void)dealloc {
    
}


@end
