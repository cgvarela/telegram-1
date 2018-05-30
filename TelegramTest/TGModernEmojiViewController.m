//
//  TGModernESGViewController.m
//  Telegram
//
//  Created by keepcoder on 19/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernEmojiViewController.h"
#import "EmojiButton.h"
#import "TGRaceEmoji.h"
#import "TGTextLabel.h"
#import "TGModernESGViewController.h"
#import "TGTextLabel.h"
#import "TGModernStickRowItem.h"
#import "NSString+Extended.h"
@interface TGModernEmojiRowView : TMRowView
@property (nonatomic, strong) RBLPopover *racePopover;
@end



@interface TGModernEmojiBottomButton : BTRButton
@property (nonatomic) int index;
@property (nonatomic,weak) id stickItem;
@end

@implementation TGModernEmojiBottomButton

- (void)handleStateChange {
    [super handleStateChange];
    
    if(self.state & BTRControlStateHover || self.state & BTRControlStateSelected || self.state & BTRControlStateHighlighted) {
        [self.backgroundImageView setAlphaValue:1];
    } else {
        [self.backgroundImageView setAlphaValue:0.7];
    }
    
}

@end


@interface TGModernEmojiRowItem : TMRowItem
@property (nonatomic,strong) NSArray *list;
@property (nonatomic,assign) NSUInteger nhash;
@property (nonatomic, weak) TGModernEmojiViewController *controller;
@property (nonatomic,strong) NSAttributedString *attr;
@property (nonatomic,assign) NSSize size;

@end

@implementation TGModernEmojiRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        NSMutableArray *list = [NSMutableArray array];
        
        
        static NSMutableParagraphStyle *paragraph;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            paragraph = [[NSMutableParagraphStyle alloc] init];
            [paragraph setLineSpacing:10];
            
        });
        
        
        [object enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
            
            NSString *modifier = [TGModernESGViewController emojiModifier:obj];
            
            if(modifier) {
                obj = [obj emojiWithModifier:modifier emoji:obj];
            }
            
            [attr appendString:obj];
            
            [attr addAttribute:NSParagraphStyleAttributeName value:paragraph range:attr.range];
            [attr addAttribute:(NSString *) kCTKernAttributeName value:@(0.0) range:attr.range];
            [attr setFont:TGSystemFont(17) forRange:attr.range];
            
            [list addObject:attr];
    
       
        }];
        
        
        _list = list;

        _nhash = [[object componentsJoinedByString:@" "] hash];
        
    }
    
    return self;
}

-(int)height {
    return 34.0;
}

-(NSUInteger)hash {
    return _nhash;
}

-(Class)viewClass {
    return [TGModernEmojiRowView class];
}

@end



@implementation TGModernEmojiRowView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        [self setWantsLayer:YES];
        
        
      //  for (int index = 0; index < 10; index++) {
            
            
            EmojiButton *button = [[EmojiButton alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect), NSHeight(frameRect))];
        
        weak();
        [button setEmojiCallback:^(NSString *emoji) {
            TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) weakSelf.rowItem;
            if(!item.controller.epopover.lockHoverClose) {
                [item.controller insertEmoji:emoji];
            }
        }];
        

           // [button addTarget:self action:@selector(emojiClick:) forControlEvents:BTRControlEventMouseUpInside];
            
            if(floor(NSAppKitVersionNumber) >= 1347 ) {
          //      [button addTarget:self action:@selector(emojiLongClick:) forControlEvents:BTRControlEventLongLeftClick];
            }
            
            [self addSubview:button];
     //   }
        
        
        
        
        
    }
    return self;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    EmojiButton *button = [self.subviews objectAtIndex:0];
    
    [button setFrameSize:newSize];
    
    
}


-(void)redrawRow {
    [super redrawRow];
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    
    
    [self setEmoji:item.attr atIndex:0];
    
}


- (void)setEmoji:(NSAttributedString *)string atIndex:(NSUInteger)index {
    
    TGModernEmojiRowItem *item = (TGModernEmojiRowItem *) self.rowItem;
    
    
    EmojiButton *button = [self.subviews objectAtIndex:index];
    button.controller = item.controller;
    
   
    
    [button setList:item.list];

//    
//    [button setHighlighted:NO];
//    [button setHovered:NO];
//    [button setSelected:NO];
}


@end


@interface TGModernEmojiViewController () <TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMView *bottomView;
@property (nonatomic,strong) BTRButton *showGSControllerView;

@end

@implementation TGModernEmojiViewController

static NSArray *segment_list;


