//
//  ComposeSettingupNewChannelViewController.m
//  Telegram
//
//  Created by keepcoder on 20.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGChannelTypeSettingViewController.h"
#import "TGSettingsTableView.h"
#import "TGChangeUserNameContainerView.h"
#import "NSAttributedString+Hyperlink.h"
#import "TGChatContainerItem.h"
@interface TGUserNameContainerRowItem : TGGeneralRowItem
@property (nonatomic,strong) TGChangeUserObserver *observer;
@end

@interface TGUserNameContainerRowView : TMRowView
@property (nonatomic,strong) TGChangeUserNameContainerView *container;
@end

@implementation TGUserNameContainerRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self =[super initWithFrame:frameRect]) {
        _container = [[TGChangeUserNameContainerView alloc] initWithFrame:self.bounds observer:nil];
        
        [self addSubview:_container];
    }
    
    return self;
}

-(BOOL)becomeFirstResponder {
    return [_container becomeFirstResponder];
}

-(void)redrawRow {
    [super redrawRow];
        
    TGUserNameContainerRowItem *item = (TGUserNameContainerRowItem *) [self rowItem];
    
    [_container setOberser:item.observer];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_container setFrameSize:newSize];
}

@end




@implementation TGUserNameContainerRowItem

-(Class)viewClass {
    return [TGUserNameContainerRowView class];
}


@end


@interface TGChannelTypeSettingViewController ()
@property (nonatomic,strong) TGSettingsTableView *tableView;
@property (nonatomic,strong) TGUserNameContainerRowItem *userNameContainerItem;
@property (nonatomic,strong) GeneralSettingsBlockHeaderItem *joinLinkItem;
@property (nonatomic,assign) BOOL isLoadedPublicNames;
@end

@implementation TGChannelTypeSettingViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TGSettingsTableView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_tableView.containerView];
    
}

-(void)setAction:(ComposeAction *)action {
    [super setAction:action];
    
    if(!self.action.result) {
        self.action.result = [[ComposeResult alloc] init];
        self.action.result.singleObject = @(YES);
    }
    
    TLChat *chat = self.action.object;
        
    _userNameContainerItem = [[TGUserNameContainerRowItem alloc] initWithHeight:120];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:NSLocalizedString(!chat.isMegagroup ?  @"Channel.NewChannelSettingUpUserNameDescription" : @"Group.PublicTypeUpJoinLinkDescription", nil)  withColor:GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(12) forRange:attr.range];
    
    [attr detectBoldColorInStringWithFont:TGSystemMediumFont(12)];
    
    _userNameContainerItem.observer = [[TGChangeUserObserver alloc] initWithDescription:attr placeholder:@"" defaultUserName:@""];
    
    weak();
    
    [_userNameContainerItem.observer setNeedDescriptionWithError:^NSString *(NSString *error) {
        
        if([error isEqualToString:@"USERNAME_CANT_FIRST_NUMBER"])  {
            return NSLocalizedString(@"Channel.Username.InvalidStartsWithNumber", nil);
        } else if([error isEqualToString:@"USERNAME_IS_ALREADY_TAKEN"]) {
            return NSLocalizedString(@"Channel.Username.InvalidTaken", nil);
        } else if([error isEqualToString:@"USERNAME_MIN_SYMBOLS_ERROR"]) {
            return NSLocalizedString(@"Channel.Username.InvalidTooShort", nil);
        } else if([error isEqualToString:@"USERNAME_INVALID"]) {
            return NSLocalizedString(@"Channel.Username.InvalidCharacters", nil);
        } else if([error isEqualToString:@"UserName.avaiable"]) {
            return NSLocalizedString(@"Channel.Username.UsernameIsAvailable", nil);
        } else if([error isEqualToString:@"CHANNELS_ADMIN_PUBLIC_TOO_MUCH"]) {
            TL_channel *channel = weakSelf.action.object;
            
            
            [weakSelf loadAllPublicChannels];
            
            if(channel.isMegagroup) {
                return NSLocalizedString(@"MEGAGROUPS_ADMIN_PUBLIC_TOO_MUCH", nil);
            }
            
        }
        
        return NSLocalizedString(error, nil);
        
    }];

    
    TL_chatInviteExported *export = self.action.reservedObject1;
    
    _joinLinkItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:export.link height:34 flipped:NO];
    _joinLinkItem.xOffset = 30;
    [_joinLinkItem setTextColor:TEXT_COLOR];
    [_joinLinkItem setFont:TGSystemFont(14)];
    _joinLinkItem.drawsSeparator = YES;
    
    _joinLinkItem.type = SettingsRowItemTypeNone;
    [_joinLinkItem setCallback:^(TGGeneralRowItem *item) {
        
        GeneralSettingsBlockHeaderItem *header = (GeneralSettingsBlockHeaderItem *) item;
        
        [TMViewController showModalProgressWithDescription:NSLocalizedString(@"Conversation.CopyToClipboard", nil)];
        
        NSPasteboard* cb = [NSPasteboard generalPasteboard];
        
        [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:item];
        [cb setString:header.header.string forType:NSStringPboardType];
        
        dispatch_after_seconds(0.2, ^{
            [TMViewController hideModalProgressWithSuccess];
        });
        
    }];
    

    [_userNameContainerItem.observer setWillNeedSaveUserName:^(NSString *username) {
        if(username.length >= 5) {
            
            weakSelf.action.reservedObject2 = username;
            [weakSelf.action.behavior composeDidDone];
            
        }
    }];
    
    [_userNameContainerItem.observer setDidChangedUserName:^(NSString *username, BOOL accept) {
        
        weakSelf.action.reservedObject2 = username;
        
        if(!accept) {
            weakSelf.action.reservedObject2 = nil;
        }
        
    }];
    
    [_userNameContainerItem.observer setNeedApiObjectWithUserName:^id(NSString *username) {
        
        return [TLAPI_channels_checkUsername createWithChannel:[weakSelf.action.object inputPeer] username:username];
    }];

    
    [self reload];
}


