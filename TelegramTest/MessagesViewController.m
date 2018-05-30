
//
//  MessagesViewController.m
//  TelegramTest
//
//  Created by keepcedr on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//
#import "TGSendTypingManager.h"
#import "MessagesViewController.h"
#import "NSString+Size.h"
#import "MessageSender.h"
#import "TLPeer+Extensions.h"
#import "CMath.h"
#import "SpacemanBlocks.h"
#import "TGInlineAudioPlayer.h"
#import "NSImage+RHResizableImageAdditions.h"
#import "Telegram.h"
#import "AppDelegate.h"
#import "MessageTableItem.h"
#import "EncryptedParams.h"
#import "NSString+Extended.h"
#import "NSDate-Utilities.h"
#import "NSArray+BlockFiltering.h"

#import "MessageTypingView.h"
#import "MessageTableElements.h"

#import "FileUtils.h"
#import "SelfDestructionController.h"
#import "MessageTableNavigationTitleView.h"
#import "TelegramPopover.h"
#import "TMMediaController.h"
#import "TMNameTextField.h"
#import "MessageTableItemAudio.h"
#import "ImageUtils.h"
#import "EncryptedKeyWindow.h"

#import "ChatHistoryController.h"
#import "ChannelHistoryController.h"

#import "TMBottomScrollView.h"
#import "ReadHistroryTask.h"
#import "TMTaskRequest.h"
#import "PhotoVideoHistoryFilter.h"
#import "PhotoHistoryFilter.h"
#import "DocumentHistoryFilter.h"
#import "VideoHistoryFilter.h"
#import "AudioHistoryFilter.h"
#import "ChannelFilter.h"
#import "NoMessagesView.h"
#import "TMAudioRecorder.h"
#import "MessagesTopInfoView.h"
#import "HackUtils.h"
#import "SearchMessagesView.h"
#import "TGPhotoViewer.h"
#import <MtProtoKitMac/MTEncryption.h>
#import "StickersPanelView.h"
#import "StickerSenderItem.h"
#import "RequestKeySecretSenderItem.h"
#import "StickerSecretSenderItem.h"
#import "TGPasslock.h"
#import "NSString+FindURLs.h"
#import "ImageAttachSenderItem.h"
#import "FullUsersManager.h"
#import "StartBotSenderItem.h"
#import "TGHelpPopup.h"
#import "TGAudioPlayerWindow.h"
#import "MessagesUtils.h"
#import "TGModalDeleteChannelMessagesView.h"
#import "ComposeActionDeleteChannelMessagesBehavior.h"

#import "TGModernUserViewController.h"
#import "TGModernChatInfoViewController.h"
#import "TGModernChannelInfoViewController.h"
#import "ExternalGifSenderItem.h"
#import "TGContextBotsPanelView.h"
#import "TGModalCompressingView.h"
#import "CompressedDocumentSenderItem.h"
#import "ContextBotSenderItem.h"
#import "InlineBotMediaSecretSenderItem.h"
#import "MessageTableCellDateView.h"

#import "TGInputMessageTemplate.h"
#import "TGMessageEditSender.h"
#import "TGMessagesViewAlertHintView.h"
#import "TGContextMessagesvViewController.h"
#import "TGModernEmojiViewController.h"
#import "TGModernESGViewController.h"
#import "TGSplitView.h"
#import "TGMessagesNavigationEditView.h"
#import "TGModernMessagesBottomView.h"
#import "TGAnimationBlockDelegate.h"
#import "TGAttachFolder.h"
#define HEADER_MESSAGES_GROUPING_TIME (10 * 60)

#define SCROLLDOWNBUTTON_OFFSET 300





@implementation SearchSelectItem

-(id)init {
    if(self = [super init]) {
        _marks = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)clear {
    ((MessageTableItemText *)self.item).mark = nil;
    [self.marks removeAllObjects];
    _marks = nil;
}

@end

@interface MessagesViewController () <SettingsListener,TMNavagationDelegate> {
    __block SMDelayedBlockHandle _delayedBlockHandle;
    __block SMDelayedBlockHandle _messagesHintHandle;
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *messagesKeys;
@property (nonatomic, assign) BOOL locked;

@property (nonatomic,strong) NSMutableDictionary *typingReservation;
@property (nonatomic, strong) ChatHistoryController *historyController;
@property (nonatomic, strong) SelfDestructionController *destructionController;
@property (nonatomic, strong) RPCRequest *typingRequest;

@property (nonatomic,strong) TL_localMessage *jumpMessage;
//Bottom
@property (nonatomic, strong) MessageTypingView *typingView;



@property (nonatomic, strong) TMNameTextField *nameTextField;


@property (nonatomic, strong) NoMessagesView *noMessagesView;
@property (nonatomic, strong) TMBottomScrollView *jumpToBottomButton;

@property (nonatomic, assign) BOOL isMarkIsset;


@property (nonatomic,assign) int lastBottomOffsetY;
@property (nonatomic,assign) int lastBottomScrollOffset;

@property (nonatomic, strong) TMTextButton *normalNavigationLeftView;
@property (nonatomic, strong) MessageTableNavigationTitleView *normalNavigationCenterView;
@property (nonatomic, strong) TGMessagesNavigationEditView *normalNavigationRightView;

@property (nonatomic, strong) TMTextButton *editableNavigationRightView;
@property (nonatomic, strong) TMTextButton *editableNavigationLeftView;

@property (nonatomic, strong) TMTextButton *editableMessageNavigationLeftView;


@property (nonatomic, strong) TMTextButton *filtredNavigationLeftView;
@property (nonatomic, strong) TMTextButton *filtredNavigationCenterView;



@property (nonatomic,strong) MessagesTopInfoView *topInfoView;

@property (nonatomic,assign) int ignoredCount;

@property (nonatomic,strong) SearchMessagesView *searchMessagesView;


@property (nonatomic,strong) NSMutableArray *searchItems;

@property (nonatomic,strong) id activity;

@property (nonatomic,strong) MessageTableItemUnreadMark *unreadMark;

@property (nonatomic,strong) StickersPanelView *stickerPanel;
@property (nonatomic,strong) TGContextBotsPanelView *contextBotsPanelView;


@property (nonatomic,strong) NSMutableArray *replyMsgsStack;

@property (nonatomic,strong) RPCRequest *webPageRequest;

@property (nonatomic, strong) TL_conversation *conversation;

@property (nonatomic, strong) TGMessagesHintView *hintView;

@property (nonatomic,assign) BOOL needNextRequest;

@property (nonatomic,strong) TGMessagesViewAlertHintView *messagesAlertHintView;

@property (nonatomic,strong) TGModernESGViewController *esgViewController;


@property (nonatomic,strong) TGModernMessagesBottomView *modernMessagesBottomView;

@end

@implementation MessagesViewController

- (id)init {
    self = [super init];
    return self;
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    return self;
}



- (NoMessagesView *)noMessagesView {
    if(self->_noMessagesView)
        return self->_noMessagesView;
    
    NoMessagesView *view = [[NoMessagesView alloc] initWithFrame:NSMakeRect(0, 60, self.view.bounds.size.width, self.view.bounds.size.height-60)];
    
    self->_noMessagesView = view;
    return self.noMessagesView;
}

- (void)jumpToLastMessages:(BOOL)force {
    
    BOOL animated = YES;
    
    
    if(!force) {
        if(self.replyMsgsStack.count > 0)
        {
            TL_localMessage *msg = [self.replyMsgsStack lastObject];
            
            [self.replyMsgsStack removeObject:[self.replyMsgsStack lastObject]];
            
            [self showMessage:msg fromMsg:nil animated:YES selectText:nil switchDiscussion:NO flags:ShowMessageTypeReply];
            return;
        }
    }
    
    
    
    if(_historyController.prevState != ChatHistoryStateFull || force) {
        
        [self flushMessages];
        
        [self.historyController drop:YES];
        
        self.isMarkIsset = NO;
                
        self.historyController = nil;
        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:self.defHFClass];
        animated = NO;
        
        
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        
        
        
        [self.table.scrollView scrollToPoint:NSMakePoint(0, 0) animation:animated];
        
        return;
    }
    
    if(_jumpToBottomButton.messagesCount > 0 && !_jumpToBottomButton.isHidden) {
        
        
        
        [self deleteItem:_unreadMark];
        
        
        
        if(!_unreadMark)
        {
            _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkAfterSecondsType];
        }
        
       // [self insertAndGoToEnd:<#(NSRange)#> forceEnd:<#(BOOL)#> items:<#(NSArray *)#>]
        
        int pos = _jumpToBottomButton.messagesCount + 1;
        
        NSArray *items = @[_unreadMark];
        
        NSRange range = [self insertMessageTableItemsToList:items startPosition:pos needCheckLastMessage:YES backItems:&items checkActive:NO];
        
        [self insertAndGoToEnd:range forceEnd:NO items:items];
        scrolledAfterAddedUnreadMark = NO;
        
       // [self messagesLoadedTryToInsert:@[_unreadMark] pos:_jumpToBottomButton.messagesCount+1 next:NO];

        //[self.table.scrollView scrollToPoint:NSMakePoint(0, self.table.scrollView.documentOffset.y - (addScrollOffset ? _unreadMark.viewSize.height : -_unreadMark.viewSize.height)) animation:NO];
      
        dispatch_async(dispatch_get_current_queue(), ^{
            [self scrollToUnreadItem:YES];
        });
        
        
        return;
    }
    
    [self.table.scrollView scrollToPoint:NSMakePoint(0, 0) animation:animated];
    
}

-(Class)hControllerClass {
    return self.conversation.type == DialogTypeChannel ? [ChannelHistoryController class] : [ChatHistoryController class];
}

-(Class)defHFClass {
    return self.conversation.type == DialogTypeChannel ? [ChannelFilter class] : [HistoryFilter class];
}


-(NSArray *)messageList {
    return [self.messages copy];
}

-(void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}

- (void)loadView {

    [super loadView];
    
    _replyMsgsStack = [[NSMutableArray alloc] init];
    
    self.typingReservation = [[NSMutableDictionary alloc] init];
    
    self.locked = NO;
    
    [Notification addObserver:self selector:@selector(messageNeedUpdate:) name:UPDATE_MESSAGE];
    [Notification addObserver:self selector:@selector(messageReadNotification:) name:MESSAGE_READ_EVENT];
    [Notification addObserver:self selector:@selector(messageTableItemUpdate:) name:UPDATE_MESSAGE_ITEM];
    [Notification addObserver:self selector:@selector(messageTableItemsWebPageUpdate:) name:UPDATE_WEB_PAGE_ITEMS];
    [Notification addObserver:self selector:@selector(messageTableItemsReadContents:) name:UPDATE_READ_CONTENTS];
    [Notification addObserver:self selector:@selector(messageTableItemsEntitiesUpdate:) name:UPDATE_MESSAGE_ENTITIES];
    [Notification addObserver:self selector:@selector(messagTableEditedMessageUpdate:) name:UPDATE_EDITED_MESSAGE];
    [Notification addObserver:self selector:@selector(updateMessageTemplate:) name:UPDATE_MESSAGE_TEMPLATE];
    
    [Notification addObserver:self selector:@selector(needSwapDialog:) name:SWAP_DIALOG];

    
    [Notification addObserver:self selector:@selector(didChangeDeleteDialog:) name:DIALOG_DELETE];
    
    [Notification addObserver:self selector:@selector(updateMessageViews:) name:UPDATE_MESSAGE_VIEWS];
    
    [Notification addObserver:self selector:@selector(showHintAlertView:) name:SHOW_ALERT_HINT_VIEW];
    
    [self.view setAutoresizesSubviews:YES];
    [self.view setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidBecomeKeyNotification object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowBecomeNotification:) name:NSWindowDidResignKeyNotification object:self.view.window];
    
    [Notification addObserver:self selector:@selector(updateChat:) name:CHAT_UPDATE_TYPE];
    
    self.messages = [[NSMutableArray alloc] init];
    self.messagesKeys = [[NSMutableDictionary alloc] init];
    self.selectedMessages = [[NSMutableArray alloc] init];
    
    weak();
    
    //Navigation
    self.normalNavigationRightView = [[TGMessagesNavigationEditView alloc] init];
    
    self.normalNavigationRightView.controller = self;
    
    self.filtredNavigationCenterView = [TMTextButton standartUserProfileButtonWithTitle:@"nil"];
    
    [self.filtredNavigationCenterView setFont:TGSystemFont(14)];
    [self.filtredNavigationCenterView setAlignment:NSCenterTextAlignment];
    
    [self.filtredNavigationCenterView setTextColor:BLUE_UI_COLOR];
    
    [self.filtredNavigationCenterView setFrameOrigin:NSMakePoint(0, -13)];
    
    
    self.filtredNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    
    
    [self.filtredNavigationLeftView setTapBlock:^{ 
        [weakSelf setHistoryFilter:[weakSelf defHFClass] force:NO];
    }];
    
    self.normalNavigationCenterView = [[MessageTableNavigationTitleView alloc] initWithFrame:NSZeroRect];
    [self.normalNavigationCenterView setController:self];
    
    [self.normalNavigationCenterView setTapBlock:^{
        if(![Telegram isTripleLayout] && self.class != [TGContextMessagesvViewController class])
            [weakSelf.navigationViewController showInfoPage:weakSelf.conversation];
    }];
    self.centerNavigationBarView = self.normalNavigationCenterView;
    
    
    
    self.editableNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.DeleteAll", nil)];
    
    [self.editableNavigationLeftView setTapBlock:^{
          [weakSelf clearHistory:weakSelf.conversation];
    }];
    
    
    self.editableNavigationRightView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Done", nil)];
    [self.editableNavigationRightView setTapBlock:^{
        [weakSelf unSelectAll];
    }];
    
    
    self.editableMessageNavigationLeftView = [TMTextButton standartMessageNavigationButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    
    [self.editableMessageNavigationLeftView setTapBlock:^{
        [weakSelf setEditableMessage:nil];
    }];
    


    //Center
    _table = [[MessagesTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.bounds) , NSHeight(self.view.bounds))];
    [self.table setAutoresizesSubviews:YES];
    [self.table.containerView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
    [self.table setDelegate:self];
    [self.table setDataSource:self];
    [self.table setViewController:self];
    
     self.table.layer.superlayer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
    
    
    [self.view addSubview:self.table.containerView];
    
    
    if(self.class == [MessagesViewController class]) {
        _esgViewController = [[TGModernESGViewController alloc] initWithFrame:NSMakeRect(NSMaxX(self.table.frame), 0, 350, NSHeight(self.view.bounds) )];
        [_esgViewController setIsLayoutStyle:YES];
        
        _esgViewController.view.autoresizingMask = NSViewMinXMargin | NSViewHeightSizable;
        _esgViewController.messagesViewController = self;
    }
    

    
    self.typingView = [[MessageTypingView alloc] initWithFrame:self.view.bounds];
    

    
    _modernMessagesBottomView = [[TGModernMessagesBottomView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width , 50) messagesController:self];
    
    [self.view addSubview:_modernMessagesBottomView];
    
    
    [self.view addSubview:self.noMessagesView];
    [self showNoMessages:NO];
    
    
    self.jumpToBottomButton = [[TMBottomScrollView alloc] initWithFrame:NSMakeRect(0, 0, 60, 44)];
    [self.jumpToBottomButton setAutoresizingMask:NSViewMinXMargin];
    [self.jumpToBottomButton setHidden:YES];
    [self.jumpToBottomButton setCallback:^{
        [weakSelf jumpToLastMessages:NO];
    }];
    
    self.jumpToBottomButton.messagesViewController = self;
    [self.view addSubview:self.jumpToBottomButton];
    
    
    self.topInfoView = [[MessagesTopInfoView alloc] initWithFrame:NSMakeRect(0,self.view.frame.size.height, self.view.frame.size.width, 40)];
    
    self.topInfoView.controller = self;
    
    [self.topInfoView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable];
    
    [self.view addSubview:self.topInfoView];
    
   
    
    self.searchMessagesView = [[SearchMessagesView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.view.frame), NSWidth(self.table.containerView.frame), 40)];
    [self.searchMessagesView setAutoresizingMask:NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewWidthSizable];
    
    self.searchMessagesView.controller = self;
    
    [self.view addSubview:self.searchMessagesView];
    
    self.searchItems = [[NSMutableArray alloc] init];
    
    
    
    [self.searchMessagesView setHidden:YES];
    
    
    self.stickerPanel = [[StickersPanelView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.modernMessagesBottomView.frame), NSWidth(self.table.containerView.frame), 76)];
    self.stickerPanel.messagesViewController = self;
    
    [self.view addSubview:self.stickerPanel];
    
    [self.stickerPanel hide:NO];
    
    self.hintView = [[TGMessagesHintView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.modernMessagesBottomView.frame), NSWidth(self.table.containerView.frame), 100)];
    self.hintView.messagesViewController = self;
    [self.hintView setHidden:YES];
    
    [self.view addSubview:self.hintView];
    
    
    _messagesAlertHintView = [[TGMessagesViewAlertHintView alloc] initWithFrame:NSMakeRect(0, NSHeight(self.view.frame) - 25, NSWidth(self.table.containerView.frame), 25)];
    
    [self.view addSubview:_messagesAlertHintView];
    [_messagesAlertHintView setHidden:YES];

    
}

