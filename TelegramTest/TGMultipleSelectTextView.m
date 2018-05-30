//
//  TGMultipleSelectTextView.m
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGMultipleSelectTextView.h"
#import "MessageTableItemText.h"
@implementation TGMultipleSelectTextView



-(void)_mouseDragged:(NSEvent *)theEvent {
   
}

-(void)_mouseDown:(NSEvent *)theEvent {
    
}



-(void)_parentMouseDragged:(NSEvent *)theEvent {
    currentSelectPosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    [self setNeedsDisplay:YES];
}

-(void)_parentMouseDown:(NSEvent *)theEvent {
    
}


-(void)copy:(id)sender {
    [[SelectTextManager instance] copy:sender];
}

-(void)_resignFirstResponder {
   
}

-(BOOL)_checkClickCount:(NSEvent *)theEvent {
    
    
    if([super _checkClickCount:theEvent]) {
         [SelectTextManager addRange:self.selectRange forItem:self.owner];
        
        return YES;
    }
    
    return NO;
    
}

-(void)open_link:(NSString *)link itsReal:(BOOL)itsReal {
    MessageTableItemText *item = self.owner;
    
    if(item.message.peer_id < 0 && item.message.fromUser.isBot && [link hasPrefix:TLBotCommandPrefix]) {
        link = [NSString stringWithFormat:@"%@@%@",link,item.message.fromUser.username];
    }
    
    
    [super open_link:link itsReal:itsReal];
}


-(void)rightMouseDown:(NSEvent *)theEvent {
    
    int index = [self currentIndexInLocation:[self convertPoint:[theEvent locationInWindow] fromView:nil]];
    
    MessageTableItem *item = self.owner;

    
    if([SelectTextManager count] > 0) {
        if ([self indexIsSelected:index] && [item isKindOfClass:[MessageTableItem class]] && item.message.conversation.canSendMessage) {
            NSTextView *view = (NSTextView *) [self.window fieldEditor:YES forObject:self];
            [view setEditable:YES];
            [view setSelectable:YES];
            [view setString:[SelectTextManager fullString]];
            
            [view setSelectedRange:NSMakeRange(0, view.string.length)];
            
            NSMenu *menu = [view menuForEvent:theEvent];
            
            [menu insertItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Quote", nil) withBlock:^(id sender) {
                
                
                __block NSString *result = @"";
                
                [SelectTextManager enumerateItems:^(MessageTableItemText *obj, NSRange range) {
                    
                    NSString *userName = @"";
                    
                    if(obj.message.fwd_from != nil) {
                        if(obj.fwd_user.username.length > 0) {
                            userName = [NSString stringWithFormat:@"@%@",obj.fwd_user.username];
                        } else {
                            userName = obj.fwd_user.first_name;
                        }
                    } else {
                        if(obj.user.username.length > 0) {
                            userName = [NSString stringWithFormat:@"@%@",obj.user.username];
                        } else {
                            userName = obj.user.first_name;
                        }
                    }
                    
                    result = [result stringByAppendingFormat:@"> %@\n%@\n\n", userName,[obj.string substringWithRange:range]];
                }];
                
                //  result = [result substringToIndex:result.length-1];
                
                if([self.owner isKindOfClass:[MessageTableItem class]]) {
                    
                    MessageTableItem *item = self.owner;
                    
                    TGInputMessageTemplate *template = item.message.conversation.inputTemplate;
                    
                    [template updateTextAndSave:[[NSAttributedString alloc] initWithString:result]];
                    [template performNotification];
                    
                    [item.table.viewController becomeFirstResponder];
                }
                
                
                
                
                NSPasteboard* cb = [NSPasteboard generalPasteboard];
                
                [cb declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:[SelectTextManager instance]];
                
                [cb setString:result forType:NSStringPboardType];
                
                
            }] atIndex:0];
            
            MessageTableItem *item = self.owner;
            
            if(item.message.conversation.canSendMessage)  {
                
                [menu insertItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Reply", nil) withBlock:^(id sender) {
                    
                    TGInputMessageTemplate *template = [TGInputMessageTemplate templateWithType:TGInputMessageTemplateTypeSimpleText ofPeerId:item.message.peer_id];
                    [template setReplyMessage:item.message save:YES];
                    [template performNotification];
                    
                }] atIndex:1];
                
                [menu insertItem:[NSMenuItem separatorItem] atIndex:2];
                
            }
            
           [NSMenu popUpContextMenu:menu withEvent:theEvent forView:view];
        }
       
    } else {
        
        [SelectTextManager clear];
        
        theEvent = [NSEvent mouseEventWithType:theEvent.type location:theEvent.locationInWindow modifierFlags:theEvent.modifierFlags timestamp:theEvent.timestamp windowNumber:theEvent.windowNumber context:theEvent.context eventNumber:theEvent.eventNumber clickCount:2 pressure:theEvent.pressure];
        
        [self _checkClickCount:theEvent];
        
        if([SelectTextManager count] > 0) {
            [self rightMouseDown:theEvent];
        } else {
            [super rightMouseDown:theEvent];
        }
        
        
        
    }
}




-(void)mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
}



@end
