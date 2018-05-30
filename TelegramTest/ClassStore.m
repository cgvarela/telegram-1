    
//
//  ClassStore.m
//  Telegram
//
    //  Created by keepcoder on 22.12.16.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "ClassStore.h"
#import "MTProto.h"
#import "TLAPIAdd.h"
#import <MTProtoKit/MTLogging.h>
@interface ClassStore()
    
@end
    
@implementation ClassStore
    
    
static NSMutableDictionary *cs_classes;
static NSMutableDictionary *cs_constuctors;
    
+(NSMutableDictionary *)cs_classes {
    return cs_classes;
}
    
+(NSMutableDictionary *)cs_constuctors {
    return cs_constuctors;
}
    
+ (id)deserialize:(NSData*)data {
        
    if(!data)
        return nil;
        
    SerializedData *stream = [[SerializedData alloc] init];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];
    [inputStream open];
    // [stream setCacheData:data];
    [stream setInput:inputStream];
    id response = [self TLDeserialize:stream];
    return response;
}
    
+ (id)constructObject:(NSInputStream *)is {
    SerializedData *stream = [[SerializedData alloc] init];
    [stream setInput:is];
    id response = [self TLDeserialize:stream];
    return response;
}
    
+ (NSData*)serialize:(TLObject*)obj isCacheSerialize:(bool)isCacheSerialize {
        
    if(!obj)
        return nil;
        
    SerializedData *stream = [[SerializedData alloc] init];
    stream.isCacheSerialize = isCacheSerialize;
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    [stream setOuput:outputStream];
    [self TLSerialize:obj stream:stream];
    return [stream getOutput];
}
    
+ (NSData*)serialize:(TLObject*)obj {
    return [self serialize:obj isCacheSerialize:YES];
}
    
+ (void)TLSerialize:(TLObject*)objOrig stream:(SerializedData*)stream {
        
        
    TLObject* obj = objOrig;
        
    Class class = [obj class];
    NSNumber *constructor = [cs_constuctors objectForKey:class];
    if(constructor == nil) {
        MTLog(@" Error. Not found constructor for class %@", class);
        //  [NSException raise:@"Error" format:@"Not implemented class %@", NSStringFromClass(class)];
    } else {
        int constructorInt = [constructor intValue];
        //        TLog("@ constructor %d find by class %@", constructorInt, class);
        [stream writeInt:constructorInt];
        [obj serialize:stream];
    }
}
    
+ (id)TLDeserialize:(SerializedData*)stream {
    int constructor = [stream readInt];
    return [self _TLDeserialize:stream constructor:constructor];
}
    
+ (id) _TLDeserialize:(SerializedData *) stream constructor:(int)constructor {
    Class class = [cs_classes objectForKey:[NSNumber numberWithInt:constructor]];
    if(class == nil) {
        if(constructor == 481674261) {
            return [self deserializeVector:stream];
        }
        [NSException raise:@"TLError" format:@"constructor not found %d",constructor];
        return nil;
    } else {
        //TLog("@ create class %@ with constructor %d", class, constructor);
    }
        
    TLObject* object = [[class alloc] init];
    [object unserialize:stream];
    return object;
}
    
