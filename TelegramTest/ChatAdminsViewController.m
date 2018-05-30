//
//  ChatAdminsViewController.m
//  Telegram
//
//  Created by keepcoder on 29/10/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "ChatAdminsViewController.h"
#import "TGSettingsTableView.h"
#import "TGUserContainerRowItem.h"
#import "TGSearchRowItem.h"
@interface ChatAdminsViewController () <TMSearchTextFieldDelegate>
@property (nonatomic,strong) TGSettingsTableView *tableView;



@end

@implementation ChatAdminsViewController

-(void)loadView {
    [super loadView];
    
    [self setCenterBarViewText:NSLocalizedString(@"Chat.Administrators", nil)];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
}

-(void)setChat:(TLChat *)chat {
    _chat = chat;
    
    [self loadViewIfNeeded];
    
    [self reloadData];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Notification addObserver:self selector:@selector(didChangeChatFlags:) name:CHAT_FLAGS_UPDATED];
    [Notification addObserver:self selector:@selector(updateParticipantsNotification:) name:CHAT_UPDATE_PARTICIPANTS];

    [self reloadData];
}

- (void)updateParticipantsNotification:(NSNotification *)notify {
    [ASQueue dispatchOnMainQueue:^{
        int chat_id = [[notify.userInfo objectForKey:KEY_CHAT_ID] intValue];
        
        if(self.chat.n_id == chat_id) {
            [self reloadData];
        }
    }];
}

-(void)didChangeChatFlags:(NSNotification *)notification {
    TLChat *chat = notification.userInfo[KEY_CHAT];
    
    if(self.chat == chat) {
        [self reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Notification removeObserver:self];
}


-(void)reloadData {
    
    [_tableView removeAllItems:YES];
    
    weak();
    
    GeneralSettingsRowItem *header = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSwitch callback:^(TGGeneralRowItem *item) {
        
        [weakSelf showModalProgress];
        
        [RPCRequest sendRequest:[TLAPI_messages_toggleChatAdmins createWithChat_id:weakSelf.chat.n_id enabled:!weakSelf.chat.isAdmins_enabled] successHandler:^(id request, id response) {
            
             [weakSelf hideModalProgressWithSuccess];
            
            [SharedManager proccessGlobalResponse:response];
            
            
            [weakSelf reloadData];
            
            
        } errorHandler:^(id request, RpcError *error) {
            
            [weakSelf hideModalProgress];
        }];
        
    } description:NSLocalizedString(@"Chat.SwitchAllAdmins", nil) height:62 stateback:^id(TGGeneralRowItem *item) {
        
        return @(!weakSelf.chat.isAdmins_enabled);
        
    }];
    
    
    [_tableView addItem:header tableRedraw:NO];
    
    GeneralSettingsBlockHeaderItem *fakeItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:self.chat.isAdmins_enabled ? NSLocalizedString(@"Chat.SwitchAdminsDescriptionOff", nil) : NSLocalizedString(@"Chat.SwitchAdminsDescription", nil) height:42 flipped:YES];
    
    [_tableView addItem:fakeItem tableRedraw:NO];
    
    
    
    TGSearchRowItem *searchItem = [[TGSearchRowItem alloc] init];
    searchItem.height = 50;
    
    searchItem.delegate = self;
    
    [_tableView addItem:searchItem tableRedraw:NO];
    
    [_tableView reloadData];
    
    [self searchFieldTextChange:@""];
    

}

- (void) searchFieldTextChange:(NSString*)searchString {
    
    [_tableView removeItemsInRange:NSMakeRange(3, _tableView.count - 3) tableRedraw:YES];
    
    NSArray *participants = [_chat.chatFull.participants.participants copy];
    
    weak();
    
    [participants enumerateObjectsUsingBlock:^(TLChatParticipant *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
        
        if(![obj isKindOfClass:[TL_chatParticipantCreator class]] && (searchString.length == 0 || [user.fullName searchInStringByWordsSeparated:searchString])) {
            
            TLUser *user = [[UsersManager sharedManager] find:obj.user_id];
            TGUserContainerRowItem *userItem = [[TGUserContainerRowItem alloc] initWithUser:user];
            userItem.height = 42;
            userItem.type = SettingsRowItemTypeSelected;
            
            BOOL isAdmin = ([obj isKindOfClass:[TL_chatParticipantAdmin class]] || [obj isKindOfClass:[TL_chatParticipantCreator class]]) && self.chat.isAdmins_enabled;
            
            [userItem setStateback:^id(TGGeneralRowItem *i) {
                
                return @(isAdmin);
                
            }];
            
            
            if(self.chat.isAdmins_enabled) {
                [userItem setStateCallback:^ {
                    
                    confirm(appName(), !isAdmin ?  NSLocalizedString(@"Chat.ToggleUserToAdminConfirm", nil) : NSLocalizedString(@"Chat.ToggleAdminToUserConfirm", nil), ^{
                        
                        [weakSelf showModalProgress];
                        
                        [RPCRequest sendRequest:[TLAPI_messages_editChatAdmin createWithChat_id:weakSelf.chat.n_id user_id:user.inputUser is_admin:!isAdmin] successHandler:^(id request, id response) {
                            
                            if([response isKindOfClass:[TL_boolTrue class]]) {
                                
                                [[ChatFullManager sharedManager] requestChatFull:weakSelf.chat.n_id force:YES];
                                
                                
                                NSArray *f = [weakSelf.chat.chatFull.participants.participants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.user_id == %d",user.n_id]];
                                
                                if(f.count == 1)
                                {
                                    TLChatParticipant *participant = [f firstObject];
                                    
                                    TLChatParticipant *newParticipant = !isAdmin ? [TL_chatParticipantAdmin createWithUser_id:participant.user_id inviter_id:participant.inviter_id date:participant.date] : [TL_chatParticipant createWithUser_id:participant.user_id inviter_id:participant.inviter_id date:participant.date];
                                    
                                    [weakSelf.chat.chatFull.participants.participants replaceObjectAtIndex:[weakSelf.chat.chatFull.participants.participants indexOfObject:participant] withObject:newParticipant];
                                    
                                    [ASQueue dispatchOnMainQueue:^{
                                        [weakSelf reloadData];
                                    }];
                                    
                                }
                                
                            }
                            [ASQueue dispatchOnMainQueue:^{
                                [weakSelf hideModalProgressWithSuccess];
                            }];
                            
                            
                        } errorHandler:^(id request, RpcError *error) {
                            [ASQueue dispatchOnMainQueue:^{
                                [weakSelf hideModalProgress];
                            }];
                        } timeout:0 queue:[ASQueue globalQueue]._dispatch_queue];
                        
                    }, nil);
                    
                }];
            }
            
            
            [_tableView addItem:userItem tableRedraw:YES];
            
        }
        
        
    }];
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
