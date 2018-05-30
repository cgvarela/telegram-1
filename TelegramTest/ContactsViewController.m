//
//  ContactsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ContactsViewController.h"
#import "SearchSeparatorItem.h"

#import "SelectUserItem.h"
#import "SelectUserRowView.h"
#import "RBLPopover.h"
#import "TLPeer+Extensions.h"
#import "TGConversationsTableView.h"
#import "TGContactSelfUserItem.h"
#import "TGSettingsTableView.h"
#import "SearchSeparatorItem.h"
#import "TGAddContactModalView.h"
@interface ContactFirstItem : TMRowItem

@end

@implementation ContactFirstItem


-(NSUInteger)hash {
    return 0;
}

-(int)height {
    return 40;
}

-(Class)viewClass {
    return NSClassFromString(@"ContactFirstView");
}

@end

@interface ContactFirstView : TMRowView
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation ContactFirstView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.field = [TMTextField defaultTextField];
        
        [self.field setBackgroundColor:[NSColor clearColor]];
        [self.field setFont:TGSystemFont(13)];
        [[self.field cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.field cell] setTruncatesLastVisibleLine:YES];
        
        [self.field setStringValue:NSLocalizedString(@"NewConversation.AddContact", nil)];
        
        [self.field sizeToFit];
        
        [self.field setTextColor:LINK_COLOR];
        
        [self.field setFrameOrigin:NSMakePoint(55, 13)];
        
        [self addSubview:self.field];
        
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(17, roundf( (40 - image_ContactsAddContact().size.height) / 2), image_ContactsAddContact().size.width, image_ContactsAddContact().size.height)];
        
        
        self.imageView.image = image_ContactsAddContact();
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

-(void)checkSelected:(BOOL)isSelected {
   // self.imageView.image = isSelected ? image_ContactsAddContactActive() : image_ContactsAddContact();
   // [self.field setTextColor:isSelected ? NSColorFromRGB(0xffffff) : LINK_COLOR];
}

-(void)drawRect:(NSRect)dirtyRect {
	
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(55, 0, NSWidth(self.frame) - 55 , 1));


}


@end


@interface ContactUserItem : SelectUserItem


@end


@implementation ContactUserItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        
    }
    
    return self;
}

-(int)height {
    return 50;
}



-(Class)viewClass {
    return NSClassFromString(@"ContactUserView");
}

@end



@interface ContactUserView : SelectUserRowView

-(ContactUserItem *)rowItem;
@property (nonatomic,strong) NSColor *color;
@end


@implementation ContactUserView



-(BOOL)isEditable {
    return NO;
}

-(BOOL)isSelectable {
    return YES;
}



-(NSColor *)color
{
    return _color != nil ? _color : NSColorFromRGB(0xffffff);
}



-(void)redrawRow {
    [super redrawRow];
}

-(ContactUserItem *)rowItem {
    return (ContactUserItem *) [super rowItem];
}


-(void)checkSelected:(BOOL)isSelected
{
    [self.titleTextField setSelected:isSelected];
    [self.lastSeenTextField setSelected:isSelected];
}


-(void)drawRect:(NSRect)dirtyRect {
    

    if(self.isSelected) {
        [BLUE_COLOR_SELECT setFill];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
    } else {
        [super drawRect:dirtyRect];
    }
	 
}

@end


@interface ContactsViewController ()<TMTableViewDelegate,TMNavagationDelegate>

@property (nonatomic,strong) TMTableView *tableView;


@property (nonatomic,strong) ContactFirstItem *firstItem;
@property (nonatomic,strong) ContactFirstView *firstView;

@end

@implementation ContactsViewController


-(void)loadView {
    [super loadView];
    
    int topOffset = 48;
    
    self.searchViewController.type = TGModernSearchTypeDialogs | TGModernSearchTypeGlobalUsers;

    
    self.tableView = [[TGConversationsTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - topOffset)];
    self.tableView.tm_delegate = self;
    
    [self.view addSubview:self.tableView.containerView];
    
    self.mainView = self.tableView.containerView;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
  //  [self.tableView insert:@[self.broadcastItem,self.secretChatItem] startIndex:self.tableView.list.count tableRedraw:YES];
    
    
    
    
    self.firstItem = [[ContactFirstItem alloc] init];
    
    self.firstView = [[ContactFirstView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), 40)];
    
}

