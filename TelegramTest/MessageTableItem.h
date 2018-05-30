//
//  MessageTableItem.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SenderHeader.h"
#import "DownloadItem.h"
#import "TGReplyObject.h"
#import "NSString+FindURLs.h"

@interface MessageTableItem : NSObject<SelectTextDelegate>

@property (nonatomic,weak) MessagesTableView *table;

@property (nonatomic,assign) NSUInteger rowId;

@property (nonatomic, strong) TL_localMessage *message;

@property (nonatomic, strong) SenderItem *messageSender;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *fullDate;
@property (nonatomic, strong) TLUser *user;

@property (nonatomic, strong) NSMutableAttributedString *headerName;
@property (nonatomic, assign) NSSize headerSize;


@property (nonatomic, strong) NSMutableAttributedString *forwardName;
@property (nonatomic, assign) NSSize forwardNameSize;

@property (nonatomic,strong) NSAttributedString *forwardHeaderAttr;
@property (nonatomic,assign) NSSize forwardHeaderSize;


@property (nonatomic, strong) NSAttributedString *dateAttributedString;
@property (nonatomic) NSSize dateSize;

@property (nonatomic,assign) NSSize rightSize;

@property (nonatomic,assign) NSSize inlineKeyboardSize;


@property (nonatomic,strong) NSAttributedString *caption;
@property (nonatomic,assign) NSSize captionSize;

@property (nonatomic, strong) TLUser *fwd_user;
@property (nonatomic, strong) TLChat *fwd_chat;

@property (nonatomic,strong) TLUser *via_bot_user;


@property (nonatomic) BOOL isForwadedMessage;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isHeaderMessage;
@property (nonatomic) BOOL isHeaderForwardedMessage;



@property (nonatomic,assign,readonly) int makeSize;

@property (nonatomic) NSSize blockSize;
@property (nonatomic) NSSize contentSize;

@property (nonatomic, strong) DownloadItem *downloadItem;

@property (nonatomic,assign,readonly) int blockWidth;

@property (nonatomic,strong) TGReplyObject *replyObject;

@property (nonatomic,strong,readonly) NSAttributedString *viewsCountAndSign;
@property (nonatomic,assign,readonly) NSSize viewsCountAndSignSize;

-(BOOL)updateViews;

- (id) initWithObject:(id)object;
+ (id) messageItemFromObject:(id)object;
+ (NSArray *)messageTableItemsFromMessages:(NSArray *)input;
- (NSSize)viewSize;
- (void)setViewSize:(NSSize)size;

- (BOOL)canDownload;
- (void)clean;
- (BOOL)makeSizeByWidth:(int)width;

- (void)rebuildDate;

- (Class)downloadClass;

- (BOOL)isset;
- (BOOL)needUploader;
- (void)doAfterDownload;
- (void)startDownload:(BOOL)cancel force:(BOOL)force;
- (void)checkStartDownload:(SettingsMask)setting size:(int)size;


-(RPCRequest *)proccessInlineKeyboardButton:(TLKeyboardButton *)keyboard handler:(void (^)(TGInlineKeyboardProccessType type))handler;

+ (NSDateFormatter *)dateFormatter;

-(BOOL)canShare;

-(NSURL *)shareObject;

-(BOOL)isReplyMessage;

-(int)fontSize;

-(BOOL)isWebPage;
-(BOOL)isViaBot;


-(Class)viewClass;
-(int)cellWidth;

typedef URLFindType (^linkTypeRequest)();

@property (nonatomic,copy) linkTypeRequest linkParseTypes;


-(int)defaultPhotoWidth;
-(int)startContentOffset;
-(int)defaultContainerOffset;
-(int)defaultContentOffset;
-(int)defaultOffset;
-(int)contentHeaderOffset;

+(int)defaultOffset;
+(int)defaultContainerOffset;
-(BOOL)hasRightView;

-(NSString *)path;

@end