-(void)didChangeDeleteDialog:(NSNotification *)notification {
    TL_conversation *conversation = notification.userInfo[KEY_DIALOG];
    
    if(conversation.peer_id == _conversation.peer_id && self.navigationViewController.currentController == self && ![notification.userInfo[KEY_DATA] boolValue]) {
        [self.navigationViewController goBackWithAnimation:NO];
    }
    
}

-(void)_didStackRemoved {
    
    
    self.conversation = nil;
    [self.historyController stopChannelPolling];
    self.historyController = nil;
    [self flushMessages];
}

static NSMutableDictionary *savedScrolling;


-(void)saveScrollingState {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        savedScrolling = [NSMutableDictionary dictionary];
    });
    
    if(_conversation) {
        NSRange range = [self.table rowsInRect:[self.table visibleRect]];
        
        if(self.table.scrollView.documentSize.height > NSHeight(self.table.scrollView.frame)) {
            NSUInteger index = range.location + range.length - 1;
            
            int yTopOffset = 0;
            
            if(index != NSNotFound) {
                NSRect rect = [self.table rectOfRow:index];
                
                yTopOffset =  self.table.scrollView.documentOffset.y + NSHeight(self.table.containerView.frame) - (rect.origin.y);
                
                MessageTableItem *item = [self objectAtIndex:index];
                if(item && item.message && self.table.scrollView.documentOffset.y > 100) {
                    savedScrolling[@(_conversation.peer_id)] = @{@"message":item.message,@"topOffset":@(yTopOffset)};
                } else {
                    [savedScrolling removeObjectForKey:@(_conversation.peer_id)];
                }
                
            
            } else {
                [savedScrolling removeObjectForKey:@(_conversation.peer_id)];
            }
        } else {
            [savedScrolling removeObjectForKey:@(_conversation.peer_id)];
        }

    }
    
    
}


-(BOOL)isShownESGController {
    return self.esgViewController.view.superview != nil;
}

-(BOOL)canShownESGController {
    return self.class == [MessagesViewController class] && self.conversation.canSendMessage && NSWidth(self.view.frame) > 850;
}

-(void)showOrHideESGController:(BOOL)animated toggle:(BOOL)toggle {
    
    static BOOL locked = NO;
    
    if(toggle)
        [SettingsArchiver toggleDefaultEnabledESGLayout];
    
    if(!locked) {
        
        locked = YES;
        
        BOOL show = self.esgViewController.view.superview == nil;
        
        weak();
        
        [self.esgViewController.emojiViewController setInsertEmoji:^(NSString *e) {
            [weakSelf.modernMessagesBottomView _insertEmoji:e];
        }];
        
        if(show) {
            [self.view addSubview:self.esgViewController.view];
            [self.esgViewController show];
        }
        
        dispatch_block_t resize = ^{
            [animated ? [self.table.containerView animator] : self.table.containerView  setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.table.containerView.frame))];
            [animated ? [self.table animator] : self.table setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.table.frame))];
            
            [animated ? [self.esgViewController.view animator] : self.esgViewController.view setFrameOrigin:NSMakePoint(!show ? NSMaxX(self.view.frame) : NSMaxX(self.view.frame) - NSWidth(_esgViewController.view.frame), NSMinY(self.esgViewController.view.frame))];
            [animated ? [self.modernMessagesBottomView animator] : self.modernMessagesBottomView setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : (NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame)), NSHeight(self.modernMessagesBottomView.frame))];
            [animated ? [self.esgViewController.view animator] : self.esgViewController.view setFrameSize:NSMakeSize(NSWidth(_esgViewController.view.frame), NSHeight(self.view.frame))];
            [animated ? [self.stickerPanel animator] : self.stickerPanel setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.stickerPanel.frame))];
            [animated ? [self.topInfoView animator] : self.topInfoView setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.stickerPanel.frame))];
            [animated ? [self.searchMessagesView animator] : self.searchMessagesView setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.stickerPanel.frame))];
            [self.noMessagesView setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.noMessagesView.frame))];
            [self.hintView setFrameSize:NSMakeSize(!show ?  NSWidth(self.view.frame) : NSWidth(self.view.frame) - NSWidth(_esgViewController.view.frame), NSHeight(self.hintView.frame))];
        };
        
        dispatch_block_t complete = ^{
            if(!show) {
                [self.esgViewController.view removeFromSuperview];
                [self.esgViewController close];
            }
            
            locked = NO;
            
            [_modernMessagesBottomView setActiveEmoji:show];
        };
        
        if(animated) {
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
                
                resize();
                
            } completionHandler:complete];
        } else {
            resize();
            complete();
        }
        
        [self jumpToBottomButtonDisplay];
        
    }
    
    
}


-(void)messagTableEditedMessageUpdate:(NSNotification *)notification {
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    if(message.peer_id == _conversation.peer_id) {
        
        [self.historyController updateMessage:message];
        
        
        [self.historyController items:@[@(message.n_id)] complete:^(NSArray *items) {
            
            [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                
               MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
                NSUInteger index = [self indexOfObject:item];

                if(item && index != NSNotFound) {
                    
                     item = [MessageTableItem messageItemFromObject:obj];
                    
                    if(item) {
                        MessageTableItem *prevItem;
                        
                        if(index+1 < self.messages.count-1) {
                            prevItem = self.messages[index+1];
                        }
                        
                        [self isHeaderMessage:item prevItem:prevItem];
                        
                        item.table = self.table;
                        [item makeSizeByWidth:item.makeSize];
                        
                        [self.messages replaceObjectAtIndex:index withObject:item];
                        self.messagesKeys[@(message.channelMsgId)] = item;
                        if(index != NSNotFound) {
                            
                            [[NSAnimationContext currentContext] setDuration:0.0f];
                            [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
                            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                            [self scrollToUnreadItemWithStartPositionChecking];
                            
                            //                        NSTableRowView *rowView = [self.table rowViewAtRow:index makeIfNecessary:NO];
                            //
                            //                        MessageTableCell *cell = rowView.subviews[0];
                            //
                            //                        MessageTableCell *nCell = (MessageTableCell *) [self tableView:_table viewForTableColumn:nil row:index];
                            //
                            //
                            //
                            //                        [self.table endUpdates];
                            //                        [nCell setFrameSize:NSMakeSize(NSWidth(cell.frame), item.viewSize.height)];
                            //
                            //#ifdef TGDEBUG
                            //                        assert(nCell.class == item.viewClass);
                            //#endif
                            //                        if(nCell.class != item.viewClass)
                            //                            return;
                            //
                            //                        POPBasicAnimation *fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
                            //                        fadeOut.fromValue = @(1.0f);
                            //                        fadeOut.toValue = @(0.0f);
                            //                        fadeOut.duration = 0.3;
                            //                        fadeOut.removedOnCompletion = YES;
                            //                        [cell.layer pop_addAnimation:fadeOut forKey:@"opacity"];
                            //
                            //                        [fadeOut setCompletionBlock:^(POPAnimation *animation, BOOL success) {
                            //
                            //                            if(success) {
                            //                                
                            //                                cell.layer.opacity = 1.0f;
                            //                                [cell setItem:item];
                            //                                [nCell removeFromSuperview];
                            //                                
                            ////                                if(![notification.userInfo[@"nonselect"] boolValue])
                            ////                                    [cell searchSelection];
                            //                            }
                            //                            
                            //                        }];
                            //                        
                            //                        assert(nCell != nil);
                            //                        
                            //                        [rowView addSubview:nCell positioned:NSWindowBelow relativeTo:cell];
                        }
                    }
                    
                    
                    
                    
                }
            }];
            
        }];
    }
    
}

-(void)updateMessageTemplate:(NSNotification *)notification {
    if([notification.userInfo[KEY_PEER_ID] intValue] == _conversation.peer_id) {
        
        
        TGInputMessageTemplate *t = notification.userInfo[KEY_TEMPLATE];
        
        if(t.applyNextNotification) {
            //t.applyNextNotification = NO;
            
            if(_editTemplate.type == TGInputMessageTemplateTypeEditMessage && !t.editMessage && [notification.userInfo[KEY_DATA] boolValue])
            {
                [self setEditableMessage:nil];
                return;
            }
            
            _editTemplate = t;
            [_modernMessagesBottomView setInputTemplate:_editTemplate animated:YES];
            
        }
        
    }
}

-(void)needSwapDialog:(NSNotification *)notification {
    
    int oPeerId = [notification.userInfo[@"o"] intValue];
    int nPeerId = [notification.userInfo[@"n"] intValue];
    
    if(_conversation.peer_id == oPeerId) {
        TL_conversation *conversation = [[DialogsManager sharedManager] find:nPeerId];
        
        if(conversation) {
            [self setCurrentConversation:conversation];
        }
    }
}


-(void)messageNeedUpdate:(NSNotification *)notification {
    
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    
    if(self.conversation.peer_id == message.peer_id) {
        
        [self.historyController updateMessage:message];
        
        [self.historyController items:@[@(message.n_id)] complete:^(NSArray *items) {
            
            if(items.count == 1) {
                MessageTableItem * item = [self itemOfMsgId:((TL_localMessage *)items[0]).channelMsgId randomId:((TL_localMessage *)items[0]).randomId];
                item.message = items[0];
                
                [item makeSizeByWidth:item.makeSize];
                
                
                
                NSUInteger index = [self indexOfObject:item];
               
                [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
                [self scrollToUnreadItemWithStartPositionChecking];

            }
            
            
        }];
    }
}

-(void)messageTableItemUpdate:(NSNotification *)notification {
    
    __block MessageTableItem *item = notification.userInfo[@"item"];
    
    
    dispatch_block_t block = ^{
        [item makeSizeByWidth:item.makeSize];
        
        NSUInteger index = [self indexOfObject:item];
        
        if(index != NSNotFound) {
            
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
            [self scrollToUnreadItemWithStartPositionChecking];

        }
    };
    
    if(!item) {
        if(self.conversation.peer_id == [notification.userInfo[KEY_PEER_ID] intValue]) {
            [self.historyController items:@[notification.userInfo[KEY_MESSAGE_ID]] complete:^(NSArray *items) {
                
                if(items.count == 1) {
                    item = [self itemOfMsgId:((TL_localMessage *)items[0]).channelMsgId randomId:((TL_localMessage *)items[0]).randomId];
                    block();
                }
               
                
            }];
        }
        
    } else {
        block();
    }
    
    
    
    
    
}

-(void)messageTableItemsReadContents:(NSNotification *)notification  {
    NSArray *messages = notification.userInfo[KEY_MESSAGE_ID_LIST];
        
    [self.historyController items:messages complete:^(NSArray *items) {
        
        [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
            item.message.flags&=~TGREADEDCONTENT;
            NSUInteger index = [self indexOfObject:item];
            
            if(index != NSNotFound) {
                [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            
        }];
        
    }];
    
}


-(void)messageTableItemsWebPageUpdate:(NSNotification *)notification {
    
    NSArray *messages = notification.userInfo[KEY_DATA][@(self.conversation.peer_id)];
    
    TLWebPage *webpage = notification.userInfo[KEY_WEBPAGE];
    
    [self.historyController items:messages complete:^(NSArray *items) {
        
        [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
            
            MessageTableItemText *item = (MessageTableItemText *) [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
            
            if([item isKindOfClass:[MessageTableItemText class]]) {
                NSUInteger index = [self indexOfObject:item];
                
                item.message.media.webpage = webpage;
                
                [item updateWebPage];
                
                [item makeSizeByWidth:item.makeSize];
                
                item.isHeaderMessage = item.isHeaderMessage || item.webpage != nil;
                
                if(index != NSNotFound) {
                    [self.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:index]];
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                    [self scrollToUnreadItemWithStartPositionChecking];
                }

            }
            
            
        }];
        
    }];
    
    
}

-(void)updateMessageViews:(NSNotification *)notification {
    
    
    if(self.conversation.peer_id == [notification.userInfo[KEY_PEER_ID] intValue]) {
        [self.historyController items:notification.userInfo[KEY_MESSAGE_ID_LIST] complete:^(NSArray *items) {
            NSDictionary *data = notification.userInfo[KEY_DATA];
            
            [items enumerateObjectsUsingBlock:^(TL_localMessage *message, NSUInteger idx, BOOL *stop) {
                
                MessageTableItem *item = [self itemOfMsgId:message.channelMsgId randomId:message.randomId];
                
                NSUInteger index = [self indexOfObject:item];
                
                item.message.views = [data[@(item.message.n_id)] intValue];
                
                BOOL upd = [item updateViews];
                
                if(upd && index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
            }];
            
        }];
    }
    
}

//-(void)messageTableItemsHoleUpdate:(NSNotification *)notification {
//    
//    
//    
//    
//    if(self.historyController.filter.class == [ChannelImportantFilter class]) {
//        TGMessageGroupHole *hole = notification.userInfo[KEY_GROUP_HOLE];
//        
//        if(hole.peer_id == self.conversation.peer_id) {
//            [self.historyController items:@[@(hole.uniqueId)] complete:^(NSArray *items) {
//                
//                MessageTableItemHole *item;
//                
//                if(items.count == 1) {
//                    
//                    item = (MessageTableItemHole *) [self itemOfMsgId:[[items firstObject] channelMsgId] randomId:[[items firstObject] randomId]];
//                    
//                    if(hole.messagesCount != 0) {
//                        
//                        [ASQueue dispatchOnMainQueue:^{
//                            NSUInteger index = [self indexOfObject:item];
//                            
//                            [item updateWithHole:hole];
//                            
//                            if(index != NSNotFound) {
//                                [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
//                            }
//                        }];
//                        
//                        
//                    } else {
//                        [Notification perform:MESSAGE_DELETE_EVENT data:@{KEY_DATA:@[@{KEY_PEER_ID:@(hole.peer_id),KEY_MESSAGE_ID:@(hole.uniqueId)}]}];
//                    }
//                } else {
//                    [Notification performOnStageQueue:MESSAGE_RECEIVE_EVENT data:@{KEY_MESSAGE:[TL_localMessageService createWithHole:hole]}];
//                }
//            }];
//        }
//    }
//
//}

-(void)messageTableItemsEntitiesUpdate:(NSNotification *)notification {
    
    TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
    
    
    if(message.peer_id == self.conversation.peer_id) {
        [self.historyController items:@[@(message.n_id)] complete:^(NSArray *items){
            
            [items enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
                
                MessageTableItemText *item = (MessageTableItemText *) [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
                
                NSUInteger index = [self indexOfObject:item];
                
                [item updateEntities];
                
                if(index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
                
            }];
        }];
    }
    
    
}


-(void)showSearchBox {
    
    if(!self.searchMessagesView.isHidden) {
        [self.searchMessagesView becomeFirstResponder];
        return;
    }
    
    
    [self.searchMessagesView showSearchBox:^(TL_localMessage *msg, NSString *searchString) {
        
        [self showMessage:msg fromMsg:nil animated:NO selectText:searchString switchDiscussion:NO flags:ShowMessageTypeReply];
        
    } closeCallback:^{
         [self hideSearchBox:YES];
    }];
   
    
 //   [self hideConnectionController:YES];
 //   [self hideTopInfoView:YES];
    
    [self.searchMessagesView setHidden:NO];
    

    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - 40);
    NSPoint newPoint = NSMakePoint(0,self.view.frame.size.height-40);
    
    [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
        [context setDuration:0.3];
        [[self.searchMessagesView animator] setFrameOrigin:newPoint];
        [[self.table.scrollView animator] setFrameSize:newSize];
        [self.searchMessagesView setNeedsDisplay:YES];
        
    } completionHandler:^{
        [self.searchMessagesView becomeFirstResponder];
    }];
    
}


-(void)nextSearchResult {
    if(self.searchBoxIsVisible)
        [self.searchMessagesView next];
}
-(void)prevSearchResult {
    if(self.searchBoxIsVisible)
        [self.searchMessagesView prev];
}

-(BOOL)searchBoxIsVisible {
    return !self.searchMessagesView.isHidden;
}


-(void)hideSearchBox:(BOOL)animated {
    
    if(self.searchMessagesView.isHidden)
        return;
    
    if(self.historyController != nil && self.historyController.prevState != ChatHistoryStateFull)
        [self jumpToLastMessages:YES];
    
    [self.searchItems enumerateObjectsUsingBlock:^(SearchSelectItem *obj, NSUInteger idx, BOOL *stop) {
        
        [obj clear];
        
        if([self indexOfObject:obj.item] != NSNotFound) {
            [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[self.messages indexOfObject:obj.item]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        }
        
        
        
    }];
    
    
    [self.searchItems removeAllObjects];

    
    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
    
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.searchMessagesView animator] setFrameOrigin:newPoint];
            [[self.table.scrollView animator] setFrameSize:newSize];
            [self.searchMessagesView setNeedsDisplay:YES];
            
        } completionHandler:^{
            [self.searchMessagesView setHidden:YES];
            [self.searchMessagesView resignFirstResponder];
        }];
    } else {
        [self.searchMessagesView setFrameOrigin:newPoint];
        [self.table.scrollView setFrameSize:newSize];
        [self.searchMessagesView setNeedsDisplay:YES];
        [self.searchMessagesView setHidden:YES];
    }
    
}


