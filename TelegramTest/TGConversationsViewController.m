//
//  DialogsViewController.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/29/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TGConversationsViewController.h"
#import "TGSecretAction.h"
#import "SelfDestructionController.h"
#import "TGModernTypingManager.h"
#import "TGPasslock.h"
#import "SecretChatAccepter.h"
#import "TMTaskRequest.h"
#import "TGModernEmojiViewController.h"
#import "TGConversationTableCell.h"
#import "TGConversationsTableView.h"
#import "MessagesUtils.h"
#import "TGModernConversationHistoryController.h"
#import "TGHeadChatPanel.h"
#import "TMAudioRecorder.h"
#import "TGModernESGViewController.h"
#import "SpacemanBlocks.h"
@interface TestView : TMView

@end

@implementation TestView

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
}

@end

@interface TGConversationsViewController ()<NSTableViewDataSource,NSTableViewDelegate,TMTableViewDelegate,TGModernConversationHistoryControllerDelegate> {
    SMDelayedBlockHandle _handle;
}
@property (nonatomic, strong) TGModernConversationHistoryController *modernHistory;
@property (nonatomic, strong) TGConversationsTableView *tableView;
@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic,assign) BOOL initedNext;



@end

@implementation TGConversationsViewController

- (void)loadView {
    [super loadView];
        
    _list = [[NSMutableArray alloc] init];
    
    
    int topOffset = 48;
    
    self.searchViewController.type = TGModernSearchTypeDialogs  | TGModernSearchTypeGlobalUsers | TGModernSearchTypeMessages;
    
    NSRect tableRect = NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - topOffset);
    
    self.tableView = [[TGConversationsTableView alloc] initWithFrame:tableRect];
    self.tableView.tm_delegate = self;
    [self.view addSubview:self.tableView.containerView];
        
    
    self.mainView = self.tableView.containerView;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
    [Notification addObserver:self selector:@selector(notificationLogout:) name:LOGOUT_EVENT];
    
    [Notification addObserver:self selector:@selector(notificationDialogsReload:) name:DIALOGS_NEED_FULL_RESORT];
    [Notification addObserver:self selector:@selector(notificationDialogToTop:) name:DIALOG_TO_TOP];
    [Notification addObserver:self selector:@selector(notificationDialogRemove:) name:DIALOG_DELETE];
    [Notification addObserver:self selector:@selector(notificationDialogChangePosition:) name:DIALOG_MOVE_POSITION];
    [Notification addObserver:self selector:@selector(notificationDialogSelectionChanged:) name:@"ChangeDialogSelection"];
    
    [Notification addObserver:self selector:@selector(notificationFlushAndReloadDialogs:) name:DIALOGS_FLUSH_AND_RELOAD];
    
    [Notification addObserver:self selector:@selector(didChangeLayout:) name:LAYOUT_CHANGED];
    [self addScrollEvent];
    
    
    
    
    if(![TGPasslock isEnabled] && [[MTNetwork instance] isAuth]) {
        [self initialize];
    }
//     [[MTNetwork instance] startNetwork];
//    
//    [[MTNetwork instance].updateService.proccessor resetStateAndSync];
}

-(void)initialize {
    
    
    [[Storage manager] users:^(NSArray *result) {
        
        [[UsersManager sharedManager] add:result];
        
        [[Storage manager] broadcastList:^(NSArray *broadcasts) {
            
            [[BroadcastManager sharedManager] add:broadcasts];
            
            [[Storage manager] loadChats:^(NSArray *chats) {
                
                [[ChatsManager sharedManager] add:chats];
                
                [ASQueue dispatchOnStageQueue:^{
                    
                    
                    [self initConversations];
                }];
                
               
                
            }];
        }];
        
        
    }];
    
}

-(BOOL)becomeFirstResponder {
    
    if(_tableView.count == 0) {
        return NO;
    }
    
    return [super becomeFirstResponder];
}

-(void)didChangeLayout:(id)notification {
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.searchViewController viewWillAppear:animated];
    
    [self.tableView.scrollView.contentView setFrameSize:[Telegram leftViewController].view.frame.size];
    [self.tableView setFrameSize:[Telegram leftViewController].view.frame.size];
  //  dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
  //  });
    
}




-(void)didLoadedConversations:(NSArray *)conversations withRange:(NSRange)range {
    [self insertAll:conversations];
    
    if(!_initedNext) {
        [self didLoadedStartedConversationNeedNext];
    }
    
}

-(int)conversationsLoadingLimit {
    return 20;
}

