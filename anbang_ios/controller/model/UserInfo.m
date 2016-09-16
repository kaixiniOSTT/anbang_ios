//
//  UserInfo.m
//  anbang_ios
//
//  Created by silenceSky  on 14-6-19.
//  Copyright (c) 2014年 ch. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo
@synthesize jid,nickName,phone,avatar,name,userName,accountType,employeeName,employeeCode,bookName,agencyName,branchName,centerName,accountName,gender,areaId,inviteUrl,email,emailActivate,secondEmail,secondEmailActivate,soure, addTime;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.accountType = [[aDecoder decodeObjectForKey:@"accountType"] intValue];
        self.employeeName = [aDecoder decodeObjectForKey:@"employeeName"];
        self.employeeCode = [aDecoder decodeObjectForKey:@"employeeCode"];
        self.myGender = [[aDecoder decodeObjectForKey:@"gender"] intValue];
        self.accountName = [aDecoder decodeObjectForKey:@"accountName"];
        self.inviteUrl = [aDecoder decodeObjectForKey:@"inviteUrl"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.emailActivate = [aDecoder decodeObjectForKey:@"emailActivate"];
        self.secondEmail = [aDecoder decodeObjectForKey:@"secondEmail"];
        self.secondEmailActivate = [aDecoder decodeObjectForKey:@"secondEmailActivate"];
        
        self.areaId = [aDecoder decodeObjectForKey:@"areaId"];
        self.bookName = [aDecoder decodeObjectForKey:@"bookName"];
        self.agencyName = [aDecoder decodeObjectForKey:@"agencyName"];
        self.branchName = [aDecoder decodeObjectForKey:@"branchName"];
        self.departmentName = [aDecoder decodeObjectForKey:@"departmentName"];
        self.signature = [aDecoder decodeObjectForKey:@"signature"];
        self.employeePhone = [aDecoder decodeObjectForKey:@"employeePhone"];
        self.officalPhone = [aDecoder decodeObjectForKey:@"officalPhone"];
        self.publicPhone = [aDecoder decodeObjectForKey:@"publicPhone"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.accountType] forKey:@"accountType"];
    [aCoder encodeObject:self.employeeName forKey:@"employeeName"];
    [aCoder encodeObject:self.employeeCode forKey:@"employeeCode"];
    [aCoder encodeObject:[NSNumber numberWithInt:self.myGender] forKey:@"gender"];
    [aCoder encodeObject:self.accountName forKey:@"accountName"];
    [aCoder encodeObject:self.inviteUrl forKey:@"inviteUrl"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.emailActivate forKey:@"emailActivate"];
    [aCoder encodeObject:self.secondEmail forKey:@"secondEmail"];
    [aCoder encodeObject:self.secondEmailActivate forKey:@"secondEmailActivate"];
    
    [aCoder encodeObject:self.areaId forKey:@"areaId"];
    [aCoder encodeObject:self.bookName forKey:@"bookName"];
    [aCoder encodeObject:self.agencyName forKey:@"agencyName"];
    [aCoder encodeObject:self.branchName forKey:@"branchName"];
    [aCoder encodeObject:self.departmentName forKey:@"departmentName"];
    [aCoder encodeObject:self.signature forKey:@"signature"];
    [aCoder encodeObject:self.employeePhone forKey:@"employeePhone"];
    [aCoder encodeObject:self.officalPhone forKey:@"officalPhone"];
    [aCoder encodeObject:self.publicPhone forKey:@"publicPhone"];
}

+ (NSString *)filePath {
    
    NSString *docDir =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    JLLog_I(@"<filePath=%@>", docDir);
    return [docDir stringByAppendingPathComponent:@"mask.mask"];
}

+ (UserInfo *)loadArchive {
    
    UserInfo *userInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    if (!userInfo) {
        userInfo = [[UserInfo alloc] init];
    }
    
    return userInfo;
}

- (void)save {
    
    [NSKeyedArchiver archiveRootObject:self toFile:[UserInfo filePath]];
}

+ (void)clearCache {
    
    UserInfo *userInfo = [[UserInfo alloc] init];
    [userInfo save];
}

- (NSString *)description {
    
    NSMutableString *desc = [NSMutableString string];
    
    [desc appendFormat:@"\n\nname:%@\n", self.name];
    [desc appendFormat:@"nickName:%@\n", self.nickName];
    [desc appendFormat:@"userName:%@\n", self.userName];
    [desc appendFormat:@"phone:%@\n", self.phone];
    [desc appendFormat:@"avatar:%@\n", self.avatar];
    [desc appendFormat:@"accountType:%d\n", self.accountType];
    [desc appendFormat:@"employeeName:%@\n", self.employeeName];
    [desc appendFormat:@"employeeCode:%@\n", self.employeeCode];
    [desc appendFormat:@"branchName:%@\n", self.branchName];
    [desc appendFormat:@"gender:%d\n", self.myGender];
    [desc appendFormat:@"accountName:%@\n", self.accountName];
    [desc appendFormat:@"inviteUrl:%@\n", self.inviteUrl];
    [desc appendFormat:@"email:%@\n", self.email];
    [desc appendFormat:@"emailActivate:%@\n", self.emailActivate];
    [desc appendFormat:@"secondEmail:%@\n", self.secondEmail];
    [desc appendFormat:@"secondEmailActivate:%@\n", self.secondEmailActivate];
    [desc appendFormat:@"signature:%@\n", self.signature];
    [desc appendFormat:@"employeePhone:%@\n", self.employeePhone];
    [desc appendFormat:@"officalPhone:%@\n", self.officalPhone];
    [desc appendFormat:@"publicPhone:%@\n\n", self.publicPhone];
    
    return [NSString stringWithFormat:@"<class=%@, userinfo=%p> {%@}", [self class], self, desc];
}


-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end