- (void)setCellsEditButtonShow:(BOOL)show animated:(BOOL)animated {
    
    if(![self acceptState: show ? MessagesViewControllerStateEditable : MessagesViewControllerStateNone])
        return;
    
    if(show) {
        [self setEditableMessage:nil];
    }
    
    [self setState: show ? MessagesViewControllerStateEditable : MessagesViewControllerStateNone animated:animated];
    for(int i = 0; i < self.messages.count; i++) {
        TGModernMessageCellContainerView *cell = (TGModernMessageCellContainerView *)[self cellForRow:i];
        if([cell isKindOfClass:[TGModernMessageCellContainerView class]] && [cell canEdit]) {
            [cell setEditable:self.state == MessagesViewControllerStateEditable animated:animated];
        }
    }

    
}




-(NSAttributedString *)stringForSharedMedia:(NSString *)mediaString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    [string appendString:mediaString withColor:BLUE_UI_COLOR];
    
    [string setFont:TGSystemFont(14) forRange:NSMakeRange(0, string.length)];
    
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:headerMediaIcon()]];
    
    [string setAlignment:NSCenterTextAlignment range:NSMakeRange(0, string.length)];
    
    return string;
}


static NSTextAttachment *headerMediaIcon() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_HeaderDropdownArrow() imageWithInsets:NSEdgeInsetsMake(0, 5, 0, 4)]];
    });
    return instance;
}

- (void)showNoMessages:(BOOL)show {
    
    [ASQueue dispatchOnMainQueue:^{
        
        if((self.conversation.user.isBot && ( (self.historyController.nextState == ChatHistoryStateFull &&  (self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]]))))) {
          
            [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewBlockChat];
            
            if(_modernMessagesBottomView.onClickToLockedView == nil) {
                weak();
                
                [_modernMessagesBottomView setOnClickToLockedView:^{
                    [weakSelf sendMessage:@"/start" forConversation:weakSelf.conversation];
                    [weakSelf.modernMessagesBottomView setOnClickToLockedView:nil];
                    [weakSelf.modernMessagesBottomView setActionState:weakSelf.state == MessagesViewControllerStateEditable ? TGModernMessagesBottomViewActionsState : TGModernMessagesBottomViewNormalState];
                }];
            }

        } else if(_modernMessagesBottomView.onClickToLockedView == nil || _modernMessagesBottomView.bot_start_var.length == 0) {
            
            TGModernMessagesBottomViewState nState = self.state == MessagesViewControllerStateEditable ? TGModernMessagesBottomViewActionsState : _modernMessagesBottomView.actionState;
            
            if(nState != _modernMessagesBottomView.actionState) {
                [_modernMessagesBottomView setActionState:nState];
                [_modernMessagesBottomView setSectedMessagesCount:self.selectedMessages.count deleteEnable:[self canDeleteMessages] forwardEnable:_conversation.type != DialogTypeSecretChat];
            }
            
            
            
            
            [_modernMessagesBottomView setOnClickToLockedView:nil];
        }
       
        
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.noMessagesView setHidden:!show];
        
        [self.table.containerView setHidden:show];
        [CATransaction commit];
        
        [self updateLoading];
    }];
}

-(void)updateLoading {
    
    [ASQueue dispatchOnMainQueue:^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self.noMessagesView setLoading:self.historyController.isProccessing || _needNextRequest];
        [CATransaction commit];
    }];
}

-(void)showBotStartButton:(NSString *)startParam bot:(TLUser *)bot {
    [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewBlockChat];
    _modernMessagesBottomView.bot_start_var = startParam;
    
    
    weak();
    [_modernMessagesBottomView setOnClickToLockedView:^{
       
        TL_conversation *conversation = weakSelf.conversation;
        
        [ChatHistoryController dispatchOnChatQueue:^{
            
            [weakSelf sendStartBot:weakSelf.modernMessagesBottomView.bot_start_var forConversation:conversation bot:bot];
            
            [ASQueue dispatchOnMainQueue:^{
                
                [weakSelf.modernMessagesBottomView setOnClickToLockedView:nil];
                [weakSelf.modernMessagesBottomView setActionState:TGModernMessagesBottomViewNormalState];
                
            }];
       
        }];
    
        
    }];
    
}

-(void)sendStartBot:(NSString *)startParam forConversation:(TL_conversation *)conversation bot:(TLUser *)bot {
    
    if(!conversation.canSendMessage)
        return;
    
     [ChatHistoryController dispatchOnChatQueue:^{
         StartBotSenderItem *sender = [[StartBotSenderItem alloc] initWithMessage:conversation.type == DialogTypeChat || conversation.type == DialogTypeChannel ? [NSString stringWithFormat:@"/start@%@",bot.username] : @"/start"  forConversation:conversation bot:bot startParam:startParam];
         
         [self.historyController addAndSendMessage:sender.message sender:sender];
     }];

}


- (void)updateChat:(NSNotification *)notify {
    TLChat *chat = [notify.userInfo objectForKey:KEY_CHAT];
    
    if(self.conversation.type == DialogTypeChat && self.conversation.peer.chat_id == chat.n_id) {
        [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewNormalState];
    }
}

- (void)setState:(MessagesViewControllerState)state {
    [self setState:state animated:NO];
    
}

-(BOOL)acceptState:(MessagesViewControllerState)state {
    return self.conversation.canEditConversation || state == MessagesViewControllerStateNone;
}

-(TMView *)standartRightBarView {
    return (TMView *) self.normalNavigationRightView;
}

- (void)setState:(MessagesViewControllerState)state animated:(BOOL)animated {
    
    self->_state = state;
    
    id rightView, leftView, centerView;
    
    centerView = self.normalNavigationCenterView;
    
    [self.hintView setHidden:self.hintView.isHidden || state != MessagesViewControllerStateNone];
    
    if(state == MessagesViewControllerStateNone) {
        rightView = [self standartRightBarView];
        leftView = [self standartLeftBarView];
        
        [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewNormalState animated:animated];
        
    } else if(state == MessagesViewControllerStateFiltred) {
        rightView = self.filtredNavigationLeftView;
        leftView = self.normalNavigationLeftView;
        centerView = self.filtredNavigationCenterView;
        
        self.filtredNavigationCenterView.attributedStringValue = [self stringForSharedMedia:[self.historyController.filter description]];
        // [self.filtredNavigationCenterView sizeToFit];
        
    } else if(state == MessagesViewControllerStateEditable) {
        rightView = self.editableNavigationRightView;
        leftView = self.conversation.type == DialogTypeChannel ? [self standartLeftBarView]  : self.editableNavigationLeftView;
        [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewActionsState animated:animated];
    } else if(state == MessagesViewControllerStateEditMessage) {
        leftView = self.editableMessageNavigationLeftView;
        rightView = self.normalNavigationRightView;
    }
    
    if(!self.conversation.canEditConversation)
        rightView = nil;
    
    if(self.rightNavigationBarView != rightView)
        [self setRightNavigationBarView:rightView animated:YES];
    
    if(self.leftNavigationBarView != leftView)
        [self setLeftNavigationBarView:leftView animated:YES];
    
    if(self.centerNavigationBarView != centerView) {
        [self setCenterNavigationBarView:centerView];
    }
    
}

- (void)rightButtonAction {
    
    if([[TMAudioRecorder sharedInstance] isRecording])
        return;
    
    [[[Telegram sharedInstance] firstController] closeAllPopovers];
    
    [self.navigationViewController showInfoPage:self.conversation];
}




+(NSMenu *)destructMenu:(dispatch_block_t)ttlCallback click:(dispatch_block_t)click {
    NSMenu *submenu = [[NSMenu alloc] init];
    
    MessagesViewController *controller = [Telegram rightViewController].messagesViewController;
    
    
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.Off",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:0 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSecond",nil),1] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:1 forConversation:controller.conversation callback:ttlCallback];
        }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),2] withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:2 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),3] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:3 forConversation:controller.conversation callback:ttlCallback];
        }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1)
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),4] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:4 forConversation:controller.conversation callback:ttlCallback];
        }]];

    [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),5] withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:5 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    if(controller.conversation.encryptedChat.encryptedParams.layer != 1) {
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),6] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:6 forConversation:controller.conversation callback:ttlCallback];
        }]];
        
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),7] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:7 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),8] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:8 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),9] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:9 forConversation:controller.conversation callback:ttlCallback];
        }]];
        
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),10] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:10 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),11] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:11 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),12] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:12 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),13] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:13 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),14] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:14 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),15] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:15 forConversation:controller.conversation callback:ttlCallback];
        }]];
        [submenu addItem:[NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Secret.SelfDestruct.RandomSeconds",nil),30] withBlock:^(id sender) {
            if(click) click();
            [controller sendSecretTTL:30 forConversation:controller.conversation callback:ttlCallback];
        }]];

    }
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1m",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1h",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1d",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60*24 forConversation:controller.conversation callback:ttlCallback];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Secret.SelfDestruct.1w",nil) withBlock:^(id sender) {
        if(click) click();
        [controller sendSecretTTL:60*60*24*7 forConversation:controller.conversation callback:ttlCallback];
    }]];
    
    
    return submenu;
}


+(NSMenu *)notifications:(dispatch_block_t)callback conversation:(TL_conversation *)conversation click:(dispatch_block_t)click {
    
    
    NSMenu *submenu = [[NSMenu alloc] init];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Enable",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:0];
    }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute1Hour",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:60*60 + 60];
    }]];
    
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute8Hours",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:8*60*60 + 60];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Mute2Days",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:2*24*60*60 + 60];
    }]];
    [submenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Notifications.Menu.Disable",nil) withBlock:^(id sender) {
        if(click) click();
        [conversation muteOrUnmute:callback until:365*24*60*60];
    }]];

    
    return submenu;
}


-(NSArray *)fwdMessages:(TL_conversation *)conversation {
    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];
    return template.forwardMessages;
}


-(void)clearFwdMessages:(TL_conversation *)conversation {
    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];
    
    template.forwardMessages = nil;
    
    [template performNotification];
}

-(void)setFwdMessages:(NSArray *)fwdMessages forConversation:(TL_conversation *)conversation {
    
    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:conversation.peer_id];
    
    template.forwardMessages = fwdMessages;
    
    [template performNotification];
    
}

-(void)performForward:(TL_conversation *)conversation {
    [ASQueue dispatchOnMainQueue:^{
        
        NSArray *fwdMessages = [self fwdMessages:conversation];
        
        if(fwdMessages.count > 0) {
            [self forwardMessages:fwdMessages conversation:conversation callback:nil];
            [self clearFwdMessages:conversation];
        }
        
    }];
}

- (void)setHistoryFilter:(Class)filter force:(BOOL)force {
    
    assert([NSThread isMainThread]);
    
    if(self.conversation.type == DialogTypeChannel)
        filter = self.historyController.filter.class;
    
    if(self.historyController.filter.class != filter || force) {
        self.ignoredCount = 0;
        [self flushMessages];
        _historyController = [[self.historyController.class alloc] initWithController:self historyFilter:filter];
        [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        self.state = MessagesViewControllerStateNone;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
    [TMMediaController setCurrentController:[TMMediaController controller]];

    [self.typingView setDialog:_conversation];
    
    [self tryRead];
    
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(((!self.conversation.canSendMessage || ![SettingsArchiver isDefaultEnabledESGLayout]) && self.isShownESGController) || (self.canShownESGController && !self.isShownESGController && [SettingsArchiver isDefaultEnabledESGLayout])) {
        [self showOrHideESGController:NO toggle:NO];
    } else {
        [_modernMessagesBottomView setActiveEmoji:self.messagesViewController.isShownESGController];
        [_esgViewController show];
    }
    
    
    if(_conversation && _conversation.type == DialogTypeUser) {
        [[FullUsersManager sharedManager] requestUserFull:_conversation.user withCallback:nil];
    }
    
//
    [self.table reloadData];
    
    [self setState:self.state];
    if(self.state == MessagesViewControllerStateEditable)
        [_modernMessagesBottomView setSectedMessagesCount:self.selectedMessages.count deleteEnable:[self canDeleteMessages] forwardEnable:_conversation.type != DialogTypeSecretChat];
    
    [self checkUserActivity];
    
    if(self.conversation) {
        [Notification perform:@"ChangeDialogSelection" data:@{KEY_DIALOG:self.conversation, @"sender":self}];
    }
    
    [self.table.scrollView setHasVerticalScroller:YES];
}

-(void)checkUserActivity {
#ifdef __MAC_10_10
    
    if([NSUserActivity class] && (self.conversation.type == DialogTypeChannel || self.conversation.type == DialogTypeChat || self.conversation.type == DialogTypeUser)) {
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:USER_ACTIVITY_CONVERSATION];
        //   activity.webpageURL = [NSURL URLWithString:@"http://telegram.org/dl"];
        activity.userInfo = @{@"peer":@{
                                      @"id":@(self.conversation.peer_id)},
                              @"user_id":@([UsersManager currentUserId])};
        
        activity.title = @"org.telegram.conversation";
        
        self.activity = activity;
        
        [self.activity becomeCurrent];
    }
    
#endif
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [Notification perform:@"ChangeDialogSelection" data:@{}];
    
   [self.table.scrollView setHasVerticalScroller:NO];
    
    if(![globalAudioPlayer().delegate isKindOfClass:[TGAudioGlobalController class]]) {
        [globalAudioPlayer() stop];
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    }
    
     [_esgViewController close];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    
    
    if(NSClassFromString(@"NSUserActivity")) {
        [self.activity invalidate];
    }
    
}



- (int)attachmentsCount {
    return _modernMessagesBottomView.attachmentsCount;
}


- (void) addScrollEvent {
    id clipView = [[self.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void) removeScrollEvent {
    id clipView = [[self.table enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}

- (void)bottomViewChangeSize:(int)height animated:(BOOL)animated {
    if(height == _lastBottomOffsetY)
        return;
    
    _lastBottomOffsetY = height;
    
    
    NSRect newFrame = NSMakeRect(0, _lastBottomOffsetY, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY);
    
    if(animated) {
        
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
       
//        int presentHeight = NSHeight(self.table.scrollView.frame);
//        int presentY = NSMinY(self.table.scrollView.frame);
//        CALayer *presentLayer = (CALayer *)[self.table.scrollView.layer presentationLayer];
//        
//        if(presentLayer && [self.table.scrollView.layer animationForKey:@"height"]) {
//            presentHeight = [[presentLayer valueForKeyPath:@"bounds.size.height"] floatValue];
//        }
//        
//        if(presentLayer && [self.table.scrollView.layer animationForKey:@"position"]) {
//            presentY = [[presentLayer valueForKeyPath:@"position.y"] floatValue];
//        }
//        
//        CABasicAnimation *sAnim = [CABasicAnimation animationWithKeyPath:@"frame.size.height"];
//        sAnim.duration = 0.2;
//        sAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        sAnim.removedOnCompletion = YES;
//        
//        sAnim.fromValue = @(presentHeight);
//        sAnim.toValue = @(NSHeight(newFrame));
//        [self.table.scrollView.layer removeAnimationForKey:@"height"];
//        [self.table.scrollView.layer addAnimation:sAnim forKey:@"height"];
//        
//        
//        sAnim = [CABasicAnimation animationWithKeyPath:@"position"];
//        sAnim.duration = 0.2;
//        sAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
//        sAnim.removedOnCompletion = YES;
//        
//        sAnim.fromValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(self.table.scrollView.frame), presentY)];
//        sAnim.toValue = [NSValue valueWithPoint:NSMakePoint(NSMinX(self.table.scrollView.frame), NSMinY(newFrame))];
//        
//        
//        
//        
//        [self.table.scrollView setFrame:newFrame];
//        
//        [self.table.scrollView.layer removeAnimationForKey:@"position"];
//        [self.table.scrollView.layer addAnimation:sAnim forKey:@"position"];
//        
        
        [[self.table.scrollView animator] setFrame:newFrame];
        
        [[self.noMessagesView animator] setFrame:newFrame];
        
        [[self.stickerPanel animator] setFrameOrigin:NSMakePoint(NSMinX(self.stickerPanel.frame), height)];
        [[self.hintView animator] setFrameOrigin:NSMakePoint(NSMinX(self.hintView.frame), height)];
    } else {
        [self.table.scrollView setFrame:newFrame];
        [self.noMessagesView setFrame:newFrame];
        
        [self.stickerPanel setFrameOrigin:NSMakePoint(NSMinX(self.stickerPanel.frame), height)];
        [self.hintView setFrameOrigin:NSMakePoint(NSMinX(self.hintView.frame), height)];
    }
    
    
   
    [self jumpToBottomButtonDisplay];
    
    
}

- (CAAnimation *)animationForTablePosition:(NSPoint)from to:(NSPoint)to {
    CAAnimation *positionAnimation = [TMAnimations postionWithDuration:5.0 fromValue:from toValue:to];
    
    
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return positionAnimation;
}

-(void)showHintAlertView:(NSNotification *)notification {
    
    NSString *text = notification.userInfo[@"text"];
    NSColor *color = notification.userInfo[@"color"];
    
    [_messagesAlertHintView setText:text backgroundColor:color];
    
    [_messagesAlertHintView setFrameSize:NSMakeSize(NSWidth(self.table.containerView.frame), NSHeight(_messagesAlertHintView.frame))];
    
    void (^runAnimation)(BOOL hide) = ^(BOOL hide){
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[_messagesAlertHintView animator] setFrameOrigin:NSMakePoint(NSMinX(_messagesAlertHintView.frame), hide ? NSHeight(self.view.frame) : (NSHeight(self.view.frame) - NSHeight(_messagesAlertHintView.frame)))];
            
        } completionHandler:^{
            [_messagesAlertHintView setHidden:hide];
        }];
    };
    
    if(_messagesAlertHintView.isHidden) {
        [_messagesAlertHintView setHidden:NO];
        [_messagesAlertHintView setFrameOrigin:NSMakePoint(NSMinX(_messagesAlertHintView.frame), NSHeight(self.view.frame))];
        runAnimation(NO);
    }
    
    
    cancel_delayed_block(_messagesHintHandle);
    
    _messagesHintHandle = perform_block_after_delay(3.5, ^{
        runAnimation(YES);
    });
    
}

- (void)showTopInfoView:(BOOL)animated {
    
    
    
    NSRect topRect = NSMakeRect(0,self.view.frame.size.height-NSHeight(self.topInfoView.frame), self.view.frame.size.width, NSHeight(self.topInfoView.frame));
    NSRect tableRect = NSMakeRect(0, self.table.scrollView.frame.origin.y, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - NSHeight(self.topInfoView.frame));
    
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.topInfoView animator] setFrame:topRect];
            [[self.table.scrollView animator] setFrame:tableRect];
            [self.topInfoView setNeedsDisplay:YES];
        } completionHandler:nil];
    } else {
        self.topInfoView.frame = topRect;
        [self.table.scrollView setFrame:tableRect];
    }
    
}