-(void)initConversations {
    
    
    _initedNext = NO;
    
     [[MTNetwork instance] startNetwork];
    
    _modernHistory = [[TGModernConversationHistoryController alloc] initWithQueue:[[ASQueue alloc] initWithName:"c_h_queue"] delegate:self];
    
    
    [self loadhistory:30];
    

    
}

-(void)notificationFlushAndReloadDialogs:(NSNotification *)notification {
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
    
    [self initialize];
    
}

-(void)didLoadedStartedConversationNeedNext {
    [[BlockedUsersManager sharedManager] remoteLoad];
    
    [TMTaskRequest executeAll];
    
    [SecretChatAccepter instance];
    
    [Notification perform:APP_RUN object:nil];
    
    [SelfDestructionController initialize];
    
    [TGModernTypingManager initialize];
    
    [[NewContactsManager sharedManager] fullReload];
    
    [TGSecretAction dequeAllStorageActions];
    
    
    [ASQueue dispatchOnMainQueue:^{
        //[EmojiViewController reloadStickers];
        [TGModernESGViewController controller];
        [TGModernESGViewController reloadStickers];
        [TGModernESGViewController controller];
        [MessageSender syncTopCategories:^(NSArray *categories) {
        }];
    }];
    
    [MessagesManager updateUnreadBadge];
    _initedNext = YES;
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kPullPinnedOnce]) {
        [RPCRequest sendRequest:[TLAPI_messages_getPinnedDialogs create] successHandler:^(id request, TL_messages_peerDialogs *response) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPullPinnedOnce];
            [SharedManager proccessGlobalResponse:response];
            
            __block NSMutableArray *updated = [NSMutableArray array];
            [response.dialogs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(TL_dialog *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TL_conversation *conversation = [[DialogsManager sharedManager] find:obj.peer.peer_id];
                
                if (!conversation) {
                    conversation = [[Storage manager] selectConversation:conversation.peer];
                } else {
                    [updated addObject:conversation];
                }
                conversation.last_message_date = [DialogsManager pullPinnedNextTime:1];
                conversation.flags |= (1 << 2);
                [conversation save];
            }];
            
            [updated enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [[DialogsManager sharedManager] notifyAfterUpdateConversation:obj];
            }];
            
        } errorHandler:^(id request, RpcError *error) {
            
        }];
    }
}

- (void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewDocumentOffsetChangingNotificationHandler:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
}

- (void)removeScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSViewBoundsDidChangeNotification object:clipView];
}



-(void)notificationLogout:(NSNotification *)notification {
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
    [_modernHistory clear];
    _modernHistory = nil;
}

- (void) scrollViewDocumentOffsetChangingNotificationHandler:(NSNotification *)aNotification {
    if(_modernHistory.isLoading || _modernHistory.state == TGModernCHStateFull || ![self.tableView.scrollView isNeedUpdateBottom])
        return;
    
     [_modernHistory requestNextConversation];
}

-(void)loadhistory:(int)limit  {
    
    cancel_delayed_block(_handle);
    
    if(_modernHistory != nil) {
        [_modernHistory requestNextConversation];
        
        _handle = perform_block_after_delay(5.0, ^{
            [self loadhistory:limit];
        });
        
       
    }
    
}

-(void)insertAll:(NSArray *)all {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for(TL_conversation *conversation in all) {
        if(!conversation.isAddToList || conversation.chat.isDeactivated)
            continue;
        
        TGConversationTableItem *item = [[TGConversationTableItem alloc] initWithConversation:conversation];
        [items addObject:item];
    }
    
    [ASQueue dispatchOnMainQueue:^{
        NSTableViewAnimationOptions animation = self.tableView.defaultAnimation;
        
        self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
        
        [self.tableView insert:items startIndex:self.tableView.list.count tableRedraw:YES];
        
        self.tableView.defaultAnimation = animation;
        
        if(self.tableView.selectedItem  != self.selectedItem) {
            
            if([self.tableView itemByHash:[self.selectedItem hash]]) {
                [self.tableView cancelSelection];
                [self.tableView setSelectedByHash:[self.selectedItem hash]];
            }
        }
        

    }];
    
}
- (void)dealloc {
    [Notification removeObserver:self];
    [self removeScrollEvent];
}

- (void) setHidden:(BOOL)isHidden {
    [super setHidden:isHidden];
    
    if(isHidden) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
}

//Notifications
- (void)notificationDialogSelectionChanged:(NSNotification *)notify {
    if([notify.userInfo objectForKey:@"sender"] != self) {
        TL_conversation *conversation = [notify.userInfo objectForKey:KEY_DIALOG];
        
        [self.tableView cancelSelection];
        
        if(![conversation isKindOfClass:NSNull.class]) {
            [self.tableView setSelectedByHash:[conversation peer_id]];
            
            if([Telegram isSingleLayout]  && !conversation) {
                [self.tableView cancelSelection];
            }
            
        }
    }
}

