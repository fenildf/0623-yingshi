//
//  YYDataService.m
//  YHB_Prj
//
//  Created by Johnny's on 15/7/10.
//  Copyright (c) 2015年 striveliu. All rights reserved.
//

#import "YYDataService.h"

@implementation YYDataService

+ (YYDataService *)sharedYYDataSevice
{
    static YYDataService *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
    });
    return sharedAccountManagerInstance;
}

- (void)saveTUser:(YYTUser *)aTUser
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aTUser];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:data forKey:@"TUser"];
}

- (void)saveTUserInfo:(YYTUserInfo *)aTUserInfo
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aTUserInfo];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:data forKey:@"TUserInfo"];
}

- (YYTUser *)getTUser
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [user objectForKey:@"TUser"];
    YYTUser *TUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return TUser;
}

- (YYTUserInfo *)getTUserInfo
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [user objectForKey:@"TUserInfo"];
    YYTUserInfo *TUserInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return TUserInfo;
}

- (void)clearUserInfo
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:@"TUserInfo"];
    [defaults removeObjectForKey:@"TUser"];
    
    [defaults synchronize];
}

@end