- (void)hideTopInfoView:(BOOL)animated {
    
    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
    if(animated) {
        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
            [context setDuration:0.3];
            [[self.table.scrollView animator] setFrameSize:newSize];
            [[self.topInfoView animator] setFrameOrigin:newPoint];
            [self.topInfoView setNeedsDisplay:YES];
        } completionHandler:nil];
        
    } else {
        [self.table.scrollView setFrameSize:newSize];
        [self.topInfoView setFrameOrigin:newPoint];
    }
    
}

-(void)showOrHideChannelDiscussion {
    
    
    [self.replyMsgsStack removeAllObjects];
    
    if(self.table.scrollView.documentOffset.y > 0) {
        NSRange range = [self.table rowsInRect:[self.table visibleRect]];
        __block MessageTableItem *item;
        
        [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if(![obj isKindOfClass:[MessageTableItemHole class]] && idx >= 2) {
                item = obj;
                *stop = YES;
            }
            
            
        }];
        
        
        if(item) {
            [self showMessage:item.message fromMsg:nil flags:0];
            return;
        } 

    }
    
    
    Class f = [ChannelFilter class];
    
    [self.historyController setFilter:[[f alloc] initWithController:self.historyController peer:_conversation.peer]];
    
    [self flushMessages];
    [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];

    
    
}

//- (void)showConnectionController:(BOOL)animated {
//    
//    [self hideTopInfoView:NO];
//    
//    self.connectionController.alphaValue = 0.0;
//    [self.connectionController setHidden:NO];
//    NSRect topRect = NSMakeRect(0,self.view.frame.size.height-20, self.view.frame.size.width, 20);
//    NSRect tableRect = NSMakeRect(0, self.table.scrollView.frame.origin.y, self.table.scrollView.frame.size.width, self.view.frame.size.height - _lastBottomOffsetY - 20);
//    
//    if(animated) {
//        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
//            [context setDuration:0.3];
//            [[self.connectionController animator] setAlphaValue:1.0f];
//            [[self.connectionController animator] setFrame:topRect];
//            [[self.table.scrollView animator] setFrame:tableRect];
//        } completionHandler:nil];
//    } else {
//        self.connectionController.frame = topRect;
//        [self.connectionController setAlphaValue:1.0f];
//        [self.table.scrollView setFrame:tableRect];
//    }
//    
//}


//- (void)hideConnectionController:(BOOL)animated {
//    self.connectionController.alphaValue = 1.0f;
//    [self.connectionController setHidden:NO];
//    NSSize newSize = NSMakeSize(self.table.scrollView.frame.size.width, self.view.frame.size.height-_lastBottomOffsetY);
//    NSPoint newPoint = NSMakePoint(0, self.view.frame.size.height);
//    if(animated) {
//        [NSAnimationContext runAnimationGroup: ^(NSAnimationContext *context) {
//            [context setDuration:0.3];
//            [[self.table.scrollView animator] setFrameSize:newSize];
//            [[self.connectionController animator] setFrameOrigin:newPoint];
//            [[self.connectionController animator] setAlphaValue:0.0f];
//            
//            
//        } completionHandler:^{
//            [self.connectionController setHidden:YES];
//            if([self.topInfoView isShown])
//                [self showTopInfoView:YES];
//        }];
//        
//    } else {
//        [self.table.scrollView setFrameSize:newSize];
//        [self.connectionController setHidden:YES];
//        [self.connectionController setFrameOrigin:newPoint];
//        if([self.topInfoView isShown])
//            [self showTopInfoView:NO];
//    }
//    
//}

- (void)showForwardMessagesModalView {
    [[Telegram rightViewController] showForwardMessagesModalView:self.conversation messagesCount:self.selectedMessages.count];
}


- (void)jumpToBottomButtonDisplay {
    [self.jumpToBottomButton sizeToFit];
    [self.jumpToBottomButton setFrameOrigin:NSMakePoint(NSWidth(self.table.bounds) - NSWidth(_jumpToBottomButton.bounds) - 30, NSHeight(_modernMessagesBottomView.frame) + 30)];
}


- (void)updateScrollBtn {
    static int min_go_size = 300;
    static int max_go_size = 500;
    
    float offset = self.table.scrollView.documentOffset.y;
    
    
    
    if([self.table.scrollView isAnimating])
        return;
    
    _lastBottomScrollOffset = offset;
    
    
    BOOL hide = !(self.table.scrollView.documentSize.height > min_go_size && offset > min_go_size);
    
    
    
    if(hide) {
        hide = !(self.isMarkIsset && offset > max_go_size);
    }
    
    if(hide && (offset - self.table.scrollView.bounds.size.height) > SCROLLDOWNBUTTON_OFFSET) {
        hide = self.jumpToBottomButton.messagesCount == 0;
    }
//    
//
    
    if(hide)
    {
        hide = self.replyMsgsStack.count == 0;
        
        if(!hide)
        {
            MessageTableItem *item = [self itemOfMsgId:[[_replyMsgsStack lastObject] channelMsgId] randomId:[[_replyMsgsStack lastObject] randomId]];
            
            if(item) {
                NSRect rowRect = [self.table rectOfRow:[self indexOfObject:item]];
                
                hide = CGRectContainsRect([self.table visibleRect], rowRect) || self.table.scrollView.documentOffset.y < rowRect.origin.y;
                
                
                if(hide) {
                    [_replyMsgsStack removeLastObject];
                }
            }
            
           
            
        }
    }
    
    if(hide) {
        [self.historyController prevStateAsync:^(ChatHistoryState state,ChatHistoryController *controller) {
         
            if(controller == self.historyController) {
                BOOL h = (hide && state == ChatHistoryStateFull) || !self.noMessagesView.isHidden;
                
                if(self.jumpToBottomButton.isHidden != h) {
                    [self.jumpToBottomButton setHidden:h];
                    [self jumpToBottomButtonDisplay];
                }
            }
            
            
            
        }];
    } else {
        if(self.jumpToBottomButton.isHidden != hide) {
            [self.jumpToBottomButton setHidden:hide];
            [self jumpToBottomButtonDisplay];
        }
    }
    
}

- (void)scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    [self updateScrollBtn];
    
    scrolledAfterAddedUnreadMark = YES;
    
    if([self.table.scrollView isNeedUpdateTop]) {
        
        [self.historyController prevStateAsync:^(ChatHistoryState state,ChatHistoryController *controller) {
            if(state != ChatHistoryStateFull && self.historyController == controller) {
                [self loadhistory:0 toEnd:NO prev:YES isFirst:NO];
            }
        }];
        
   } else if([self.table.scrollView isNeedUpdateBottom]) {
        
        [self.historyController nextStateAsync:^(ChatHistoryState state,ChatHistoryController *controller) {
            if(state != ChatHistoryStateFull && self.historyController == controller) {
                [self loadhistory:0 toEnd:NO prev:NO isFirst:NO];
            }
        }];
    }
    
   // [self tryRead];
}

- (void) dealloc {
    [Notification removeObserver:self];
}

- (void) drop {
    self.conversation = nil;
    [self.historyController drop:YES];
    self.historyController = nil;
    [self.messages removeAllObjects];
    [self.messagesKeys removeAllObjects];
    [self.table deselectRow:self.table.selectedRow];
    [self.table reloadData];
    [Notification removeObserver:self];
}

-(void)dialogDeleteNotification:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    if(self.conversation.peer.peer_id == dialog.peer.peer_id) {
        [self.messages removeAllObjects];
        [self.messagesKeys removeAllObjects];
        [self.table reloadData];
    }
}

- (void)windowBecomeNotification:(NSNotification *)notify {
    if(![TMViewController isModalActive])
        [self becomeFirstResponder];
    
    [self tryRead];
    
    if(_conversation &&_conversation.type == DialogTypeUser) {
        [[FullUsersManager sharedManager] requestUserFull:_conversation.user withCallback:nil];
    }
    
    
    [self.normalNavigationCenterView setDialog:self.conversation];
    
    
    
    if(self.unreadMark) {
        self.unreadMark.removeType = RemoveUnreadMarkAfterSecondsType;
        
        dispatch_after_seconds(5, ^{
            
            [self deleteItem:self.unreadMark];
            self.unreadMark = nil;
            
        });
    }
}

- (void)messageReadNotification:(NSNotification *)notify {
    
    NSArray *readed = [notify.userInfo objectForKey:KEY_MESSAGE_ID_LIST];
    
    [ASQueue dispatchOnMainQueue:^{
        [self.historyController items:readed complete:^(NSArray * filtred) {
            
            
            
            [filtred enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
               MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
                
              
                
                item.message.flags&= ~TGUNREADMESSAGE;
                
                NSUInteger index = [self indexOfObject:item];
                
                if(index != NSNotFound) {
                    [self.table reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                }
                
            }];
            
            if(readed.count == 0) {
                [self.table reloadData];
            }
            
            
        }];
    }]; 
    
}

- (MessageTableCell *)cellForRow:(NSInteger)row {
    
    @try {
        return [self.table rowViewAtRow:row makeIfNecessary:NO].subviews[0];
    } @catch (NSException *exception) {
        return nil;
    }
    
}


- (void)receivedMessage:(MessageTableItem *)message position:(int)position itsSelf:(BOOL)force  {
    
    NSArray *items;
    
    NSRange range = [self insertMessageTableItemsToList:@[message] startPosition:position needCheckLastMessage:YES backItems:&items checkActive:!force];
    
    if(range.length) {
        if(message.message.from_id != [UsersManager currentUserId]) {
            if(self.table.scrollView.documentOffset.y > SCROLLDOWNBUTTON_OFFSET) {
                [self.jumpToBottomButton setHidden:NO];
                [self.jumpToBottomButton setMessagesCount:self.jumpToBottomButton.messagesCount + 1];
                [self jumpToBottomButtonDisplay];
            }
            
        }
        
        [self insertAndGoToEnd:range forceEnd:force items:items];
        [self didUpdateTable];
    }
}


- (void)didAddIgnoredMessages:(NSArray *)items {
    self.ignoredCount+= (int)items.count;
}

-(void)setIgnoredCount:(int)ignoredCount {
    
    [CATransaction begin];
    
    [CATransaction disableActions];
    
    self->_ignoredCount = ignoredCount;
    if(ignoredCount > 0) {
        [self.filtredNavigationLeftView setStringValue:[NSString stringWithFormat:@"%@ (%@)",NSLocalizedString(@"Profile.Cancel", nil),[NSString stringWithFormat:NSLocalizedString(ignoredCount == 1 ? @"Messages.scrollToBottomNewMessage" : @"Messages.scrollToBottomNewMessages", nil), ignoredCount]]];
    } else
        [self.filtredNavigationLeftView setStringValue:NSLocalizedString(@"Profile.Cancel", nil)];
    
    [self.filtredNavigationLeftView sizeToFit];
    
    self.rightNavigationBarView = self.rightNavigationBarView;
    
    [CATransaction commit];
}


-(void)forceAddUnreadMark {
    if(!_unreadMark)
    {
        _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkAfterSecondsType];
    }
    
    scrolledAfterAddedUnreadMark = NO;
    
    [self messagesLoadedTryToInsert:@[_unreadMark] pos:0 next:NO];
}

- (void)insertAndGoToEnd:(NSRange)range forceEnd:(BOOL)forceEnd items:(NSArray *)items {
    
    
   // [CATransaction begin];
    StandartViewController *controller = (StandartViewController *) [[Telegram leftViewController] currentTabController];
    if([controller isKindOfClass:[StandartViewController class]] && controller.isSearchActive && forceEnd) {
        [(StandartViewController *)controller hideSearchViewControllerWithConversationUsed:self.conversation];
    }
    
    NSRect prevRect;
    
    if(self.unreadMark && self.unreadMark.removeType == RemoveUnreadMarkNoneType)
    {
        prevRect = [self.table rectOfRow:[self indexOfObject:self.unreadMark]];
    }
    
    
    BOOL isScrollToEnd = [self.table.scrollView isScrollEndOfDocument];
    
    forceEnd = isScrollToEnd ? NO : forceEnd;
    
    int height = 0;
    
    for (MessageTableItem *item in items) {
        height+=item.viewSize.height;
    }
    
    
  //   [self.table beginUpdates];
    
    
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
    
    
//     [self.table endUpdates];
    
    
    
    if(isScrollToEnd || forceEnd) {
        if(_historyController.prevState != ChatHistoryStateFull) {
            [self jumpToLastMessages:YES];
            return;
        } else {
             [self.table.scrollView scrollToEndWithAnimation:YES];
        }
    }

     MessageTypingView *typingCell = [self.table viewAtColumn:0 row:0 makeIfNecessary:NO];
    
    if([typingCell isKindOfClass:[MessageTypingView class]]) {
        
        if([typingCell isActive]) {
            CALayer *parentLayer = typingCell.layer.superlayer.superlayer;
            
            [typingCell.layer.superlayer removeFromSuperlayer];
            [parentLayer insertSublayer:typingCell.layer.superlayer atIndex: (int) [parentLayer.sublayers count]];
        }
    }
   
    __block BOOL addAnimation = YES;
    
     NSRange visibleRange = [self.table rowsInRect:self.table.visibleRect];
    
    [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
            
        NSUInteger row = [self indexOfObject:obj];
            
        if(row < visibleRange.location || row > (visibleRange.location+visibleRange.length) ) {
            addAnimation = NO;
                
            *stop = YES;
                
        }
            
    }];
    
    
    if(self.unreadMark && self.unreadMark.removeType == RemoveUnreadMarkNoneType)
    {
        NSUInteger idx = [self indexOfObject:self.unreadMark];
        NSRect rect = [self.table rectOfRow:idx];
        
        
        if(NSMinY(rect) + NSHeight(rect) > NSHeight(self.table.scrollView.frame)) {
            addAnimation = (rect.origin.y - 1) != (self.table.scrollView.documentOffset.y + NSHeight(self.table.scrollView.frame)) && (NSMaxY(rect) < self.table.scrollView.documentOffset.y);
            
            if(!addAnimation)
                forceEnd = YES;
            
            [self scrollToUnreadItem:NO];
            
            if(rect.origin.y + height  > NSHeight(self.table.scrollView.frame) && addAnimation)
            {
                height= rect.origin.y - prevRect.origin.y;
                
                addAnimation = height > 0;
            }
        }
        
    }

    
    if(!addAnimation) {
        if(!isScrollToEnd && !forceEnd) {
            [self.table.scrollView scrollToPoint:NSMakePoint(self.table.scrollView.documentOffset.x, self.table.scrollView.documentOffset.y + height) animation:NO];
        }

        return;
    }
    
    

    
   

    NSUInteger count = visibleRange.location+visibleRange.length + 10;
    
    for (NSUInteger i = range.location; i < count && i < self.messages.count; i++) {
        
        MessageTableCell *cell = [self.table viewAtColumn:0 row:i makeIfNecessary:NO];
        
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        animation.duration = 0.2;
        
        
        CALayer *presentLayer = (CALayer *)[cell.layer.superlayer presentationLayer];
        
        
        float cellY = cell.layer.superlayer.frame.origin.y - height;
        
        if(presentLayer && [cell.layer.superlayer animationForKey:@"position"]) {
            float presentY = [[presentLayer valueForKeyPath:@"frame.origin.y"] floatValue];
            
            cellY = presentY;
        }
        

        
        NSPoint fromValue = NSMakePoint(0, cellY);
        
        NSPoint toValue = NSMakePoint(0, cell.layer.superlayer.frame.origin.y);
        
        NSValue *fromValueValue = [NSValue value:&fromValue withObjCType:@encode(CGPoint)];
        NSValue *toValueValue = [NSValue value:&toValue withObjCType:@encode(CGPoint)];
        
        animation.fromValue = fromValueValue;
        animation.toValue = toValueValue;
        [animation setValue:@(CALayerPositionAnimation) forKey:@"type"];
        
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        
        animation.removedOnCompletion = YES;
        
        [cell.layer.superlayer removeAllAnimations];
        
        [cell.layer.superlayer addAnimation:animation forKey:@"position"];
        
        
        
        
        
        CABasicAnimation *oAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
        oAnim.duration = 0.2;
        oAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        oAnim.removedOnCompletion = YES;
        [oAnim setValue:@(CALayerOpacityAnimation) forKey:@"type"];
        
        float presentY = [[presentLayer valueForKeyPath:@"opacity"] floatValue];
        
        oAnim.fromValue = @(presentY);
        oAnim.toValue = @(1.0f);
        
        [cell.layer.superlayer addAnimation:oAnim forKey:@"opacity"];

    }
    
    //  [CATransaction commit];
    
}


