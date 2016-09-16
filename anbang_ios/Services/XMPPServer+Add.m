//
//  XMPPServer+Add.m
//  anbang_ios
//
//  Created by silenceSky  on 14-3-15.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "XMPPServer+Add.h"

@implementation XMPPServer (Add)

+(XMPPStream *)xmppStream{
    return [self sharedServer].xmppStream;
}

+(XMPPReconnect *)xmppReconnect{
    return [self sharedServer].xmppReconnect;
}

+(XMPPRoster *)xmppRoster{
    return [self sharedServer].xmppRoster;
}

+(XMPPRosterCoreDataStorage *)xmppRosterStorage{
    return [self sharedServer].xmppRosterStorage;
}

+(XMPPvCardTempModule *)xmppvCardTempModule{
    return [self sharedServer].xmppvCardTempModule;
}

+(XMPPvCardAvatarModule *)xmppvCardAvatarModule{
    return [self sharedServer].xmppvCardAvatarModule;
}

+(XMPPCapabilities *)xmppCapabilities{
    return [self sharedServer].xmppCapabilities;
}

+(XMPPCapabilitiesCoreDataStorage *)xmppCapabilitiesStorage{
    return [self sharedServer].xmppCapabilitiesStorage;
}

@end
