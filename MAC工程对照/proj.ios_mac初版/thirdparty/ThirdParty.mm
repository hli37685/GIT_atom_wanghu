//
//  ThirdParty.cpp
//  GloryProject
//
//  Created by zhong on 16/9/8.
//
//

#import "ThirdParty.h"

#import "AppController.h"
#import "RootViewController.h"

//友盟
#import "UMSocialWechatHandler.h"


//bugly
#import "BuglyAgent.h"
#import <Bugly/Bugly.h>


#include "cocos2d.h"
#include "json/document.h"
#include "json/stringbuffer.h"
#include "json/writer.h"


#include <network/HttpRequest.h>
#include <network/HttpClient.h>



@implementation ThirdParty
static ThirdParty* s_instance = nil;
+ (ThirdParty*) getInstance
{
    if (nil == s_instance)
    {
        s_instance = [ThirdParty alloc];
        [s_instance defaultInit];
    }
    return s_instance;
}

+ (void) destroy
{
    if (nil != s_instance)
    {
        [s_instance->_platformArray release];
        [s_instance->_umDict release];
        [s_instance->_umSharePlat release];
        [s_instance->_share release];
        [s_instance->_wechat release];

        
        [s_instance release];
    }
}
@synthesize shareDelegate = _shareDelegate;

#pragma mark UMSocial
-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if (nil == _shareDelegate)
    {
        return;
    }
    
    if (response.responseCode == UMSResponseCodeCancel)
    {
        [_shareDelegate onCancel:INVALIDPLAT];
    }
    else if (response.responseCode == UMSResponseCodeSuccess)
    {
        [_shareDelegate onComplete:INVALIDPLAT backCode:response.responseCode backMsg:response.message];
    }
    else
    {
        [_shareDelegate onError:INVALIDPLAT backMsg:response.message];
    }
    [self setShareDelegate:nil];
}
#pragma mark -

#pragma mark -
#pragma mark WXApiDelegate

-(void) onReq:(BaseReq*)req
{
    
}
-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[PayResp class]])
    {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        //NSString *strMsg,*strTitle = [NSString stringWithFormat:@"充值结果"];
        
        switch (resp.errCode)
        {
            case WXSuccess:
                NSLog(@"充值成功");
                [self onPayResult:TRUE msg:@""];
                break;
                
            default:
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                [self onPayResult:FALSE msg:resp.errStr];
                break;
        }
    }
}
#pragma mark -

//应用打开成功
- (void)thirdAppOpenSucceed;
{
    
}

//应用打开失败
- (void)thirdAppOpenFailure
{
    if (nil != _payDelegate)
    {
        [_payDelegate onPayNotify:@"" backMsg:@"第三方应用打开失败"];
    }
}

//pcsoama
- (void)openWebSuccessed
{
    
}

- (void)openWebFailer:(NSString *)failer
{
    if (nil != _payDelegate)
    {
        [_payDelegate onPayNotify:@"" backMsg:failer];
    }
}
#pragma mark -

- (void) defaultInit
{
    //bugly
    [BuglyAgent class];
    [Bugly sdkVersion];
    
    _shareDelegate = nil;
    _payDelegate = nil;
    _payPlat = INVALIDPLAT;
    
    //配置第三方平台
    _platformArray = [NSMutableArray arrayWithCapacity:20];
    [_platformArray insertObject:WECHAT atIndex:0];
    [_platformArray insertObject:WECHAT_CIRCLE atIndex:1];
    [_platformArray insertObject:ALIPAY atIndex:2];
    [_platformArray insertObject:JFT atIndex:3];
    [_platformArray insertObject:AMAP atIndex:4];
    [_platformArray insertObject:IOSIAP atIndex:5];
    [_platformArray insertObject:SMS atIndex:6];
    [_platformArray retain];
    
    //配置友盟平台
    _umDict = [NSDictionary dictionaryWithObjectsAndKeys:
               UMShareToWechatSession, WECHAT,
               UMShareToWechatTimeline, WECHAT_CIRCLE,
               UMShareToSms, SMS,
               nil];
    [_umDict retain];
    
    //友盟分享平台
    _umSharePlat = [NSArray arrayWithObjects:UMShareToWechatSession, UMShareToWechatTimeline, nil];
    [_umSharePlat retain];
    
    _share = [ShareConfig alloc];
    [_share retain];
    _wechat = [WeChatConfig alloc];
    [_wechat retain];

    
    _locationDelegate = nil;
    m_bConfigAmap = FALSE;
}