- (void) notificationDialogRemove:(NSNotification *)notify {
    TL_conversation *conversation = [notify.userInfo objectForKey:KEY_DIALOG];
    id object = [self.tableView itemByHash:[conversation peer_id]];
    [self.tableView removeItem:object];
    
    
    
}

- (void) notificationDialogsReload:(NSNotification *)notify {
    
    
    NSArray *copy = [self.tableView.list copy];
    
    [_modernHistory.queue dispatchOnQueue:^{
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        NSArray *current = [[DialogsManager sharedManager] all];
        
        
        [current enumerateObjectsUsingBlock:^(TL_conversation *obj, NSUInteger idx, BOOL *stop) {
            
            if(!obj.isAddToList || obj.chat.isDeactivated)
                return;
            
            
            TGConversationTableItem *item;
            
            NSArray *f = [copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.conversation.peer_id == %d",obj.peer_id]];
            
            if(f.count == 1) {
                item = f[0];
                
                if(![item itemIsUpdated])
                {
                    [item needUpdateMessage:[[NSNotification alloc] initWithName:@"" object:nil userInfo:@{KEY_LAST_CONVRESATION_DATA:[MessagesUtils conversationLastData:obj],@"isNotForReload":@(YES),KEY_DIALOG:obj}]];
                    
                }
            } else {
                item = [[TGConversationTableItem alloc] initWithConversation:obj];
            }
            
            
            [items addObject:item];
            
        }];
        
        
        [ASQueue dispatchOnMainQueue:^{
            
            [self.tableView removeAllItems:NO];
            [self.tableView insert:items startIndex:0 tableRedraw:NO];
            [self.tableView reloadData];
            
            [self.tableView setSelectedByHash:[self.tableView.selectedItem hash]];
            
        }];
    }];
}

- (void)notificationDialogToTop:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    [self move:0 conversation:dialog];
}

- (void)notificationDialogChangePosition:(NSNotification *)notify {
    TL_conversation *dialog = [notify.userInfo objectForKey:KEY_DIALOG];
    int position = [[notify.userInfo objectForKey:KEY_POSITION] intValue];
    [self move:position conversation:dialog];
}

-(void)move:(int)position conversation:(TL_conversation *)conversation {
    
    
    if(!conversation.isAddToList || conversation.chat.isDeactivated)
        return;
    
    if(position == 0 && conversation.top_message > TGMINFAKEID) {
        [self.tableView scrollToBeginningOfDocument:self];
    }
    
    if(position != 0 && position >= self.tableView.count)
        position = MAX((int) self.tableView.count-1,0);
    
    TGConversationTableItem *object = (TGConversationTableItem *) [self.tableView itemByHash:[conversation peer_id]];
    if(object) {
        [self.tableView moveItemFrom:[self.tableView positionOfItem:object] to:position tableRedraw:YES];
    } else {
        object = [[TGConversationTableItem alloc] initWithConversation:conversation];
        [self.tableView insert:object atIndex:position tableRedraw:YES];
    }
    
    if(conversation == [Telegram rightViewController].messagesViewController.conversation)
        [self.tableView setSelectedByHash:object.hash];
    
}

- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    return 66;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (NSView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    
    TGConversationTableCell *view = (TGConversationTableCell *)[self.tableView cacheViewForClass:[TGConversationTableCell class] identifier:@"tgconvcell" withSize:NSMakeSize(NSWidth(self.view.frame), 66)];
    
    return view;
    
    
}

- (BOOL) selectionWillChange:(NSInteger)row item:(TGConversationTableItem *) item {
    
    if([[TMAudioRecorder sharedInstance] isRecording]) {
        return NO;
    }
    
    if([[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] modalViewSendAction:item.conversation];
        return NO;
    }
    
    
    return ![Telegram rightViewController].navigationViewController.isLocked;
}

- (void) selectionDidChange:(NSInteger)row item:(TGConversationTableItem *) item {
    
  
    
    [[Telegram delegate].mainWindow.navigationController showMessagesViewController:item.conversation];
    
    [self.tableView setSelectedByHash:[item hash]];
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    [self.tableView tableViewSelectionDidChange:notification];
}

- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return YES;
}

-(TGConversationTableItem *)selectedItem {
    return (TGConversationTableItem *)self.tableView.selectedItem;
}

