//
//  InlineBotMediaSecretSenderItem.m
//  Telegram
//
//  Created by keepcoder on 22/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "InlineBotMediaSecretSenderItem.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
#import "DownloadPhotoItem.h"



@interface FileSecretSenderItem ()
-(void)performRequest;


@end

@interface InlineBotMediaSecretSenderItem ()
@property (nonatomic,strong) DownloadItem *downloadItem;
@property (nonatomic,strong) DownloadEventListener *downloadEventListener;
@end


@implementation InlineBotMediaSecretSenderItem

-(id)initWithBotContextResult:(TLBotInlineResult *)result via_bot_name:(NSString *)via_bot_name conversation:(TL_conversation *)conversation {
    if(self = [super initWithConversation:conversation]) {
        
        int ttl = self.params.ttl;
        
        TLMessageMedia *media = [TL_messageMediaBotResult createWithBot_result:result query_id:-1];
        
        self.message = [TL_destructMessage45 createWithN_id:[MessageSender getFutureMessageId] flags:TGOUTUNREADMESSAGE from_id:UsersManager.currentUserId to_id:[TL_peerSecret createWithChat_id:conversation.peer.chat_id] date:[[MTNetwork instance] getTime] message:nil media:media destruction_time:0 randomId:rand_long() fakeId:[MessageSender getFakeMessageId] ttl_seconds:ttl == -1 ? 0 : ttl entities:nil via_bot_name:via_bot_name reply_to_random_id:0 out_seq_no:-1 dstate:DeliveryStatePending];
        
        [self takeAndFillReplyMessage];
        
//        if([result isKindOfClass:[TL_botInlineMediaResultPhoto class]])
//            [self setUploaderType:UploadImageType];
//        else if([result isKindOfClass:[TL_botInlineMediaResultDocument class]])
//            [self setUploaderType:UploadDocumentType];
//        else if([result isKindOfClass:[TL_botInlineResult class]]) {
//            if([result.content_type hasPrefix:@"image"])
//                [self setUploaderType:UploadImageType];
//            else
//                [self setUploaderType:UploadVideoType];
//        }
//        
//        [self.message save:YES];
        
        
        
    }
    
    return self;
}

-(void)performRequest {
    
    self.filePath = mediaFilePath(self.message);
    
//    if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultDocument class]]) {
//        if(self.message.media.bot_result.document != nil) {
//            if(checkFileSize(self.filePath, self.message.media.bot_result.document.size)) {
//                [self startSenderAfterDownload];
//            } else
//                [self downloadBeforeSending];
//        } else {
//            if(fileSize(self.filePath) > 0) {
//                [self startSenderAfterDownload];
//            }else
//                [self downloadBeforeSending];
//        }
//    } else if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultPhoto class]]) {
//        if(self.message.media.bot_result.photo != nil) {
//            
//            TLPhotoSize *size = [self.message.media.bot_result.photo.sizes lastObject];
//            
//            if(checkFileSize(self.filePath, size.size)) {
//                [self startSenderAfterDownload];
//            } else
//                [self downloadBeforeSending];
//        } else {
//            if(fileSize(self.filePath) > 0) {
//                [self startSenderAfterDownload];
//            }else
//                [self downloadBeforeSending];
//        }
//    } else {
//        if(fileSize(self.filePath) > 0) {
//            [self startSenderAfterDownload];
//        }else
//            [self downloadBeforeSending];
//    }
    
}

-(void)downloadBeforeSending {
    
    
    NSString *external_path = self.message.media.bot_result.content_url;
    
    if(self.message.media.bot_result.document == nil && self.message.media.bot_result.photo == nil) {
        self.downloadItem = [[DownloadExternalItem alloc] initWithObject:external_path];
    } else {
        if(self.message.media.bot_result.document)
            self.downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.message];
        else
            if(self.message.media.bot_result.photo) {
                TLPhotoSize *size = [self.message.media.bot_result.photo.sizes lastObject];
                self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:[size location] size:[size size]];
            }
    }
    
    self.downloadEventListener = [[DownloadEventListener alloc] init];
    
    weak();
    
    [self.downloadEventListener setProgressHandler:^(DownloadItem *item) {
        strongWeak();
        
        if(strongSelf != nil)
            [strongSelf updateProgress];
    }];
    
    [self.downloadEventListener setCompleteHandler:^(DownloadItem *item) {
        strongWeak();
        
        if(strongSelf != nil) {
            strongSelf.downloadItem = nil;
            [strongSelf updateProgress];
            [strongSelf startSenderAfterDownload];
        }
    }];
    
    [self.downloadEventListener setErrorHandler:^(DownloadItem *item) {
        
    }];
    
    [self.downloadItem addEvent:self.downloadEventListener];
    
    [self.downloadItem start];
}

