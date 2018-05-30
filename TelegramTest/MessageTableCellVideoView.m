//
//  MessageTableCellVideoView.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/13/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellVideoView.h"
#import "TMCircularProgress.h"
#import "TGTimer.h"
#import "TLPeer+Extensions.h"
#import "TMMediaController.h"
#import "TMPreviewVideoItem.h"
#import "FileUtils.h"
#import "MessageCellDescriptionView.h"

#import "TGPhotoViewer.h"
#import "TGCTextView.h"
#import <pop/POPCGUtils.h>
#import "TGCaptionView.h"
@interface MessageTableCellVideoView()
@property (nonatomic, strong) NSImageView *playImage;
@property (nonatomic,strong) BTRButton *downloadButton;
@property (nonatomic, strong) MessageCellDescriptionView *videoTimeView;

@property (nonatomic,assign) NSPoint startDragLocation;

@property (nonatomic,strong) NSView *visualView;
@end

@implementation MessageTableCellVideoView






- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        weak();
        
        self.imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
        [self.imageView setCornerRadius:4];
        

        
        [self.imageView setTapBlock:^{
           
            [weakSelf checkOperation];
            
        }];
        
        [self setProgressToView:self.imageView];
        [self.containerView addSubview:self.imageView];
        
        self.playImage = imageViewWithImage(video_play_image());
        
        [self.imageView addSubview:self.playImage];
        
        self.imageView.borderWidth = 1;
        self.imageView.borderColor = NSColorFromRGB(0xf3f3f3);
        [self.imageView setContentMode:BTRViewContentModeScaleAspectFill];
        
        [self.playImage setCenterByView:self.imageView];
        [self.playImage setAutoresizingMask:NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
        
        self.videoTimeView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(5, 5, 0, 0)];
        [self.imageView addSubview:self.videoTimeView];
                
        [self setProgressStyle:TMCircularProgressDarkStyle];
        
        
        [self.progressView setImage:image_DownloadIconWhite() forState:TMLoaderViewStateNeedDownload];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateDownloading];
        [self.progressView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
        
        [self.containerView setIsFlipped:YES];
        

    }
    return self;
}


-(void)setEditable:(BOOL)editable animated:(BOOL)animated
{
    [super setEditable:editable animated:animated];
    self.imageView.isNotNeedHackMouseUp = editable;
}

- (void)open {
    
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    if (floor(NSAppKitVersionNumber) > 1187 )  {
    
        if(!self.item.message.isFake) {
            [[TGPhotoViewer viewer] show:previewObject conversation:self.item.message.conversation isReversed:YES];
        } else {
            [[TGPhotoViewer viewer] show:previewObject];
        }
        
        
    } else {
        
        TMPreviewVideoItem *item = [[TMPreviewVideoItem alloc] initWithItem:previewObject];
        if(item) {
            [[TMMediaController controller] show:item];
        }
    }
      

}

- (void)setCellState:(CellState)cellState animated:(BOOL)animated  {
    [super setCellState:cellState animated:animated];
    
    [self.playImage setHidden:!(cellState == CellStateNormal)];
    
    
    [self.playImage setCenterByView:self.imageView];
    
    
    self.imageView.object = ((MessageTableItemVideo *)self.item).imageObject;

}

- (NSMenu *)contextMenu {
    
    
    if([self.item.message isKindOfClass:[TL_destructMessage class]])
        return [super contextMenu];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Video menu"];
    
    weak();
    
    if([self.item isset]) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(saveAs:) withObject:weakSelf];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [weakSelf performSelector:@selector(copy:) withObject:weakSelf];
        }]];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}


- (void) setItem:(MessageTableItemVideo *)item {
    [super setItem:item];
    
    [self updateDownloadState:NO];
   
    
    [self.imageView setFrameSize:item.contentSize];
    
    [self.progressView setCenterByView:self.progressView.superview];
    
    [self updateVideoTimeView];
    
}




- (void)updateVideoTimeView {
    [self.videoTimeView setFrameSize:((MessageTableItemVideo *)self.item).videoTimeSize];
    [self.videoTimeView setString:((MessageTableItemVideo *)self.item).videoTimeAttributedString];
    [self.videoTimeView setHidden:((MessageTableItemVideo *)self.item).videoTimeAttributedString == nil];
}

- (void)onStateChanged:(SenderItem *)item {
    
    
    [ASQueue dispatchOnMainQueue:^{
        if(item == self.item.messageSender) {
            [(MessageTableItemVideo *)self.item rebuildTimeString];
            [self updateVideoTimeView];
            
            if(item.state == MessageSendingStateSent) {
                [self.item doAfterDownload];
            }
        }
        
    }];
    
    [super onStateChanged:item];
}


-(void)mouseDown:(NSEvent *)theEvent {
    
    _startDragLocation = [self.containerView convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if([_imageView mouse:_startDragLocation inRect:_imageView.frame])
        return;
    
    [super mouseDown:theEvent];
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
    
    if(![_imageView mouse:_startDragLocation inRect:_imageView.frame])
    return;
    
    NSPoint eventLocation = [_imageView convertPoint: [theEvent locationInWindow] fromView: nil];
    
    if([_imageView hitTest:eventLocation]) {
        NSPoint dragPosition = [self convertPoint:self.imageView.frame.origin fromView:self.imageView];        
        NSString *path = mediaFilePath(self.item.message);
        
        
        NSPasteboard *pasteBrd=[NSPasteboard pasteboardWithName:TGImagePType];
        
        
        [pasteBrd declareTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,NSStringPboardType,nil] owner:self];
        
        
        NSImage *dragImage = [_imageView.image copy];
        
        dragImage = cropCenterWithSize(dragImage,_imageView.frame.size);
        
        dragImage = imageWithRoundCorners(dragImage,4,dragImage.size);
        
        [pasteBrd setPropertyList:@[path] forType:NSFilenamesPboardType];
        
        [pasteBrd setString:path forType:NSStringPboardType];
        
        [self dragImage:dragImage at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pasteBrd source:self slideBack:NO];
    }
    
}

@end
