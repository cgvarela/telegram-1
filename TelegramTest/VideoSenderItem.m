//
//  VideoSenderItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 17.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "VideoSenderItem.h"
#import "ImageUtils.h"
#import "TGSendTypingManager.h"
@interface VideoSenderItem ()
@property (nonatomic,strong) NSString *path_for_file;
@property (nonatomic,strong) UploadOperation *uploader;
@property (nonatomic,assign) BOOL isCompressed;
@end

@implementation VideoSenderItem

-(void)setState:(MessageState)state {
    [super setState:state];
}

-(id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags caption:(NSString *)caption {
    if(self = [super init]) {
        self.path_for_file = path_for_file;
        self.conversation = conversation;
        NSDictionary *params = [[MessageSender videoParams:path_for_file thumbSize:strongsize(NSMakeSize(640, 480), 90)] mutableCopy];
        
        int duration = [[params objectForKey:@"duration"] intValue];
        NSSize size = NSSizeFromString([params objectForKey:@"size"]);
        
        NSImage *thumbImage = [params objectForKey:@"image"];
        
        TLPhotoSize *cachedSize;
        NSData *imageData = nil;
        if(thumbImage) {
            imageData = jpegNormalizedData(thumbImage);
            
            imageData = compressImage(imageData, 0.1);
            
            if(imageData) {
                cachedSize = [TL_photoCachedSize createWithType:@"jpeg" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:0 secret:0] w:thumbImage.size.width h:thumbImage.size.height bytes:imageData];
            }
        }
        
        
        if(!cachedSize) {
            cachedSize = [TL_photoSizeEmpty createWithType:@"x"];
        }
        
        NSMutableArray *attributes = [NSMutableArray array];
        
        [attributes addObject:[TL_documentAttributeFilename createWithFile_name:[path_for_file lastPathComponent]]];
        [attributes addObject:[TL_documentAttributeVideo createWithDuration:duration w:size.width h:size.height]];
        
        TL_messageMediaDocument *media = [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:0 access_hash:0 date:[[MTNetwork instance] getTime] mime_type:@"video/mp4" size:(int)fileSize(path_for_file) thumb:cachedSize dc_id:0 version:0 attributes:attributes] caption:caption];
        
        [TGCache cacheImage:thumbImage forKey:cachedSize.location.cacheKey groups:@[IMGCACHE]];
        
        
        self.message = [MessageSender createOutMessage:@"" media:media conversation:conversation additionFlags:additionFlags];
        
    }
    
    return self;
}


-(id)initWithPath:(NSString *)path_for_file forConversation:(TL_conversation *)conversation additionFlags:(int)additionFlags {
    return [self initWithPath:path_for_file forConversation:conversation additionFlags:additionFlags caption:nil];
}