-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    int topOffset = self.esgViewController.isLayoutStyle ? 58 : 44;
    
    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, topOffset, NSWidth(self.view.frame) - 0, NSHeight(self.view.frame) - topOffset)];
    [self.view addSubview:_tableView.containerView];
    
    _tableView.tm_delegate = self;
    
    
    self.bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, topOffset)];
    
    weak();
    
    [self.bottomView setDrawBlock:^{
        [DIALOG_BORDER_COLOR set];
        NSRectFill(NSMakeRect(0, NSHeight(weakSelf.bottomView.frame) - DIALOG_BORDER_WIDTH, NSWidth(weakSelf.bottomView.frame), DIALOG_BORDER_WIDTH));
    }];
    
    
    float w = roundf( NSWidth(self.view.frame)/(float)(self.segments.count ));
    
    int xoffset = 0;
    for(int i = 1; i <= self.segments.count; i++) {
        BTRButton *button = [self createButtonForIndex:i width:w];//20
        [button setFrameOrigin:NSMakePoint(xoffset, roundf((NSHeight(self.bottomView.frame) - NSHeight(button.frame))/2.0f))];
        xoffset+=NSWidth(button.frame);
        [self.bottomView addSubview:button];
    }
    
    [self.view addSubview:self.bottomView];
    
    _showGSControllerView = [[BTRButton alloc] initWithFrame:NSZeroRect];
    
    [_showGSControllerView setTitle:NSLocalizedString(@"EGS.GifsAndStickers", nil) forControlState:BTRControlStateNormal];
    [_showGSControllerView setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
    [_showGSControllerView setTitleFont:TGSystemMediumFont(13) forControlState:BTRControlStateNormal];
    
    [_showGSControllerView.titleLabel sizeToFit];
    
    [_showGSControllerView setFrame:NSMakeRect(NSWidth(self.view.frame) - NSWidth(_showGSControllerView.titleLabel.frame) - 10, NSHeight(self.view.frame) - NSHeight(_showGSControllerView.titleLabel.frame) - 8, NSWidth(_showGSControllerView.titleLabel.frame), 20)];
    _showGSControllerView.autoresizingMask = NSViewMinYMargin;
    
    
    [_showGSControllerView addBlock:^(BTRControlEvents events) {
        
        [weakSelf.esgViewController showSGController:YES];
        
    } forControlEvents:BTRControlEventClick];
    [self.view addSubview:_showGSControllerView];
    
    [self addScrollEvent];

}

-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
    [_showGSControllerView setHidden:_messagesViewController == nil];
}

-(void)addScrollEvent {
    id clipView = [[self.tableView enclosingScrollView] contentView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didScrolledTableView:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:clipView];
    
}

-(void)removeScrollEvent {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self show];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self close];
}


-(NSArray *)segments {
    return @[@"Emoji.Recent",@"Emoji.SmilesAndPeople",@"Emoji.AnimalsAndNature",@"Emoji.FoodAndDrink",@"Emoji.ActivityAndSport",@"Emoji.TravelAndPlaces",@"Emoji.Objects",@"Emoji.Symbols",@"Emoji.Flags"];
}

- (void)show {
    
    [self.tableView removeAllItems:NO];
    
    int rowCount = floor(NSWidth(_tableView.frame) / 34.0f) ;
    
    NSMutableArray *stickyItems = [NSMutableArray array];
    
    [segment_list enumerateObjectsUsingBlock:^(NSArray *list, NSUInteger idx, BOOL * _Nonnull stop) {
        
         NSMutableArray *items = [NSMutableArray array];
        
        id stickyItem = [[TGModernStickRowItem alloc] initWithObject:NSLocalizedString(self.segments[idx], nil)];
        [stickyItems addObject:stickyItem];
        [_tableView addItem:stickyItem tableRedraw:NO];
        
        if(self.bottomView.subviews.count > idx)
            [self.bottomView.subviews[idx] setStickItem:stickyItem];
        
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            [items addObject:obj];
            
            if(items.count == rowCount ) {
                TGModernEmojiRowItem *item = [[TGModernEmojiRowItem alloc] initWithObject:[items copy]];
                item.controller = self;
                
                [_tableView addItem:item tableRedraw:NO];
                [items removeAllObjects];
            }
            
        }];
        
        if(items.count > 0) {
            TGModernEmojiRowItem *item = [[TGModernEmojiRowItem alloc] initWithObject:[items copy]];
            item.controller = self;

            [_tableView addItem:item tableRedraw:NO];
        }
        
    }];
    
    
    [self.tableView reloadData];
    
    [self.tableView setStickClass:[TGModernStickRowItem class]];
    
    [self _didScrolledTableView:nil];

}

- (void)close {
    [self.tableView removeAllItems:NO];
    [self.tableView reloadData];
}


+(void)initialize {
   
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *path;
        
        if(NSAppKitVersionNumber >= 1404)
            path = [[NSBundle mainBundle] pathForResource:@"emoji1404" ofType:@"txt"];
        else if(floor(NSAppKitVersionNumber) >= 1347)
             path = [[NSBundle mainBundle] pathForResource:@"emoji1347" ofType:@"txt"];
        else
             path = [[NSBundle mainBundle] pathForResource:@"emoji" ofType:@"txt"];
        
        NSError *error;
        
        NSString *emoji = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:&error];
        
        NSArray *list = [emoji componentsSeparatedByString:@"\n\n"];
        
        NSMutableArray *separated = [NSMutableArray array];
        
        [list enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [separated addObject:[[obj componentsSeparatedByString:@" "] mutableCopy]];
        }];
        
        
        NSArray *recently = [Storage emoji];
        
        NSMutableArray *recent = separated[0];
        
        [recently enumerateObjectsUsingBlock:^(NSString *emoji, NSUInteger idx, BOOL *stop) {
            [recent removeObject:emoji];
        }];
        
        [recent addObjectsFromArray:recently];
        
        segment_list = [separated copy];
        
    });
    
    
}