- (void)receivedMessageList:(NSArray *)list inRange:(NSRange)range itsSelf:(BOOL)force {
    
    
    
    NSArray *items;
    
    NSRange r = [self insertMessageTableItemsToList:list startPosition:range.location needCheckLastMessage:YES backItems:&items checkActive:!force];
    
    if(r.length) {
        
        if(!_jumpToBottomButton.isHidden) {
            [items enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if(obj.message.from_id != [UsersManager currentUserId]) {
                    self.jumpToBottomButton.messagesCount++;
                } 
            }];
            
            [self jumpToBottomButtonDisplay];

        }
        
        
        [self insertAndGoToEnd:r forceEnd:force items:items];
        [self didUpdateTable];
    }
    
}

- (void) deleteSelectedMessages {
    [self deleteSelectedMessages:nil];
}

- (void) deleteSelectedMessages:(dispatch_block_t)deleteAcceptBlock {
    
    if(![self canDeleteMessages])
        return;
    
    NSMutableDictionary *peers = [NSMutableDictionary dictionary];
    
    [self.selectedMessages enumerateObjectsUsingBlock:^(MessageTableItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *data = peers[@(item.message.peer_id)];
        
        if(!data) {
            data = [NSMutableDictionary dictionary];
            peers[@(item.message.peer_id)] = data;
            data[@"conversation"] = item.message.conversation;
            data[@"ids"] = [NSMutableArray array];
            data[@"messages"] = [NSMutableArray array];
        }
        
        if(item.message.dstate == DeliveryStateNormal) {
            
            if([item.message isChannelMessage])
                [data[@"ids"] addObject:@(item.message.channelMsgId)];
            else if([item.message isKindOfClass:[TL_destructMessage class]])
                [data[@"ids"] addObject:@(item.message.randomId)];
            else
                [data[@"ids"] addObject:@(item.message.n_id)];
            
            [data[@"messages"] addObject:item];
            
        }
        
        
    }];
    
   
    [peers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSDictionary  *obj, BOOL * _Nonnull stop) {
        
        TL_conversation *conversation = obj[@"conversation"];
        NSMutableArray *array = obj[@"ids"];
        NSMutableArray *messages = obj[@"messages"];
        
        __block id request = [TLAPI_messages_deleteMessages createWithFlags:0 n_id:array];
        
        
        if(conversation.type == DialogTypeChannel) {
            request = [TLAPI_channels_deleteMessages createWithChannel:[TL_inputChannel createWithChannel_id:conversation.peer.channel_id access_hash:conversation.chat.access_hash] n_id:array];
            if(array.count > 0 && ![[(MessageTableItem *)messages[0] message] n_out] && ![[(MessageTableItem *)messages[0] message] isPost]) {
                
                __block BOOL canMultiEdit = YES;
                
                int from_id = [[(MessageTableItem *)messages[0] message] from_id];
                
                [messages enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if(obj.message.from_id != from_id || obj.message.isPost)
                    {
                        canMultiEdit = NO;
                        *stop = YES;
                    }
                }];
                
                if(canMultiEdit) {
                    
                    
                    TGModalDeleteChannelMessagesView *modalDeleteView = [[TGModalDeleteChannelMessagesView alloc] initWithFrame:appWindow().contentView.bounds];
                    
                    ComposeAction *action = [[ComposeAction alloc] initWithBehaviorClass:[ComposeActionDeleteChannelMessagesBehavior class] filter:@[] object:conversation.chat reservedObjects:@[array]];
                    
                    action.result = [[ComposeResult alloc] initWithMultiObjects:@[@(YES),@(NO),@(NO),@(NO)]];
                    
                    
                    action.result.singleObject = [[(MessageTableItem *)messages[0] message] fromUser];
                    
                    [modalDeleteView showWithAction:action];
                    
                    return;
                }
                
            }
            
        }
        
        __block BOOL canDeleteForAll = true;
        [messages enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.message.canDeleteForAll) {
                canDeleteForAll = false;
                *stop = true;
            }
        }];
        
        dispatch_block_t completeBlock = ^ {
            
            if(conversation.type != DialogTypeChannel) {
                [[DialogsManager sharedManager] deleteMessagesWithMessageIds:array];
            }
            
        };
        
        if(conversation.type == DialogTypeSecretChat) {
            
            if(!conversation.canSendMessage)
            {
                completeBlock();
                return;
            }
            
            
            DeleteRandomMessagesSenderItem *sender = [[DeleteRandomMessagesSenderItem alloc] initWithConversation:self.conversation random_ids:array];
            
            [sender send];
            
            [[DialogsManager sharedManager] deleteMessagesWithRandomMessageIds:array isChannelMessages:NO];
            
            completeBlock();
            
             [self unSelectAll];
            
        } else {
            
            
            NSAlert *alert = [NSAlert alertWithMessageText:appName() informativeText:[NSString stringWithFormat:NSLocalizedString(array.count == 1 ? @"Messages.ConfirmDeleteMessage" : @"Messages.ConfirmDeleteMessages", nil), array.count] block:^(id result) {
                
                BOOL success = [result intValue] == 1000 || [result intValue] == 1002;
                if ([result intValue] == 1002) {
                    request = [TLAPI_messages_deleteMessages createWithFlags:1 << 0 n_id:array];
                }
                if(success) {
                    
                    [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
                        
                        if(conversation.type == DialogTypeChannel)
                        {
                            [[MTNetwork instance].updateService.proccessor addUpdate:[TL_updateDeleteChannelMessages createWithChannel_id:conversation.peer.channel_id messages:array pts:[response pts] pts_count:[response pts_count]]];
                        }
                        
                        completeBlock();
                        
                    } errorHandler:^(RPCRequest *request, RpcError *error) {
                        completeBlock();
                    }];
                    
                    if(deleteAcceptBlock)
                        deleteAcceptBlock();
                    
                    [self unSelectAll];
                }
                
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
            
            if (canDeleteForAll && ACCEPT_FEATURE) {
                [alert addButtonWithTitle:NSLocalizedString(@"Messages.DeleteMessagesForAll", nil)];
            }
            [alert show];
            
            
            
        }
        
    }];
    
    
   
    
}

-(void)flushMessages {
    self.locked = YES;
    [self.selectedMessages removeAllObjects];
    [self.messages removeAllObjects];
    [self.messagesKeys removeAllObjects];
    [self.messages addObject:[[MessageTableItemTyping alloc] init]];
    [self.table reloadData];
    
    self.locked = NO;
    
    [self didUpdateTable];
    
    
}

- (void)deleteItems:(NSArray *)messages orMessageIds:(NSArray *)ids {
    
  //  [self.table beginUpdates];
    
    if(self.messages.count > 0) {
        NSUInteger count = self.selectedMessages.count;
        
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(_editTemplate.type == TGInputMessageTemplateTypeEditMessage) {
                if(obj.n_id == _editTemplate.postId) {
                    [self setEditableMessage:nil];
                }
            }
            
            MessageTableItem *item = [self itemOfMsgId:obj.channelMsgId randomId:obj.randomId];
            
            NSUInteger row = [self.messages indexOfObject:item];
            
            if(row != NSNotFound) {
                [self.messages removeObjectAtIndex:row];
                [self.messagesKeys removeObjectForKey:@(item.message.channelMsgId)];
                [self.selectedMessages removeObject:item];
                
                [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
                [item clean];
            }

            
        }];
        
        
        if(_unreadMark && [self indexOfObject:_unreadMark] == 1) {
            [self.messages removeObjectAtIndex:1];
            [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:1] withAnimation:NSTableViewAnimationEffectFade];
        }
        
        while (self.messages.count > 1 && [self.messages[1] isKindOfClass:[MessageTableItemDate class]]) {
            [self.messages removeObjectAtIndex:1];
            [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:1] withAnimation:NSTableViewAnimationEffectFade];
        }

        
        __block NSInteger row = self.messages.count - 1;
        __block MessageTableItem *backItem = nil;
        [self.messages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(MessageTableItem *item, NSUInteger idx, BOOL *stop) {
            BOOL isHeaderMessage = item.isHeaderMessage;
            [self isHeaderMessage:item prevItem:backItem];
            if(item.isHeaderMessage != isHeaderMessage) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
                [self.table noteHeightOfRowsWithIndexesChanged:indexSet];
                [self.table reloadDataForRowIndexes:indexSet columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                [self scrollToUnreadItemWithStartPositionChecking];
            }
            backItem = item;
            row--;
        }];
        
        
        [self didUpdateTable];
        
        if(count != self.selectedMessages.count) {
            if(self.selectedMessages.count)
                [_modernMessagesBottomView setSectedMessagesCount:self.selectedMessages.count deleteEnable:[self canDeleteMessages] forwardEnable:_conversation.type != DialogTypeSecretChat];
            else
                [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewNormalState];
        }
    }
    
   // [self.table endUpdates];
    
}

-(BOOL)canDeleteMessages {
    
    NSMutableArray *msgs = [[NSMutableArray alloc] init];
    
    [self.selectedMessages enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL *stop) {
        [msgs addObject:obj.message];
    }];
    
    return [MessagesViewController canDeleteMessages:msgs inConversation:self.conversation];
}

+(BOOL)canDeleteMessages:(NSArray *)messages inConversation:(TL_conversation *)conversation {
    
    __block BOOL accept = YES;
    
    [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL *stop) {
        
        accept =obj.conversation.type == DialogTypeChannel ? ( obj.chat.isCreator || (obj.chat.isEditor && (obj.from_id != 0 || obj.n_out)) || (obj.chat.isModerator && obj.from_id != 0) || obj.n_out) : YES;
        
        if(!accept) {
            *stop = YES;
        }
        
    }];
    
    return accept;
    
}

- (MessageTableItem *) findMessageItemById:(long)msgId randomId:(long)randomId {
    
    MessageTableItem *item = self.messagesKeys[@(msgId)];;
    
    if(!item) {
        item = self.messagesKeys[@(randomId)];
        
        if(!item) {
            item = [[self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.message.channelMsgId == %ld",msgId]] lastObject];
        }
        
        if(item) {
            self.messagesKeys[@(msgId)] = item;
        }
    }
    
    return item;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    return NO;
}


// notifications

- (void)setSelectedMessage:(MessageTableItem *)item selected:(BOOL)selected {
    if(selected) {
        if([self.selectedMessages indexOfObject:item] == NSNotFound) {
            [self.selectedMessages addObject:item];
        }
    } else {
        [self.selectedMessages removeObject:item];
    }
    
    [_modernMessagesBottomView setSectedMessagesCount:self.selectedMessages.count deleteEnable:[self canDeleteMessages] forwardEnable:_conversation.type != DialogTypeSecretChat];
}

-(void)unSelectAll {
    [self unSelectAll:YES];
}

- (void)unSelectAll:(BOOL)animated {
    [self setCellsEditButtonShow:NO animated:animated];
    
    [self.selectedMessages removeAllObjects];
    
    for(NSUInteger i = 0; i < self.messages.count; i++) {
        NSTableRowView *rowView = [self.table rowViewAtRow:i makeIfNecessary:NO];
        if(!rowView)
            continue;
        
        TGModernMessageCellContainerView *view = [[rowView subviews] objectAtIndex:0];
        if(view && [view isKindOfClass:[TGModernMessageCellContainerView class]]) {
            [view setSelected:NO animated:animated];
        }
    }
    
    for(MessageTableItem *item in self.selectedMessages)
        item.isSelected = NO;
}



- (BOOL)becomeFirstResponder {
    [_modernMessagesBottomView becomeFirstResponder];
    return YES;
}


- (NSUInteger)messagesCount {
    return self.messages.count;
}


- (void)recommendStickers {
    
    if(!self.conversation || !self.conversation.cacheKey)
        return;
    
    
    
    if(self.conversation.type == DialogTypeSecretChat && self.conversation.encryptedChat.encryptedParams.layer < 23)
        return;
    
    NSArray *emoji = [_editTemplate.attributedString.string getEmojiFromString:NO];
    
    if([_editTemplate.attributedString.string isEqualToString:[emoji lastObject]])
    {
        emoji = [_editTemplate.attributedString.string getEmojiFromString:YES];
        
        [self.stickerPanel showAndSearch:[emoji lastObject] animated:YES];
    } else
    {
        [self.stickerPanel hide:YES];
    }
    
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg flags:(int)flags {
    [self showMessage:message fromMsg:fromMsg animated:YES selectText:nil switchDiscussion:NO flags:flags];
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg switchDiscussion:(BOOL)switchDiscussion {
    [self showMessage:message fromMsg:fromMsg animated:YES selectText:nil switchDiscussion:switchDiscussion flags:0];
}

- (void)showMessage:(TL_localMessage *)message fromMsg:(TL_localMessage *)fromMsg animated:(BOOL)animated selectText:(NSString *)text switchDiscussion:(BOOL)switchDiscussion flags:(int)flags  {
    
    _needNextRequest = YES;
    
    
    if(fromMsg != nil)
        [_replyMsgsStack addObject:fromMsg];
    
    MessageTableItem *item = message.hole != nil ? [self itemOfMsgId:channelMsgId(message.hole.min_id, message.peer_id) randomId:message.randomId] : [self itemOfMsgId:message.channelMsgId randomId:message.randomId];
    
    if(item && (flags & ShowMessageTypeReply) > 0) {
        [self scrollToItem:item animated:YES centered:YES highlight:YES];
        
        return;
    } else if(item && (flags & ShowMessageTypeDateJump) > 0) {
         [self scrollToRect:[self.table rectOfRow:[self indexOfObject:item]] isCenter:NO animated:NO yOffset:28];
        
        return;
    }
    
    TL_conversation *conversation = self.conversation;
    
    __block TL_localMessage *msg = conversation.type == DialogTypeChannel && !conversation.chat.isMegagroup && fromMsg == nil && ((flags & ShowMessageTypeUnreadMark) == 0 && (flags & ShowMessageTypeSearch) == 0) ? [[Storage manager] lastImportantMessageAroundMinId: message.hole ? channelMsgId(message.hole.min_id, message.peer_id) : message.channelMsgId] : [[Storage manager] messageById:message.hole ? message.hole.min_id : message.n_id inChannel:-message.to_id.channel_id];
    
    if((flags & ShowMessageTypeUnreadMark) > 0 && conversation.type == DialogTypeChannel && !msg) {
        [self flushMessages];
    }
    
    
    dispatch_block_t block = ^{
        
        if(conversation != self.conversation || !msg) {
            _needNextRequest = NO;
            return;
        }

        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:conversation.type == DialogTypeChannel ? [ChannelFilter class] : [HistoryFilter class]];
        
        
        
        NSUInteger index = [self indexOfObject:[self itemOfMsgId:msg.channelMsgId randomId:msg.randomId]];
        
        __block NSRect rect = NSZeroRect;
        
        int yTopOffset = 0;
        
        if(index != NSNotFound) {
            rect = [self.table rectOfRow:index];
            
            yTopOffset =  self.table.scrollView.documentOffset.y + NSHeight(self.table.containerView.frame) - (rect.origin.y);
            
        }
        
        if((flags & ShowMessageTypeSaveScrolled) > 0) {
            yTopOffset = [savedScrolling[@(message.peer_id)][@"topOffset"] intValue];
        }
        
        [self removeScrollEvent];
        
        
        if((flags & ShowMessageTypeUnreadMark) > 0 && msg.isChannelMessage ) {
            [self flushMessages];
        }
        
        
        int count = NSHeight(self.table.containerView.frame)/20;
        
        self.historyController.selectLimit = count/2 + 20;
        
        [self.historyController loadAroundMessagesWithMessage:msg prevLimit:count nextLimit:(flags & ShowMessageTypeUnreadMark) > 0 ? 0 : count selectHandler:^(NSArray *result, NSRange range, id controller) {
            
            if(controller == self.historyController && _conversation.peer_id == conversation.peer_id) {
                [self flushMessages];
                
                _needNextRequest = NO;
                
               
                __block NSUInteger index = [result indexOfObjectPassingTest:^BOOL(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    BOOL res = obj.message.channelMsgId == msg.channelMsgId;
                    
                    *stop = res;
                    
                    return res;
                }];
                
                MessageTableItem *item = result[MAX(MIN(result.count - 1, index),0)];
                
                if((flags & ShowMessageTypeUnreadMark) > 0) {
                    
                    if(index != 0 && index != NSNotFound) {
                        _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkAfterSecondsType];
                        
                        [result enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)] options:NSEnumerationReverse usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            
                            if(obj.message.n_out)
                                index--;
                             else
                                 *stop = YES;
                        }];
                        
                        if(index != 0) {
                            NSMutableArray *copy = [result mutableCopy];
                            [copy insertObject:_unreadMark atIndex:index];
                            
                            result = copy;
                        }
                        
                        
                    }
                    
                }
                
                [self messagesLoadedTryToInsert:result pos:range.location next:YES];
                
                
                
                [self.table setNeedsDisplay:YES];
                [self.table display];
                
                
                if((flags & ShowMessageTypeUnreadMark) > 0) {
                    
                    [self scrollToUnreadItem:NO];
                    
                } else if((rect.origin.y == 0 && (flags & ShowMessageTypeSaveScrolled) == 0)  || ((flags & ShowMessageTypeReply) > 0 || (flags & ShowMessageTypeSearch) > 0)) {
                    [self scrollToItem:item animated:NO centered:YES highlight:YES];
                } else if((flags & ShowMessageTypeDateJump) > 0) {
                    [self scrollToRect:[self.table rectOfRow:[self indexOfObject:item]] isCenter:NO animated:NO yOffset:48];
                } else {
                
                    __block NSRect drect = [self.table rectOfRow:[self indexOfObject:item]];
                    
                    
                    dispatch_block_t block = ^{
                        
                        drect.origin.y -= (NSHeight(self.table.containerView.frame)  -yTopOffset);
                        
                        drect.origin.y = MAX(0,drect.origin.y);
                        
                        [self.table.scrollView scrollToPoint:drect.origin animation:NO];
                        
                    };
                    
                    if(NSEqualRects(drect, NSZeroRect)) {
                        
                        dispatch_async(dispatch_get_main_queue(), block);
                    } else {
                        block();
                    }
                    
                    
                }
                
                if(index < 10) {
                    [self requestNextHistory];
                }
                
                [self addScrollEvent];
            }
            
        }];
        
    };
    
    if(!msg) {
        
        _needNextRequest = YES;
        
        [self flushMessages];
        
        
        
        id request = [TLAPI_messages_getMessages createWithN_id:[@[@(message.n_id)] mutableCopy]];
        
        if(self.conversation.type == DialogTypeChannel) {
            request = [TLAPI_channels_getMessages createWithChannel:message.conversation.inputPeer n_id:[@[@(message.hole ? message.hole.min_id : message.n_id)] mutableCopy]];
        }
        
        [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TL_messages_messages * response) {
            
            _needNextRequest = NO;
            
            if(response.messages.count > 0 && ![response.messages[0] isKindOfClass:[TL_messageEmpty class]]) {
                msg = [TL_localMessage convertReceivedMessage:response.messages[0]];
                
                [response.messages removeAllObjects];
                [SharedManager proccessGlobalResponse:response];
                
                if(![msg isKindOfClass:[TL_messageEmpty class]]) {
                    block();
                } else {
                    if((flags & ShowMessageTypeUnreadMark)) {
                        [self jumpToLastMessages:YES];
                    }
                }
            } else {
                [self jumpToLastMessages:YES];
            }
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
             [self jumpToLastMessages:YES];
            
        } timeout:10];
        
        
    } else {
        block();
    }
    
}

