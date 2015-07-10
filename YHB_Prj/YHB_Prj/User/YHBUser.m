//
//  YHBUser.m
//  YHB_Prj
//
//  Created by yato_kami on 14/11/13.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import "YHBUser.h"
#import "SynthesizeSingleton.h"
#import "NetManager.h"
#import "YHBUserManager.h"
//#import "IChatManagerLogin.h"
//#import "EaseMob.h"
@interface YHBUser()<UIAlertViewDelegate>
@property (strong, nonatomic) NSString *userFilePath; //用户文件路径
//@property (strong, nonatomic) NSMutableDictionary *userInfoDic;//用户信息字典
@property (strong, nonatomic) YHBUserManager *userManger;
@property (strong, nonatomic) NSString *docPath;
@end

@implementation YHBUser
SYNTHESIZE_SINGLETON_FOR_CLASS(YHBUser);
#pragma mark - getter and setter

- (NSString *)docPath
{
    if (!_docPath) {
        NSArray *storeFilePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _docPath = storeFilePath[0];
    }
    return _docPath;
}

- (NSString *)localHeadUrl
{
    if (!_localHeadUrl) {
        
        NSString *path = [self.docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"head_%d.png",(self.userInfo ? (int)self.userInfo.userId : 0)]];
        _localHeadUrl = path;
    }
    return _localHeadUrl;
}

- (NSString *)localBannerUrl
{
    if (!_localBannerUrl) {
        NSString *path = [self.docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"banner_%d.png",(self.userInfo ? (int)self.userInfo.userId : 0)]];
        _localBannerUrl = path;
    }
    return _localBannerUrl;
}

- (YHBUserManager *)userManger
{
    if (!_userManger) {
        _userManger = [[YHBUserManager alloc] init];
    }
    return _userManger;
}

- (NSString *)userFilePath
{
    if (!_userFilePath) {
        _userFilePath = [self.docPath stringByAppendingPathComponent:@"user.plist"];
        //MLOG(@"%@",_userFilePath);
    }
    return _userFilePath;
}

- (id)init
{
    MLOG(@"%@",self.userFilePath);
    self = [super init];
    self.token = nil;
    _isLogin = NO;
    _userInfo = nil;
    _statusIsChanged = NO;
    [self loadLocalUserInfo]; //判断沙箱是否有数据，并修改数据
    return self;
}

//加载本地用户文件数据
- (void)loadLocalUserInfo
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.userFilePath]) {
        NSDictionary *userDic = [NSDictionary dictionaryWithContentsOfFile:self.userFilePath];
        NSString *token = userDic[@"token"];
        NSData *infoData = userDic[@"userInfo"];
        if (token.length>1) {
            self.token = token;
            _isLogin = YES;
            if (infoData) {
                ResultTUserInfo *info = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
                self.userInfo = info;
                [[NetManager shareInstance] setUserid:[NSString stringWithFormat:@"%d",(int)self.userInfo.userId]];
            }
            //刷新用户数据
            [self refreshUserInfoWithSuccess:nil failure:nil];
        }
    }
}

//刷新数据
- (void)refreshUserInfoWithSuccess:(void(^)())sBlock failure:(void(^)())fBlock
{
    __weak YHBUser *weakSelf = self;
    [self.userManger getUserInfoWithToken:self.token orUserId:nil action:nil Success:^(NSDictionary *dataDic) {
        //MLOG(@"%@",dataDic);
        weakSelf.userInfo = [ResultTUserInfo modelObjectWithDictionary:dataDic];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoGetMessage object:nil];
//        [self LoginEaseMobIfNeeded];
        if (sBlock) sBlock();
    } failure:^{
        if(fBlock) fBlock();
    }];
}

//获取用户信息并存入文件
- (void)loadUserInfoAndSaveWithUserDictionnary:(NSDictionary *)userDic
{
    MLOG(@"%@",userDic);
    self.userInfo = [ResultTUserInfo modelObjectWithDictionary:userDic];
    [self writeUserInfoToFile];
}

//登陆用户-传token 并自动获取用户信息
- (void)loginUserWithUserToken:(NSString *)token
{
    self.token = token;
    _isLogin = YES;
    [self refreshUserInfoWithSuccess:^{
        [self writeUserInfoToFile];
    } failure:nil];
    [self writeUserInfoToFile];
}

//退出登录
- (void)logoutUser
{
    _isLogin = NO;
    _token = @"";
    _localBannerUrl = nil;
    _localHeadUrl = nil;
    [self writeUserInfoToFile];
//    [[EaseMob sharedInstance].chatManager asyncLogoff];
    
}

//保存用户信息文件至沙箱
- (void)writeUserInfoToFile
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    MLOG(@"写入了用户信息--------------------token = '%@'",self.token);
    [dic setObject:self.token?:@"" forKey:@"token"];
    
    if (self.userInfo.userId ) {
        NSData *info = [NSKeyedArchiver archivedDataWithRootObject:self.userInfo];
        [dic setObject:info forKey:@"userInfo"];
    }
    [dic writeToFile:self.userFilePath atomically:YES];
    //MLOG(@"%@",self.userFilePath);
}

//#pragma mark - 全局异常result  时的alertview回调方法
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if ([alertView.title isEqualToString:@"APP维护中"]) {
//        NSMutableArray *ary = [NSMutableArray array];
//        [ary addObject:nil];
//    }
//    if (buttonIndex == 1) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginForUserMessage object:[NSNumber numberWithBool:NO]];
//    }
//}

//#pragma mark - 环信相关
//- (void)LoginEaseMobIfNeeded
//{
//    if (self.userInfo && ![[EaseMob sharedInstance].chatManager isLoggedIn]) {
//        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%d",(int)self.userInfo.userid] password:self.userInfo.empass completion:^(NSDictionary *loginInfo, EMError *error) {
//            if (!error && loginInfo) {
//                MLOG(@"登陆环信成功");
//            }else{
//                MLOG(@"登陆失败 %@",error);
//            }
//        } onQueue:nil];
//    }
//}

@end
