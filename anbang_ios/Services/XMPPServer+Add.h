//
//  XMPPServer+Add.h
//  anbang_ios
//
//  Created by silenceSky  on 14-3-15.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "XMPPServer.h"

@interface XMPPServer (Add)

+(XMPPStream *)xmppStream;

+(XMPPReconnect *)xmppReconnect;

+(XMPPRoster *)xmppRoster;

+(XMPPRosterCoreDataStorage *)xmppRosterStorage;

+(XMPPvCardTempModule *)xmppvCardTempModule;

+(XMPPvCardAvatarModule *)xmppvCardAvatarModule;

+(XMPPCapabilities *)xmppCapabilities;

+(XMPPCapabilitiesCoreDataStorage *)xmppCapabilitiesStorage;

@end
