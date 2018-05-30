//
//  TLApi.h
//  Telegram
//
//  Auto created by Mikhail Filimonov on 22.12.16.
//  Copyright (c) 2013 Telegram for OS X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLApi.h"
#import "TLApiObject.h"

@interface TLAPI_auth_checkPhone : TLApiObject
@property (nonatomic, strong) NSString* phone_number;

+(TLAPI_auth_checkPhone*)createWithPhone_number:(NSString*)phone_number;
@end

@interface TLAPI_auth_sendCode : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAllow_flashcall;
@property (nonatomic, strong) NSString* phone_number;
@property Boolean current_number;
@property int api_id;
@property (nonatomic, strong) NSString* api_hash;

+(TLAPI_auth_sendCode*)createWithFlags:(int)flags  phone_number:(NSString*)phone_number current_number:(Boolean)current_number api_id:(int)api_id api_hash:(NSString*)api_hash;
@end

@interface TLAPI_auth_signUp : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;

+(TLAPI_auth_signUp*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code first_name:(NSString*)first_name last_name:(NSString*)last_name;
@end

@interface TLAPI_auth_signIn : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;

+(TLAPI_auth_signIn*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code;
@end

@interface TLAPI_auth_logOut : TLApiObject


+(TLAPI_auth_logOut*)create;
@end

@interface TLAPI_auth_resetAuthorizations : TLApiObject


+(TLAPI_auth_resetAuthorizations*)create;
@end

@interface TLAPI_auth_sendInvites : TLApiObject
@property (nonatomic, strong) NSMutableArray* phone_numbers;
@property (nonatomic, strong) NSString* message;

+(TLAPI_auth_sendInvites*)createWithPhone_numbers:(NSMutableArray*)phone_numbers message:(NSString*)message;
@end

@interface TLAPI_auth_exportAuthorization : TLApiObject
@property int dc_id;

+(TLAPI_auth_exportAuthorization*)createWithDc_id:(int)dc_id;
@end

@interface TLAPI_auth_importAuthorization : TLApiObject
@property int n_id;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_auth_importAuthorization*)createWithN_id:(int)n_id bytes:(NSData*)bytes;
@end

@interface TLAPI_auth_bindTempAuthKey : TLApiObject
@property long perm_auth_key_id;
@property long nonce;
@property int expires_at;
@property (nonatomic, strong) NSData* encrypted_message;

+(TLAPI_auth_bindTempAuthKey*)createWithPerm_auth_key_id:(long)perm_auth_key_id nonce:(long)nonce expires_at:(int)expires_at encrypted_message:(NSData*)encrypted_message;
@end

@interface TLAPI_account_registerDevice : TLApiObject
@property int token_type;
@property (nonatomic, strong) NSString* token;

+(TLAPI_account_registerDevice*)createWithToken_type:(int)token_type token:(NSString*)token;
@end

@interface TLAPI_account_unregisterDevice : TLApiObject
@property int token_type;
@property (nonatomic, strong) NSString* token;

+(TLAPI_account_unregisterDevice*)createWithToken_type:(int)token_type token:(NSString*)token;
@end

@interface TLAPI_account_updateNotifySettings : TLApiObject
@property (nonatomic, strong) TLInputNotifyPeer* peer;
@property (nonatomic, strong) TLInputPeerNotifySettings* settings;

+(TLAPI_account_updateNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer settings:(TLInputPeerNotifySettings*)settings;
@end

@interface TLAPI_account_getNotifySettings : TLApiObject
@property (nonatomic, strong) TLInputNotifyPeer* peer;

+(TLAPI_account_getNotifySettings*)createWithPeer:(TLInputNotifyPeer*)peer;
@end

@interface TLAPI_account_resetNotifySettings : TLApiObject


+(TLAPI_account_resetNotifySettings*)create;
@end

@interface TLAPI_account_updateProfile : TLApiObject
@property int flags;
@property (nonatomic, strong) NSString* first_name;
@property (nonatomic, strong) NSString* last_name;
@property (nonatomic, strong) NSString* about;

+(TLAPI_account_updateProfile*)createWithFlags:(int)flags first_name:(NSString*)first_name last_name:(NSString*)last_name about:(NSString*)about;
@end

@interface TLAPI_account_updateStatus : TLApiObject
@property Boolean offline;

+(TLAPI_account_updateStatus*)createWithOffline:(Boolean)offline;
@end

@interface TLAPI_account_getWallPapers : TLApiObject


+(TLAPI_account_getWallPapers*)create;
@end

@interface TLAPI_account_reportPeer : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) TLReportReason* reason;

+(TLAPI_account_reportPeer*)createWithPeer:(TLInputPeer*)peer reason:(TLReportReason*)reason;
@end

@interface TLAPI_users_getUsers : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_users_getUsers*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_users_getFullUser : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_users_getFullUser*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_getStatuses : TLApiObject


+(TLAPI_contacts_getStatuses*)create;
@end

@interface TLAPI_contacts_getContacts : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_contacts_getContacts*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_contacts_importContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray* contacts;
@property Boolean replace;

+(TLAPI_contacts_importContacts*)createWithContacts:(NSMutableArray*)contacts replace:(Boolean)replace;
@end

@interface TLAPI_contacts_deleteContact : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_deleteContact*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_deleteContacts : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_contacts_deleteContacts*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_contacts_block : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_block*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_unblock : TLApiObject
@property (nonatomic, strong) TLInputUser* n_id;

+(TLAPI_contacts_unblock*)createWithN_id:(TLInputUser*)n_id;
@end

@interface TLAPI_contacts_getBlocked : TLApiObject
@property int offset;
@property int limit;

+(TLAPI_contacts_getBlocked*)createWithOffset:(int)offset limit:(int)limit;
@end

@interface TLAPI_contacts_exportCard : TLApiObject


+(TLAPI_contacts_exportCard*)create;
@end

@interface TLAPI_contacts_importCard : TLApiObject
@property (nonatomic, strong) NSMutableArray* export_card;

+(TLAPI_contacts_importCard*)createWithExport_card:(NSMutableArray*)export_card;
@end

@interface TLAPI_messages_getMessages : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_getMessages*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_getDialogs : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isExclude_pinned;
@property int offset_date;
@property int offset_id;
@property (nonatomic, strong) TLInputPeer* offset_peer;
@property int limit;

+(TLAPI_messages_getDialogs*)createWithFlags:(int)flags  offset_date:(int)offset_date offset_id:(int)offset_id offset_peer:(TLInputPeer*)offset_peer limit:(int)limit;
@end

@interface TLAPI_messages_getHistory : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int offset_id;
@property int offset_date;
@property int add_offset;
@property int limit;
@property int max_id;
@property int min_id;

+(TLAPI_messages_getHistory*)createWithPeer:(TLInputPeer*)peer offset_id:(int)offset_id offset_date:(int)offset_date add_offset:(int)add_offset limit:(int)limit max_id:(int)max_id min_id:(int)min_id;
@end

@interface TLAPI_messages_search : TLApiObject
@property int flags;
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) NSString* q;
@property (nonatomic, strong) TLMessagesFilter* filter;
@property int min_date;
@property int max_date;
@property int offset;
@property int max_id;
@property int limit;