- (NSString*) getPlatform:(int)nidx
{
    if(nidx > [_platformArray count])
    {
        return INVALIDPLAT;
    }
    return [_platformArray objectAtIndex:nidx];
}

- (ShareConfig*) getDefaultShareConfig
{
    return _share;
}

- (BOOL) openURL:(NSURL *)url
{
    BOOL bRes;
   // BOOL bRes = [UMSocialSnsService handleOpenURL:url];
    //if (FALSE == bRes)
    //{
        NSString *pstr = [[NSString alloc] initWithFormat:@"%@://pay", _wechat.WeChatAppID];
        if ([[url absoluteString] rangeOfString:pstr].location == 0)
        {
            bRes = [WXApi handleOpenURL:url delegate:self];
        }else if([url.host isEqualToString:@"safepay"])
        {

            
        
        }else
        {
            bRes = [UMSocialSnsService handleOpenURL:url];
        }
    
    
 //   [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
     //   NSLog(@"result = %@",resultDic);
   //     [[NSNotificationCenter defaultCenter]postNotificationName:k_Noti_transeAlipayCallBackResault object:resultDic];
   // }];
    //}
    return bRes;
}

- (void) willEnterForegound
{

}

- (void) configThirdParty:(NSString*)plat platConfig:(NSDictionary*)config
{
    BOOL bRes = FALSE;
    if ([plat isEqualToString:WECHAT])
    {
        [_wechat setWeChatAppID:[config objectForKey:@"AppID"]];
        bRes = (_wechat.WeChatAppID != nil);
        [_wechat setWeChatAppSecret:[config objectForKey:@"AppSecret"]];
        bRes = (_wechat.WeChatAppSecret != nil);
        [_wechat setWeChatPartnerID:[config objectForKey:@"PartnerID"]];
        bRes = (_wechat.WeChatPartnerID != nil);
        [_wechat setWeChatPayKey:[config objectForKey:@"PayKey"]];
        bRes = (_wechat.WeChatPayKey != nil);
        [_wechat setWeChatURL:[config objectForKey:@"URL"]];
        bRes = (_wechat.WeChatURL != nil);
        [_wechat setConfiged:bRes];
        
        if (TRUE == _wechat.Configed)
        {
            [UMSocialWechatHandler setWXAppId:_wechat.WeChatAppID appSecret:_wechat.WeChatAppSecret url:_wechat.WeChatURL];
        }
    }
 }

- (void) configSocialShare:(NSDictionary *)config
{
    BOOL bConfiged = FALSE;
    [_share setShareTitle:[config objectForKey:@"title"]];
    bConfiged = (_share.ShareTitle != nil);
    [_share setShareContent:[config objectForKey:@"content"]];
    bConfiged = (_share.ShareContent != nil);
    [_share setShareUrl:[config objectForKey:@"url"]];
    bConfiged = (_share.ShareUrl != nil);
    [_share setAppKey:[config objectForKey:@"AppKey"]];
    bConfiged = (_share.AppKey != nil);
    [_share setConfiged:bConfiged];
    
    if (_share.Configed)
    {
        [UMSocialData setAppKey:_share.AppKey];
        [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
    }
}

- (void) thirdPartyLogin:(NSString*)plat delegate:(id<LoginDelegate>) delegate
{
    //判断友盟平台
    NSString *platstr = [_umDict objectForKey:plat];
    if (nil != platstr)
    {
        //判断是否配置
        if (FALSE == _wechat.Configed || FALSE == _share.Configed)
        {
            [delegate onLoginFail:platstr backMsg:@"did not config platform"];
            return;
        }
        
        //判断是否安装微信
        if (FALSE == [WXApi isWXAppInstalled])
        {
            [delegate onLoginFail:platstr backMsg:@"微信客户端未安装,无法进行授权登陆!"];
            return;
        }
        
        //是否授权(微信暂时需要重新授权)
        if ([UMSocialAccountManager isOauthWithPlatform:platstr] && FALSE == [WECHAT isEqualToString:plat])
        {
            [self getAuthorizedUserInfo:platstr delegate:delegate];
            return;
        }
        
        UMSocialSnsPlatform *snsplat = nil;
        //微信登陆
        if ([WECHAT isEqualToString:plat])
        {
            snsplat = [UMSocialSnsPlatformManager getSocialPlatformWithName:platstr];
        }
        
        //账户信息
        if (nil != snsplat)
        {
            AppController *pApp = (AppController*)[[UIApplication sharedApplication] delegate];
            [UMSocialConfig setSupportedInterfaceOrientations:UIInterfaceOrientationMaskAll];
            snsplat.loginClickHandler(pApp->viewController, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response)
                                      {
                                          [self parseAuthorizeData:platstr response:response delegate:delegate];
                                      });
        }
    }
    else
    {
        [delegate onLoginSuccess:INVALIDPLAT backMsg:@""];
    }
}

