//
//  MessageTableItemPhoto.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "TGImageObject.h"
@interface MessageTableItemPhoto : MessageTableItem


@property (nonatomic,strong) TGImageObject *imageObject;


-(BOOL)isSecretPhoto;


@end