+(id)deserializeVector:(SerializedData *)stream {
    NSMutableArray *vector = [[NSMutableArray alloc] init];
    int count = [stream readInt];
    for(int i = 0; i < count; i++) {
        //Очень фикс, потому что может быть Long, или прочая хуета
        int constructor = [stream readInt];
        Class class = [cs_classes objectForKey:[NSNumber numberWithInt:constructor]];
        if(class == nil) {
            [vector addObject:[NSNumber numberWithInt:constructor]];
        } else {
            id obj = [self _TLDeserialize:stream constructor:constructor];
            [vector addObject:obj];
        }
    }
    return vector;
}
    
    
+ (SerializedData*)streamWithConstuctor:(int)constructor {
    SerializedData* stream = [[SerializedData alloc] init];
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];
    [outputStream open];
    [stream setOuput:outputStream];
    [stream writeInt:constructor];
    
    return stream;
}
    
    
    
    
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cs_classes = [[NSMutableDictionary alloc] init];
        cs_constuctors = [[NSMutableDictionary alloc] init];
                      
        // insert constructors here.
        [cs_classes setObject:[TL_boolFalse class] forKey:[NSNumber numberWithInt:-1132882121]];
   [cs_classes setObject:[TL_boolTrue class] forKey:[NSNumber numberWithInt:-1720552011]];
   [cs_classes setObject:[TL_true class] forKey:[NSNumber numberWithInt:1072550713]];
   [cs_classes setObject:[TL_inputPeerEmpty class] forKey:[NSNumber numberWithInt:2134579434]];
   [cs_classes setObject:[TL_inputPeerSelf class] forKey:[NSNumber numberWithInt:2107670217]];
   [cs_classes setObject:[TL_inputPeerChat class] forKey:[NSNumber numberWithInt:396093539]];
   [cs_classes setObject:[TL_inputUserEmpty class] forKey:[NSNumber numberWithInt:-1182234929]];
   [cs_classes setObject:[TL_inputUserSelf class] forKey:[NSNumber numberWithInt:-138301121]];
   [cs_classes setObject:[TL_inputPhoneContact class] forKey:[NSNumber numberWithInt:-208488460]];
   [cs_classes setObject:[TL_inputFile class] forKey:[NSNumber numberWithInt:-181407105]];
   [cs_classes setObject:[TL_inputMediaEmpty class] forKey:[NSNumber numberWithInt:-1771768449]];
   [cs_classes setObject:[TL_inputMediaUploadedPhoto class] forKey:[NSNumber numberWithInt:1661770481]];
   [cs_classes setObject:[TL_inputMediaPhoto class] forKey:[NSNumber numberWithInt:-373312269]];
   [cs_classes setObject:[TL_inputMediaGeoPoint class] forKey:[NSNumber numberWithInt:-104578748]];
   [cs_classes setObject:[TL_inputMediaContact class] forKey:[NSNumber numberWithInt:-1494984313]];
   [cs_classes setObject:[TL_inputChatPhotoEmpty class] forKey:[NSNumber numberWithInt:480546647]];
   [cs_classes setObject:[TL_inputChatUploadedPhoto class] forKey:[NSNumber numberWithInt:-1837345356]];
   [cs_classes setObject:[TL_inputChatPhoto class] forKey:[NSNumber numberWithInt:-1991004873]];
   [cs_classes setObject:[TL_inputGeoPointEmpty class] forKey:[NSNumber numberWithInt:-457104426]];
   [cs_classes setObject:[TL_inputGeoPoint class] forKey:[NSNumber numberWithInt:-206066487]];
   [cs_classes setObject:[TL_inputPhotoEmpty class] forKey:[NSNumber numberWithInt:483901197]];
   [cs_classes setObject:[TL_inputPhoto class] forKey:[NSNumber numberWithInt:-74070332]];
   [cs_classes setObject:[TL_inputFileLocation class] forKey:[NSNumber numberWithInt:342061462]];
   [cs_classes setObject:[TL_inputAppEvent class] forKey:[NSNumber numberWithInt:1996904104]];
   [cs_classes setObject:[TL_peerUser class] forKey:[NSNumber numberWithInt:-1649296275]];
   [cs_classes setObject:[TL_peerChat class] forKey:[NSNumber numberWithInt:-1160714821]];
   [cs_classes setObject:[TL_storage_fileUnknown class] forKey:[NSNumber numberWithInt:-1432995067]];
   [cs_classes setObject:[TL_storage_fileJpeg class] forKey:[NSNumber numberWithInt:8322574]];
   [cs_classes setObject:[TL_storage_fileGif class] forKey:[NSNumber numberWithInt:-891180321]];
   [cs_classes setObject:[TL_storage_filePng class] forKey:[NSNumber numberWithInt:172975040]];
   [cs_classes setObject:[TL_storage_filePdf class] forKey:[NSNumber numberWithInt:-1373745011]];
   [cs_classes setObject:[TL_storage_fileMp3 class] forKey:[NSNumber numberWithInt:1384777335]];
   [cs_classes setObject:[TL_storage_fileMov class] forKey:[NSNumber numberWithInt:1258941372]];
   [cs_classes setObject:[TL_storage_filePartial class] forKey:[NSNumber numberWithInt:1086091090]];
   [cs_classes setObject:[TL_storage_fileMp4 class] forKey:[NSNumber numberWithInt:-1278304028]];
   [cs_classes setObject:[TL_storage_fileWebp class] forKey:[NSNumber numberWithInt:276907596]];
   [cs_classes setObject:[TL_fileLocationUnavailable class] forKey:[NSNumber numberWithInt:2086234950]];
   [cs_classes setObject:[TL_fileLocation class] forKey:[NSNumber numberWithInt:1406570614]];
   [cs_classes setObject:[TL_userEmpty class] forKey:[NSNumber numberWithInt:537022650]];
   [cs_classes setObject:[TL_userProfilePhotoEmpty class] forKey:[NSNumber numberWithInt:1326562017]];
   [cs_classes setObject:[TL_userProfilePhoto class] forKey:[NSNumber numberWithInt:-715532088]];
   [cs_classes setObject:[TL_userStatusEmpty class] forKey:[NSNumber numberWithInt:164646985]];
   [cs_classes setObject:[TL_userStatusOnline class] forKey:[NSNumber numberWithInt:-306628279]];
   [cs_classes setObject:[TL_userStatusOffline class] forKey:[NSNumber numberWithInt:9203775]];
   [cs_classes setObject:[TL_chatEmpty class] forKey:[NSNumber numberWithInt:-1683826688]];
   [cs_classes setObject:[TL_chat class] forKey:[NSNumber numberWithInt:-652419756]];
   [cs_classes setObject:[TL_chatForbidden class] forKey:[NSNumber numberWithInt:120753115]];
   [cs_classes setObject:[TL_chatFull class] forKey:[NSNumber numberWithInt:771925524]];
   [cs_classes setObject:[TL_chatParticipant class] forKey:[NSNumber numberWithInt:-925415106]];
   [cs_classes setObject:[TL_chatParticipantsForbidden class] forKey:[NSNumber numberWithInt:-57668565]];
   [cs_classes setObject:[TL_chatParticipants class] forKey:[NSNumber numberWithInt:1061556205]];
   [cs_classes setObject:[TL_chatPhotoEmpty class] forKey:[NSNumber numberWithInt:935395612]];
   [cs_classes setObject:[TL_chatPhoto class] forKey:[NSNumber numberWithInt:1632839530]];
   [cs_classes setObject:[TL_messageEmpty class] forKey:[NSNumber numberWithInt:-2082087340]];
   [cs_classes setObject:[TL_message class] forKey:[NSNumber numberWithInt:-1063525281]];
   [cs_classes setObject:[TL_messageService class] forKey:[NSNumber numberWithInt:-1642487306]];
   [cs_classes setObject:[TL_messageMediaEmpty class] forKey:[NSNumber numberWithInt:1038967584]];
   [cs_classes setObject:[TL_messageMediaPhoto class] forKey:[NSNumber numberWithInt:1032643901]];
   [cs_classes setObject:[TL_messageMediaGeo class] forKey:[NSNumber numberWithInt:1457575028]];
   [cs_classes setObject:[TL_messageMediaContact class] forKey:[NSNumber numberWithInt:1585262393]];
   [cs_classes setObject:[TL_messageMediaUnsupported class] forKey:[NSNumber numberWithInt:-1618676578]];
   [cs_classes setObject:[TL_messageActionEmpty class] forKey:[NSNumber numberWithInt:-1230047312]];
   [cs_classes setObject:[TL_messageActionChatCreate class] forKey:[NSNumber numberWithInt:-1503425638]];
   [cs_classes setObject:[TL_messageActionChatEditTitle class] forKey:[NSNumber numberWithInt:-1247687078]];
   [cs_classes setObject:[TL_messageActionChatEditPhoto class] forKey:[NSNumber numberWithInt:2144015272]];
   [cs_classes setObject:[TL_messageActionChatDeletePhoto class] forKey:[NSNumber numberWithInt:-1780220945]];
   [cs_classes setObject:[TL_messageActionChatAddUser class] forKey:[NSNumber numberWithInt:1217033015]];
   [cs_classes setObject:[TL_messageActionChatDeleteUser class] forKey:[NSNumber numberWithInt:-1297179892]];
   [cs_classes setObject:[TL_dialog class] forKey:[NSNumber numberWithInt:1728035348]];
   [cs_classes setObject:[TL_photoEmpty class] forKey:[NSNumber numberWithInt:590459437]];
   [cs_classes setObject:[TL_photo class] forKey:[NSNumber numberWithInt:-1836524247]];
   [cs_classes setObject:[TL_photoSizeEmpty class] forKey:[NSNumber numberWithInt:236446268]];
   [cs_classes setObject:[TL_photoSize class] forKey:[NSNumber numberWithInt:2009052699]];
   [cs_classes setObject:[TL_photoCachedSize class] forKey:[NSNumber numberWithInt:-374917894]];
   [cs_classes setObject:[TL_geoPointEmpty class] forKey:[NSNumber numberWithInt:286776671]];
   [cs_classes setObject:[TL_geoPoint class] forKey:[NSNumber numberWithInt:541710092]];
   [cs_classes setObject:[TL_auth_checkedPhone class] forKey:[NSNumber numberWithInt:-2128698738]];
   [cs_classes setObject:[TL_auth_sentCode class] forKey:[NSNumber numberWithInt:1577067778]];
   [cs_classes setObject:[TL_auth_authorization class] forKey:[NSNumber numberWithInt:-855308010]];
   [cs_classes setObject:[TL_auth_exportedAuthorization class] forKey:[NSNumber numberWithInt:-543777747]];
   [cs_classes setObject:[TL_inputNotifyPeer class] forKey:[NSNumber numberWithInt:-1195615476]];
   [cs_classes setObject:[TL_inputNotifyUsers class] forKey:[NSNumber numberWithInt:423314455]];
   [cs_classes setObject:[TL_inputNotifyChats class] forKey:[NSNumber numberWithInt:1251338318]];
   [cs_classes setObject:[TL_inputNotifyAll class] forKey:[NSNumber numberWithInt:-1540769658]];
   [cs_classes setObject:[TL_inputPeerNotifyEventsEmpty class] forKey:[NSNumber numberWithInt:-265263912]];
   [cs_classes setObject:[TL_inputPeerNotifyEventsAll class] forKey:[NSNumber numberWithInt:-395694988]];
   [cs_classes setObject:[TL_inputPeerNotifySettings class] forKey:[NSNumber numberWithInt:949182130]];
   [cs_classes setObject:[TL_peerNotifyEventsEmpty class] forKey:[NSNumber numberWithInt:-1378534221]];
   [cs_classes setObject:[TL_peerNotifyEventsAll class] forKey:[NSNumber numberWithInt:1830677896]];
   [cs_classes setObject:[TL_peerNotifySettingsEmpty class] forKey:[NSNumber numberWithInt:1889961234]];
   [cs_classes setObject:[TL_peerNotifySettings class] forKey:[NSNumber numberWithInt:-1697798976]];
   [cs_classes setObject:[TL_peerSettings class] forKey:[NSNumber numberWithInt:-2122045747]];
   [cs_classes setObject:[TL_wallPaper class] forKey:[NSNumber numberWithInt:-860866985]];
   [cs_classes setObject:[TL_inputReportReasonSpam class] forKey:[NSNumber numberWithInt:1490799288]];
   [cs_classes setObject:[TL_inputReportReasonViolence class] forKey:[NSNumber numberWithInt:505595789]];
   [cs_classes setObject:[TL_inputReportReasonPornography class] forKey:[NSNumber numberWithInt:777640226]];
   [cs_classes setObject:[TL_inputReportReasonOther class] forKey:[NSNumber numberWithInt:-512463606]];
   [cs_classes setObject:[TL_userFull class] forKey:[NSNumber numberWithInt:253890367]];
   [cs_classes setObject:[TL_contact class] forKey:[NSNumber numberWithInt:-116274796]];
   [cs_classes setObject:[TL_importedContact class] forKey:[NSNumber numberWithInt:-805141448]];
   [cs_classes setObject:[TL_contactBlocked class] forKey:[NSNumber numberWithInt:1444661369]];
   [cs_classes setObject:[TL_contactStatus class] forKey:[NSNumber numberWithInt:-748155807]];
   [cs_classes setObject:[TL_contacts_link class] forKey:[NSNumber numberWithInt:986597452]];
   [cs_classes setObject:[TL_contacts_contactsNotModified class] forKey:[NSNumber numberWithInt:-1219778094]];
   [cs_classes setObject:[TL_contacts_contacts class] forKey:[NSNumber numberWithInt:1871416498]];
   [cs_classes setObject:[TL_contacts_importedContacts class] forKey:[NSNumber numberWithInt:-1387117803]];
   [cs_classes setObject:[TL_contacts_blocked class] forKey:[NSNumber numberWithInt:471043349]];
   [cs_classes setObject:[TL_contacts_blockedSlice class] forKey:[NSNumber numberWithInt:-1878523231]];
   [cs_classes setObject:[TL_messages_dialogs class] forKey:[NSNumber numberWithInt:364538944]];
   [cs_classes setObject:[TL_messages_dialogsSlice class] forKey:[NSNumber numberWithInt:1910543603]];
   [cs_classes setObject:[TL_messages_messages class] forKey:[NSNumber numberWithInt:-1938715001]];
   [cs_classes setObject:[TL_messages_messagesSlice class] forKey:[NSNumber numberWithInt:189033187]];
   [cs_classes setObject:[TL_messages_chats class] forKey:[NSNumber numberWithInt:1694474197]];
   [cs_classes setObject:[TL_messages_chatFull class] forKey:[NSNumber numberWithInt:-438840932]];
   [cs_classes setObject:[TL_messages_affectedHistory class] forKey:[NSNumber numberWithInt:-1269012015]];
   [cs_classes setObject:[TL_inputMessagesFilterEmpty class] forKey:[NSNumber numberWithInt:1474492012]];
   [cs_classes setObject:[TL_inputMessagesFilterPhotos class] forKey:[NSNumber numberWithInt:-1777752804]];
   [cs_classes setObject:[TL_inputMessagesFilterVideo class] forKey:[NSNumber numberWithInt:-1614803355]];
   [cs_classes setObject:[TL_inputMessagesFilterPhotoVideo class] forKey:[NSNumber numberWithInt:1458172132]];
   [cs_classes setObject:[TL_inputMessagesFilterPhotoVideoDocuments class] forKey:[NSNumber numberWithInt:-648121413]];
   [cs_classes setObject:[TL_inputMessagesFilterDocument class] forKey:[NSNumber numberWithInt:-1629621880]];
   [cs_classes setObject:[TL_inputMessagesFilterUrl class] forKey:[NSNumber numberWithInt:2129714567]];
   [cs_classes setObject:[TL_inputMessagesFilterGif class] forKey:[NSNumber numberWithInt:-3644025]];
   [cs_classes setObject:[TL_updateNewMessage class] forKey:[NSNumber numberWithInt:522914557]];
   [cs_classes setObject:[TL_updateMessageID class] forKey:[NSNumber numberWithInt:1318109142]];
   [cs_classes setObject:[TL_updateDeleteMessages class] forKey:[NSNumber numberWithInt:-1576161051]];
   [cs_classes setObject:[TL_updateUserTyping class] forKey:[NSNumber numberWithInt:1548249383]];
   [cs_classes setObject:[TL_updateChatUserTyping class] forKey:[NSNumber numberWithInt:-1704596961]];
   [cs_classes setObject:[TL_updateChatParticipants class] forKey:[NSNumber numberWithInt:125178264]];
   [cs_classes setObject:[TL_updateUserStatus class] forKey:[NSNumber numberWithInt:469489699]];
   [cs_classes setObject:[TL_updateUserName class] forKey:[NSNumber numberWithInt:-1489818765]];
   [cs_classes setObject:[TL_updateUserPhoto class] forKey:[NSNumber numberWithInt:-1791935732]];
   [cs_classes setObject:[TL_updateContactRegistered class] forKey:[NSNumber numberWithInt:628472761]];
   [cs_classes setObject:[TL_updateContactLink class] forKey:[NSNumber numberWithInt:-1657903163]];
   [cs_classes setObject:[TL_updates_state class] forKey:[NSNumber numberWithInt:-1519637954]];
   [cs_classes setObject:[TL_updates_differenceEmpty class] forKey:[NSNumber numberWithInt:1567990072]];
   [cs_classes setObject:[TL_updates_difference class] forKey:[NSNumber numberWithInt:16030880]];
   [cs_classes setObject:[TL_updates_differenceSlice class] forKey:[NSNumber numberWithInt:-1459938943]];
   [cs_classes setObject:[TL_updatesTooLong class] forKey:[NSNumber numberWithInt:-484987010]];
   [cs_classes setObject:[TL_updateShortMessage class] forKey:[NSNumber numberWithInt:-1857044719]];
   [cs_classes setObject:[TL_updateShortChatMessage class] forKey:[NSNumber numberWithInt:377562760]];
   [cs_classes setObject:[TL_updateShort class] forKey:[NSNumber numberWithInt:2027216577]];
   [cs_classes setObject:[TL_updatesCombined class] forKey:[NSNumber numberWithInt:1918567619]];
   [cs_classes setObject:[TL_updates class] forKey:[NSNumber numberWithInt:1957577280]];
   [cs_classes setObject:[TL_photos_photos class] forKey:[NSNumber numberWithInt:-1916114267]];
   [cs_classes setObject:[TL_photos_photosSlice class] forKey:[NSNumber numberWithInt:352657236]];
   [cs_classes setObject:[TL_photos_photo class] forKey:[NSNumber numberWithInt:539045032]];
   [cs_classes setObject:[TL_upload_file class] forKey:[NSNumber numberWithInt:157948117]];
   [cs_classes setObject:[TL_dcOption class] forKey:[NSNumber numberWithInt:98092748]];
   [cs_classes setObject:[TL_config class] forKey:[NSNumber numberWithInt:989264735]];
   [cs_classes setObject:[TL_nearestDc class] forKey:[NSNumber numberWithInt:-1910892683]];
   [cs_classes setObject:[TL_help_appUpdate class] forKey:[NSNumber numberWithInt:-1987579119]];
   [cs_classes setObject:[TL_help_noAppUpdate class] forKey:[NSNumber numberWithInt:-1000708810]];
   [cs_classes setObject:[TL_help_inviteText class] forKey:[NSNumber numberWithInt:415997816]];
   [cs_classes setObject:[TL_wallPaperSolid class] forKey:[NSNumber numberWithInt:1662091044]];
   [cs_classes setObject:[TL_updateNewEncryptedMessage class] forKey:[NSNumber numberWithInt:314359194]];
   [cs_classes setObject:[TL_updateEncryptedChatTyping class] forKey:[NSNumber numberWithInt:386986326]];
   [cs_classes setObject:[TL_updateEncryption class] forKey:[NSNumber numberWithInt:-1264392051]];
   [cs_classes setObject:[TL_updateEncryptedMessagesRead class] forKey:[NSNumber numberWithInt:956179895]];
   [cs_classes setObject:[TL_encryptedChatEmpty class] forKey:[NSNumber numberWithInt:-1417756512]];
   [cs_classes setObject:[TL_encryptedChatWaiting class] forKey:[NSNumber numberWithInt:1006044124]];
   [cs_classes setObject:[TL_encryptedChatRequested class] forKey:[NSNumber numberWithInt:-931638658]];
   [cs_classes setObject:[TL_encryptedChat class] forKey:[NSNumber numberWithInt:-94974410]];
   [cs_classes setObject:[TL_encryptedChatDiscarded class] forKey:[NSNumber numberWithInt:332848423]];
   [cs_classes setObject:[TL_inputEncryptedChat class] forKey:[NSNumber numberWithInt:-247351839]];
   [cs_classes setObject:[TL_encryptedFileEmpty class] forKey:[NSNumber numberWithInt:-1038136962]];
   [cs_classes setObject:[TL_encryptedFile class] forKey:[NSNumber numberWithInt:1248893260]];
   [cs_classes setObject:[TL_inputEncryptedFileEmpty class] forKey:[NSNumber numberWithInt:406307684]];
   [cs_classes setObject:[TL_inputEncryptedFileUploaded class] forKey:[NSNumber numberWithInt:1690108678]];
   [cs_classes setObject:[TL_inputEncryptedFile class] forKey:[NSNumber numberWithInt:1511503333]];
   [cs_classes setObject:[TL_inputEncryptedFileLocation class] forKey:[NSNumber numberWithInt:-182231723]];
   [cs_classes setObject:[TL_encryptedMessage class] forKey:[NSNumber numberWithInt:-317144808]];
   [cs_classes setObject:[TL_encryptedMessageService class] forKey:[NSNumber numberWithInt:594758406]];
   [cs_classes setObject:[TL_messages_dhConfigNotModified class] forKey:[NSNumber numberWithInt:-1058912715]];
   [cs_classes setObject:[TL_messages_dhConfig class] forKey:[NSNumber numberWithInt:740433629]];
   [cs_classes setObject:[TL_messages_sentEncryptedMessage class] forKey:[NSNumber numberWithInt:1443858741]];
   [cs_classes setObject:[TL_messages_sentEncryptedFile class] forKey:[NSNumber numberWithInt:-1802240206]];
   [cs_classes setObject:[TL_inputFileBig class] forKey:[NSNumber numberWithInt:-95482955]];
   [cs_classes setObject:[TL_inputEncryptedFileBigUploaded class] forKey:[NSNumber numberWithInt:767652808]];
   [cs_classes setObject:[TL_updateChatParticipantAdd class] forKey:[NSNumber numberWithInt:-364179876]];
   [cs_classes setObject:[TL_updateChatParticipantDelete class] forKey:[NSNumber numberWithInt:1851755554]];
   [cs_classes setObject:[TL_updateDcOptions class] forKey:[NSNumber numberWithInt:-1906403213]];
   [cs_classes setObject:[TL_inputMediaUploadedDocument class] forKey:[NSNumber numberWithInt:-797904407]];
   [cs_classes setObject:[TL_inputMediaUploadedThumbDocument class] forKey:[NSNumber numberWithInt:1356369070]];
   [cs_classes setObject:[TL_inputMediaDocument class] forKey:[NSNumber numberWithInt:444068508]];
   [cs_classes setObject:[TL_messageMediaDocument class] forKey:[NSNumber numberWithInt:-203411800]];
   [cs_classes setObject:[TL_inputDocumentEmpty class] forKey:[NSNumber numberWithInt:1928391342]];
   [cs_classes setObject:[TL_inputDocument class] forKey:[NSNumber numberWithInt:410618194]];
   [cs_classes setObject:[TL_inputDocumentFileLocation class] forKey:[NSNumber numberWithInt:1125058340]];
   [cs_classes setObject:[TL_documentEmpty class] forKey:[NSNumber numberWithInt:922273905]];
   [cs_classes setObject:[TL_document class] forKey:[NSNumber numberWithInt:-2027738169]];
   [cs_classes setObject:[TL_help_support class] forKey:[NSNumber numberWithInt:398898678]];
   [cs_classes setObject:[TL_notifyPeer class] forKey:[NSNumber numberWithInt:-1613493288]];
   [cs_classes setObject:[TL_notifyUsers class] forKey:[NSNumber numberWithInt:-1261946036]];
   [cs_classes setObject:[TL_notifyChats class] forKey:[NSNumber numberWithInt:-1073230141]];
   [cs_classes setObject:[TL_notifyAll class] forKey:[NSNumber numberWithInt:1959820384]];
   [cs_classes setObject:[TL_updateUserBlocked class] forKey:[NSNumber numberWithInt:-2131957734]];
   [cs_classes setObject:[TL_updateNotifySettings class] forKey:[NSNumber numberWithInt:-1094555409]];
   [cs_classes setObject:[TL_sendMessageTypingAction class] forKey:[NSNumber numberWithInt:381645902]];
   [cs_classes setObject:[TL_sendMessageCancelAction class] forKey:[NSNumber numberWithInt:-44119819]];
   [cs_classes setObject:[TL_sendMessageRecordVideoAction class] forKey:[NSNumber numberWithInt:-1584933265]];
   [cs_classes setObject:[TL_sendMessageUploadVideoAction class] forKey:[NSNumber numberWithInt:-378127636]];
   [cs_classes setObject:[TL_sendMessageRecordAudioAction class] forKey:[NSNumber numberWithInt:-718310409]];
   [cs_classes setObject:[TL_sendMessageUploadAudioAction class] forKey:[NSNumber numberWithInt:-212740181]];
   [cs_classes setObject:[TL_sendMessageUploadPhotoAction class] forKey:[NSNumber numberWithInt:-774682074]];
   [cs_classes setObject:[TL_sendMessageUploadDocumentAction class] forKey:[NSNumber numberWithInt:-1441998364]];
   [cs_classes setObject:[TL_sendMessageGeoLocationAction class] forKey:[NSNumber numberWithInt:393186209]];
   [cs_classes setObject:[TL_sendMessageChooseContactAction class] forKey:[NSNumber numberWithInt:1653390447]];
   [cs_classes setObject:[TL_contacts_found class] forKey:[NSNumber numberWithInt:446822276]];
   [cs_classes setObject:[TL_updateServiceNotification class] forKey:[NSNumber numberWithInt:-337352679]];
   [cs_classes setObject:[TL_userStatusRecently class] forKey:[NSNumber numberWithInt:-496024847]];
   [cs_classes setObject:[TL_userStatusLastWeek class] forKey:[NSNumber numberWithInt:129960444]];
   [cs_classes setObject:[TL_userStatusLastMonth class] forKey:[NSNumber numberWithInt:2011940674]];
   [cs_classes setObject:[TL_updatePrivacy class] forKey:[NSNumber numberWithInt:-298113238]];
   [cs_classes setObject:[TL_inputPrivacyKeyStatusTimestamp class] forKey:[NSNumber numberWithInt:1335282456]];
   [cs_classes setObject:[TL_privacyKeyStatusTimestamp class] forKey:[NSNumber numberWithInt:-1137792208]];
   [cs_classes setObject:[TL_inputPrivacyValueAllowContacts class] forKey:[NSNumber numberWithInt:218751099]];
   [cs_classes setObject:[TL_inputPrivacyValueAllowAll class] forKey:[NSNumber numberWithInt:407582158]];
   [cs_classes setObject:[TL_inputPrivacyValueAllowUsers class] forKey:[NSNumber numberWithInt:320652927]];
   [cs_classes setObject:[TL_inputPrivacyValueDisallowContacts class] forKey:[NSNumber numberWithInt:195371015]];
   [cs_classes setObject:[TL_inputPrivacyValueDisallowAll class] forKey:[NSNumber numberWithInt:-697604407]];
   [cs_classes setObject:[TL_inputPrivacyValueDisallowUsers class] forKey:[NSNumber numberWithInt:-1877932953]];
   [cs_classes setObject:[TL_privacyValueAllowContacts class] forKey:[NSNumber numberWithInt:-123988]];
   [cs_classes setObject:[TL_privacyValueAllowAll class] forKey:[NSNumber numberWithInt:1698855810]];
   [cs_classes setObject:[TL_privacyValueAllowUsers class] forKey:[NSNumber numberWithInt:1297858060]];
   [cs_classes setObject:[TL_privacyValueDisallowContacts class] forKey:[NSNumber numberWithInt:-125240806]];
   [cs_classes setObject:[TL_privacyValueDisallowAll class] forKey:[NSNumber numberWithInt:-1955338397]];
   [cs_classes setObject:[TL_privacyValueDisallowUsers class] forKey:[NSNumber numberWithInt:209668535]];
   [cs_classes setObject:[TL_account_privacyRules class] forKey:[NSNumber numberWithInt:1430961007]];
   [cs_classes setObject:[TL_accountDaysTTL class] forKey:[NSNumber numberWithInt:-1194283041]];
   [cs_classes setObject:[TL_updateUserPhone class] forKey:[NSNumber numberWithInt:314130811]];
   [cs_classes setObject:[TL_documentAttributeImageSize class] forKey:[NSNumber numberWithInt:1815593308]];
   [cs_classes setObject:[TL_documentAttributeAnimated class] forKey:[NSNumber numberWithInt:297109817]];
   [cs_classes setObject:[TL_documentAttributeSticker class] forKey:[NSNumber numberWithInt:1662637586]];
   [cs_classes setObject:[TL_documentAttributeVideo class] forKey:[NSNumber numberWithInt:1494273227]];
   [cs_classes setObject:[TL_documentAttributeAudio class] forKey:[NSNumber numberWithInt:-1739392570]];
   [cs_classes setObject:[TL_documentAttributeFilename class] forKey:[NSNumber numberWithInt:358154344]];
   [cs_classes setObject:[TL_messages_stickersNotModified class] forKey:[NSNumber numberWithInt:-244016606]];
   [cs_classes setObject:[TL_messages_stickers class] forKey:[NSNumber numberWithInt:-1970352846]];
   [cs_classes setObject:[TL_stickerPack class] forKey:[NSNumber numberWithInt:313694676]];
   [cs_classes setObject:[TL_messages_allStickersNotModified class] forKey:[NSNumber numberWithInt:-395967805]];
   [cs_classes setObject:[TL_messages_allStickers class] forKey:[NSNumber numberWithInt:-302170017]];
   [cs_classes setObject:[TL_disabledFeature class] forKey:[NSNumber numberWithInt:-1369215196]];
   [cs_classes setObject:[TL_updateReadHistoryInbox class] forKey:[NSNumber numberWithInt:-1721631396]];
   [cs_classes setObject:[TL_updateReadHistoryOutbox class] forKey:[NSNumber numberWithInt:791617983]];
   [cs_classes setObject:[TL_messages_affectedMessages class] forKey:[NSNumber numberWithInt:-2066640507]];
   [cs_classes setObject:[TL_contactLinkUnknown class] forKey:[NSNumber numberWithInt:1599050311]];
   [cs_classes setObject:[TL_contactLinkNone class] forKey:[NSNumber numberWithInt:-17968211]];
   [cs_classes setObject:[TL_contactLinkHasPhone class] forKey:[NSNumber numberWithInt:646922073]];
   [cs_classes setObject:[TL_contactLinkContact class] forKey:[NSNumber numberWithInt:-721239344]];
   [cs_classes setObject:[TL_updateWebPage class] forKey:[NSNumber numberWithInt:2139689491]];
   [cs_classes setObject:[TL_webPageEmpty class] forKey:[NSNumber numberWithInt:-350980120]];
   [cs_classes setObject:[TL_webPagePending class] forKey:[NSNumber numberWithInt:-981018084]];
   [cs_classes setObject:[TL_webPage class] forKey:[NSNumber numberWithInt:1594340540]];
   [cs_classes setObject:[TL_messageMediaWebPage class] forKey:[NSNumber numberWithInt:-1557277184]];
   [cs_classes setObject:[TL_authorization class] forKey:[NSNumber numberWithInt:2079516406]];
   [cs_classes setObject:[TL_account_authorizations class] forKey:[NSNumber numberWithInt:307276766]];
   [cs_classes setObject:[TL_account_noPassword class] forKey:[NSNumber numberWithInt:-1764049896]];
   [cs_classes setObject:[TL_account_password class] forKey:[NSNumber numberWithInt:2081952796]];
   [cs_classes setObject:[TL_account_passwordSettings class] forKey:[NSNumber numberWithInt:-1212732749]];
   [cs_classes setObject:[TL_account_passwordInputSettings class] forKey:[NSNumber numberWithInt:-2037289493]];
   [cs_classes setObject:[TL_auth_passwordRecovery class] forKey:[NSNumber numberWithInt:326715557]];
   [cs_classes setObject:[TL_inputMediaVenue class] forKey:[NSNumber numberWithInt:673687578]];
   [cs_classes setObject:[TL_messageMediaVenue class] forKey:[NSNumber numberWithInt:2031269663]];
   [cs_classes setObject:[TL_receivedNotifyMessage class] forKey:[NSNumber numberWithInt:-1551583367]];
   [cs_classes setObject:[TL_chatInviteEmpty class] forKey:[NSNumber numberWithInt:1776236393]];
   [cs_classes setObject:[TL_chatInviteExported class] forKey:[NSNumber numberWithInt:-64092740]];
   [cs_classes setObject:[TL_chatInviteAlready class] forKey:[NSNumber numberWithInt:1516793212]];
   [cs_classes setObject:[TL_chatInvite class] forKey:[NSNumber numberWithInt:-613092008]];
   [cs_classes setObject:[TL_messageActionChatJoinedByLink class] forKey:[NSNumber numberWithInt:-123931160]];
   [cs_classes setObject:[TL_updateReadMessagesContents class] forKey:[NSNumber numberWithInt:1757493555]];
   [cs_classes setObject:[TL_inputStickerSetEmpty class] forKey:[NSNumber numberWithInt:-4838507]];
   [cs_classes setObject:[TL_inputStickerSetID class] forKey:[NSNumber numberWithInt:-1645763991]];
   [cs_classes setObject:[TL_inputStickerSetShortName class] forKey:[NSNumber numberWithInt:-2044933984]];
   [cs_classes setObject:[TL_stickerSet class] forKey:[NSNumber numberWithInt:-852477119]];
   [cs_classes setObject:[TL_messages_stickerSet class] forKey:[NSNumber numberWithInt:-1240849242]];
   [cs_classes setObject:[TL_user class] forKey:[NSNumber numberWithInt:-787638374]];
   [cs_classes setObject:[TL_botCommand class] forKey:[NSNumber numberWithInt:-1032140601]];
   [cs_classes setObject:[TL_botInfo class] forKey:[NSNumber numberWithInt:-1729618630]];
   [cs_classes setObject:[TL_keyboardButton class] forKey:[NSNumber numberWithInt:-1560655744]];
   [cs_classes setObject:[TL_keyboardButtonRow class] forKey:[NSNumber numberWithInt:2002815875]];
   [cs_classes setObject:[TL_replyKeyboardHide class] forKey:[NSNumber numberWithInt:-1606526075]];
   [cs_classes setObject:[TL_replyKeyboardForceReply class] forKey:[NSNumber numberWithInt:-200242528]];
   [cs_classes setObject:[TL_replyKeyboardMarkup class] forKey:[NSNumber numberWithInt:889353612]];
   [cs_classes setObject:[TL_inputPeerUser class] forKey:[NSNumber numberWithInt:2072935910]];
   [cs_classes setObject:[TL_inputUser class] forKey:[NSNumber numberWithInt:-668391402]];
   [cs_classes setObject:[TL_help_appChangelogEmpty class] forKey:[NSNumber numberWithInt:-1350696044]];
   [cs_classes setObject:[TL_help_appChangelog class] forKey:[NSNumber numberWithInt:705920636]];
   [cs_classes setObject:[TL_messageEntityUnknown class] forKey:[NSNumber numberWithInt:-1148011883]];
   [cs_classes setObject:[TL_messageEntityMention class] forKey:[NSNumber numberWithInt:-100378723]];
   [cs_classes setObject:[TL_messageEntityHashtag class] forKey:[NSNumber numberWithInt:1868782349]];
   [cs_classes setObject:[TL_messageEntityBotCommand class] forKey:[NSNumber numberWithInt:1827637959]];
   [cs_classes setObject:[TL_messageEntityUrl class] forKey:[NSNumber numberWithInt:1859134776]];
   [cs_classes setObject:[TL_messageEntityEmail class] forKey:[NSNumber numberWithInt:1692693954]];
   [cs_classes setObject:[TL_messageEntityBold class] forKey:[NSNumber numberWithInt:-1117713463]];
   [cs_classes setObject:[TL_messageEntityItalic class] forKey:[NSNumber numberWithInt:-2106619040]];
   [cs_classes setObject:[TL_messageEntityCode class] forKey:[NSNumber numberWithInt:681706865]];
   [cs_classes setObject:[TL_messageEntityPre class] forKey:[NSNumber numberWithInt:1938967520]];
   [cs_classes setObject:[TL_messageEntityTextUrl class] forKey:[NSNumber numberWithInt:1990644519]];
   [cs_classes setObject:[TL_updateShortSentMessage class] forKey:[NSNumber numberWithInt:301019932]];
   [cs_classes setObject:[TL_inputChannelEmpty class] forKey:[NSNumber numberWithInt:-292807034]];
   [cs_classes setObject:[TL_inputChannel class] forKey:[NSNumber numberWithInt:-1343524562]];
   [cs_classes setObject:[TL_peerChannel class] forKey:[NSNumber numberWithInt:-1109531342]];
   [cs_classes setObject:[TL_inputPeerChannel class] forKey:[NSNumber numberWithInt:548253432]];
   [cs_classes setObject:[TL_channel class] forKey:[NSNumber numberWithInt:-1588737454]];
   [cs_classes setObject:[TL_channelForbidden class] forKey:[NSNumber numberWithInt:-2059962289]];
   [cs_classes setObject:[TL_contacts_resolvedPeer class] forKey:[NSNumber numberWithInt:2131196633]];
   [cs_classes setObject:[TL_channelFull class] forKey:[NSNumber numberWithInt:-1009430225]];
   [cs_classes setObject:[TL_messageRange class] forKey:[NSNumber numberWithInt:182649427]];
   [cs_classes setObject:[TL_messages_channelMessages class] forKey:[NSNumber numberWithInt:-1725551049]];
   [cs_classes setObject:[TL_messageActionChannelCreate class] forKey:[NSNumber numberWithInt:-1781355374]];
   [cs_classes setObject:[TL_updateChannelTooLong class] forKey:[NSNumber numberWithInt:-352032773]];
   [cs_classes setObject:[TL_updateChannel class] forKey:[NSNumber numberWithInt:-1227598250]];
   [cs_classes setObject:[TL_updateNewChannelMessage class] forKey:[NSNumber numberWithInt:1656358105]];
   [cs_classes setObject:[TL_updateReadChannelInbox class] forKey:[NSNumber numberWithInt:1108669311]];
   [cs_classes setObject:[TL_updateDeleteChannelMessages class] forKey:[NSNumber numberWithInt:-1015733815]];
   [cs_classes setObject:[TL_updateChannelMessageViews class] forKey:[NSNumber numberWithInt:-1734268085]];
   [cs_classes setObject:[TL_updates_channelDifferenceEmpty class] forKey:[NSNumber numberWithInt:1041346555]];
   [cs_classes setObject:[TL_updates_channelDifferenceTooLong class] forKey:[NSNumber numberWithInt:1091431943]];
   [cs_classes setObject:[TL_updates_channelDifference class] forKey:[NSNumber numberWithInt:543450958]];
   [cs_classes setObject:[TL_channelMessagesFilterEmpty class] forKey:[NSNumber numberWithInt:-1798033689]];
   [cs_classes setObject:[TL_channelMessagesFilter class] forKey:[NSNumber numberWithInt:-847783593]];
   [cs_classes setObject:[TL_channelParticipant class] forKey:[NSNumber numberWithInt:367766557]];
   [cs_classes setObject:[TL_channelParticipantSelf class] forKey:[NSNumber numberWithInt:-1557620115]];
   [cs_classes setObject:[TL_channelParticipantModerator class] forKey:[NSNumber numberWithInt:-1861910545]];
   [cs_classes setObject:[TL_channelParticipantEditor class] forKey:[NSNumber numberWithInt:-1743180447]];
   [cs_classes setObject:[TL_channelParticipantKicked class] forKey:[NSNumber numberWithInt:-1933187430]];
   [cs_classes setObject:[TL_channelParticipantCreator class] forKey:[NSNumber numberWithInt:-471670279]];
   [cs_classes setObject:[TL_channelParticipantsRecent class] forKey:[NSNumber numberWithInt:-566281095]];
   [cs_classes setObject:[TL_channelParticipantsAdmins class] forKey:[NSNumber numberWithInt:-1268741783]];
   [cs_classes setObject:[TL_channelParticipantsKicked class] forKey:[NSNumber numberWithInt:1010285434]];
   [cs_classes setObject:[TL_channelRoleEmpty class] forKey:[NSNumber numberWithInt:-1299865402]];
   [cs_classes setObject:[TL_channelRoleModerator class] forKey:[NSNumber numberWithInt:-1776756363]];
   [cs_classes setObject:[TL_channelRoleEditor class] forKey:[NSNumber numberWithInt:-2113143156]];
   [cs_classes setObject:[TL_channels_channelParticipants class] forKey:[NSNumber numberWithInt:-177282392]];
   [cs_classes setObject:[TL_channels_channelParticipant class] forKey:[NSNumber numberWithInt:-791039645]];
   [cs_classes setObject:[TL_chatParticipantCreator class] forKey:[NSNumber numberWithInt:-636267638]];
   [cs_classes setObject:[TL_chatParticipantAdmin class] forKey:[NSNumber numberWithInt:-489233354]];
   [cs_classes setObject:[TL_updateChatAdmins class] forKey:[NSNumber numberWithInt:1855224129]];
   [cs_classes setObject:[TL_updateChatParticipantAdmin class] forKey:[NSNumber numberWithInt:-1232070311]];
   [cs_classes setObject:[TL_messageActionChatMigrateTo class] forKey:[NSNumber numberWithInt:1371385889]];
   [cs_classes setObject:[TL_messageActionChannelMigrateFrom class] forKey:[NSNumber numberWithInt:-1336546578]];
   [cs_classes setObject:[TL_channelParticipantsBots class] forKey:[NSNumber numberWithInt:-1328445861]];
   [cs_classes setObject:[TL_help_termsOfService class] forKey:[NSNumber numberWithInt:-236044656]];
   [cs_classes setObject:[TL_updateNewStickerSet class] forKey:[NSNumber numberWithInt:1753886890]];
   [cs_classes setObject:[TL_updateStickerSetsOrder class] forKey:[NSNumber numberWithInt:196268545]];
   [cs_classes setObject:[TL_updateStickerSets class] forKey:[NSNumber numberWithInt:1135492588]];
   [cs_classes setObject:[TL_foundGif class] forKey:[NSNumber numberWithInt:372165663]];
   [cs_classes setObject:[TL_foundGifCached class] forKey:[NSNumber numberWithInt:-1670052855]];
   [cs_classes setObject:[TL_inputMediaGifExternal class] forKey:[NSNumber numberWithInt:1212395773]];
   [cs_classes setObject:[TL_messages_foundGifs class] forKey:[NSNumber numberWithInt:1158290442]];
   [cs_classes setObject:[TL_messages_savedGifsNotModified class] forKey:[NSNumber numberWithInt:-402498398]];
   [cs_classes setObject:[TL_messages_savedGifs class] forKey:[NSNumber numberWithInt:772213157]];
   [cs_classes setObject:[TL_updateSavedGifs class] forKey:[NSNumber numberWithInt:-1821035490]];
   [cs_classes setObject:[TL_inputBotInlineMessageMediaAuto class] forKey:[NSNumber numberWithInt:691006739]];
   [cs_classes setObject:[TL_inputBotInlineMessageText class] forKey:[NSNumber numberWithInt:1036876423]];
   [cs_classes setObject:[TL_inputBotInlineResult class] forKey:[NSNumber numberWithInt:750510426]];
   [cs_classes setObject:[TL_botInlineMessageMediaAuto class] forKey:[NSNumber numberWithInt:175419739]];
   [cs_classes setObject:[TL_botInlineMessageText class] forKey:[NSNumber numberWithInt:-1937807902]];
   [cs_classes setObject:[TL_botInlineResult class] forKey:[NSNumber numberWithInt:-1679053127]];
   [cs_classes setObject:[TL_messages_botResults class] forKey:[NSNumber numberWithInt:-858565059]];
   [cs_classes setObject:[TL_updateBotInlineQuery class] forKey:[NSNumber numberWithInt:1417832080]];
   [cs_classes setObject:[TL_inputMessagesFilterVoice class] forKey:[NSNumber numberWithInt:1358283666]];
   [cs_classes setObject:[TL_inputMessagesFilterMusic class] forKey:[NSNumber numberWithInt:928101534]];
   [cs_classes setObject:[TL_inputPrivacyKeyChatInvite class] forKey:[NSNumber numberWithInt:-1107622874]];
   [cs_classes setObject:[TL_privacyKeyChatInvite class] forKey:[NSNumber numberWithInt:1343122938]];
   [cs_classes setObject:[TL_exportedMessageLink class] forKey:[NSNumber numberWithInt:524838915]];
   [cs_classes setObject:[TL_messageFwdHeader class] forKey:[NSNumber numberWithInt:-947462709]];
   [cs_classes setObject:[TL_updateEditChannelMessage class] forKey:[NSNumber numberWithInt:457133559]];
   [cs_classes setObject:[TL_updateChannelPinnedMessage class] forKey:[NSNumber numberWithInt:-1738988427]];
   [cs_classes setObject:[TL_messageActionPinMessage class] forKey:[NSNumber numberWithInt:-1799538451]];
   [cs_classes setObject:[TL_auth_codeTypeSms class] forKey:[NSNumber numberWithInt:1923290508]];
   [cs_classes setObject:[TL_auth_codeTypeCall class] forKey:[NSNumber numberWithInt:1948046307]];
   [cs_classes setObject:[TL_auth_codeTypeFlashCall class] forKey:[NSNumber numberWithInt:577556219]];
   [cs_classes setObject:[TL_auth_sentCodeTypeApp class] forKey:[NSNumber numberWithInt:1035688326]];
   [cs_classes setObject:[TL_auth_sentCodeTypeSms class] forKey:[NSNumber numberWithInt:-1073693790]];
   [cs_classes setObject:[TL_auth_sentCodeTypeCall class] forKey:[NSNumber numberWithInt:1398007207]];
   [cs_classes setObject:[TL_auth_sentCodeTypeFlashCall class] forKey:[NSNumber numberWithInt:-1425815847]];
   [cs_classes setObject:[TL_keyboardButtonUrl class] forKey:[NSNumber numberWithInt:629866245]];
   [cs_classes setObject:[TL_keyboardButtonCallback class] forKey:[NSNumber numberWithInt:1748655686]];
   [cs_classes setObject:[TL_keyboardButtonRequestPhone class] forKey:[NSNumber numberWithInt:-1318425559]];
   [cs_classes setObject:[TL_keyboardButtonRequestGeoLocation class] forKey:[NSNumber numberWithInt:-59151553]];
   [cs_classes setObject:[TL_keyboardButtonSwitchInline class] forKey:[NSNumber numberWithInt:90744648]];
   [cs_classes setObject:[TL_replyInlineMarkup class] forKey:[NSNumber numberWithInt:1218642516]];
   [cs_classes setObject:[TL_messages_botCallbackAnswer class] forKey:[NSNumber numberWithInt:911761060]];
   [cs_classes setObject:[TL_messages_messageEditData class] forKey:[NSNumber numberWithInt:649453030]];
   [cs_classes setObject:[TL_updateEditMessage class] forKey:[NSNumber numberWithInt:-469536605]];
   [cs_classes setObject:[TL_inputBotInlineMessageMediaGeo class] forKey:[NSNumber numberWithInt:-190472735]];
   [cs_classes setObject:[TL_inputBotInlineMessageMediaVenue class] forKey:[NSNumber numberWithInt:-1431327288]];
   [cs_classes setObject:[TL_inputBotInlineMessageMediaContact class] forKey:[NSNumber numberWithInt:766443943]];
   [cs_classes setObject:[TL_botInlineMessageMediaGeo class] forKey:[NSNumber numberWithInt:982505656]];
   [cs_classes setObject:[TL_botInlineMessageMediaVenue class] forKey:[NSNumber numberWithInt:1130767150]];
   [cs_classes setObject:[TL_botInlineMessageMediaContact class] forKey:[NSNumber numberWithInt:904770772]];
   [cs_classes setObject:[TL_inputBotInlineResultPhoto class] forKey:[NSNumber numberWithInt:-1462213465]];
   [cs_classes setObject:[TL_inputBotInlineResultDocument class] forKey:[NSNumber numberWithInt:-459324]];
   [cs_classes setObject:[TL_botInlineMediaResult class] forKey:[NSNumber numberWithInt:400266251]];
   [cs_classes setObject:[TL_inputBotInlineMessageID class] forKey:[NSNumber numberWithInt:-1995686519]];
   [cs_classes setObject:[TL_updateInlineBotCallbackQuery class] forKey:[NSNumber numberWithInt:-103646630]];
   [cs_classes setObject:[TL_inlineBotSwitchPM class] forKey:[NSNumber numberWithInt:1008755359]];
   [cs_classes setObject:[TL_messages_peerDialogs class] forKey:[NSNumber numberWithInt:863093588]];
   [cs_classes setObject:[TL_topPeer class] forKey:[NSNumber numberWithInt:-305282981]];
   [cs_classes setObject:[TL_topPeerCategoryBotsPM class] forKey:[NSNumber numberWithInt:-1419371685]];
   [cs_classes setObject:[TL_topPeerCategoryBotsInline class] forKey:[NSNumber numberWithInt:344356834]];
   [cs_classes setObject:[TL_topPeerCategoryCorrespondents class] forKey:[NSNumber numberWithInt:104314861]];
   [cs_classes setObject:[TL_topPeerCategoryGroups class] forKey:[NSNumber numberWithInt:-1122524854]];
   [cs_classes setObject:[TL_topPeerCategoryChannels class] forKey:[NSNumber numberWithInt:371037736]];
   [cs_classes setObject:[TL_topPeerCategoryPeers class] forKey:[NSNumber numberWithInt:-75283823]];
   [cs_classes setObject:[TL_contacts_topPeersNotModified class] forKey:[NSNumber numberWithInt:-567906571]];
   [cs_classes setObject:[TL_contacts_topPeers class] forKey:[NSNumber numberWithInt:1891070632]];
   [cs_classes setObject:[TL_messageEntityMentionName class] forKey:[NSNumber numberWithInt:892193368]];
   [cs_classes setObject:[TL_inputMessageEntityMentionName class] forKey:[NSNumber numberWithInt:546203849]];
   [cs_classes setObject:[TL_inputMessagesFilterChatPhotos class] forKey:[NSNumber numberWithInt:975236280]];
   [cs_classes setObject:[TL_updateReadChannelOutbox class] forKey:[NSNumber numberWithInt:634833351]];
   [cs_classes setObject:[TL_updateDraftMessage class] forKey:[NSNumber numberWithInt:-299124375]];
   [cs_classes setObject:[TL_draftMessageEmpty class] forKey:[NSNumber numberWithInt:-1169445179]];
   [cs_classes setObject:[TL_draftMessage class] forKey:[NSNumber numberWithInt:-40996577]];
   [cs_classes setObject:[TL_messageActionHistoryClear class] forKey:[NSNumber numberWithInt:-1615153660]];
   [cs_classes setObject:[TL_messages_featuredStickersNotModified class] forKey:[NSNumber numberWithInt:82699215]];
   [cs_classes setObject:[TL_messages_featuredStickers class] forKey:[NSNumber numberWithInt:-123893531]];
   [cs_classes setObject:[TL_updateReadFeaturedStickers class] forKey:[NSNumber numberWithInt:1461528386]];
   [cs_classes setObject:[TL_messages_recentStickersNotModified class] forKey:[NSNumber numberWithInt:186120336]];
   [cs_classes setObject:[TL_messages_recentStickers class] forKey:[NSNumber numberWithInt:1558317424]];
   [cs_classes setObject:[TL_updateRecentStickers class] forKey:[NSNumber numberWithInt:-1706939360]];
   [cs_classes setObject:[TL_messages_archivedStickers class] forKey:[NSNumber numberWithInt:1338747336]];
   [cs_classes setObject:[TL_messages_stickerSetInstallResultSuccess class] forKey:[NSNumber numberWithInt:946083368]];
   [cs_classes setObject:[TL_messages_stickerSetInstallResultArchive class] forKey:[NSNumber numberWithInt:904138920]];
   [cs_classes setObject:[TL_stickerSetCovered class] forKey:[NSNumber numberWithInt:1678812626]];
   [cs_classes setObject:[TL_updateConfig class] forKey:[NSNumber numberWithInt:-1574314746]];
   [cs_classes setObject:[TL_updatePtsChanged class] forKey:[NSNumber numberWithInt:861169551]];
   [cs_classes setObject:[TL_inputMediaPhotoExternal class] forKey:[NSNumber numberWithInt:-1252045032]];
   [cs_classes setObject:[TL_inputMediaDocumentExternal class] forKey:[NSNumber numberWithInt:-437690244]];
   [cs_classes setObject:[TL_stickerSetMultiCovered class] forKey:[NSNumber numberWithInt:872932635]];
   [cs_classes setObject:[TL_maskCoords class] forKey:[NSNumber numberWithInt:-1361650766]];
   [cs_classes setObject:[TL_documentAttributeHasStickers class] forKey:[NSNumber numberWithInt:-1744710921]];
   [cs_classes setObject:[TL_inputStickeredMediaPhoto class] forKey:[NSNumber numberWithInt:1251549527]];
   [cs_classes setObject:[TL_inputStickeredMediaDocument class] forKey:[NSNumber numberWithInt:70813275]];
   [cs_classes setObject:[TL_game class] forKey:[NSNumber numberWithInt:-1107729093]];
   [cs_classes setObject:[TL_inputBotInlineResultGame class] forKey:[NSNumber numberWithInt:1336154098]];
   [cs_classes setObject:[TL_inputBotInlineMessageGame class] forKey:[NSNumber numberWithInt:1262639204]];
   [cs_classes setObject:[TL_messageMediaGame class] forKey:[NSNumber numberWithInt:-38694904]];
   [cs_classes setObject:[TL_inputMediaGame class] forKey:[NSNumber numberWithInt:-750828557]];
   [cs_classes setObject:[TL_inputGameID class] forKey:[NSNumber numberWithInt:53231223]];
   [cs_classes setObject:[TL_inputGameShortName class] forKey:[NSNumber numberWithInt:-1020139510]];
   [cs_classes setObject:[TL_keyboardButtonGame class] forKey:[NSNumber numberWithInt:1358175439]];
   [cs_classes setObject:[TL_messageActionGameScore class] forKey:[NSNumber numberWithInt:-1834538890]];
   [cs_classes setObject:[TL_highScore class] forKey:[NSNumber numberWithInt:1493171408]];
   [cs_classes setObject:[TL_messages_highScores class] forKey:[NSNumber numberWithInt:-1707344487]];
   [cs_classes setObject:[TL_updates_differenceTooLong class] forKey:[NSNumber numberWithInt:1258196845]];
   [cs_classes setObject:[TL_updateChannelWebPage class] forKey:[NSNumber numberWithInt:1081547008]];
   [cs_classes setObject:[TL_messages_chatsSlice class] forKey:[NSNumber numberWithInt:-1663561404]];
   [cs_classes setObject:[TL_textEmpty class] forKey:[NSNumber numberWithInt:-599948721]];
   [cs_classes setObject:[TL_textPlain class] forKey:[NSNumber numberWithInt:1950782688]];
   [cs_classes setObject:[TL_textBold class] forKey:[NSNumber numberWithInt:1730456516]];
   [cs_classes setObject:[TL_textItalic class] forKey:[NSNumber numberWithInt:-653089380]];
   [cs_classes setObject:[TL_textUnderline class] forKey:[NSNumber numberWithInt:-1054465340]];
   [cs_classes setObject:[TL_textStrike class] forKey:[NSNumber numberWithInt:-1678197867]];
   [cs_classes setObject:[TL_textFixed class] forKey:[NSNumber numberWithInt:1816074681]];
   [cs_classes setObject:[TL_textUrl class] forKey:[NSNumber numberWithInt:1009288385]];
   [cs_classes setObject:[TL_textEmail class] forKey:[NSNumber numberWithInt:-564523562]];
   [cs_classes setObject:[TL_textConcat class] forKey:[NSNumber numberWithInt:2120376535]];
   [cs_classes setObject:[TL_pageBlockUnsupported class] forKey:[NSNumber numberWithInt:324435594]];
   [cs_classes setObject:[TL_pageBlockTitle class] forKey:[NSNumber numberWithInt:1890305021]];
   [cs_classes setObject:[TL_pageBlockSubtitle class] forKey:[NSNumber numberWithInt:-1879401953]];
   [cs_classes setObject:[TL_pageBlockAuthorDate class] forKey:[NSNumber numberWithInt:-1162877472]];
   [cs_classes setObject:[TL_pageBlockHeader class] forKey:[NSNumber numberWithInt:-1076861716]];
   [cs_classes setObject:[TL_pageBlockSubheader class] forKey:[NSNumber numberWithInt:-248793375]];
   [cs_classes setObject:[TL_pageBlockParagraph class] forKey:[NSNumber numberWithInt:1182402406]];
   [cs_classes setObject:[TL_pageBlockPreformatted class] forKey:[NSNumber numberWithInt:-1066346178]];
   [cs_classes setObject:[TL_pageBlockFooter class] forKey:[NSNumber numberWithInt:1216809369]];
   [cs_classes setObject:[TL_pageBlockDivider class] forKey:[NSNumber numberWithInt:-618614392]];
   [cs_classes setObject:[TL_pageBlockAnchor class] forKey:[NSNumber numberWithInt:-837994576]];
   [cs_classes setObject:[TL_pageBlockList class] forKey:[NSNumber numberWithInt:978896884]];
   [cs_classes setObject:[TL_pageBlockBlockquote class] forKey:[NSNumber numberWithInt:641563686]];
   [cs_classes setObject:[TL_pageBlockPullquote class] forKey:[NSNumber numberWithInt:1329878739]];
   [cs_classes setObject:[TL_pageBlockPhoto class] forKey:[NSNumber numberWithInt:-372860542]];
   [cs_classes setObject:[TL_pageBlockVideo class] forKey:[NSNumber numberWithInt:-640214938]];
   [cs_classes setObject:[TL_pageBlockCover class] forKey:[NSNumber numberWithInt:972174080]];
   [cs_classes setObject:[TL_pageBlockEmbed class] forKey:[NSNumber numberWithInt:-840826671]];
   [cs_classes setObject:[TL_pageBlockEmbedPost class] forKey:[NSNumber numberWithInt:690781161]];
   [cs_classes setObject:[TL_pageBlockCollage class] forKey:[NSNumber numberWithInt:145955919]];
   [cs_classes setObject:[TL_pageBlockSlideshow class] forKey:[NSNumber numberWithInt:319588707]];
   [cs_classes setObject:[TL_pagePart class] forKey:[NSNumber numberWithInt:-1913754556]];
   [cs_classes setObject:[TL_pageFull class] forKey:[NSNumber numberWithInt:-677274263]];
   [cs_classes setObject:[TL_webPageNotModified class] forKey:[NSNumber numberWithInt:-2054908813]];
   [cs_classes setObject:[TL_inputPhoneCall class] forKey:[NSNumber numberWithInt:506920429]];
   [cs_classes setObject:[TL_phoneCallEmpty class] forKey:[NSNumber numberWithInt:1399245077]];
   [cs_classes setObject:[TL_phoneCallWaiting class] forKey:[NSNumber numberWithInt:462375633]];
   [cs_classes setObject:[TL_phoneCallRequested class] forKey:[NSNumber numberWithInt:1816431336]];
   [cs_classes setObject:[TL_phoneCall class] forKey:[NSNumber numberWithInt:-1660057]];
   [cs_classes setObject:[TL_phoneCallDiscarded class] forKey:[NSNumber numberWithInt:1355435489]];
   [cs_classes setObject:[TL_phoneConnection class] forKey:[NSNumber numberWithInt:-1655957568]];
   [cs_classes setObject:[TL_phoneCallProtocol class] forKey:[NSNumber numberWithInt:-1564789301]];
   [cs_classes setObject:[TL_updatePhoneCall class] forKey:[NSNumber numberWithInt:-1425052898]];
   [cs_classes setObject:[TL_phone_phoneCall class] forKey:[NSNumber numberWithInt:-326966976]];
   [cs_classes setObject:[TL_inputPrivacyKeyPhoneCall class] forKey:[NSNumber numberWithInt:-88417185]];
   [cs_classes setObject:[TL_privacyKeyPhoneCall class] forKey:[NSNumber numberWithInt:1030105979]];
   [cs_classes setObject:[TL_sendMessageGamePlayAction class] forKey:[NSNumber numberWithInt:-580219064]];
   [cs_classes setObject:[TL_phoneCallDiscardReasonMissed class] forKey:[NSNumber numberWithInt:-2048646399]];
   [cs_classes setObject:[TL_phoneCallDiscardReasonDisconnect class] forKey:[NSNumber numberWithInt:-527056480]];
   [cs_classes setObject:[TL_phoneCallDiscardReasonHangup class] forKey:[NSNumber numberWithInt:1471006352]];
   [cs_classes setObject:[TL_phoneCallDiscardReasonBusy class] forKey:[NSNumber numberWithInt:-84416311]];
   [cs_classes setObject:[TL_updateDialogPinned class] forKey:[NSNumber numberWithInt:-686710068]];
   [cs_classes setObject:[TL_updatePinnedDialogs class] forKey:[NSNumber numberWithInt:-657787251]];
   [cs_classes setObject:[TL_inputMessagesFilterPhoneCalls class] forKey:[NSNumber numberWithInt:-2134272152]];
   [cs_classes setObject:[TL_messageActionPhoneCall class] forKey:[NSNumber numberWithInt:-2132731265]];
   [cs_classes setObject:[TL_userSelf class] forKey:[NSNumber numberWithInt:476112392]];
   [cs_classes setObject:[TL_userContact class] forKey:[NSNumber numberWithInt:-894214632]];
   [cs_classes setObject:[TL_userRequest class] forKey:[NSNumber numberWithInt:-640891665]];
   [cs_classes setObject:[TL_userForeign class] forKey:[NSNumber numberWithInt:123533224]];
   [cs_classes setObject:[TL_userDeleted class] forKey:[NSNumber numberWithInt:-704549510]];
   [cs_classes setObject:[TL_chatFull_old29 class] forKey:[NSNumber numberWithInt:-891418735]];
   [cs_classes setObject:[TL_documentAttributeAudio_old31 class] forKey:[NSNumber numberWithInt:85215461]];
   [cs_classes setObject:[TL_photo_old31 class] forKey:[NSNumber numberWithInt:-1014792074]];
   [cs_classes setObject:[TL_audio_old29 class] forKey:[NSNumber numberWithInt:-945003370]];
   [cs_classes setObject:[TL_video_old29 class] forKey:[NSNumber numberWithInt:-291550643]];
   [cs_classes setObject:[TL_webPage_old34 class] forKey:[NSNumber numberWithInt:-1558273867]];
   [cs_classes setObject:[TL_chat_old34 class] forKey:[NSNumber numberWithInt:1855757255]];
   [cs_classes setObject:[TL_inputMediaUploadedVideo_old34 class] forKey:[NSNumber numberWithInt:-515910468]];
   [cs_classes setObject:[TL_inputMediaUploadedThumbVideo_old32 class] forKey:[NSNumber numberWithInt:-1761896484]];
   [cs_classes setObject:[TL_chatForbidden_old34 class] forKey:[NSNumber numberWithInt:-83047359]];
   [cs_classes setObject:[TL_chatParticipantsForbidden_old34 class] forKey:[NSNumber numberWithInt:265468810]];
   [cs_classes setObject:[TL_chatParticipants_old38 class] forKey:[NSNumber numberWithInt:2017571861]];
   [cs_classes setObject:[TL_chat_old38 class] forKey:[NSNumber numberWithInt:1930607688]];
   [cs_classes setObject:[TL_channelFull_old39 class] forKey:[NSNumber numberWithInt:-88925533]];
   [cs_classes setObject:[TL_chatParticipants_old39 class] forKey:[NSNumber numberWithInt:2017571861]];
   [cs_classes setObject:[TL_messageActionChatAddUser_old40 class] forKey:[NSNumber numberWithInt:1581055051]];
   [cs_classes setObject:[TL_contextBotSender class] forKey:[NSNumber numberWithInt:-19]];
   [cs_classes setObject:[TL_user_old43 class] forKey:[NSNumber numberWithInt:585404530]];
   [cs_classes setObject:[TL_channel_old43 class] forKey:[NSNumber numberWithInt:1737397639]];
   [cs_classes setObject:[TL_channelForbidden_old52 class] forKey:[NSNumber numberWithInt:763724588]];
   [cs_classes setObject:[TL_compressDocument class] forKey:[NSNumber numberWithInt:-20]];
   [cs_classes setObject:[TL_messageMediaDocument_old44 class] forKey:[NSNumber numberWithInt:802824708]];
   [cs_classes setObject:[TL_messageMediaBotResult class] forKey:[NSNumber numberWithInt:-21]];
   [cs_classes setObject:[TL_messageMediaAudio class] forKey:[NSNumber numberWithInt:-961117440]];
   [cs_classes setObject:[TL_audio class] forKey:[NSNumber numberWithInt:-102543275]];
   [cs_classes setObject:[TL_documentAttributeAudio_old45 class] forKey:[NSNumber numberWithInt:-556656416]];
   [cs_classes setObject:[TL_messageMediaVideo class] forKey:[NSNumber numberWithInt:1540298357]];
   [cs_classes setObject:[TL_video class] forKey:[NSNumber numberWithInt:-148338733]];
   [cs_classes setObject:[TL_peerNotifySettings_old47 class] forKey:[NSNumber numberWithInt:-1923214866]];
   [cs_classes setObject:[TL_channelFull_old48 class] forKey:[NSNumber numberWithInt:-1640751649]];
   [cs_classes setObject:[TL_channel_old48 class] forKey:[NSNumber numberWithInt:1260090630]];
   [cs_classes setObject:[TL_localMessageFwdHeader class] forKey:[NSNumber numberWithInt:-22]];
   [cs_classes setObject:[TL_documentAttributeLocalFile class] forKey:[NSNumber numberWithInt:-23]];
   [cs_classes setObject:[TL_document_old53 class] forKey:[NSNumber numberWithInt:-106717361]];
   [cs_classes setObject:[TL_config_old53 class] forKey:[NSNumber numberWithInt:-918482040]];
   [cs_classes setObject:[TL_photo_old55 class] forKey:[NSNumber numberWithInt:-840088834]];
   [cs_classes setObject:[TL_documentAttributeSticker_old55 class] forKey:[NSNumber numberWithInt:978674434]];
   [cs_classes setObject:[TL_webPage_old58 class] forKey:[NSNumber numberWithInt:-897446185]];
   [cs_classes setObject:[TL_proto_message class] forKey:[NSNumber numberWithInt:1538843921]];
   [cs_classes setObject:[TL_msg_container class] forKey:[NSNumber numberWithInt:1945237724]];
   [cs_classes setObject:[TL_req_pq class] forKey:[NSNumber numberWithInt:1615239032]];
   [cs_classes setObject:[TL_server_DH_inner_data class] forKey:[NSNumber numberWithInt:-1249309254]];
   [cs_classes setObject:[TL_p_q_inner_data class] forKey:[NSNumber numberWithInt:-2083955988]];
   [cs_classes setObject:[TL_req_DH_params class] forKey:[NSNumber numberWithInt:-686627650]];
   [cs_classes setObject:[TL_server_DH_params_fail class] forKey:[NSNumber numberWithInt:2043348061]];
   [cs_classes setObject:[TL_server_DH_params_ok class] forKey:[NSNumber numberWithInt:-790100132]];
   [cs_classes setObject:[TL_client_DH_inner_data class] forKey:[NSNumber numberWithInt:1715713620]];
   [cs_classes setObject:[TL_set_client_DH_params class] forKey:[NSNumber numberWithInt:-184262881]];
   [cs_classes setObject:[TL_dh_gen_ok class] forKey:[NSNumber numberWithInt:1003222836]];
   [cs_classes setObject:[TL_dh_gen_retry class] forKey:[NSNumber numberWithInt:1188831161]];
   [cs_classes setObject:[TL_dh_gen_fail class] forKey:[NSNumber numberWithInt:-1499615742]];
   [cs_classes setObject:[TL_ping class] forKey:[NSNumber numberWithInt:2059302892]];
   [cs_classes setObject:[TL_pong class] forKey:[NSNumber numberWithInt:880243653]];
   [cs_classes setObject:[TL_bad_msg_notification class] forKey:[NSNumber numberWithInt:-1477445615]];
   [cs_classes setObject:[TL_bad_server_salt class] forKey:[NSNumber numberWithInt:-307542917]];
   [cs_classes setObject:[TL_new_session_created class] forKey:[NSNumber numberWithInt:-1631450872]];
   [cs_classes setObject:[TL_rpc_result class] forKey:[NSNumber numberWithInt:-212046591]];
   [cs_classes setObject:[TL_rpc_error class] forKey:[NSNumber numberWithInt:558156313]];
   [cs_classes setObject:[TL_rsa_public_key class] forKey:[NSNumber numberWithInt:2048510838]];
   [cs_classes setObject:[TL_resPQ class] forKey:[NSNumber numberWithInt:85337187]];
   [cs_classes setObject:[TL_msgs_ack class] forKey:[NSNumber numberWithInt:1658238041]];
   [cs_classes setObject:[TL_rpc_drop_answer class] forKey:[NSNumber numberWithInt:1491380032]];
   [cs_classes setObject:[TL_rpc_answer_unknown class] forKey:[NSNumber numberWithInt:1579864942]];
   [cs_classes setObject:[TL_rpc_answer_dropped_running class] forKey:[NSNumber numberWithInt:-847714938]];
   [cs_classes setObject:[TL_rpc_answer_dropped class] forKey:[NSNumber numberWithInt:-1539647305]];
   [cs_classes setObject:[TL_get_future_salts class] forKey:[NSNumber numberWithInt:-1188971260]];
   [cs_classes setObject:[TL_future_salt class] forKey:[NSNumber numberWithInt:155834844]];
   [cs_classes setObject:[TL_future_salts class] forKey:[NSNumber numberWithInt:-1370486635]];
   [cs_classes setObject:[TL_destroy_session class] forKey:[NSNumber numberWithInt:-414113498]];
   [cs_classes setObject:[TL_destroy_session_ok class] forKey:[NSNumber numberWithInt:-501201412]];
   [cs_classes setObject:[TL_destroy_session_none class] forKey:[NSNumber numberWithInt:1658015945]];
   [cs_classes setObject:[TL_msg_copy class] forKey:[NSNumber numberWithInt:-530561358]];
   [cs_classes setObject:[TL_gzip_packed class] forKey:[NSNumber numberWithInt:812830625]];
   [cs_classes setObject:[TL_http_wait class] forKey:[NSNumber numberWithInt:-1835453025]];
   [cs_classes setObject:[TL_msgs_state_req class] forKey:[NSNumber numberWithInt:-630588590]];
   [cs_classes setObject:[TL_msgs_state_info class] forKey:[NSNumber numberWithInt:81704317]];
   [cs_classes setObject:[TL_msgs_all_info class] forKey:[NSNumber numberWithInt:-1933520591]];
   [cs_classes setObject:[TL_msg_detailed_info class] forKey:[NSNumber numberWithInt:661470918]];
   [cs_classes setObject:[TL_msg_new_detailed_info class] forKey:[NSNumber numberWithInt:-2137147681]];
   [cs_classes setObject:[TL_msg_resend_req class] forKey:[NSNumber numberWithInt:2105940488]];
                      
        [cs_classes setObject:[TL_invokeAfter class] forKey:[NSNumber numberWithInt:-878758099]];
                      
                      
                      
                      
        for(NSNumber* number in [cs_classes allKeys]) {
            [cs_constuctors setObject:number forKey:[cs_classes objectForKey:number]];
        }
                      
    });
        
}
    
@end
    
    

    
    