-(BOOL)selectNextStickerIfNeeded {
    if(!_stickerPanel.isHidden) {
        [_stickerPanel selectNext];
    }
    return !_stickerPanel.isHidden;
}
-(BOOL)selectPrevStickerIfNeeded {
    if(!_stickerPanel.isHidden) {
        [_stickerPanel selectPrev];
    }
    
    return !_stickerPanel.isHidden;
}


-(void)paste:(id)sender {
    [_modernMessagesBottomView paste:sender];
}

-(void)selectInputTextByText:(NSString *)text {
    [_modernMessagesBottomView selectInputTextByText:text];
}

- (void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message force:(BOOL)force {
  
    [self loadViewIfNeeded];
    
    [self hideSearchBox:NO];
    
    cancel_delayed_block(_messagesHintHandle);
    [_messagesAlertHintView setHidden:YES];
    
    if(![globalAudioPlayer().delegate isKindOfClass:[TGAudioGlobalController class]]) {
        [globalAudioPlayer() stop];
        [globalAudioPlayer().delegate audioPlayerDidFinishPlaying:globalAudioPlayer()];
    }
    
   
    
    
     if(!self.locked &&  (((message != nil && message.channelMsgId != _jumpMessage.channelMsgId) || force) || [self.conversation.peer peer_id] != [dialog.peer peer_id] )) {
        
         if(dialog.type == DialogTypeChannel || dialog.type == DialogTypeChat) {
             [[ChatFullManager sharedManager] requestChatFull:dialog.chat.n_id force:dialog.type == DialogTypeChannel];
         } else if(dialog.type == DialogTypeUser) {
             [[FullUsersManager sharedManager] requestUserFull:dialog.user withCallback:nil];
         }
         
         
        self.jumpMessage = message;
        self.conversation = dialog;
        
        [self checkUserActivity];
        
        [Notification perform:@"ChangeDialogSelection" data:@{KEY_DIALOG:self.conversation, @"sender":self}];
        
        
        [_replyMsgsStack removeAllObjects];
         
         
        
         
         
        [self becomeFirstResponder];
        
        [self.noMessagesView setConversation:dialog];
        
        
        _isMarkIsset = NO;
        
        [self.table.scrollView dropScrollData];
        
        [self.topInfoView setConversation:dialog];
        
        [self.jumpToBottomButton setHidden:YES];
        
        [self.typingView setDialog:dialog];
        
        [self.historyController drop:NO];
        
        [self.normalNavigationCenterView setDialog:dialog];
        
        
         
         

        
        self.historyController = [[[self hControllerClass] alloc] initWithController:self historyFilter:[self defHFClass]];
        
        self.state = MessagesViewControllerStateNone;
        
        
         _editTemplate = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:dialog.peer_id];
         

         
        [_modernMessagesBottomView setInputTemplate:_editTemplate animated:NO];
        
        [self unSelectAll:NO];
        
        [self.typingReservation removeAllObjects];
        [self removeScrollEvent];
        
  
         if(message != nil) {
            [self showMessage:message fromMsg:nil flags:ShowMessageTypeSearch];
        } else if(dialog.read_inbox_max_id != -1 && dialog.read_inbox_max_id < dialog.top_message && dialog.top_message < TGMINFAKEID && dialog.unread_count > 0) {
            
            TL_localMessage *msg =  [[TL_localMessage alloc] init];
            
            msg.n_id = dialog.read_inbox_max_id;
            msg.to_id = dialog.peer;
            
            [self showMessage:msg fromMsg:nil flags:ShowMessageTypeUnreadMark];
            
        } else  if(savedScrolling[@(_conversation.peer_id)]) {
            [self showMessage:savedScrolling[@(_conversation.peer_id)][@"message"] fromMsg:nil flags:ShowMessageTypeSaveScrolled];
        } else  {
            
            [self flushMessages];
            [self loadhistory:0 toEnd:YES prev:NO isFirst:YES];
        }
        
        [self addScrollEvent];
        
        if(self.conversation.type == DialogTypeChannel) {
            [self.historyController startChannelPolling];
        }
         
         if((!self.conversation.canSendMessage && self.isShownESGController) || (self.canShownESGController && !self.isShownESGController && [SettingsArchiver isDefaultEnabledESGLayout])) {
             [self showOrHideESGController:NO toggle:NO];
         } else
             [_modernMessagesBottomView setActiveEmoji:self.messagesViewController.isShownESGController];


    }
}

-(void)setCurrentConversation:(TL_conversation *)dialog withMessageJump:(TL_localMessage *)message   {

    [self setCurrentConversation:dialog withMessageJump:message force:NO];
    
}


-(void)setCurrentConversation:(TL_conversation *)dialog {
    [self setCurrentConversation:dialog withMessageJump:nil];
}

- (void)cancelSelectionAndScrollToBottom {
    [self cancelSelectionAndScrollToBottom:YES];
}

- (void)cancelSelectionAndScrollToBottom:(BOOL)scrollToBottom {
    [self unSelectAll:NO];
    self.state = MessagesViewControllerStateNone;
    [self.table.scrollView scrollToEndWithAnimation:scrollToBottom];
}

-(void)setEditableMessage:(TL_localMessage *)message {
    
    TGInputMessageTemplate *currentTemplate = _editTemplate;
    
    if(message) {
        [self setState:MessagesViewControllerStateEditMessage];
        
        _editTemplate = [[TGInputMessageTemplate alloc] initWithType:TGInputMessageTemplateTypeEditMessage text:[[NSAttributedString alloc] initWithString:message.message.length > 0 ? message.message : (!message.media.caption ? @"" : message.media.caption)] peer_id:message.peer_id postId:message.n_id];
        _editTemplate.editMessage = message;
        
        [_editTemplate setAutoSave:NO];
    } else {
        [self setState:MessagesViewControllerStateNone];
        
        _editTemplate = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:_conversation.peer_id];
    }
    
    if(currentTemplate != _editTemplate)
        [_modernMessagesBottomView setInputTemplate:_editTemplate animated:YES];
}

-(void)forceSetEditSentMessage:(BOOL)rollback {
    
    [self.messages enumerateObjectsWithOptions:rollback ? NSEnumerationReverse : 0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.message.isN_out && obj.message.dstate == DeliveryStateNormal && obj.message.canEdit) {
            if(_editTemplate.editMessage == nil || ((!rollback && _editTemplate.editMessage.n_id > obj.message.n_id) || (rollback && _editTemplate.editMessage.n_id < obj.message.n_id))) {
                [self setEditableMessage:obj.message];
                *stop = YES;
            }
        }
        
    }];
    
}

-(BOOL)proccessEscAction {
    if(self.state == MessagesViewControllerStateEditMessage) {
        [self setEditableMessage:nil];
        
        return YES;
    } else if(self.state == MessagesViewControllerStateEditable) {
        [self unSelectAll];
        return YES;
    } else if(self.editTemplate.attributedString.length > 0) {
        
        if(!_hintView.isHidden)
            [_hintView hide];
        
        return YES;
    }
    
    
    return NO;
}

-(TGInputMessageTemplateType)templateType {
    return _editTemplate.type;
}

-(BOOL)contextAbility {
    return YES;
}

-(BOOL)haveUnreadMessagesInVisibleRect {
    NSRange range = [self.table rowsInRect:[self.table visibleRect]];
    
    
    __block BOOL have = NO;
    
    [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:0 usingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.message.n_id > self.conversation.read_inbox_max_id) {
            *stop = have = YES;
        }
        
    }];
    
    return have;
}

- (void)tryRead {
    
    
    if(!self.view.isHidden && self.view.window.isKeyWindow && ![TGPasslock isVisibility] ) {
        
        [MessagesManager clearNotifies:_conversation max_id:_conversation.top_message];
        
        self.conversation.last_marked_message = self.conversation.top_message;
        self.conversation.last_marked_date = [[MTNetwork instance] getTime];
        
        [self.conversation save];
        
        if(self.conversation.unread_count > 0 || self.conversation.peer.user_id == [UsersManager currentUserId]) {
            [self readHistory:0];
        }
    }
}



- (void)readHistory:(int)offset{
    
    if(!self.conversation || (self.conversation.unread_count == 0) || (self.conversation.type != DialogTypeSecretChat && (self.conversation.chat.isKicked || self.conversation.chat.isLeft)))
        return;
    
    [[DialogsManager sharedManager] markAllMessagesAsRead:self.conversation];
    
    
    
    self.conversation.unread_count = 0;
    _conversation.read_inbox_max_id = self.conversation.top_message;
    
    [self.conversation save];
    
    
    [Notification perform:[Notification notificationNameByDialog:self.conversation action:@"unread_count"] data:@{KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:self.conversation],KEY_DIALOG:self.conversation}];
    
    [MessagesManager updateUnreadBadge];
        
    ReadHistroryTask *task = [[ReadHistroryTask alloc] initWithParams:@{@"conversation":self.conversation}];
    
    [TMTaskRequest addTask:task];
    
    
}



- (void)messagesLoadedTryToInsert:(NSArray *) array pos:(NSUInteger)pos next:(BOOL)next {
    
    assert([NSThread currentThread] == [NSThread mainThread]);
    
    if(array.count > 0) {
        self.locked = YES;
        
        if(self.messages.count > 1) {
        //    dispatch_async(dispatch_get_main_queue(), ^{
            
            NSRange range = [self insertMessageTableItemsToList:array startPosition:pos needCheckLastMessage:NO backItems:nil checkActive:NO];
            NSSize oldsize = self.table.scrollView.documentSize;
            NSPoint offset = self.table.scrollView.documentOffset;
            
            [self.table beginUpdates];
            [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
            [self.table endUpdates];
            
            if(!next) {
                NSSize newsize = self.table.scrollView.documentSize;
                
                [self.table.scrollView scrollToPoint:NSMakePoint(0, newsize.height - oldsize.height + offset.y) animation:NO];
            }
            
            [self didUpdateTable];
            self.locked = NO;
            
            
            
           // });
        } else {
             [self insertMessageTableItemsToList:array startPosition:pos needCheckLastMessage:NO backItems:nil checkActive:NO];
            [self.table reloadData];
            [self didUpdateTable];
            self.locked = NO;
            
        }
    } else {
        [self didUpdateTable];
    }
    
    
    if(_conversation.user.isBot && _historyController.nextState == ChatHistoryStateFull) {
        
        [[FullUsersManager sharedManager] requestUserFull:_conversation.user withCallback:^(TLUserFull *userFull) {
            
            if(userFull.bot_info.n_description.length > 0) {
                TL_localMessageService *service = [TL_localMessageService createWithFlags:0 n_id:0 from_id:0 to_id:_conversation.peer reply_to_msg_id:0 date:0 action:[TL_messageActionBotDescription createWithTitle:userFull.bot_info.n_description] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
                
                NSArray *items;
                
                NSRange range = [self insertMessageTableItemsToList:[self messageTableItemsFromMessages:@[service]] startPosition:_messages.count needCheckLastMessage:YES backItems:&items checkActive:NO];
                [self.table beginUpdates];
                [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] withAnimation:NSTableViewAnimationEffectNone];
                [self.table endUpdates];
                
                
                [self didUpdateTable];
            }
            
        }];
        
    }
}


- (void)didUpdateTable {
    [self showNoMessages:self.messages.count == 1 || (self.conversation.user.isBot && self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]])];
    
    
    if(self.conversation.user.isBot &&  (self.messages.count == 1 || (self.messages.count == 2 && [self.messages[1] isKindOfClass:[MessageTableItemServiceMessage class]]))) {
        [self showBotStartButton:_modernMessagesBottomView.bot_start_var bot:self.conversation.user];
    } else if(self.conversation.user.isBot) {
        [_modernMessagesBottomView setActionState:TGModernMessagesBottomViewNormalState];
    }
    
    BOOL isHaveMessages = NO;
    for(MessageTableItem *item in self.messages) {
        if(item.message && !item.message.action) {
            isHaveMessages = YES;
            break;
        }
    }
    
    if(!isHaveMessages) {
        [self.normalNavigationLeftView setDisable:YES];
    } else {
        [self.normalNavigationLeftView setDisable:NO];
    }
    
    [self updateScrollBtn];
    
    [self.table setNeedsDisplay:YES];
    [self.table display];
    
    
//    if(self.conversation.type != DialogTypeSecretChat) {
//        
//        __block BOOL showReport = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"showreport_%d",self.conversation.user.n_id]];
//        
//        __block BOOL alwaysShowReport = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"always_showreport1_%d",self.conversation.user.n_id]];
//        
//        if(self.messages.count > 1 && (showReport || !alwaysShowReport)) {
//            if(self.historyController.nextState == ChatHistoryStateFull) {
//                
//                showReport = YES;
//                
//                [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.messages.count - 1)] options:0 usingBlock:^(MessageTableItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    
//                    if(obj.message.n_out) {
//                        showReport = NO;
//                        *stop = YES;
//                    }
//                    
//                }];
//                
//                alwaysShowReport = showReport;
//                
//                [[NSUserDefaults standardUserDefaults] setBool:showReport forKey:[NSString stringWithFormat:@"showreport_%d",self.conversation.user.n_id]];
//            }
//        }
//        
//        if(showReport) {
//            [_topInfoView setConversation:self.conversation];
//        }
//        
//    }
    
}

-(void)requestNextHistory {
    [self loadhistory:0 toEnd:NO prev:NO isFirst:NO];
}

