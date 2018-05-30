//
//  MessageTableCellContainerView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"
#import "SenderHeader.h"
#import "TMCircularProgress.h"
#import "TMLoaderView.h"
typedef enum {
    CellStateNormal = 2,
    CellStateSending = 4,
    CellStateCancelled = 8,
    CellStateDownloading = 16,
    CellStateNeedDownload = 32
} CellState;

typedef enum {
    MessageTableCellUnread,
    MessageTableCellRead,
    MessageTableCellSending,
    MessageTableCellSendingError
} MessageTableCellState;

@interface MessageTableCellContainerView : MessageTableCell<SenderListener>



@property (nonatomic, assign) CellState cellState;
@property (nonatomic) MessageTableCellState actionState;
@property (nonatomic, strong) TMView *containerView;

@property (nonatomic, strong,readonly) TMLoaderView *progressView;


-(void)setCellState:(CellState)cellState animated:(BOOL)animated;

-(void)checkOperation;

- (void)alertError;

-(void)open;

- (void)cancelDownload;
- (void)deleteAndCancel:(MessageTableItem *)item;
- (void)deleteAndCancel;
- (void)doAfterDownload;
- (void)startDownload:(BOOL)cancel;
- (void)updateCellState:(BOOL)animated;
- (void)setProgressFrameSize:(NSSize)newsize;
- (void)updateDownloadState:(BOOL)animated;
- (BOOL)canEdit;

- (void)uploadProgressHandler:(SenderItem *)item animated:(BOOL)animation;
- (void)downloadProgressHandler:(DownloadItem *)item;



- (void)setProgressToView:(NSView *)view;
- (void)setProgressStyle:(TMCircularProgressStyle)style;


- (void)checkActionState:(BOOL)redraw;

- (NSMenu *)contextMenu;

-(NSArray *)defaultMenuItems;



@end
