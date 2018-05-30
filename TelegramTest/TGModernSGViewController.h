//
//  TGModernSGViewController.h
//  Telegram
//
//  Created by keepcoder on 20/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"
@class TGModernESGViewController;
@interface TGModernSGViewController : TMViewController

@property (nonatomic,weak) TGModernESGViewController *esgViewController;

@property (nonatomic,assign) BOOL hideEmoji;


-(void)show;
-(void)close;


-(void)reloadStickers;

@end