- (void)loadhistory:(int)message_id toEnd:(BOOL)toEnd prev:(BOOL)prev isFirst:(BOOL)isFirst {
    if(!self.conversation || _locked)
        return;
    

    NSSize size = self.table.scrollView.documentSize;
    
    int count = size.height/20;
    
    self.historyController.selectLimit = isFirst ? count : 50;
    
     [self removeScrollEvent];
    
    _needNextRequest = NO;
    
    
    

    [self.historyController request:!prev anotherSource:YES sync:isFirst selectHandler:^(NSArray *prevResult, NSRange range1, id controller) {
        
        
        NSUInteger pos = prev ? 0 : self.messages.count;
        
        if(self.historyController == controller) {
            [self messagesLoadedTryToInsert:prevResult pos:pos next:!prev];
            
            if(self.didUpdatedTable) {
                self.didUpdatedTable();
            }
            
            if(prevResult.count+1 < 10 && prevResult.count > 0) {
                [self loadhistory:0 toEnd:YES prev:prev isFirst:NO];
            } else if(NSHeight(self.table.frame) < NSHeight(self.table.scrollView.frame)) {
                [self loadhistory:0 toEnd:YES prev:prev isFirst:NO];
            }
            
            [self addScrollEvent];
        }
        

    }];
}

-(void)scrollToRect:(NSRect)rect isCenter:(BOOL)isCenter animated:(BOOL)animated yOffset:(int)yOffset {
    
    if(isCenter) {
        rect.origin.y += roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
    }
    
    if(self.table.scrollView.documentSize.height > NSHeight(self.table.containerView.frame))
        rect.origin.y-=NSHeight(self.table.scrollView.frame)-rect.size.height;
    
    if(rect.origin.y < 0)
        rect.origin.y = 0;
    
    rect.origin.y+=yOffset;
    
    [self.table.scrollView scrollToPoint:rect.origin animation:animated];
    
    
    [self updateScrollBtn];
    
}

static BOOL scrolledAfterAddedUnreadMark = NO;

-(void)scrollToUnreadItemWithStartPositionChecking {
    if(self.unreadMark.removeType == RemoveUnreadMarkAfterSecondsType && !scrolledAfterAddedUnreadMark) {
        [self scrollToItem:self.unreadMark animated:NO centered:NO highlight:NO];
    }
}


- (void)scrollToUnreadItem:(BOOL)animated {
    
    if(self.unreadMark != nil) {
        [self scrollToItem:self.unreadMark animated:animated centered:NO highlight:NO];
    }
}

- (void)scrollToItem:(MessageTableItem *)item animated:(BOOL)animated centered:(BOOL)centered highlight:(BOOL)highlight {
    
    if(item) {
        NSUInteger index = [self indexOfObject:item];
        
        NSRect rect = [self.table rectOfRow:index];
        
        if(centered) {
            if(self.table.scrollView.documentOffset.y > rect.origin.y)
                rect.origin.y -= roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
            else
                rect.origin.y += roundf((self.table.containerView.frame.size.height - rect.size.height) / 2) ;
            
            [self.table.scrollView.clipView scrollRectToVisible:rect animated:animated completion:^(BOOL scrolled) {
                if(highlight) {
                    
                    if(index != NSNotFound) {
                        MessageTableCellContainerView *cell = (MessageTableCellContainerView *)[self cellForRow:index];
                        
                        if(cell && [cell isKindOfClass:[MessageTableCellContainerView class]]) {
                            
                            for(int i = 0; i < self.messages.count; i++) {
                                MessageTableCellContainerView *cell2 = (MessageTableCellContainerView *)[self cellForRow:i];
                                if(cell2 && [cell2 isKindOfClass:[MessageTableCellContainerView class]]) {
                                    [cell2 stopSearchSelection];
                                }
                            }
                            
                            
                            [cell searchSelection];
                        }
                    }
                    
                    [self updateScrollBtn];
                }
            }];

        } else {
            [self scrollToRect:rect isCenter:centered animated:animated yOffset:0];
        }
        
    }
}


- (NSArray *)messageTableItemsFromMessages:(NSArray *)input {
    NSMutableArray *array = [NSMutableArray array];
    
    for(TLMessage *message in input) {
        MessageTableItem *item = [MessageTableItem messageItemFromObject:message];        

        if(item) {
            item.isSelected = NO;
            [array addObject:item];
        }
    }
    

    return array;
}




- (NSRange)insertMessageTableItemsToList:(NSArray *)array startPosition:(NSInteger)pos needCheckLastMessage:(BOOL)needCheckLastMessage backItems:(NSArray **)back checkActive:(BOOL)checkActive {
    assert([NSThread isMainThread]);
    
    
   // if(pos != 1)
   //     return NSMakeRange(pos, 0);
    
    if(![[NSApplication sharedApplication] isActive] && checkActive) {
        
        if(!self.unreadMark) {
            _unreadMark = [[MessageTableItemUnreadMark alloc] initWithCount:0 type:RemoveUnreadMarkNoneType];
            if(array.count > 0)
                array = [array arrayByAddingObjectsFromArray:@[_unreadMark]];
        }
    }
    
 //   [self.table beginUpdates];
    
    if(back != NULL)
        *back = array;
    
    if(pos > self.messages.count)
        pos = self.messages.count-1;
    
    
    if(pos == 0)
        pos++;
    
    
    {
        // fill date items
        
        if(array.count > 0) {
            NSMutableArray *items = [NSMutableArray array];
            
            __block NSDate *prevDate = [NSDate dateWithTimeIntervalSince1970:[[(MessageTableItem *)[array firstObject] message] date]];
            
            [items addObject:array[0]];
            
            
            [array enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, array.count - 1)] options:0 usingBlock:^(MessageTableItem *currentItem, NSUInteger idx, BOOL * _Nonnull stop) {
                
                
                
                NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[[currentItem message] date]];
                
                if(currentItem.message != nil && ![prevDate isEqualToDateIgnoringTime:currentDate] && prevDate.timeIntervalSince1970 != 0) {
                    MessageTableItemDate *dateItem= [[MessageTableItemDate alloc] initWithObject:prevDate];
                    [dateItem setTable:_table];
                    [dateItem makeSizeByWidth:dateItem.makeSize];
                    [items addObject:dateItem];
                }
                
                [items addObject:currentItem];
                
                
                if(currentItem.message != nil)
                    prevDate = currentDate;
                
            }];;
            
            
            
            
            if(needCheckLastMessage) {
                
                __block MessageTableItem *currentItem;
                
                [array enumerateObjectsUsingBlock:^(MessageTableItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if(obj.message != nil) {
                        currentItem = obj;
                        *stop = YES;
                    }
                    
                }];
                
                if(currentItem) {
                    NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:[[currentItem message] date]];
                    
                    if(self.messages.count > 1 && pos != self.messages.count) {
                        NSDate *prevDate = [NSDate dateWithTimeIntervalSince1970:[[(MessageTableItem *)self.messages[pos] message] date]];
                        
                        if(![prevDate isEqualToDateIgnoringTime:currentDate] && currentDate.timeIntervalSince1970 != 0) {
                            MessageTableItemDate *dateItem= [[MessageTableItemDate alloc] initWithObject:currentDate];
                            [dateItem setTable:_table];
                            [dateItem makeSizeByWidth:dateItem.makeSize];
                            [items addObject:dateItem];
                        }
                        
                    } else if(currentDate.timeIntervalSince1970 != 0) {
                        MessageTableItemDate *dateItem= [[MessageTableItemDate alloc] initWithObject:currentDate];
                        [dateItem setTable:_table];
                        [dateItem makeSizeByWidth:dateItem.makeSize];
                        [items addObject:dateItem];
                    }
                }  
                
            }
            
            
            array = items;
        }
        
        
    }
    
    [array enumerateObjectsUsingBlock:^(MessageTableItem  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        _messagesKeys[@(obj.message.n_id < TGMINFAKEID ? obj.message.channelMsgId : obj.message.randomId)] = obj;
    }];
    
    
    [self.messages insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(pos, array.count)]];
    
    
    NSInteger max = MIN(pos + array.count + 1, self.messages.count );
    
    __block MessageTableItem *backItem = max == self.messages.count ? nil : self.messages[max - 1];
    
    
    NSRange range = NSMakeRange(0, backItem ? max - 1 : max);
    
    NSMutableIndexSet *rld = [[NSMutableIndexSet alloc] init];
    
    
    
    [self.messages enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range] options:NSEnumerationReverse usingBlock:^(MessageTableItem *current, NSUInteger idx, BOOL *stop) {
        
        
        [current setTable:_table];
        [backItem setTable:_table];
        
        BOOL isCHdr = current.isHeaderMessage;
        BOOL isCFwdHdr = current.isHeaderForwardedMessage;

        BOOL isBHdr = backItem.isHeaderMessage;
        BOOL isBFwdHdr = backItem.isHeaderForwardedMessage;
        
        
        [self isHeaderMessage:current prevItem:backItem];
        
        if(pos != 1 && idx < pos) {
            if(isCHdr != current.isHeaderMessage ||
               isCFwdHdr != current.isHeaderForwardedMessage)
            {
                [rld addIndex:idx];
            }
            
            if(isBHdr != backItem.isHeaderMessage ||
               isBFwdHdr != backItem.isHeaderForwardedMessage) {
                [rld addIndex:idx-1];
            }
        }
        [backItem makeSizeByWidth:backItem.makeSize];
        [current makeSizeByWidth:current.makeSize];

        
        backItem = current;
        
    }];
    
    
    if(rld.count > 0)
    {
        [[NSAnimationContext currentContext] setDuration:0];
        [self.table noteHeightOfRowsWithIndexesChanged:rld];
        [self.table reloadDataForRowIndexes:rld columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self scrollToUnreadItemWithStartPositionChecking];
    }
    

    if(needCheckLastMessage && pos > 1) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, pos - 2)];
        [[NSAnimationContext currentContext] setDuration:0];
        [self.table noteHeightOfRowsWithIndexesChanged:set];
        [self.table reloadDataForRowIndexes:set columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [self scrollToUnreadItemWithStartPositionChecking];
    }
    
    
    [self tryRead];
    
    return NSMakeRange(pos, array.count);
}




- (void)isHeaderMessage:(MessageTableItem *)item prevItem:(MessageTableItem *)prevItem {
    if([item isKindOfClass:[MessageTableItemTyping class]] || [item isKindOfClass:[MessageTableItemUnreadMark class]])
        return;
    
    item.isHeaderMessage = YES;
    item.isHeaderForwardedMessage = YES;
    
    if((item.message.isChannelMessage && item.message.isPost) || item.isViaBot) {
        return;
    }
    
    if(prevItem.message && item.message && ![item isReplyMessage] && (!item.message.media.webpage || [item.message.media.webpage isKindOfClass:[TL_webPageEmpty class]])) {
        if(!prevItem.message.action && !item.message.action && !item.message.media.game) {
            if(prevItem.message.from_id == item.message.from_id && ABS(prevItem.message.date - item.message.date) < HEADER_MESSAGES_GROUPING_TIME) {
                item.isHeaderMessage = NO;
            }
            
            if(!item.isHeaderMessage && prevItem.isForwadedMessage && ABS(prevItem.message.fwd_from.date - item.message.fwd_from.date) < HEADER_MESSAGES_GROUPING_TIME) {
                item.isHeaderForwardedMessage = NO;
            }
        }
    }
    
    if(!item.isHeaderMessage && item.isHeaderForwardedMessage && item.isForwadedMessage) {
        item.isHeaderMessage = YES;
    }
    
}

- (void)deleteItem:(MessageTableItem *)item {
    
    NSUInteger row = [self.messages indexOfObject:item];
    if(row != NSNotFound) {
        [self.messages removeObjectAtIndex:row];
        [self.selectedMessages removeObject:item];
        
        [self.table beginUpdates];
        
        [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationEffectFade];
        
        [self.table endUpdates];
        
        [item clean];
    }
}

- (void)resendItem:(MessageTableItem *)item {
    NSUInteger row = [self indexOfObject:item];
    if(row != NSNotFound) {
        item.message.date = [[MTNetwork instance] getTime];
        [item.message save:YES];
        
        
        
        [item rebuildDate];
        
        [self.table beginUpdates];
        
        NSUInteger nRow = 1;
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:nRow];
        if(row != 0) {
            
            [self.messages removeObjectAtIndex:row];
            
            [self.messages insertObject:item atIndex:nRow];
            
            
            [self isHeaderMessage:item prevItem:[self.messages objectAtIndex:MIN(self.messages.count-1,nRow+1)]];
            
            if(row != nRow)
                [self.table moveRowAtIndex:row toIndex:nRow];
            
            [self.table noteHeightOfRowsWithIndexesChanged:set];
            [self scrollToUnreadItemWithStartPositionChecking];
        }
        
        
        [self.table reloadDataForRowIndexes:set columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        [item.messageSender addEventListener:self.historyController];
        [item.messageSender send];
        
        [self.table endUpdates];
    }
}

- (MessageTableItem *)firstMessageItem {
    for(MessageTableItem *object in self.messages) {
        if(object.message.n_id != 0)
            return object;
    }
    return nil;
}

- (MessageTableItem *)lastMessageItem {
    NSUInteger count = self.messages.count;
    for(NSUInteger i = count-1; i != NSUIntegerMax; i--) {
        id object = [self.messages objectAtIndex:i];
        if([object isKindOfClass:[MessageTableItem class]] && ![object isKindOfClass:[MessageTableItemTyping class]]) {
            return object;
        }
    }
    return nil;
}

-(void)setConversation:(TL_conversation *)conversation {
    
    [self saveScrollingState];
    
    if(_conversation != nil) {
        
        [_editTemplate saveTemplateInCloudIfNeeded];
    }
    
    _conversation = conversation;
    

}

- (void)sendMessage {
    
    if(!self.conversation.canSendMessage)  {
        NSBeep();
        return;
    }
    
    if(!_stickerPanel.isHidden) {
        TLDocument *sticker = [_stickerPanel selectedSticker];
        if(sticker) {
            [self sendSticker:sticker forConversation:_conversation addCompletionHandler:nil];
            [_editTemplate updateTextAndSave:nil];
            [_editTemplate performNotification];
            return;
        }
    }

    if(_editTemplate.attributedString.length > 0) {
        if(_editTemplate.type == TGInputMessageTemplateTypeEditMessage) {
            
            TGMessageEditSender *editSender = [[TGMessageEditSender alloc] initWithTemplate:_editTemplate conversation:_conversation];
            
            BOOL noWebpage = _editTemplate.noWebpage;
            
            [editSender performEdit:noWebpage ? 2 : 0];
            
            [self setEditableMessage:nil];
            
        } else {
            
            BOOL nowebpage = _editTemplate.noWebpage;
            
            NSMutableArray *entities = [NSMutableArray array];
            
            NSString *message = [_editTemplate textWithEntities:entities];
            
            [self sendMessage:message forConversation:self.conversation entities:entities nowebpage:nowebpage callback:^{
                [_typingReservation removeAllObjects];
            }];
        }
    }
    
    
    
   
    
    
}

-(void)sendMessage:(NSString *)message forConversation:(TL_conversation *)conversation {
    [self sendMessage:message forConversation:conversation entities:nil nowebpage:NO callback:nil];
}



- (void)sendMessage:(NSString *)message forConversation:(TL_conversation *)conversation entities:(NSArray *)entities nowebpage:(BOOL)noWebpage callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    
    NSArray *array = [message getEmojiFromString:YES];
    if(array.count > 0) {
        [TGModernEmojiViewController saveEmoji:array];
    }
    
    [Telegram saveHashTags:message peer_id:0];
    
    [self readHistory:0];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        
        Class cs = conversation.type == DialogTypeSecretChat ? [MessageSenderSecretItem class] : [MessageSenderItem class];
        
        static const NSInteger messagePartLimit = 4096;
        
        if (message.length <= messagePartLimit) {
            MessageSenderItem *sender = [[cs alloc] initWithMessage:message forConversation:conversation  entities:entities noWebpage:noWebpage additionFlags:self.senderFlags];
            [self.historyController addAndSendMessage:sender.message sender:sender];
            
        }
        
        else
        {
            
            NSArray<NSString *> *parts = cut_messages(message,messagePartLimit);
            
            NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
            NSMutableArray *preparedSenders = [[NSMutableArray alloc] init];

            
            [parts enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MessageSenderItem *sender = [[cs alloc] initWithMessage:obj forConversation:conversation entities:entities noWebpage:noWebpage  additionFlags:self.senderFlags];
                
                [preparedMessages insertObject:sender.message atIndex:0];
                [preparedSenders insertObject:sender atIndex:0];
            }];

            
            [self.historyController addAndSendMessages:preparedMessages senders:preparedSenders sync:YES];
        }
        
        [self performForward:self.conversation];
        
    } synchronous:YES];
}


- (void)sendLocation:(CLLocationCoordinate2D)coordinates forConversation:(TL_conversation *)conversation {
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        Class cs = self.conversation.type == DialogTypeSecretChat ? [LocationSenderItem class] : [LocationSenderItem class];
        
        LocationSenderItem *sender = [[cs alloc] initWithCoordinates:coordinates conversation:conversation additionFlags:self.senderFlags];
        [self.historyController addAndSendMessage:sender.message sender:sender];
        
    }];
    
}

- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    [self sendVideo:file_path forConversation:conversation addCompletionHandler:nil];
}