- (void) getAuthorizedUserInfo:(NSString *)platstr delegate:(id<LoginDelegate>) delegate
{
    [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *response)
     {
         [self parseAuthorizeData:platstr response:response delegate:delegate];
     }];
}

- (void) parseAuthorizeData:(NSString *)platstr response:(UMSocialResponseEntity *)response delegate:(id<LoginDelegate>) delegate
{
    if (response.responseCode == UMSResponseCodeSuccess)
    {
        //添加同安卓一致信息
        [response.thirdPlatformUserProfile setValue:[response.thirdPlatformUserProfile objectForKey:@"nickname"] forKey:@"screen_name"];
        [response.thirdPlatformUserProfile setValue:[response.thirdPlatformUserProfile objectForKey:@"headimgurl"] forKey:@"profile_image_url"];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response.thirdPlatformUserProfile
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (nil != jsonData)
        {
            NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //NSLog(@"json : %@",jsonString);
            [delegate onLoginSuccess:platstr backMsg:jsonString];
            [jsonString release];
        }
        else
        {
            NSLog(@"to json error:%@", error);
            [delegate onLoginFail:platstr backMsg:@""];
        }
    }
    else if(response.responseCode == UMSResponseCodeCancel)
    {
        [delegate onLoginCancel:platstr backMsg:@""];
    }
    else
    {
        [delegate onLoginFail:platstr backMsg:@""];
    }
}

- (void) openShare:(id<ShareDelegate>)delegate share:(tagShareParam)param
{
    [self setShareDelegate:delegate];
    AppController *pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    
    if (TRUE == param.bImageOnly)
    {
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    }
    else
    {
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
        [UMSocialWechatHandler setWXAppId:_wechat.WeChatAppID appSecret:_wechat.WeChatAppSecret url: param.sTargetURL];
    }
    [UMSocialData defaultData].extConfig.wechatSessionData.title = param.sTitle;
    
    [UMSocialSnsService presentSnsIconSheetView:pApp->viewController
                                         appKey:_share.AppKey
                                      shareText:param.sContent
                                     shareImage:[self getShareImage:param]
                                shareToSnsNames:[NSArray arrayWithArray:_umSharePlat]
                                       delegate:self];
}

- (void) targetShare:(id<ShareDelegate>)delegate share:(tagShareParam)param
{
    NSString *plat = [self getPlatform:param.nTarget];
    NSString *platstr = [_umDict objectForKey:plat];    
    [self setShareDelegate:delegate];
    AppController *pApp = (AppController*)[[UIApplication sharedApplication] delegate];
    
    if (TRUE == param.bImageOnly)
    {
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    }
    else
    {
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
        [UMSocialWechatHandler setWXAppId:_wechat.WeChatAppID appSecret:_wechat.WeChatAppSecret url: param.sTargetURL];
    }
    [UMSocialData defaultData].extConfig.wechatSessionData.title = param.sTitle;
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[platstr]
                                                       content:param.sContent
                                                         image:[self getShareImage:param]
                                                      location:nil
                                                   urlResource:nil
                                           presentedController:pApp->viewController
                                                    completion:^(UMSocialResponseEntity *response)
     {
         if (response.responseCode == UMSResponseCodeCancel)
         {
             [_shareDelegate onCancel:INVALIDPLAT];
         }
         else if (response.responseCode == UMSResponseCodeSuccess)
         {
             [_shareDelegate onComplete:INVALIDPLAT backCode:response.responseCode backMsg:response.message];
         }
         else
         {
             [_shareDelegate onError:INVALIDPLAT backMsg:response.message];
         }
         [self setShareDelegate:nil];
     }];
}