-(void)loadAllPublicChannels {

    CHECK_LOCKER(_isLoadedPublicNames)

    [[[MTNetwork instance] requestSignal:[TLAPI_channels_getAdminedPublicChannels create]] startWithNext:^(TL_messages_chats *next) {
                
        [_tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:40] tableRedraw:YES];
        
        [next.chats enumerateObjectsUsingBlock:^(TLChat *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGChatContainerItem *chat = [[TGChatContainerItem alloc] initWithObject:obj];
            chat.height = 50;
            chat.type = SettingsRowItemTypeNone;
            chat.status = [NSString stringWithFormat:@"telegram.me/%@",obj.username];
            chat.editable = YES;
            
            [chat setStateback:^id(TGGeneralRowItem * item) {
                
                return @(YES);
            }];
            
            __weak TGChatContainerItem *item = chat;
            
            [chat setStateCallback:^{
                
                confirm(NSLocalizedString(@"Alert.RevokeLink", nil), [NSString stringWithFormat:NSLocalizedString(@"Alert.RevokeLinkInfo", nil),obj.username,obj.title], ^{
                    
                    [self showModalProgress];
                    
                    [RPCRequest sendRequest:[TLAPI_channels_updateUsername createWithChannel:obj.inputPeer username:@""] successHandler:^(id request, id response) {
                        [self hideModalProgressWithSuccess];
                        
                        [_tableView removeItem:item tableRedraw:YES];
                        
                        TGUserNameContainerRowView *view = [_tableView rowViewAtRow:[_tableView indexOfItem:_userNameContainerItem] makeIfNecessary:NO].subviews[0];
                        
                        [view.container forceUpdate];
                        
                        
                    } errorHandler:^(id request, RpcError *error) {
                        [self hideModalProgress];
                    } timeout:10];
                    
                    
                }, nil);

                
            }];
            
            [_tableView addItem:chat tableRedraw:YES];
            
        }];
        
        
    }];
    
}

-(BOOL)becomeFirstResponder {
    if([self.action.result.singleObject boolValue]) {
        
        NSUInteger index = [self.tableView indexOfItem:_userNameContainerItem];
        
        if(index != NSNotFound) {
            TGUserNameContainerRowView *view = (TGUserNameContainerRowView *) [self.tableView rowViewAtRow:index makeIfNecessary:NO].subviews[0];
            
            
            if(view)
                return [view becomeFirstResponder];
        }
       

        
    }
    
    return [super becomeFirstResponder];
}


-(void)reload {
    
    [self.tableView removeAllItems:NO];
    
    weak();
    
    TLChat *chat = self.action.object;
    
    GeneralSettingsBlockHeaderItem *headerItem = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(!chat.isMegagroup ? @"Channel.TypeHeader" : @"Group.TypeHeader", nil) height:60 flipped:NO];
    headerItem.xOffset = 30;
    
    
    GeneralSettingsRowItem *publicSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
        weakSelf.action.result.singleObject = @(YES);
        
        [weakSelf reload];
        
    } description:NSLocalizedString(@"Channel.Public", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return weakSelf.action.result.singleObject;
    }];
    
    GeneralSettingsRowItem *privateSelector = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeSelected callback:^(TGGeneralRowItem *item) {
        
         weakSelf.action.result.singleObject = @(NO);
        
         [weakSelf reload];
        
    } description:NSLocalizedString(@"Channel.Private", nil) height:42 stateback:^id(TGGeneralRowItem *item) {
        return @(![weakSelf.action.result.singleObject boolValue]);
    }];

    
    GeneralSettingsBlockHeaderItem *selectorDesc = [[GeneralSettingsBlockHeaderItem alloc] initWithString:[self.action.result.singleObject boolValue] ? NSLocalizedString(!chat.isMegagroup ? @"Channel.ChoiceTypeDescriptionPublic" : @"Group.ChoiceTypeDescriptionPublic", nil) : NSLocalizedString(!chat.isMegagroup ?  @"Channel.ChoiceTypeDescriptionPrivate" : @"Group.ChoiceTypeDescriptionPrivate", nil) flipped:YES];
    
    
    selectorDesc.xOffset = privateSelector.xOffset = publicSelector.xOffset = 30;
    
    
    [self.tableView addItem:headerItem tableRedraw:NO];
    [self.tableView addItem:publicSelector tableRedraw:NO];
    [self.tableView addItem:privateSelector tableRedraw:NO];
    [self.tableView addItem:selectorDesc tableRedraw:NO];
    
    [self.tableView addItem:[[TGGeneralRowItem alloc] initWithHeight:20] tableRedraw:NO];
    
    
    if([self.action.result.singleObject boolValue]) {
        [self.tableView addItem:_userNameContainerItem tableRedraw:NO];
    } else {
        
        [self.tableView addItem:_joinLinkItem tableRedraw:NO];
        
        GeneralSettingsBlockHeaderItem *joinDescription = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(!chat.isMegagroup ? @"Channel.NewChannelSettingUpJoinLinkDescription" : @"Group.PrivateTypeUpJoinLinkDescription", nil) flipped:YES];
        
        [self.tableView addItem:joinDescription tableRedraw:NO];
        
        joinDescription.xOffset = 30;
    }
   
    [self.tableView reloadData];
    
}

-(void)performEnter {
    
}

-(void)dealloc {
    [_tableView clear];
}

@end
