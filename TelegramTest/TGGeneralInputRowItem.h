//
//  TGGeneralInputRowItem.h
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralRowItem.h"

@interface TGGeneralInputRowItem : TGGeneralRowItem

@property (nonatomic,assign) int limit;

@property (nonatomic,strong) NSString *placeholder;
@property (nonatomic,strong) NSString *placeholderAttributed;
@property (nonatomic,strong) NSAttributedString *result;

@property (nonatomic,assign) BOOL hintAbility;

@property (nonatomic,strong) TL_conversation *conversation;

@end