+ (void)showPopupMenuForDialog:(TL_conversation *)dialog withEvent:(NSEvent *)theEvent forView:(NSView *)view {
    NSMenu *menu = [[NSMenu alloc] init];
    
    __block TLUser *user = dialog.type == DialogTypeSecretChat ? dialog.encryptedChat.peerUser : dialog.user;
    __block TLChat *chat = dialog.chat;
    
    NSMenuItem *openConversationMenuItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.OpenConversation", nil) withBlock:^(id sender) {
        [appWindow().navigationController showMessagesViewController:dialog];
    }];
    if(appWindow().navigationController.messagesViewController.conversation == dialog)
        openConversationMenuItem.target = nil;
    
    [menu addItem:openConversationMenuItem];
    
    NSMenuItem *pinOrUnpin = [NSMenuItem menuItemWithTitle:NSLocalizedString(dialog.isPinned ? @"Conversation.Unpin" : @"Conversation.Pin", nil) withBlock:^(id sender) {
        [[DialogsManager sharedManager] pinned:^(NSArray *pinned) {
            if (dialog.type != DialogTypeSecretChat) {
                NSArray *simplePinned = [pinned filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type != 2"]];

                if (simplePinned.count < chat_pin_limit() || dialog.isPinned) {
                    [RPCRequest sendRequest:[TLAPI_messages_toggleDialogPin createWithFlags:dialog.isPinned ? 0 : 1 << 0 peer:dialog.inputPeer] successHandler:^(id request, id response) {
                        
                        [[DialogsManager sharedManager] togglePinned:dialog];
                    } errorHandler:^(id request, RpcError *error) {
                        
                    }];
                } else {
                    alert(appName(), [NSString stringWithFormat:NSLocalizedString(@"Conversation.Alert.PinLimitError", nil),chat_pin_limit()]);
                }
            } else {
                NSArray *secretPinned = [pinned filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.type == 2"]];
                if (secretPinned.count < chat_pin_limit() || dialog.isPinned ) {
                    [[DialogsManager sharedManager] togglePinned:dialog];
                } else {
                    alert(appName(), [NSString stringWithFormat:NSLocalizedString(@"Conversation.Alert.SecretPinLimitError", nil),chat_pin_limit()]);
                }
            }
            
        }];
        
    }];
    [menu addItem:pinOrUnpin];
    
    NSMenuItem *anotherWindow = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"ShowConversationWithAnotherWindow", nil) withBlock:^(id sender) {
        [TGHeadChatPanel showWithConversation:dialog];
    }];
    
    
    [menu addItem:anotherWindow];
    
    
   
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    if(dialog.type != DialogTypeChat && dialog.type != DialogTypeBroadcast && dialog.type != DialogTypeChannel) {
        NSMenuItem *showUserProfile = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Conversation.ShowProfile", nil), user.dialogFullName] withBlock:^(id sender) {
            
            [appWindow().navigationController showInfoPage:dialog];
            
        }];
        [menu addItem:showUserProfile];
        
        
        BOOL isMuted = dialog.isMute;
        
        NSMenuItem *muteMenuItem = [NSMenuItem menuItemWithTitle:isMuted ? NSLocalizedString(@"Conversation.Unmute", nil) : NSLocalizedString(@"Conversation.Mute", nil) withBlock:^(id sender) {
            [dialog muteOrUnmute:nil until:isMuted ? 0 : 365*24*60*60];
        }];
        if(dialog.type == DialogTypeSecretChat)
            muteMenuItem.target = nil;
        [menu addItem:muteMenuItem];
        
        
        if(user.type == TLUserTypeRequest) {
            [menu addItem:[NSMenuItem separatorItem]];
            __block BOOL isBlocked = [[BlockedUsersManager sharedManager] isBlocked:user.n_id];
            NSMenuItem *blockUser = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:isBlocked ? NSLocalizedString(@"User.UnlockUser", nil) : NSLocalizedString(@"User.BlockUser", nil), user.dialogFullName] withBlock:^(id sender) {
                
                if(isBlocked) {
                    [[BlockedUsersManager sharedManager] unblock:user.n_id completeHandler:nil];
                } else {
                    [[BlockedUsersManager sharedManager] block:user.n_id completeHandler:nil];
                }
            }];
            [menu addItem:blockUser];
            
            NSMenuItem *addToContacts = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"User.AddToContacts", nil) withBlock:^(id sender) {
                [[NewContactsManager sharedManager] importContact:[TL_inputPhoneContact createWithClient_id:0 phone:user.phone first_name:user.first_name last_name:user.last_name] callback:^(BOOL isAdd, TL_importedContact *contact, TLUser *user) {
                    
                }];
            }];
            [menu addItem:addToContacts];
        }
        
        if(dialog.type == DialogTypeSecretChat) {
            [menu addItem:[NSMenuItem separatorItem]];
            NSMenuItem *deleteMenuItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.DeleteSecretChat", nil) withBlock:^(id sender) {
                [appWindow().navigationController.messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteMenuItem];
        }
        
        if(dialog.type == DialogTypeUser) {
            [menu addItem:[NSMenuItem separatorItem]];
            
            NSMenuItem *clearHistory = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.Delete", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:clearHistory];
        }
        
        if(dialog.type == DialogTypeUser && dialog.user.isBot) {
            
            NSMenuItem *deleteAndStop = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.DeleteAndStopBot", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
                [[BlockedUsersManager sharedManager] block:dialog.user.n_id completeHandler:^(BOOL response) {
                    
                }];
            }];
            [menu addItem:deleteAndStop];
        }
        
    } else {
        
        NSMenuItem *showСhatProfile;
        
        if(dialog.type == DialogTypeChat || dialog.type == DialogTypeChannel) {
            showСhatProfile = [NSMenuItem menuItemWithTitle:dialog.type != DialogTypeChannel || dialog.chat.isMegagroup ? NSLocalizedString(@"Conversation.ShowGroupInfo", nil) : NSLocalizedString(@"Conversation.ShowChannelInfo", nil) withBlock:^(id sender) {
                [appWindow().navigationController showInfoPage:dialog];
            }];
            
        } else {
            showСhatProfile = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Conversation.ShowBroadcastInfo", nil) withBlock:^(id sender) {
                [appWindow().navigationController showInfoPage:dialog];
            }];
            
        }
        
        if(chat.type != TLChatTypeNormal || chat.isLeft)
            showСhatProfile.target = nil;
        
        [menu addItem:showСhatProfile];
        
        BOOL isMuted = dialog.isMute;
        
        NSMenuItem *muteMenuItem = [NSMenuItem menuItemWithTitle:isMuted ? NSLocalizedString(@"Conversation.Unmute", nil) : NSLocalizedString(@"Conversation.Mute", nil) withBlock:^(id sender) {
            [dialog muteOrUnmute:nil until:isMuted ? 0 : 365*24*60*60];
        }];
        if(dialog.type == DialogTypeSecretChat)
            muteMenuItem.target = nil;
        [menu addItem:muteMenuItem];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
        
        if(dialog.type == DialogTypeChat || dialog.type == DialogTypeChannel) {
            
            NSMenuItem *deleteAndExitItem = [NSMenuItem menuItemWithTitle:chat.type == TLChatTypeNormal ? (dialog.type != DialogTypeChannel ? NSLocalizedString(@"Profile.DeleteAndExit", nil) : (chat.isCreator ? NSLocalizedString(chat.isMegagroup ?@"Conversation.Confirm.DeleteGroup" : @"Profile.DeleteChannel", nil) : NSLocalizedString(chat.isMegagroup ? @"Conversation.Actions.LeaveGroup" : @"Profile.LeaveChannel", nil)) ) : NSLocalizedString(@"Profile.DeleteConversation", nil)  withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteAndExitItem];
            
            if(dialog.type == DialogTypeChat) {
                NSMenuItem *leaveFromGroupItem = [NSMenuItem menuItemWithTitle:!dialog.chat.isLeft ? NSLocalizedString(@"Conversation.Actions.LeaveGroup", nil) : NSLocalizedString(@"Conversation.Actions.ReturnToGroup", nil) withBlock:^(id sender) {
                    [[Telegram rightViewController].messagesViewController leaveOrReturn:dialog];
                }];
                if(chat.type != TLChatTypeNormal)
                    leaveFromGroupItem.target = nil;
                
                [menu addItem:leaveFromGroupItem];
                
                
                NSMenuItem *clearHistory = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Confirm.ClearHistory", nil) withBlock:^(id sender) {
                    [[Telegram rightViewController].messagesViewController clearHistory:dialog];
                }];

                
                [menu addItem:clearHistory];
            }
            
            
        } else {
            NSMenuItem *deleteBroadcast = [NSMenuItem menuItemWithTitle: NSLocalizedString(@"Profile.DeleteBroadcast", nil) withBlock:^(id sender) {
                [[Telegram rightViewController].messagesViewController deleteDialog:dialog];
            }];
            [menu addItem:deleteBroadcast];
        }
        
        
    }
    
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:view];
}



- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [TMTableView setCurrent:self.tableView];
}

@end