-(void)saveModifier:(NSString *)modifier forEmoji:(NSString *)emoji {
    
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *modifiers = [s objectForKey:@"emojiModifiers"];
    
    if(!modifiers) {
        modifiers = [[NSMutableDictionary alloc] init];
        
    } else {
        modifiers = [modifiers mutableCopy];
    }
    
    if(modifier) {
        modifiers[emoji] = modifier;
    } else {
        [modifiers removeObjectForKey:emoji];
    }
    
    
    
    [s setObject:modifiers forKey:@"emojiModifiers"];
    
    
    [self show];
    
}

-(NSString *)emojiModifier:(NSString *)emoji {
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableDictionary *modifiers = [s objectForKey:@"emojiModifiers"];
    
    
    return modifiers[emoji];
}

- (void)insertEmoji:(NSString *)emoji {
    if(self.insertEmoji)
        self.insertEmoji(emoji);
}

+ (void)saveEmoji:(NSArray *)array {
    
    NSMutableArray *recent = segment_list[0];
    
    for(NSString *emoji in array) {
        [recent removeObject:emoji];
        [recent insertObject:emoji atIndex:0];
    }
    
    [Storage saveEmoji:recent];

}


- (TGModernEmojiBottomButton *)createButtonForIndex:(int)index width:(int)width {
    
    NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"emojiContainer%d",index]];
    
    image = [image imageTintedWithColor:GRAY_ICON_COLOR];
    NSImage *active = [image imageTintedWithColor:BLUE_ICON_COLOR];
    
    
    TGModernEmojiBottomButton *button = [[TGModernEmojiBottomButton alloc] initWithFrame:NSMakeRect(0, 0, width, image.size.height)];
    [button setImage:image forControlState:BTRControlStateNormal];
    [button setImage:image forControlState:BTRControlStateHover];
    [button setImage:active forControlState:BTRControlStateHover | BTRControlStateSelected];
    [button setImage:active forControlState:BTRControlStateHighlighted];
    [button setImage:active forControlState:BTRControlStateSelected];
    [button setIndex:index];
    [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:BTRControlEventLeftClick];
    return button;
}

-(void)bottomButtonClick:(TGModernEmojiBottomButton *)button {
    
    __block id currentStick;
    
    __block int currentStickIdx = 0;
    
    [self.tableView.list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([obj isKindOfClass:_tableView.stickClass]) {
            currentStickIdx ++;
            
            if(button.index == currentStickIdx) {
                currentStick = obj;
                *stop = YES;
            }
        }
        
    }];
    
    NSRect rect = [self.tableView rectOfRow:[self.tableView indexOfItem:currentStick]];
    
    [self.tableView.scrollView.clipView scrollRectToVisible:NSMakeRect(0, NSMaxY(rect) + 20, NSWidth(rect), NSHeight(_tableView.containerView.frame)) animated:YES];
    
}

-(void)_didScrolledTableView:(NSNotification *)notification {
    __block id currentStick;
    
    
    if(self.tableView.list.count > 0) {
        NSRange range = [self.tableView rowsInRect:[self.tableView visibleRect]];
        
        if(range.location != NSNotFound) {
            [self.tableView.list enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, range.location + 1)] options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if([obj isKindOfClass:_tableView.stickClass]) {
                    currentStick = obj;
                    *stop = YES;
                }
                
            }];
            
            
            __block BOOL s = NO;
            
            [self.bottomView.subviews enumerateObjectsUsingBlock:^(TGModernEmojiBottomButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [obj setSelected:obj.stickItem == currentStick];
                
                if(obj.isSelected && !s)
                {
                    s = YES;
                }
                
                
                if(idx == self.bottomView.subviews.count-1 && !s) {
                    [obj setSelected:YES];
                }
                
            }];
        }
        
       
    }
    
    
}

-(void)dealloc {
    [self removeScrollEvent];
}


- (CGFloat)rowHeight:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return item.height;
}
- (BOOL)isGroupRow:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}
- (TMRowView *)viewForRow:(NSUInteger)row item:(TGModernEmojiRowItem *) item {
    return [_tableView cacheViewForClass:[item viewClass] identifier:NSStringFromClass([item viewClass]) withSize:NSMakeSize(NSWidth(_tableView.frame), item.height)];
}
- (void)selectionDidChange:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    
}
- (BOOL)selectionWillChange:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}
- (BOOL)isSelectable:(NSInteger)row item:(TGModernEmojiRowItem *) item {
    return NO;
}


@end