+(TLAPI_messages_search*)createWithFlags:(int)flags peer:(TLInputPeer*)peer q:(NSString*)q filter:(TLMessagesFilter*)filter min_date:(int)min_date max_date:(int)max_date offset:(int)offset max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_readHistory : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int max_id;

+(TLAPI_messages_readHistory*)createWithPeer:(TLInputPeer*)peer max_id:(int)max_id;
@end

@interface TLAPI_messages_deleteHistory : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isJust_clear;
@property (nonatomic, strong) TLInputPeer* peer;
@property int max_id;

+(TLAPI_messages_deleteHistory*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer max_id:(int)max_id;
@end

@interface TLAPI_messages_deleteMessages : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isRevoke;
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_deleteMessages*)createWithFlags:(int)flags  n_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_receivedMessages : TLApiObject
@property int max_id;

+(TLAPI_messages_receivedMessages*)createWithMax_id:(int)max_id;
@end

@interface TLAPI_messages_setTyping : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) TLSendMessageAction* action;

+(TLAPI_messages_setTyping*)createWithPeer:(TLInputPeer*)peer action:(TLSendMessageAction*)action;
@end

@interface TLAPI_messages_sendMessage : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isNo_webpage;
@property (nonatomic,assign,readonly) BOOL isSilent;
@property (nonatomic,assign,readonly) BOOL isBackground;
@property (nonatomic,assign,readonly) BOOL isClear_draft;
@property (nonatomic, strong) TLInputPeer* peer;
@property int reply_to_msg_id;
@property (nonatomic, strong) NSString* message;
@property long random_id;
@property (nonatomic, strong) TLReplyMarkup* reply_markup;
@property (nonatomic, strong) NSMutableArray* entities;

+(TLAPI_messages_sendMessage*)createWithFlags:(int)flags     peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id message:(NSString*)message random_id:(long)random_id reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities;
@end

@interface TLAPI_messages_sendMedia : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSilent;
@property (nonatomic,assign,readonly) BOOL isBackground;
@property (nonatomic,assign,readonly) BOOL isClear_draft;
@property (nonatomic, strong) TLInputPeer* peer;
@property int reply_to_msg_id;
@property (nonatomic, strong) TLInputMedia* media;
@property long random_id;
@property (nonatomic, strong) TLReplyMarkup* reply_markup;

+(TLAPI_messages_sendMedia*)createWithFlags:(int)flags    peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id media:(TLInputMedia*)media random_id:(long)random_id reply_markup:(TLReplyMarkup*)reply_markup;
@end

@interface TLAPI_messages_forwardMessages : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSilent;
@property (nonatomic,assign,readonly) BOOL isBackground;
@property (nonatomic,assign,readonly) BOOL isWith_my_score;
@property (nonatomic, strong) TLInputPeer* from_peer;
@property (nonatomic, strong) NSMutableArray* n_id;
@property (nonatomic, strong) NSMutableArray* random_id;
@property (nonatomic, strong) TLInputPeer* to_peer;

+(TLAPI_messages_forwardMessages*)createWithFlags:(int)flags    from_peer:(TLInputPeer*)from_peer n_id:(NSMutableArray*)n_id random_id:(NSMutableArray*)random_id to_peer:(TLInputPeer*)to_peer;
@end

@interface TLAPI_messages_reportSpam : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;

+(TLAPI_messages_reportSpam*)createWithPeer:(TLInputPeer*)peer;
@end

@interface TLAPI_messages_hideReportSpam : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;

+(TLAPI_messages_hideReportSpam*)createWithPeer:(TLInputPeer*)peer;
@end

@interface TLAPI_messages_getPeerSettings : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;

+(TLAPI_messages_getPeerSettings*)createWithPeer:(TLInputPeer*)peer;
@end

@interface TLAPI_messages_getChats : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_getChats*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_getFullChat : TLApiObject
@property int chat_id;

