//
//  TGForwardObject.m
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForwardObject.h"



@implementation TGForwardObject

-(id)initWithMessages:(NSArray *)messages {
    if(self = [super init]) {
        
        _messages = messages;
        
        
        NSMutableAttributedString *n = [[NSMutableAttributedString alloc] init];
        
        NSMutableArray *firstNames = [[NSMutableArray alloc] init];
        
        
        NSMutableArray *exception = [[NSMutableArray alloc] init];
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage  *obj, NSUInteger idx, BOOL *stop) {
            
            if(obj.from_id != 0) {
                if([exception indexOfObject:obj.fromUser] == NSNotFound) {
                    [firstNames addObject:obj.fromUser.first_name];
                    [exception addObject:obj.fromUser];
                }
            } else {
                [firstNames addObject:obj.chat.title];
                *stop = YES;
            }
            
        }];
        
        
        
        
        [n appendString:[firstNames componentsJoinedByString:@", "] withColor:LINK_COLOR];
        
        [n setFont:[SettingsArchiver fontMedium125] forRange:n.range];
        
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        
        [n addAttribute:NSParagraphStyleAttributeName value:style range:n.range];
        
        _names = n;
        
        
        
         NSMutableAttributedString *d = [[NSMutableAttributedString alloc] init];
        
        [d appendString:[NSString stringWithFormat:NSLocalizedString(messages.count == 1 ? @"Forward.Message" : @"Forward.Messages", nil), messages.count] withColor:GRAY_TEXT_COLOR];
        
        [d setFont:[SettingsArchiver font125] forRange:d.range];
        
        _fwd_desc = d;
        

        
        
        
    }
    
    return self;
}

@end
