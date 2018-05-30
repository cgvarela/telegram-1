//
//  ImageSengerItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ImageSenderItem.h"
#import "FileUtils.h"
#import "ImageUtils.h"
#import "PreviewObject.h"
#import "TGCache.h"
#import "TLFileLocation+Extensions.h"
#import "TGSendTypingManager.h"
#import "TGTimer.h"
#import "MessageTableItemPhoto.h"
@interface ImageSenderItem ()
@property (nonatomic, strong) UploadOperation *uploadOperation;
@property (nonatomic, strong) NSImage *image;
@end

@implementation ImageSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

- (id)initWithImage:(NSImage *)image jpegData:(NSData *)jpegData forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags caption:(NSString *)caption {
    if(self = [super initWithConversation:conversation]) {
        
        
        NSSize realSize = image.size;
        NSSize maxSize = strongsize(realSize, MIN_IMG_SIZE.width);
        
        
        if(realSize.width < 50 || realSize.height < 50)
            self.image = [ImageUtils imageResize:image newSize:NSMakeSize(MAX(100,realSize.width), MAX(100,realSize.height))];
        else
            self.image = image;
        
        if(realSize.width > MIN_IMG_SIZE.width && realSize.height > MIN_IMG_SIZE.height && maxSize.width == MIN_IMG_SIZE.width && maxSize.height == MIN_IMG_SIZE.height) {
            
            int difference = roundf( (realSize.width - maxSize.width) /2);
            
            image = cropImage(image,maxSize, NSMakePoint(difference, 0));
            
        }
        
        
        NSData *preview = compressImage(jpegNormalizedData(renderedImage(image, strongsize(maxSize, 90))), 0.1);
        
        
        TL_photoCachedSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:realSize.width h:realSize.height bytes:preview];
        
       
        
        TL_photoSize *size1 = [TL_photoSize createWithType:@"x" location:size.location w:realSize.width h:realSize.height size:0];
        
        NSMutableArray *sizes = [[NSMutableArray alloc] init];
        
        [sizes addObject:size];
        [sizes addObject:size1];

        TL_messageMediaPhoto *photo = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithFlags:0 n_id:rand_long() access_hash:0 date:(int)[[MTNetwork instance] getTime] sizes:sizes] caption:caption];
        
        
        [TGCache cacheImage:renderedImage([[NSImage alloc] initWithData:jpegNormalizedData(image)], maxSize) forKey:size.location.cacheKey groups:@[IMGCACHE]];
      
        self.message = [MessageSender createOutMessage:@"" media:photo conversation:conversation additionFlags:additionFlags];
        
        
        [jpegData writeToFile:mediaFilePath(self.message) atomically:YES];
        [self.message save:YES];
        
        
        
    }
    return self;
}

-(void)performRequest {
    
    self.uploadOperation = [[UploadOperation alloc] init];
    
    self.filePath = mediaFilePath(self.message);
    
    weak();
    
    [self.uploadOperation setUploadComplete:^(UploadOperation *operation, id input) {
        
        __strong ImageSenderItem *strongSelf = weakSelf;
        
        
        if(strongSelf == nil || strongSelf != weakSelf)
            return;
        
        TLInputMedia *media;
        
        if([input isKindOfClass:[TL_inputPhoto class]]) {
            media = [TL_inputMediaPhoto createWithN_id:input caption:self.message.media.caption];
        } else {
            media = [TL_inputMediaUploadedPhoto createWithFlags:0 file:input caption:self.message.media.caption stickers:nil];
        }
        
        
        id request = [TLAPI_messages_sendMedia createWithFlags:[strongSelf senderFlags] peer:strongSelf.conversation.inputPeer reply_to_msg_id:strongSelf.message.reply_to_msg_id media:media random_id:strongSelf.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];

        
        strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {
            
            strongWeak();
            
            if(strongSelf == nil || strongSelf != weakSelf)
                return;
            
            [strongSelf updateMessageId:response];
            
            TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[strongSelf updateNewMessageWithUpdates:response] message]];
            
            if(msg == nil)
            {
                [strongSelf cancel];
                return;
            }
            
            [[Storage manager] setFileInfo:[TL_inputPhoto createWithN_id:msg.media.photo.n_id access_hash:msg.media.photo.access_hash] forPathHash:fileMD5(strongSelf.filePath)];
            
            
            if(strongSelf.conversation.type != DialogTypeBroadcast)  {
                strongSelf.message.n_id = msg.n_id;
                strongSelf.message.date = msg.date;
                
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:exportPath(strongSelf.message.media.photo.n_id, @"jpg") error:nil];

            
            TLPhotoSize *newSize = [msg.media.photo.sizes lastObject];
            
            if(strongSelf.message.media.photo.sizes.count > 1) {
                TL_photoSize *size =strongSelf.message.media.photo.sizes[1];
                [TGCache changeKey:size.location.cacheKey withKey:newSize.location.cacheKey];
                size.location = newSize.location;
                
            } else {
                ((TL_localMessage *)strongSelf.message).media = msg.media;
            }
            
            
            // fix file location for download image after clearing cache.
            {
//                MessageTableItemPhoto *item = (MessageTableItemPhoto *)strongSelf.tableItem;
//                
//                item.imageObject.location = newSize.location;
            }
            
             [[NSFileManager defaultManager] moveItemAtPath:strongSelf.filePath toPath:mediaFilePath(strongSelf.message) error:nil];
            
           
            strongSelf.uploadOperation = nil;
            
            strongSelf.message.dstate = DeliveryStateNormal;
            
            [strongSelf.message save:YES];
            
            
            PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:strongSelf.message.n_id media:strongSelf.message peer_id:strongSelf.message.peer_id];
            
            [Notification perform:MEDIA_RECEIVE data:@{KEY_PREVIEW_OBJECT:previewObject}];
            
            
            strongSelf.state = MessageSendingStateSent;
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
            strongSelf.uploadOperation = nil;
            
            if([strongSelf checkErrorAndReUploadFile:error path:strongSelf.filePath])
                return;
            
            strongSelf.state = MessageSendingStateError;
            
        } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];
        
    }];
    
    
    [self.uploadOperation setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        __strong ImageSenderItem *strongSelf = weakSelf;
 
        if(strongSelf != nil && strongSelf == weakSelf) {
            strongSelf.progress = ((float)current/(float)total) * 100.0f;
        }
    }];
    
    [self.uploadOperation setUploadTypingNeed:^(UploadOperation *operation) {
        __strong ImageSenderItem *strongSelf = weakSelf;
        if(strongSelf != nil && strongSelf == weakSelf) {
            [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction createWithProgress:strongSelf.progress] forConversation:strongSelf.conversation];
        }
        
    }];
    
    [self.uploadOperation setUploadStarted:^(UploadOperation *operation, NSData *data) {
        __strong ImageSenderItem *strongSelf = weakSelf;
        if(strongSelf != nil && strongSelf == weakSelf) {
            [TGSendTypingManager addAction:[TL_sendMessageUploadPhotoAction createWithProgress:strongSelf.progress] forConversation:strongSelf.conversation];
        }

        
    }];
    
    
    [self.uploadOperation setFilePath:self.filePath];
    [self.uploadOperation setFileName:@"photo.jpeg"];
    [self.uploadOperation ready:UploadImageType];
}


-(void)cancel {
    [self.uploadOperation cancel];
    [super cancel];
}



@end