-(void)performRequest {
    
    
    
    NSData *thumbData = self.message.media.document.thumb.bytes;

    
    NSString *export = exportPath(self.message.randomId,@"mp4");
    
    NSError *error;
    
    [[NSFileManager defaultManager] copyItemAtPath:self.path_for_file toPath:export error:&error];
    
    if(!error)
        self.path_for_file = export;
    else
        [self cancel];
    

    
    self.uploader = [[UploadOperation alloc] init];
    
    weak();
    [self.uploader setUploadComplete:^(UploadOperation *video, id input) {
        
        strongWeak();
        
        __block BOOL isFirstSend = [input isKindOfClass:[TLInputFile class]];
        __block id media = nil;

        dispatch_block_t block = ^{
            

            id request = [TLAPI_messages_sendMedia createWithFlags:[strongSelf senderFlags] peer:strongSelf.conversation.inputPeer reply_to_msg_id:strongSelf.message.reply_to_msg_id media:media random_id:strongSelf.message.randomId  reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];

            
            
            strongSelf.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates *response) {

                
                [SharedManager proccessGlobalResponse:response];
               
                [strongSelf updateMessageId:response];
                
                if(response.updates.count < 2)
                {
                    [strongSelf cancel];
                    return;
                }
                
                
                TLMessage *msg = [strongSelf updateNewMessageWithUpdates:response].message;
                
                strongSelf.message.n_id = msg.n_id;
                strongSelf.message.date = msg.date;
                    

                strongSelf.message.media.document.dc_id = [msg media].document.dc_id;
                strongSelf.message.media.document.size = [msg media].document.size;
                strongSelf.message.media.document.access_hash = [msg media].document.access_hash;
                strongSelf.message.media.document.n_id = [msg media].document.n_id;
                strongSelf.message.media.document.mime_type = msg.media.document.mime_type;
                strongSelf.message.media.document.attributes = msg.media.document.attributes;
                strongSelf.message.media.document.thumb = msg.media.document.thumb;
                
                TL_documentAttributeVideo *video = (TL_documentAttributeVideo *) [strongSelf.message.media.document attributeWithClass:[TL_documentAttributeVideo class]];
                
                [[NSFileManager defaultManager] moveItemAtPath:strongSelf.path_for_file toPath:mediaFilePath(strongSelf.message) error:nil];
            
                NSImage *thumb = [MessageSender videoParams:mediaFilePath(strongSelf.message) thumbSize:strongsize(NSMakeSize(video.w, video.h), 320)][@"image"];
                
                
                if(thumb.size.width > 0 && thumb.size.height > 0) {
                    TLFileLocation *location = msg.media.document.thumb.location;
                    
                    [TGCache cacheImage:thumb forKey:location.cacheKey groups:@[IMGCACHE]];
                    
                    [jpegNormalizedData(thumb) writeToFile:locationFilePath(location, @"jpg") atomically:YES];
                }
                

                strongSelf.uploader = nil;
                
                strongSelf.message.dstate = DeliveryStateNormal;
                
                
                [strongSelf.message save:YES];
                strongSelf.state = MessageSendingStateSent;
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                strongSelf.uploader = nil;
                
                if([strongSelf checkErrorAndReUploadFile:error path:strongSelf.filePath])
                    return;
                
                strongSelf.state = MessageSendingStateError;
            } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];
        };

        if(!isFirstSend) {
            TLVideo *video = input;
            media = [TL_inputMediaDocument createWithN_id:[TL_inputDocument createWithN_id:video.n_id access_hash:video.access_hash] caption:@""];
            block();
        } else {
            
            if(thumbData) {
                UploadOperation *thumbUpload = [[UploadOperation alloc] init];
                [thumbUpload setUploadComplete:^(UploadOperation *thumb, TL_inputFile *inputThumbFile) {
                    
                    media = [TL_inputMediaUploadedThumbDocument createWithFlags:0 file:input thumb:inputThumbFile mime_type:@"video/mp4" attributes:self.message.media.document.attributes caption:self.message.media.caption stickers:nil];
                    
                    block();
                }];
                
                [thumbUpload setFileData:thumbData];
                [thumbUpload ready:UploadImageType];
            } else {
                media = [TL_inputMediaUploadedDocument createWithFlags:0 file:input mime_type:@"video/mp4" attributes:self.message.media.document.attributes caption:self.message.media.caption stickers:nil];
                block();
            }
        }
        
        
        
       
    }];
    
    
    [self.uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        //weakSelf.progress =VIDEO_COMPRESSED_PROGRESS + (((float)current/(float)total) * (100.0f - VIDEO_COMPRESSED_PROGRESS));
        weakSelf.progress = ((float)current/(float)total) * 100.0f;
    }];
    
    [self.uploader setUploadTypingNeed:^(UploadOperation *operation) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadVideoAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    [self.uploader setUploadStarted:^(UploadOperation *operation, NSData *data) {
        [TGSendTypingManager addAction:[TL_sendMessageUploadVideoAction createWithProgress:weakSelf.progress] forConversation:weakSelf.conversation];
    }];
    
    self.isCompressed = YES;
    
    
    [self.uploader setFilePath:self.path_for_file];
    [self.uploader ready:UploadVideoType];
    
    [self.message save:YES];
    
    
//    [MessageSender compressVideo:self.path_for_file randomId:[self.message randomId] completeHandler:^(BOOL success,NSString *c) {
//        
//       
//        if(self.state == MessageSendingStateCancelled)
//            return;
//        
//        self.isCompressed = YES;
//        
//        self.path_for_file = c;
//            
//        [self.uploader setFilePath:self.path_for_file];
//        [self.uploader ready:UploadVideoType];
//        
//        [self.message save:YES];
//        
//            
//        ((TL_localMessage *)self.message).media.document.size = self.uploader.total_size;
//        self.state = self.state;
//    } progressHandler:^(float progress) {
//        self.progress = (progress/1.0f) * VIDEO_COMPRESSED_PROGRESS;
//    }];

    
}

- (void)cancel {
    
    [self.uploader cancel];
    [super cancel];
}

@end