- (id) getShareImage:(tagShareParam)param
{
    id image = nil;
    NSString *imageString = param.sMedia;
    if ([imageString hasPrefix:@"http://"] || [imageString hasPrefix:@"https://"])
    {
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageString];
    }
    else
    {
        if (FALSE == [param.sMedia isEqualToString:@""])
        {
            NSString *imageString = param.sMedia;
            if ([imageString.lowercaseString hasSuffix:@".gif"])
            {
                NSString *path = [[NSBundle mainBundle] pathForResource:[[imageString componentsSeparatedByString:@"."] objectAtIndex:0]
                                                                 ofType:@"gif"];
                image = [NSData dataWithContentsOfFile:path];
            }
            else if ([imageString rangeOfString:@"/"].length > 0)
            {
                image = [NSData dataWithContentsOfFile:imageString];
            }
            else
            {
                image = [UIImage imageNamed:imageString];
            }
            [UMSocialData defaultData].urlResource.resourceType = UMSocialUrlResourceTypeDefault;
        }
        else
        {
            image = [UIImage imageNamed:@"Icon-72.png"];
        }
    }
    return image;
}

- (void) thirdPartyPay:(NSString *)plat delegate:(id<PayDelegate>)delegate payparam:(NSDictionary *)payparam
{
    
    _payPlat = plat;
    [self setPayDelegate:delegate];
    
    if ([WECHAT isEqualToString:plat])
    {
        [self doWeChatPay:[payparam objectForKey:@"info"]];
    }
    else if ([IOSIAP isEqualToString:plat])
    {
        [self doIapPay:payparam];
    }
}

- (void) getPayList:(NSString *)token delegate:(id<PayDelegate>)delegate
{

}

- (BOOL) isPlatformInstalled:(NSString *)plat
{
    if ([WECHAT isEqualToString:plat])
    {
        return [WXApi isWXAppInstalled];
    }
    else if ([ALIPAY isEqualToString:plat])
    {
        NSURL *alipayUrl = [NSURL URLWithString:@"alipay:"];
        return [[UIApplication sharedApplication] canOpenURL:alipayUrl];
    }
    return FALSE;
}

- (void) requestLocation:(id<LocationDelegate>)delegate
{
    [self setLocationDelegate:delegate];

}

- (NSString*) metersBetweenLocation:(NSDictionary *)loParam
{
    return nullptr;
}

#pragma mark -
- (void) doWeChatPay:(NSString*) infostr
{

}
    //ethj  支付宝充值
  - (void) doAliPay:(tagPayParam) param
{
    
   
}

- (void) doJftPay:(NSDictionary *)payparam
{
    
}

- (void) doIapPay:(NSDictionary *)payparam
{
    NSString *nsUrl = [payparam objectForKey:@"http_url"];
    if (nil == nsUrl)
    {
        [self onPayResult:FALSE msg:@"URL为空"];
        return;
    }
    std::string url = [nsUrl UTF8String];
    int dwudi = [[payparam objectForKey:@"uid"] intValue];
    NSString *nsProduct = [payparam objectForKey:@"productid"];
    if (nil == nsProduct)
    {
        [self onPayResult:FALSE msg:@"产品ID为空"];
        return;
    }
    std::string productid = [nsProduct UTF8String];
    float price = [[payparam objectForKey:@"price"] floatValue];
    m_iosiap.requestProducts(productid, [self,price](IOSProduct *product, int code)
                             {
                                 if (IAP_REQUEST_SUCCESS == code)
                                 {
                                     m_iosiap.requestPayment(1, price, [self](bool succeed, std::string &identifier, int quantity)
                                                             {
                                                                 if (false == succeed)
                                                                 {
                                                                     [self onPayResult:FALSE msg:@""];
                                                                 }
                                                                 else
                                                                 {
                                                                     [self onPayResult:TRUE msg:@""];
                                                                 }
                                                             });
                                 }
                             }, url, dwudi);
}

- (void) onPayResult:(BOOL)res msg:(NSString*)msg
{
    if (nil != _payDelegate)
    {
        if (TRUE == res)
        {
            [_payDelegate onPaySuccess:_payPlat backMsg:msg];
        }
        else
        {
            [_payDelegate onPayFail:_payPlat backMsg:msg];
        }
    }
    [self setPayDelegate:nil];
}
@end