-(void)startSenderAfterDownload {
    
//    if([self.message.media.bot_result isKindOfClass:[TL_botInlineMediaResultPhoto class]] || [self.message.media.bot_result.content_type hasPrefix:@"image"]) {
//        
//        NSImage *image = imageFromFile(self.filePath);
//        
//        image = prettysize(image);
//        
//        NSSize maxSize = strongsizeWithMinMax(image.size, MIN_IMG_SIZE.height, MIN_IMG_SIZE.width);
//        
//        NSImage *thumb = strongResize(image, 90);
//        
//        NSData *thumbData = compressImage(jpegNormalizedData(thumb), 0.1);
//        
//        NSSize origin = image.size;
//        
//        NSMutableArray *sizes = [[NSMutableArray alloc] init];
//        
//        
//        TL_photoSize *photoSize = [TL_photoSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:rand_long() local_id:-1 secret:rand_long()] w:origin.width h:origin.height size:0];
//        
//        
//        TL_photoCachedSize *cachedSize = [TL_photoCachedSize createWithType:@"x" location:photoSize.location w:thumb.size.width h:thumb.size.height bytes:thumbData];
//        
//        [sizes addObject:cachedSize];
//        [sizes addObject:photoSize];
//        
//        [TGCache cacheImage:renderedImage(image, maxSize) forKey:photoSize.location.cacheKey groups:@[IMGCACHE]];
//        
//        
//        self.message.media = [TL_messageMediaPhoto createWithPhoto:[TL_photo createWithN_id:rand_long() access_hash:0 date:[[MTNetwork instance] getTime] sizes:sizes] caption:@""];
//        
//        [jpegNormalizedData(image) writeToFile:mediaFilePath(self.message) atomically:YES];
//        
//    } else {
//        TLBotInlineResult *bot_result = self.message.media.bot_result;
//        
//        CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)[NSURL fileURLWithPath:self.filePath], CGSizeMake(90, 90), nil);
//        
//        NSData *thumbData;
//        NSImage *thumb;
//        if (quickLookIcon != NULL) {
//            thumb = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(0, 0)];
//            CFRelease(quickLookIcon);
//            
//            thumbData = compressImage([ thumb TIFFRepresentation], 0.4);
//        }
//        
//        TLPhotoSize *size = [TL_photoCachedSize createWithType:@"x" location:[TL_fileLocation createWithDc_id:0 volume_id:0 local_id:0 secret:0] w:thumb.size.width h:thumb.size.height bytes:thumbData];
//        
//        if(!thumbData) {
//            size = [TL_photoSizeEmpty createWithType:@"x"];
//        }
//        
//        NSMutableArray *attrs = [NSMutableArray array];
//        [attrs addObject:[TL_documentAttributeLocalFile createWithFile_path:self.filePath]];
//        [attrs addObject:[TL_documentAttributeFilename createWithFile_name:[self.filePath lastPathComponent]]];
//        
//        self.message.media = [TL_messageMediaDocument createWithDocument:[TL_document createWithN_id:rand_long() access_hash:0 date:[[MTNetwork instance] getTime] mime_type:mimetypefromExtension([self.filePath pathExtension]) size:(int)fileSize(self.filePath) thumb:size dc_id:0 attributes:attrs] caption:@""];
//        
//        if([bot_result.type isEqualToString:@"gif"]) {
//            [self.message.media.document.attributes addObjectsFromArray:@[[TL_documentAttributeAnimated create]]];
//        }
//    }
//    
//    [self.message save:YES];
//    
//    
//    [super performRequest];
}

-(void)setProgress:(float)progress {
    [super setProgress:progress/2 + (self.downloadItem ? self.downloadItem.progress/2 : 50)];
}

-(void)updateProgress {
    self.progress = self.progress;
}


@end