-(void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation caption:(NSString *)caption addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        SenderItem *sender;
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadVideoType forConversation:conversation];
        } else {
            sender = [[VideoSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags caption:caption];
        }
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
}

- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    [self sendDocument:file_path forConversation:conversation addCompletionHandler:nil];
}

-(void)sendCompressedItem:(TGCompressItem *)compressedItem {
    
    int senderFlags = self.senderFlags;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        SenderItem *sender = [[CompressedDocumentSenderItem alloc] initWithItem:compressedItem additionFlags:senderFlags];
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];

}

- (void)sendContextBotResult:(TLBotInlineResult *)botContextResult via_bot_id:(int)via_bot_id via_bot_name:(NSString *)via_bot_name queryId:(long)queryId forConversation:(TL_conversation *)conversation {
   
    int additionFlags = [self senderFlags];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        SenderItem *sender;
        if(conversation.type != DialogTypeSecretChat)
            sender = [[ContextBotSenderItem alloc] initWithBotContextResult:botContextResult via_bot_id:via_bot_id queryId:queryId additionFlags:additionFlags conversation:conversation];

        if(sender != nil) {
            [self.historyController addAndSendMessage:sender.message sender:sender];
        }
        
    }];
}

- (void)sendVideo:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    [self sendVideo:file_path forConversation:conversation caption:nil addCompletionHandler:completeHandler];
}
- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    [self sendDocument:file_path forConversation:conversation caption:nil addCompletionHandler:completeHandler];
}

- (void)sendDocument:(NSString *)file_path forConversation:(TL_conversation *)conversation caption:(NSString *)caption addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    if([[file_path pathExtension] isEqualToString:@"gif"] && conversation.type != DialogTypeSecretChat) {
        
        TGCompressGifItem *gifItem = [[TGCompressGifItem alloc] initWithPath:file_path conversation:conversation];
        
        if(gifItem != nil && fileSize(gifItem.path) < 15*1024*1024) {
            [self sendCompressedItem:gifItem];
            return;
        }
        
    }
    
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadDocumentType forConversation:conversation];
        } else {
            sender = [[DocumentSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags caption:caption];
        }
        
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
}

- (void)sendFolder:(NSString *)file_path forConversation:(TL_conversation *)conversation {
    if(self.conversation.type == DialogTypeSecretChat || !self.conversation.canSendMessage)
        return;
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        NSMutableArray *attachments = [transaction objectForKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        if(!attachments) {
            attachments = [[NSMutableArray alloc] init];
        }
        
        TGAttachFolder *attach = [[TGAttachFolder alloc] initWithOriginFile:file_path orData:nil peer_id:conversation.peer_id];
        
        [attachments addObject:attach];
        
        [transaction setObject:attachments forKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        [ASQueue dispatchOnMainQueue:^{
            
            [_modernMessagesBottomView addAttachment:[[TGImageAttachment alloc] initWithItem:attach]];
            
        }];
        
    }];

}


-(void)sendSticker:(TLDocument *)sticker forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage) return;
    
    if(self.conversation.type == DialogTypeSecretChat && self.conversation.encryptedChat.encryptedParams.layer < 23)
        return;
    
    [MessageSender addRecentSticker:sticker];
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [[TGModernESGViewController controller].epopover close];
    
    
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        
        SenderItem *sender;
        
        if(self.conversation.type != DialogTypeSecretChat) {
            sender = [[StickerSenderItem alloc] initWithDocument:sticker forConversation:conversation additionFlags:self.senderFlags];
        } else {
            sender = [[StickerSecretSenderItem alloc] initWithConversation:conversation document:sticker];
        }
        
        [self.historyController addAndSendMessage:sender.message sender:sender];
        
    }];
    
}


- (void)sendAudio:(NSString *)file_path forConversation:(TL_conversation *)conversation waveforms:(NSData *)waveforms {
    
    if(!conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        if(!check_file_size(file_path)) {
            alert_bad_files(@[[file_path lastPathComponent]]);
            return;
        }
        
        SenderItem *sender;
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithPath:file_path uploadType:UploadAudioType forConversation:conversation];
        } else {
            sender = [[AudioSenderItem alloc] initWithPath:file_path forConversation:conversation additionFlags:self.senderFlags waveforms:waveforms];
        }
        
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
}

- (void)forwardMessages:(NSArray *)messages conversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        
        void (^fwd_blck) (NSArray *fwd_msgs) = ^(NSArray *fwd_messages) {
            ForwardSenterItem *sender = [[ForwardSenterItem alloc] initWithMessages:fwd_messages forConversation:conversation additionFlags:conversation != _conversation ? 0 : self.senderFlags];
            [self.historyController addAndSendMessages:sender.fakes senders:@[sender] sync:YES];
        };
        
        void (^custom_blck) (TL_localMessage *msg) = ^(TL_localMessage *msg) {
            MessageSenderItem *sender = [[MessageSenderItem alloc] initWithMessage:msg.message forConversation:conversation additionFlags:conversation != _conversation ? 0 : self.senderFlags];
            [self.historyController addAndSendMessage:sender.message sender:sender];
        };
        
                    
        NSMutableArray *copy = [messages mutableCopy];
        
        NSMutableArray *fwdMax = [NSMutableArray array];
        
        [copy enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(obj.n_id < TGMINFAKEID) {
                [fwdMax addObject:obj];
                
                if(fwdMax.count == 50) {
                    fwd_blck([fwdMax copy]);
                    [fwdMax removeAllObjects];
                }
            } else {
                if(fwdMax.count > 0) {
                    fwd_blck([fwdMax copy]);
                    [fwdMax removeAllObjects];
                }
                custom_blck(obj);
            }
            
        }];
        
        if(fwdMax.count > 0) {
            fwd_blck(fwdMax);
        }
        
        
        
        
    } synchronous:YES];
}

- (void)shareContact:(TLUser *)contact forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback  {
    
    if(!self.conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        ShareContactSenterItem *sender = [[ShareContactSenterItem alloc] initWithContact:contact forConversation:conversation additionFlags:self.senderFlags];
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation {
    [self sendSecretTTL:ttl forConversation:conversation callback:nil];
}

- (void)sendSecretTTL:(int)ttl forConversation:(TL_conversation *)conversation callback:(dispatch_block_t)callback {
    
    if(!conversation.canSendMessage || conversation.type != DialogTypeSecretChat) {
        if(callback) callback();
        return;
    }
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    NSUInteger lastTTL = [EncryptedParams findAndCreate:conversation.peer.peer_id].ttl;
    
    if(lastTTL == -1 || lastTTL != ttl ) {
        
        [ChatHistoryController dispatchOnChatQueue:^{
            SetTTLSenderItem *sender = [[SetTTLSenderItem alloc] initWithConversation:conversation ttl:ttl];
            [self.historyController addAndSendMessage:sender.message sender:sender];
        }];
        
    } else if(callback) callback();
}


- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data {
    [self sendImage:file_path forConversation:conversation file_data:data isMultiple:YES addCompletionHandler:nil];
}

- (void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data caption:(NSString *)caption {
    [self sendImage:file_path forConversation:conversation file_data:data isMultiple:NO caption:caption addCompletionHandler:nil];
}

- (void)sendAttachments:(NSArray *)attachments forConversation:(TL_conversation *)conversation addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage || conversation.type == DialogTypeSecretChat)
        return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        NSMutableArray *preparedMessages = [[NSMutableArray alloc] init];
        NSMutableArray *preparedSenders = [[NSMutableArray alloc] init];
        [attachments enumerateObjectsUsingBlock:^(TGImageAttachment *obj, NSUInteger idx, BOOL *stop) {
            
            SenderItem *sender = [[[obj.item senderClass] alloc] initWithConversation:conversation attachObject:obj.item additionFlags:self.senderFlags];
            [preparedMessages addObject:sender.message];
            [preparedSenders addObject:sender];
 
        }];
        
        [self.historyController addAndSendMessages:preparedMessages senders:preparedSenders sync:YES];
        
        
    } synchronous:YES];
}

- (void)addImageAttachment:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data addCompletionHandler:(dispatch_block_t)completeHandler {
    if(self.conversation.type == DialogTypeSecretChat || (!file_path && !data))
        return;
    
    [[Storage yap] asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        
        NSMutableArray *attachments = [transaction objectForKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        if(!attachments) {
            attachments = [[NSMutableArray alloc] init]; 
        }
        
        TGAttachObject *attach = [[TGAttachObject alloc] initWithOriginFile:file_path orData:data peer_id:conversation.peer_id];
        
        [attachments addObject:attach];
        
        [transaction setObject:attachments forKey:conversation.cacheKey inCollection:ATTACHMENTS];
        
        [ASQueue dispatchOnMainQueue:^{
            
            [_modernMessagesBottomView addAttachment:[[TGImageAttachment alloc] initWithItem:attach]];
            
            if(completeHandler) completeHandler();
        }];
        
    }];
    
}

-(void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data isMultiple:(BOOL)isMultiple addCompletionHandler:(dispatch_block_t)completeHandler {
    [self sendImage:file_path forConversation:conversation file_data:data isMultiple:isMultiple caption:nil addCompletionHandler:completeHandler];
}

-(void)sendImage:(NSString *)file_path forConversation:(TL_conversation *)conversation file_data:(NSData *)data isMultiple:(BOOL)isMultiple caption:(NSString *)caption addCompletionHandler:(dispatch_block_t)completeHandler {
    if(!conversation.canSendMessage)
        return;
    
    if(self.conversation.type != DialogTypeSecretChat && (isMultiple || _modernMessagesBottomView.attachmentsCount > 0 || _modernMessagesBottomView.inputTemplate.attributedString.length > 0)) {
        [self addImageAttachment:file_path forConversation:conversation file_data:data addCompletionHandler:completeHandler];
        
        return;
    }

    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        
        NSImage *originImage;
        
        if(data) {
            originImage = [[NSImage alloc] initWithData:data];
        } else {
            originImage = imageFromFile(file_path);
        }
        
        
        
        originImage = prettysize(originImage);
        
        
        
        if(originImage.size.width / 10 > originImage.size.height) {
            
            NSString *path = file_path;
            
            
            if(!file_path) {
                path = exportPath(rand_long(), @"jpg");
                [data writeToFile:path atomically:YES];
            }
            
           
            [ASQueue dispatchOnMainQueue:^{
                [self sendDocument:path forConversation:conversation caption:caption addCompletionHandler:completeHandler];
            }];
            
            
            return;
        }
        
        
        originImage = strongResize(originImage, 1280);
        
        
        NSData *imageData = jpegNormalizedData(originImage);
        
        
        SenderItem *sender;
        
        if(self.conversation.type == DialogTypeSecretChat) {
            sender = [[FileSecretSenderItem alloc] initWithImage:originImage uploadType:UploadImageType forConversation:conversation];
        } else {
            sender = [[ImageSenderItem alloc] initWithImage:originImage jpegData:imageData forConversation:conversation additionFlags:self.senderFlags caption:caption];
        }
        
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
}

- (void)sendFoundGif:(TLMessageMedia *)media forConversation:(TL_conversation *)conversation; {
   
    if(!self.conversation.canSendMessage) return;
    
    [self setHistoryFilter:self.defHFClass force:self.historyController.prevState != ChatHistoryStateFull];
    
    int senderFlags = [self senderFlags];
    
    
    [ChatHistoryController dispatchOnChatQueue:^{
        
        ExternalGifSenderItem *sender = [[ExternalGifSenderItem alloc] initWithMedia:media additionFlags:senderFlags forConversation:conversation];
        [self.historyController addAndSendMessage:sender.message sender:sender];
    }];
    
}




-(int)senderFlags {
    if(self.conversation.type != DialogTypeChannel)
        return self.historyController.filter.additionSenderFlags;
    
    return self.conversation.canSendChannelMessageAsUser ? 0 : self.historyController.filter.additionSenderFlags;
}


//Table methods

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (BOOL) tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (CGFloat) tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    MessageTableItem *item = [self.messages objectAtIndex:row];
    
    return item.viewSize.height;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    
    MessageTableItem *item = [self.messages objectAtIndex:row];
    
    
    if([item isKindOfClass:[MessageTableItemTyping class]]) {
        return _typingView;
    }
    
    NSString *identifier = NSStringFromClass(item.viewClass);
    
    MessageTableCell *cell = [self.table makeViewWithIdentifier:identifier owner:self];
    
    if(!cell)
    {
        cell = [[item.viewClass alloc] initWithFrame:self.view.bounds];
        cell.identifier = identifier;
        cell.messagesViewController = self;
    } else {
        [cell.layer pop_removeAllAnimations];
        

        if(cell.superview.subviews.count > 1) {
            [cell.superview.subviews[0] removeFromSuperview]; // remove editd view
        }
        cell.layer.opacity = 1.0f;
        
    }
    
    item.table = self.table;
    item.rowId = row;
    [cell setItem:item];

    return cell;

}


- (void)backOrClose:(NSMenuItem *)sender {
    if(self.state == MessagesViewControllerStateEditable) {
        [self unSelectAll];
    } else {
        [[Telegram rightViewController] navigationGoBack];
    }
}

- (MessageTableItem *)objectAtIndex:(NSUInteger)position {
    if(position < self.messages.count)
        return [self.messages objectAtIndex:position];
    
    return nil;
}

- (NSUInteger)indexOfObject:(MessageTableItem *)item {
    return [self.messages indexOfObject:item];
}

- (MessageTableItem *)itemOfMsgId:(long)msg_id randomId:(long)randomId {
    return [self findMessageItemById:msg_id randomId:randomId];
}

- (void)clearHistory:(TL_conversation *)dialog {
    
    weak();
    
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Conversation.Confirm.ClearHistory", nil) informativeText:NSLocalizedString(@"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            [[DialogsManager sharedManager] clearHistory:dialog completeHandler:^{
                if(weakSelf.conversation == dialog) {
                    weakSelf.conversation = nil;
                    [weakSelf setCurrentConversation:dialog];
                }
            }];
        }
    }];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Profile.Cancel", nil)];
    [alert show];
}




- (void)leaveOrReturn:(TL_conversation *)dialog {
    TLInputUser *input = [[UsersManager currentUser] inputUser];
    
    id request = dialog.chat.isLeft ? [TLAPI_messages_addChatUser createWithChat_id:dialog.chat.n_id user_id:input fwd_limit:50] : [TLAPI_messages_deleteChatUser createWithChat_id:dialog.chat.n_id user_id:input];
    
    
    confirm(appName(), dialog.chat.isLeft ? NSLocalizedString(@"Confirm.ReturnToGroup", nil) : NSLocalizedString(@"Confirm.LeaveFromGroup", nil), ^{
        if(dialog.chat.isLeft) {
            [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
                
                [[ChatFullManager sharedManager] requestChatFull:dialog.chat.n_id force:YES];
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
            }];
        } else {
            [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
            }];
        }
    }, nil);
    

}

- (void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback startDeleting:(dispatch_block_t)startDeleting {
   
    
    weak();
    
    
    if(!dialog)
    {
        if(callback) callback();
        return;
    }
    
    dispatch_block_t block = ^{
        [[DialogsManager sharedManager] deleteDialog:dialog completeHandler:^{
            
            if(callback) callback();
            
            if(dialog == weakSelf.conversation) {
                [[Telegram sharedInstance] showNotSelectedDialog];
                weakSelf.conversation = nil;
            }
        }];
    };
    
    if(dialog.type == DialogTypeSecretChat) {
        block();
        return;
    }
    
    if(dialog.type == DialogTypeChat && dialog.chat.isLeft) {
        if(startDeleting != nil)
            startDeleting();
        block();
        return;
    }
    
    NSAlert *alert = [NSAlert alertWithMessageText:dialog.type == DialogTypeChannel && dialog.chat.isCreator ? (NSLocalizedString(dialog.chat.isMegagroup ? @"Conversation.Confirm.DeleteGroup" : @"Conversation.Confirm.DeleteChannel", nil)) : (dialog.type == DialogTypeChat && dialog.chat.type == TLChatTypeNormal ? NSLocalizedString(@"Conversation.Confirm.LeaveAndClear", nil) :  NSLocalizedString(dialog.type == DialogTypeChannel ? appName() : @"Conversation.Confirm.DeleteAndClear", nil)) informativeText:dialog.type == DialogTypeChannel && dialog.chat.isCreator ? NSLocalizedString(dialog.chat.isMegagroup ? @"Conversation.Confirm.DeleteSupergroupInfo" : @"Conversation.Confirm.DeleteChannelInfo", nil) : NSLocalizedString(dialog.type == DialogTypeChannel ? (dialog.chat.isMegagroup ? @"Conversation.Delete.ConfirmLeaveSupergroup" : @"Conversation.Delete.ConfirmLeaveChannel") : @"Conversation.Confirm.UndoneAction", nil) block:^(NSNumber *result) {
        if([result intValue] == 1000) {
            if(startDeleting != nil)
                startDeleting();
            block();
        }
    }];
    
    
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [alert show];
}

-(void)deleteDialog:(TL_conversation *)dialog callback:(dispatch_block_t)callback {
    [self deleteDialog:dialog callback:callback startDeleting:nil];
}

- (void)deleteDialog:(TL_conversation *)dialog {
    [self deleteDialog:dialog callback:nil];
}


@end