-(void)onContactsSortChanged:(NSNotification *)notification {
    [self.tableView.list sortUsingComparator:^NSComparisonResult(ContactUserItem *obj1, ContactUserItem *obj2) {
        
        if([obj1 isKindOfClass:[TGContactSelfUserItem class]]) {
            return NSOrderedAscending;
        } else if([obj2 isKindOfClass:[TGContactSelfUserItem class]]) {
            return NSOrderedDescending;
        }
        
        if([obj1 isKindOfClass:[SearchSeparatorItem class]]) {
            return NSOrderedAscending;
        } else if([obj2 isKindOfClass:[SearchSeparatorItem class]]) {
            return NSOrderedDescending;
        }
        
        
        
        if([obj1 isKindOfClass:[ContactFirstItem class]] )
        {
            return NSOrderedAscending;
        } else if([obj2 isKindOfClass:[ContactFirstItem class]] )
        {
            return NSOrderedDescending;
        }
        
        
        NSComparisonResult result = [@(obj1.user.lastSeenTime) compare:@(obj2.user.lastSeenTime)];
        
        return result == NSOrderedAscending ? NSOrderedDescending : result == NSOrderedDescending ? NSOrderedAscending : NSOrderedSame;
        
    }];
    
    [self.tableView reloadData];
}

-(void)didChangedController:(TMViewController *)controller {
    
}

-(void)willChangedController:(TMViewController *)controller {
    __block BOOL ret = NO;
    
    [[Telegram rightViewController].navigationViewController.viewControllerStack enumerateObjectsUsingBlock:^(TMViewController *obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[MessagesViewController class]]) {
            MessagesViewController *messagesController = (MessagesViewController *)obj;
            if(messagesController.conversation.type == DialogTypeUser) {
                [self.tableView setSelectedByHash:messagesController.conversation.peer.peer_id];
                
                *stop = YES;
                ret = YES;
            }
        }
        
        
        
    }];
    
    if(ret)
        return;
    
    
    [self.tableView cancelSelection];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[Telegram rightViewController].navigationViewController addDelegate:self];
    
    [self willChangedController:[Telegram rightViewController].navigationViewController.currentController];
    
    [Notification addObserver:self selector:@selector(onContactsSortChanged:) name:CONTACTS_SORT_CHANGED];
    [Notification addObserver:self selector:@selector(contactsLoaded:) name:CONTACTS_MODIFIED];
    
    [self contactsLoaded:nil];
}

-(void)dealloc {
    [Notification removeObserver:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [Notification removeObserver:self];
}

-(void)contactsLoaded:(NSNotification *)notify {
    
    NSArray *all = [[[NewContactsManager sharedManager] all] copy];
    
    [self.tableView removeAllItems:NO];
    
    [self.tableView reloadData];
    
    
    [self.tableView addItem:[[TGContactSelfUserItem alloc] initWithObject:[UsersManager currentUser]] tableRedraw:NO];
    [self.tableView addItem:[[SearchSeparatorItem alloc] initWithOneName:NSLocalizedString(@"Search.Separator.Contacts", nil) pluralName:nil] tableRedraw:NO];
    [self.tableView addItem:self.firstItem tableRedraw:NO];
    
    [self.tableView reloadData];
    
    if(all.count > 100) {
        [self insertAll:[all subarrayWithRange:NSMakeRange(0, 20)]];
        
        dispatch_after_seconds(0.2, ^{
            [self insertAll:[all subarrayWithRange:NSMakeRange(20, all.count-20)]];
        });
    } else {
        [self insertAll:all];
    }
}

-(void)insertAll:(NSArray *)all {
    
    
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for(TL_contact *contact in all) {
        
        if(contact.user.type != TLUserTypeEmpty && contact.user.type != TLUserTypeDeleted) {
            ContactUserItem *item = [[ContactUserItem alloc] initWithObject:contact.user];
            [contacts addObject:item];
        }
    }
    
    
    NSTableViewAnimationOptions animation = self.tableView.defaultAnimation;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    
    [self.tableView insert:contacts startIndex:self.tableView.list.count tableRedraw:NO];
    
    [self.tableView reloadData];
    
    self.tableView.defaultAnimation = animation;
}


- (void) setHidden:(BOOL)isHidden {
    [super setHidden:isHidden];
    
    if(isHidden) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
}



- (void)notificationContactsReload:(NSNotification *)notify {
    
    MTLog(@"notification reload");
}



- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    return item.height;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (NSView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    
    return  [self.tableView cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(_tableView.frame), item.height)];
}


- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

- (BOOL) selectionWillChange:(NSInteger)row item:(ContactUserItem *) item {
    if(row != 0 && [[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] modalViewSendAction:item.user.dialog];
        return NO;
    }
    
    if(row == 0 && [[Telegram rightViewController] isModalViewActive]) {
        [[Telegram rightViewController] modalViewSendAction:[UsersManager currentUser].dialog];
    }
    return ![Telegram rightViewController].navigationViewController.isLocked;
}

- (void) selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[ContactUserItem class]]) {
         ContactUserItem *searchItem = (ContactUserItem *) item;
        
        [appWindow().navigationController showMessagesViewController:searchItem.user.dialog];
        
    } else if([item isKindOfClass:[ContactFirstItem class]]) {
        
        TGAddContactModalView *modalView = [[TGAddContactModalView alloc] init];
        
        [modalView show:self.view.window animated:YES];

    } else if([item isKindOfClass:[TGContactSelfUserItem class]]) {
        [appWindow().navigationController showMessagesViewController:[UsersManager currentUser].dialog];

    }
   
}


@end