+(TLAPI_messages_getFullChat*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_editChatTitle : TLApiObject
@property int chat_id;
@property (nonatomic, strong) NSString* title;

+(TLAPI_messages_editChatTitle*)createWithChat_id:(int)chat_id title:(NSString*)title;
@end

@interface TLAPI_messages_editChatPhoto : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputChatPhoto* photo;

+(TLAPI_messages_editChatPhoto*)createWithChat_id:(int)chat_id photo:(TLInputChatPhoto*)photo;
@end

@interface TLAPI_messages_addChatUser : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputUser* user_id;
@property int fwd_limit;

+(TLAPI_messages_addChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id fwd_limit:(int)fwd_limit;
@end

@interface TLAPI_messages_deleteChatUser : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_messages_deleteChatUser*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_messages_createChat : TLApiObject
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSString* title;

+(TLAPI_messages_createChat*)createWithUsers:(NSMutableArray*)users title:(NSString*)title;
@end

@interface TLAPI_updates_getState : TLApiObject


+(TLAPI_updates_getState*)create;
@end

@interface TLAPI_updates_getDifference : TLApiObject
@property int flags;
@property int pts;
@property int pts_total_limit;
@property int date;
@property int qts;

+(TLAPI_updates_getDifference*)createWithFlags:(int)flags pts:(int)pts pts_total_limit:(int)pts_total_limit date:(int)date qts:(int)qts;
@end

@interface TLAPI_photos_updateProfilePhoto : TLApiObject
@property (nonatomic, strong) TLInputPhoto* n_id;

+(TLAPI_photos_updateProfilePhoto*)createWithN_id:(TLInputPhoto*)n_id;
@end

@interface TLAPI_photos_uploadProfilePhoto : TLApiObject
@property (nonatomic, strong) TLInputFile* file;

+(TLAPI_photos_uploadProfilePhoto*)createWithFile:(TLInputFile*)file;
@end

@interface TLAPI_photos_deletePhotos : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_photos_deletePhotos*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_upload_saveFilePart : TLApiObject
@property long file_id;
@property int file_part;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_upload_saveFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part bytes:(NSData*)bytes;
@end

@interface TLAPI_upload_getFile : TLApiObject
@property (nonatomic, strong) TLInputFileLocation* location;
@property int offset;
@property int limit;

+(TLAPI_upload_getFile*)createWithLocation:(TLInputFileLocation*)location offset:(int)offset limit:(int)limit;
@end

@interface TLAPI_help_getConfig : TLApiObject


+(TLAPI_help_getConfig*)create;
@end

@interface TLAPI_help_getNearestDc : TLApiObject


+(TLAPI_help_getNearestDc*)create;
@end

@interface TLAPI_help_getAppUpdate : TLApiObject


+(TLAPI_help_getAppUpdate*)create;
@end

@interface TLAPI_help_saveAppLog : TLApiObject
@property (nonatomic, strong) NSMutableArray* events;

+(TLAPI_help_saveAppLog*)createWithEvents:(NSMutableArray*)events;
@end

@interface TLAPI_help_getInviteText : TLApiObject


+(TLAPI_help_getInviteText*)create;
@end

@interface TLAPI_photos_getUserPhotos : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int offset;
@property long max_id;
@property int limit;

+(TLAPI_photos_getUserPhotos*)createWithUser_id:(TLInputUser*)user_id offset:(int)offset max_id:(long)max_id limit:(int)limit;
@end

@interface TLAPI_messages_forwardMessage : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;
@property long random_id;

+(TLAPI_messages_forwardMessage*)createWithPeer:(TLInputPeer*)peer n_id:(int)n_id random_id:(long)random_id;
@end

@interface TLAPI_messages_getDhConfig : TLApiObject
@property int version;
@property int random_length;

+(TLAPI_messages_getDhConfig*)createWithVersion:(int)version random_length:(int)random_length;
@end

@interface TLAPI_messages_requestEncryption : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int random_id;
@property (nonatomic, strong) NSData* g_a;

+(TLAPI_messages_requestEncryption*)createWithUser_id:(TLInputUser*)user_id random_id:(int)random_id g_a:(NSData*)g_a;
@end

@interface TLAPI_messages_acceptEncryption : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property (nonatomic, strong) NSData* g_b;
@property long key_fingerprint;

+(TLAPI_messages_acceptEncryption*)createWithPeer:(TLInputEncryptedChat*)peer g_b:(NSData*)g_b key_fingerprint:(long)key_fingerprint;
@end

@interface TLAPI_messages_discardEncryption : TLApiObject
@property int chat_id;

+(TLAPI_messages_discardEncryption*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_setEncryptedTyping : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property Boolean typing;

+(TLAPI_messages_setEncryptedTyping*)createWithPeer:(TLInputEncryptedChat*)peer typing:(Boolean)typing;
@end

@interface TLAPI_messages_readEncryptedHistory : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property int max_date;

+(TLAPI_messages_readEncryptedHistory*)createWithPeer:(TLInputEncryptedChat*)peer max_date:(int)max_date;
@end

@interface TLAPI_messages_sendEncrypted : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;

+(TLAPI_messages_sendEncrypted*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data;
@end

@interface TLAPI_messages_sendEncryptedFile : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) TLInputEncryptedFile* file;

+(TLAPI_messages_sendEncryptedFile*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data file:(TLInputEncryptedFile*)file;
@end

@interface TLAPI_messages_sendEncryptedService : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;
@property long random_id;
@property (nonatomic, strong) NSData* data;

+(TLAPI_messages_sendEncryptedService*)createWithPeer:(TLInputEncryptedChat*)peer random_id:(long)random_id data:(NSData*)data;
@end

@interface TLAPI_messages_receivedQueue : TLApiObject
@property int max_qts;

+(TLAPI_messages_receivedQueue*)createWithMax_qts:(int)max_qts;
@end

@interface TLAPI_messages_reportEncryptedSpam : TLApiObject
@property (nonatomic, strong) TLInputEncryptedChat* peer;

+(TLAPI_messages_reportEncryptedSpam*)createWithPeer:(TLInputEncryptedChat*)peer;
@end

@interface TLAPI_upload_saveBigFilePart : TLApiObject
@property long file_id;
@property int file_part;
@property int file_total_parts;
@property (nonatomic, strong) NSData* bytes;

+(TLAPI_upload_saveBigFilePart*)createWithFile_id:(long)file_id file_part:(int)file_part file_total_parts:(int)file_total_parts bytes:(NSData*)bytes;
@end

@interface TLAPI_help_getSupport : TLApiObject


+(TLAPI_help_getSupport*)create;
@end

@interface TLAPI_messages_readMessageContents : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_readMessageContents*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_account_checkUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_account_checkUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_account_updateUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_account_updateUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_contacts_search : TLApiObject
@property (nonatomic, strong) NSString* q;
@property int limit;

+(TLAPI_contacts_search*)createWithQ:(NSString*)q limit:(int)limit;
@end

@interface TLAPI_account_getPrivacy : TLApiObject
@property (nonatomic, strong) TLInputPrivacyKey* n_key;

+(TLAPI_account_getPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key;
@end

@interface TLAPI_account_setPrivacy : TLApiObject
@property (nonatomic, strong) TLInputPrivacyKey* n_key;
@property (nonatomic, strong) NSMutableArray* rules;

+(TLAPI_account_setPrivacy*)createWithN_key:(TLInputPrivacyKey*)n_key rules:(NSMutableArray*)rules;
@end

@interface TLAPI_account_deleteAccount : TLApiObject
@property (nonatomic, strong) NSString* reason;

+(TLAPI_account_deleteAccount*)createWithReason:(NSString*)reason;
@end

@interface TLAPI_account_getAccountTTL : TLApiObject


+(TLAPI_account_getAccountTTL*)create;
@end

@interface TLAPI_account_setAccountTTL : TLApiObject
@property (nonatomic, strong) TLAccountDaysTTL* ttl;

+(TLAPI_account_setAccountTTL*)createWithTtl:(TLAccountDaysTTL*)ttl;
@end

@interface TLAPI_contacts_resolveUsername : TLApiObject
@property (nonatomic, strong) NSString* username;

+(TLAPI_contacts_resolveUsername*)createWithUsername:(NSString*)username;
@end

@interface TLAPI_account_sendChangePhoneCode : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAllow_flashcall;
@property (nonatomic, strong) NSString* phone_number;
@property Boolean current_number;

+(TLAPI_account_sendChangePhoneCode*)createWithFlags:(int)flags  phone_number:(NSString*)phone_number current_number:(Boolean)current_number;
@end

@interface TLAPI_account_changePhone : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;

+(TLAPI_account_changePhone*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code;
@end

@interface TLAPI_messages_getAllStickers : TLApiObject
@property int n_hash;

+(TLAPI_messages_getAllStickers*)createWithN_hash:(int)n_hash;
@end

@interface TLAPI_account_updateDeviceLocked : TLApiObject
@property int period;

+(TLAPI_account_updateDeviceLocked*)createWithPeriod:(int)period;
@end

@interface TLAPI_auth_importBotAuthorization : TLApiObject
@property int flags;
@property int api_id;
@property (nonatomic, strong) NSString* api_hash;
@property (nonatomic, strong) NSString* bot_auth_token;

+(TLAPI_auth_importBotAuthorization*)createWithFlags:(int)flags api_id:(int)api_id api_hash:(NSString*)api_hash bot_auth_token:(NSString*)bot_auth_token;
@end

@interface TLAPI_messages_getWebPagePreview : TLApiObject
@property (nonatomic, strong) NSString* message;

+(TLAPI_messages_getWebPagePreview*)createWithMessage:(NSString*)message;
@end

@interface TLAPI_account_getAuthorizations : TLApiObject


+(TLAPI_account_getAuthorizations*)create;
@end

@interface TLAPI_account_resetAuthorization : TLApiObject
@property long n_hash;

+(TLAPI_account_resetAuthorization*)createWithN_hash:(long)n_hash;
@end

@interface TLAPI_account_getPassword : TLApiObject


+(TLAPI_account_getPassword*)create;
@end

@interface TLAPI_account_getPasswordSettings : TLApiObject
@property (nonatomic, strong) NSData* current_password_hash;

+(TLAPI_account_getPasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash;
@end

@interface TLAPI_account_updatePasswordSettings : TLApiObject
@property (nonatomic, strong) NSData* current_password_hash;
@property (nonatomic, strong) TLaccount_PasswordInputSettings* n_settings;

+(TLAPI_account_updatePasswordSettings*)createWithCurrent_password_hash:(NSData*)current_password_hash n_settings:(TLaccount_PasswordInputSettings*)n_settings;
@end

@interface TLAPI_auth_checkPassword : TLApiObject
@property (nonatomic, strong) NSData* password_hash;

+(TLAPI_auth_checkPassword*)createWithPassword_hash:(NSData*)password_hash;
@end

@interface TLAPI_auth_requestPasswordRecovery : TLApiObject


+(TLAPI_auth_requestPasswordRecovery*)create;
@end

@interface TLAPI_auth_recoverPassword : TLApiObject
@property (nonatomic, strong) NSString* code;

+(TLAPI_auth_recoverPassword*)createWithCode:(NSString*)code;
@end

@interface TLAPI_messages_exportChatInvite : TLApiObject
@property int chat_id;

+(TLAPI_messages_exportChatInvite*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_checkChatInvite : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_checkChatInvite*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_messages_importChatInvite : TLApiObject
@property (nonatomic, strong) NSString* n_hash;

+(TLAPI_messages_importChatInvite*)createWithN_hash:(NSString*)n_hash;
@end

@interface TLAPI_messages_getStickerSet : TLApiObject
@property (nonatomic, strong) TLInputStickerSet* stickerset;

+(TLAPI_messages_getStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset;
@end

@interface TLAPI_messages_installStickerSet : TLApiObject
@property (nonatomic, strong) TLInputStickerSet* stickerset;
@property Boolean archived;

+(TLAPI_messages_installStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset archived:(Boolean)archived;
@end

@interface TLAPI_messages_uninstallStickerSet : TLApiObject
@property (nonatomic, strong) TLInputStickerSet* stickerset;

+(TLAPI_messages_uninstallStickerSet*)createWithStickerset:(TLInputStickerSet*)stickerset;
@end

@interface TLAPI_messages_startBot : TLApiObject
@property (nonatomic, strong) TLInputUser* bot;
@property (nonatomic, strong) TLInputPeer* peer;
@property long random_id;
@property (nonatomic, strong) NSString* start_param;

+(TLAPI_messages_startBot*)createWithBot:(TLInputUser*)bot peer:(TLInputPeer*)peer random_id:(long)random_id start_param:(NSString*)start_param;
@end

@interface TLAPI_help_getAppChangelog : TLApiObject


+(TLAPI_help_getAppChangelog*)create;
@end

@interface TLAPI_messages_getMessagesViews : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) NSMutableArray* n_id;
@property Boolean increment;

+(TLAPI_messages_getMessagesViews*)createWithPeer:(TLInputPeer*)peer n_id:(NSMutableArray*)n_id increment:(Boolean)increment;
@end

@interface TLAPI_channels_readHistory : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property int max_id;

+(TLAPI_channels_readHistory*)createWithChannel:(TLInputChannel*)channel max_id:(int)max_id;
@end

@interface TLAPI_channels_deleteMessages : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_channels_deleteMessages*)createWithChannel:(TLInputChannel*)channel n_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_channels_deleteUserHistory : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_channels_deleteUserHistory*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_channels_reportSpam : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputUser* user_id;
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_channels_reportSpam*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id n_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_channels_getMessages : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_channels_getMessages*)createWithChannel:(TLInputChannel*)channel n_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_channels_getParticipants : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLChannelParticipantsFilter* filter;
@property int offset;
@property int limit;

+(TLAPI_channels_getParticipants*)createWithChannel:(TLInputChannel*)channel filter:(TLChannelParticipantsFilter*)filter offset:(int)offset limit:(int)limit;
@end

@interface TLAPI_channels_getParticipant : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_channels_getParticipant*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_channels_getChannels : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_channels_getChannels*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_channels_getFullChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;

+(TLAPI_channels_getFullChannel*)createWithChannel:(TLInputChannel*)channel;
@end

@interface TLAPI_channels_createChannel : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isBroadcast;
@property (nonatomic,assign,readonly) BOOL isMegagroup;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* about;

+(TLAPI_channels_createChannel*)createWithFlags:(int)flags   title:(NSString*)title about:(NSString*)about;
@end

@interface TLAPI_channels_editAbout : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSString* about;

+(TLAPI_channels_editAbout*)createWithChannel:(TLInputChannel*)channel about:(NSString*)about;
@end

@interface TLAPI_channels_editAdmin : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputUser* user_id;
@property (nonatomic, strong) TLChannelParticipantRole* role;

+(TLAPI_channels_editAdmin*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id role:(TLChannelParticipantRole*)role;
@end

@interface TLAPI_channels_editTitle : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSString* title;

+(TLAPI_channels_editTitle*)createWithChannel:(TLInputChannel*)channel title:(NSString*)title;
@end

@interface TLAPI_channels_editPhoto : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputChatPhoto* photo;

+(TLAPI_channels_editPhoto*)createWithChannel:(TLInputChannel*)channel photo:(TLInputChatPhoto*)photo;
@end

@interface TLAPI_channels_checkUsername : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSString* username;

+(TLAPI_channels_checkUsername*)createWithChannel:(TLInputChannel*)channel username:(NSString*)username;
@end

@interface TLAPI_channels_updateUsername : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSString* username;

+(TLAPI_channels_updateUsername*)createWithChannel:(TLInputChannel*)channel username:(NSString*)username;
@end

@interface TLAPI_channels_joinChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;

+(TLAPI_channels_joinChannel*)createWithChannel:(TLInputChannel*)channel;
@end

@interface TLAPI_channels_leaveChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;

+(TLAPI_channels_leaveChannel*)createWithChannel:(TLInputChannel*)channel;
@end

@interface TLAPI_channels_inviteToChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) NSMutableArray* users;

+(TLAPI_channels_inviteToChannel*)createWithChannel:(TLInputChannel*)channel users:(NSMutableArray*)users;
@end

@interface TLAPI_channels_kickFromChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLInputUser* user_id;
@property Boolean kicked;

+(TLAPI_channels_kickFromChannel*)createWithChannel:(TLInputChannel*)channel user_id:(TLInputUser*)user_id kicked:(Boolean)kicked;
@end

@interface TLAPI_channels_exportInvite : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;

+(TLAPI_channels_exportInvite*)createWithChannel:(TLInputChannel*)channel;
@end

@interface TLAPI_channels_deleteChannel : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;

+(TLAPI_channels_deleteChannel*)createWithChannel:(TLInputChannel*)channel;
@end

@interface TLAPI_updates_getChannelDifference : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isForce;
@property (nonatomic, strong) TLInputChannel* channel;
@property (nonatomic, strong) TLChannelMessagesFilter* filter;
@property int pts;
@property int limit;

+(TLAPI_updates_getChannelDifference*)createWithFlags:(int)flags  channel:(TLInputChannel*)channel filter:(TLChannelMessagesFilter*)filter pts:(int)pts limit:(int)limit;
@end

@interface TLAPI_messages_toggleChatAdmins : TLApiObject
@property int chat_id;
@property Boolean enabled;

+(TLAPI_messages_toggleChatAdmins*)createWithChat_id:(int)chat_id enabled:(Boolean)enabled;
@end

@interface TLAPI_messages_editChatAdmin : TLApiObject
@property int chat_id;
@property (nonatomic, strong) TLInputUser* user_id;
@property Boolean is_admin;

+(TLAPI_messages_editChatAdmin*)createWithChat_id:(int)chat_id user_id:(TLInputUser*)user_id is_admin:(Boolean)is_admin;
@end

@interface TLAPI_messages_migrateChat : TLApiObject
@property int chat_id;

+(TLAPI_messages_migrateChat*)createWithChat_id:(int)chat_id;
@end

@interface TLAPI_messages_searchGlobal : TLApiObject
@property (nonatomic, strong) NSString* q;
@property int offset_date;
@property (nonatomic, strong) TLInputPeer* offset_peer;
@property int offset_id;
@property int limit;

+(TLAPI_messages_searchGlobal*)createWithQ:(NSString*)q offset_date:(int)offset_date offset_peer:(TLInputPeer*)offset_peer offset_id:(int)offset_id limit:(int)limit;
@end

@interface TLAPI_help_getTermsOfService : TLApiObject


+(TLAPI_help_getTermsOfService*)create;
@end

@interface TLAPI_messages_reorderStickerSets : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isMasks;
@property (nonatomic, strong) NSMutableArray* order;

+(TLAPI_messages_reorderStickerSets*)createWithFlags:(int)flags  order:(NSMutableArray*)order;
@end

@interface TLAPI_messages_getDocumentByHash : TLApiObject
@property (nonatomic, strong) NSData* sha256;
@property int size;
@property (nonatomic, strong) NSString* mime_type;

+(TLAPI_messages_getDocumentByHash*)createWithSha256:(NSData*)sha256 size:(int)size mime_type:(NSString*)mime_type;
@end

@interface TLAPI_messages_searchGifs : TLApiObject
@property (nonatomic, strong) NSString* q;
@property int offset;

+(TLAPI_messages_searchGifs*)createWithQ:(NSString*)q offset:(int)offset;
@end

@interface TLAPI_messages_getSavedGifs : TLApiObject
@property int n_hash;

+(TLAPI_messages_getSavedGifs*)createWithN_hash:(int)n_hash;
@end

@interface TLAPI_messages_saveGif : TLApiObject
@property (nonatomic, strong) TLInputDocument* n_id;
@property Boolean unsave;

+(TLAPI_messages_saveGif*)createWithN_id:(TLInputDocument*)n_id unsave:(Boolean)unsave;
@end

@interface TLAPI_messages_getInlineBotResults : TLApiObject
@property int flags;
@property (nonatomic, strong) TLInputUser* bot;
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) TLInputGeoPoint* geo_point;
@property (nonatomic, strong) NSString* query;
@property (nonatomic, strong) NSString* offset;

+(TLAPI_messages_getInlineBotResults*)createWithFlags:(int)flags bot:(TLInputUser*)bot peer:(TLInputPeer*)peer geo_point:(TLInputGeoPoint*)geo_point query:(NSString*)query offset:(NSString*)offset;
@end

@interface TLAPI_messages_setInlineBotResults : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isGallery;
@property (nonatomic,assign,readonly) BOOL isPrivate;
@property long query_id;
@property (nonatomic, strong) NSMutableArray* results;
@property int cache_time;
@property (nonatomic, strong) NSString* next_offset;
@property (nonatomic, strong) TLInlineBotSwitchPM* switch_pm;

+(TLAPI_messages_setInlineBotResults*)createWithFlags:(int)flags   query_id:(long)query_id results:(NSMutableArray*)results cache_time:(int)cache_time next_offset:(NSString*)next_offset switch_pm:(TLInlineBotSwitchPM*)switch_pm;
@end

@interface TLAPI_messages_sendInlineBotResult : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSilent;
@property (nonatomic,assign,readonly) BOOL isBackground;
@property (nonatomic,assign,readonly) BOOL isClear_draft;
@property (nonatomic, strong) TLInputPeer* peer;
@property int reply_to_msg_id;
@property long random_id;
@property long query_id;
@property (nonatomic, strong) NSString* n_id;

+(TLAPI_messages_sendInlineBotResult*)createWithFlags:(int)flags    peer:(TLInputPeer*)peer reply_to_msg_id:(int)reply_to_msg_id random_id:(long)random_id query_id:(long)query_id n_id:(NSString*)n_id;
@end

@interface TLAPI_channels_toggleInvites : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property Boolean enabled;

+(TLAPI_channels_toggleInvites*)createWithChannel:(TLInputChannel*)channel enabled:(Boolean)enabled;
@end

@interface TLAPI_channels_exportMessageLink : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property int n_id;

+(TLAPI_channels_exportMessageLink*)createWithChannel:(TLInputChannel*)channel n_id:(int)n_id;
@end

@interface TLAPI_channels_toggleSignatures : TLApiObject
@property (nonatomic, strong) TLInputChannel* channel;
@property Boolean enabled;

+(TLAPI_channels_toggleSignatures*)createWithChannel:(TLInputChannel*)channel enabled:(Boolean)enabled;
@end

@interface TLAPI_channels_updatePinnedMessage : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isSilent;
@property (nonatomic, strong) TLInputChannel* channel;
@property int n_id;

+(TLAPI_channels_updatePinnedMessage*)createWithFlags:(int)flags  channel:(TLInputChannel*)channel n_id:(int)n_id;
@end

@interface TLAPI_auth_resendCode : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;

+(TLAPI_auth_resendCode*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash;
@end

@interface TLAPI_auth_cancelCode : TLApiObject
@property (nonatomic, strong) NSString* phone_number;
@property (nonatomic, strong) NSString* phone_code_hash;

+(TLAPI_auth_cancelCode*)createWithPhone_number:(NSString*)phone_number phone_code_hash:(NSString*)phone_code_hash;
@end

@interface TLAPI_messages_getMessageEditData : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;

+(TLAPI_messages_getMessageEditData*)createWithPeer:(TLInputPeer*)peer n_id:(int)n_id;
@end

@interface TLAPI_messages_editMessage : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isNo_webpage;
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) TLReplyMarkup* reply_markup;
@property (nonatomic, strong) NSMutableArray* entities;

+(TLAPI_messages_editMessage*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer n_id:(int)n_id message:(NSString*)message reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities;
@end

@interface TLAPI_messages_editInlineBotMessage : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isNo_webpage;
@property (nonatomic, strong) TLInputBotInlineMessageID* n_id;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) TLReplyMarkup* reply_markup;
@property (nonatomic, strong) NSMutableArray* entities;

+(TLAPI_messages_editInlineBotMessage*)createWithFlags:(int)flags  n_id:(TLInputBotInlineMessageID*)n_id message:(NSString*)message reply_markup:(TLReplyMarkup*)reply_markup entities:(NSMutableArray*)entities;
@end

@interface TLAPI_messages_getBotCallbackAnswer : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isGame;
@property (nonatomic, strong) TLInputPeer* peer;
@property int msg_id;
@property (nonatomic, strong) NSData* data;

+(TLAPI_messages_getBotCallbackAnswer*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer msg_id:(int)msg_id data:(NSData*)data;
@end

@interface TLAPI_messages_setBotCallbackAnswer : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAlert;
@property long query_id;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* url;
@property int cache_time;

+(TLAPI_messages_setBotCallbackAnswer*)createWithFlags:(int)flags  query_id:(long)query_id message:(NSString*)message url:(NSString*)url cache_time:(int)cache_time;
@end

@interface TLAPI_contacts_getTopPeers : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isCorrespondents;
@property (nonatomic,assign,readonly) BOOL isBots_pm;
@property (nonatomic,assign,readonly) BOOL isBots_inline;
@property (nonatomic,assign,readonly) BOOL isGroups;
@property (nonatomic,assign,readonly) BOOL isChannels;
@property int offset;
@property int limit;
@property int n_hash;

+(TLAPI_contacts_getTopPeers*)createWithFlags:(int)flags      offset:(int)offset limit:(int)limit n_hash:(int)n_hash;
@end

@interface TLAPI_contacts_resetTopPeerRating : TLApiObject
@property (nonatomic, strong) TLTopPeerCategory* category;
@property (nonatomic, strong) TLInputPeer* peer;

+(TLAPI_contacts_resetTopPeerRating*)createWithCategory:(TLTopPeerCategory*)category peer:(TLInputPeer*)peer;
@end

@interface TLAPI_messages_getPeerDialogs : TLApiObject
@property (nonatomic, strong) NSMutableArray* peers;

+(TLAPI_messages_getPeerDialogs*)createWithPeers:(NSMutableArray*)peers;
@end

@interface TLAPI_messages_saveDraft : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isNo_webpage;
@property int reply_to_msg_id;
@property (nonatomic, strong) TLInputPeer* peer;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSMutableArray* entities;

+(TLAPI_messages_saveDraft*)createWithFlags:(int)flags  reply_to_msg_id:(int)reply_to_msg_id peer:(TLInputPeer*)peer message:(NSString*)message entities:(NSMutableArray*)entities;
@end

@interface TLAPI_messages_getAllDrafts : TLApiObject


+(TLAPI_messages_getAllDrafts*)create;
@end

@interface TLAPI_messages_getFeaturedStickers : TLApiObject
@property int n_hash;

+(TLAPI_messages_getFeaturedStickers*)createWithN_hash:(int)n_hash;
@end

@interface TLAPI_messages_readFeaturedStickers : TLApiObject
@property (nonatomic, strong) NSMutableArray* n_id;

+(TLAPI_messages_readFeaturedStickers*)createWithN_id:(NSMutableArray*)n_id;
@end

@interface TLAPI_messages_getRecentStickers : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAttached;
@property int n_hash;

+(TLAPI_messages_getRecentStickers*)createWithFlags:(int)flags  n_hash:(int)n_hash;
@end

@interface TLAPI_messages_saveRecentSticker : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAttached;
@property (nonatomic, strong) TLInputDocument* n_id;
@property Boolean unsave;

+(TLAPI_messages_saveRecentSticker*)createWithFlags:(int)flags  n_id:(TLInputDocument*)n_id unsave:(Boolean)unsave;
@end

@interface TLAPI_messages_clearRecentStickers : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAttached;

+(TLAPI_messages_clearRecentStickers*)createWithFlags:(int)flags ;
@end

@interface TLAPI_messages_getArchivedStickers : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isMasks;
@property long offset_id;
@property int limit;

+(TLAPI_messages_getArchivedStickers*)createWithFlags:(int)flags  offset_id:(long)offset_id limit:(int)limit;
@end

@interface TLAPI_account_sendConfirmPhoneCode : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isAllow_flashcall;
@property (nonatomic, strong) NSString* n_hash;
@property Boolean current_number;

+(TLAPI_account_sendConfirmPhoneCode*)createWithFlags:(int)flags  n_hash:(NSString*)n_hash current_number:(Boolean)current_number;
@end

@interface TLAPI_account_confirmPhone : TLApiObject
@property (nonatomic, strong) NSString* phone_code_hash;
@property (nonatomic, strong) NSString* phone_code;

+(TLAPI_account_confirmPhone*)createWithPhone_code_hash:(NSString*)phone_code_hash phone_code:(NSString*)phone_code;
@end

@interface TLAPI_channels_getAdminedPublicChannels : TLApiObject


+(TLAPI_channels_getAdminedPublicChannels*)create;
@end

@interface TLAPI_messages_getMaskStickers : TLApiObject
@property int n_hash;

+(TLAPI_messages_getMaskStickers*)createWithN_hash:(int)n_hash;
@end

@interface TLAPI_messages_getAttachedStickers : TLApiObject
@property (nonatomic, strong) TLInputStickeredMedia* media;

+(TLAPI_messages_getAttachedStickers*)createWithMedia:(TLInputStickeredMedia*)media;
@end

@interface TLAPI_auth_dropTempAuthKeys : TLApiObject
@property (nonatomic, strong) NSMutableArray* except_auth_keys;

+(TLAPI_auth_dropTempAuthKeys*)createWithExcept_auth_keys:(NSMutableArray*)except_auth_keys;
@end

@interface TLAPI_messages_setGameScore : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isEdit_message;
@property (nonatomic,assign,readonly) BOOL isForce;
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;
@property (nonatomic, strong) TLInputUser* user_id;
@property int score;

+(TLAPI_messages_setGameScore*)createWithFlags:(int)flags   peer:(TLInputPeer*)peer n_id:(int)n_id user_id:(TLInputUser*)user_id score:(int)score;
@end

@interface TLAPI_messages_setInlineGameScore : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isEdit_message;
@property (nonatomic,assign,readonly) BOOL isForce;
@property (nonatomic, strong) TLInputBotInlineMessageID* n_id;
@property (nonatomic, strong) TLInputUser* user_id;
@property int score;

+(TLAPI_messages_setInlineGameScore*)createWithFlags:(int)flags   n_id:(TLInputBotInlineMessageID*)n_id user_id:(TLInputUser*)user_id score:(int)score;
@end

@interface TLAPI_messages_getGameHighScores : TLApiObject
@property (nonatomic, strong) TLInputPeer* peer;
@property int n_id;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_messages_getGameHighScores*)createWithPeer:(TLInputPeer*)peer n_id:(int)n_id user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_messages_getInlineGameHighScores : TLApiObject
@property (nonatomic, strong) TLInputBotInlineMessageID* n_id;
@property (nonatomic, strong) TLInputUser* user_id;

+(TLAPI_messages_getInlineGameHighScores*)createWithN_id:(TLInputBotInlineMessageID*)n_id user_id:(TLInputUser*)user_id;
@end

@interface TLAPI_messages_getCommonChats : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int max_id;
@property int limit;

+(TLAPI_messages_getCommonChats*)createWithUser_id:(TLInputUser*)user_id max_id:(int)max_id limit:(int)limit;
@end

@interface TLAPI_messages_getAllChats : TLApiObject
@property (nonatomic, strong) NSMutableArray* except_ids;

+(TLAPI_messages_getAllChats*)createWithExcept_ids:(NSMutableArray*)except_ids;
@end

@interface TLAPI_help_setBotUpdatesStatus : TLApiObject
@property int pending_updates_count;
@property (nonatomic, strong) NSString* message;

+(TLAPI_help_setBotUpdatesStatus*)createWithPending_updates_count:(int)pending_updates_count message:(NSString*)message;
@end

@interface TLAPI_messages_getWebPage : TLApiObject
@property (nonatomic, strong) NSString* url;
@property int n_hash;

+(TLAPI_messages_getWebPage*)createWithUrl:(NSString*)url n_hash:(int)n_hash;
@end

@interface TLAPI_phone_requestCall : TLApiObject
@property (nonatomic, strong) TLInputUser* user_id;
@property int random_id;
@property (nonatomic, strong) NSData* g_a;
@property (nonatomic, strong) TLPhoneCallProtocol* protocol;

+(TLAPI_phone_requestCall*)createWithUser_id:(TLInputUser*)user_id random_id:(int)random_id g_a:(NSData*)g_a protocol:(TLPhoneCallProtocol*)protocol;
@end

@interface TLAPI_phone_acceptCall : TLApiObject
@property (nonatomic, strong) TLInputPhoneCall* peer;
@property (nonatomic, strong) NSData* g_b;
@property long key_fingerprint;
@property (nonatomic, strong) TLPhoneCallProtocol* protocol;

+(TLAPI_phone_acceptCall*)createWithPeer:(TLInputPhoneCall*)peer g_b:(NSData*)g_b key_fingerprint:(long)key_fingerprint protocol:(TLPhoneCallProtocol*)protocol;
@end

@interface TLAPI_phone_discardCall : TLApiObject
@property (nonatomic, strong) TLInputPhoneCall* peer;
@property int duration;
@property (nonatomic, strong) TLPhoneCallDiscardReason* reason;
@property long connection_id;

+(TLAPI_phone_discardCall*)createWithPeer:(TLInputPhoneCall*)peer duration:(int)duration reason:(TLPhoneCallDiscardReason*)reason connection_id:(long)connection_id;
@end

@interface TLAPI_phone_receivedCall : TLApiObject
@property (nonatomic, strong) TLInputPhoneCall* peer;

+(TLAPI_phone_receivedCall*)createWithPeer:(TLInputPhoneCall*)peer;
@end

@interface TLAPI_messages_toggleDialogPin : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isPinned;
@property (nonatomic, strong) TLInputPeer* peer;

+(TLAPI_messages_toggleDialogPin*)createWithFlags:(int)flags  peer:(TLInputPeer*)peer;
@end

@interface TLAPI_messages_reorderPinnedDialogs : TLApiObject
@property int flags;
@property (nonatomic,assign,readonly) BOOL isForce;
@property (nonatomic, strong) NSMutableArray* order;

+(TLAPI_messages_reorderPinnedDialogs*)createWithFlags:(int)flags  order:(NSMutableArray*)order;
@end

@interface TLAPI_messages_getPinnedDialogs : TLApiObject


+(TLAPI_messages_getPinnedDialogs*)create;
@end

