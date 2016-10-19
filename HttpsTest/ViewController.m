//
//  ViewController.m
//  HttpsTest
//
//  Created by Murphy Zheng on 16/8/17.
//  Copyright © 2016年 Mieasy. All rights reserved.
//  本文

#import "ViewController.h"
#import "NSString+MEJSON.h"


@interface ViewController ()<NSURLConnectionDelegate>
@property(nonatomic,strong)NSMutableData * mData;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDataWithURLRequest];
//    [self post];
}


#pragma mark  -－－－－－－－－－－－－－－－－－－－－－－－－－-

- (void)getDataWithURLRequest {
    //connect
    NSString *urlStr = @"https://192.168.8.100:8443/smr/user/testfind";//请替换你需要访问的URL
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
}


-(void)post
{
    //对请求路径的说明
    //http://120.25.226.186:32812/login
    //协议头+主机地址+接口名称
    //协议头(http://)+主机地址(120.25.226.186:32812)+接口名称(login)
    //POST请求需要修改请求方法为POST，并把参数转换为二进制数据设置为请求体
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"https://192.168.8.100:8443/smr/user/testUpdate"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    
    //5.设置请求体
    request.HTTPBody = [@"username=520it&pwd=520it&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     26      第一个参数：请求对象
     27      第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     28                 data：响应体信息（期望的数据）
     29                 response：响应头信息，主要是对服务器端的描述
     30                 error：错误信息，如果请求失败，则error有值
     31      */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //8.解析数据
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@",dict);
        
    }];
    
    //7.执行任务
    [dataTask resume];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    /*
     
    //直接验证服务器是否被认证（serverTrust），这种方式直接忽略证书验证，信任该connect
    SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
    return [[challenge sender] useCredential: [NSURLCredential credentialForTrust: serverTrust]
                  forAuthenticationChallenge: challenge];
     
     */
    
    if ([[[challenge protectionSpace] authenticationMethod] isEqualToString: NSURLAuthenticationMethodServerTrust]) {
        do
        {
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            NSCAssert(serverTrust != nil, @"serverTrust is nil");
            if(nil == serverTrust)
                break; /* failed */
            /**
             *  导入多张CA证书（Certification Authority，支持SSL证书以及自签名的CA），请替换掉你的证书名称
             */
//            NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"Unknown" ofType:@"cer"];//自签名证书
//            NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
            
            NSString *cerPath2 = [[NSBundle mainBundle] pathForResource:@"192.168.8.100" ofType:@"cer"];//SSL证书
            NSData * caCert2 = [NSData dataWithContentsOfFile:cerPath2];
            
//            NSCAssert(caCert != nil, @"caCert is nil");
//            if(nil == caCert)
//                break; /* failed */
            
            NSCAssert(caCert2 != nil, @"caCert2 is nil");
            if (nil == caCert2) {
                break;
            }
            
//            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
//            NSCAssert(caRef != nil, @"caRef is nil");
//            if(nil == caRef)
//                break; /* failed */
            
            SecCertificateRef caRef2 = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert2);
            NSCAssert(caRef2 != nil, @"caRef2 is nil");
            if(nil == caRef2)
                break; /* failed */
            
            NSArray *caArray = @[(__bridge id)(caRef2)];
        
            NSCAssert(caArray != nil, @"caArray is nil");
            if(nil == caArray)
                break; /* failed */
            
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            if(!(errSecSuccess == status))
                break; /* failed */
            
            SecTrustResultType result = -1;
            status = SecTrustEvaluate(serverTrust, &result);
            if(!(errSecSuccess == status))
                break; /* failed */
            NSLog(@"stutas:%d",(int)status);
            NSLog(@"Result: %d", result);
            
            BOOL allowConnect = (result == kSecTrustResultUnspecified) || (result == kSecTrustResultProceed);
            if (allowConnect) {
                NSLog(@"success");
            }else {
                NSLog(@"error");
            }
            /* https://developer.apple.com/library/ios/technotes/tn2232/_index.html */
            /* https://developer.apple.com/library/mac/qa/qa1360/_index.html */
            /* kSecTrustResultUnspecified and kSecTrustResultProceed are success */
            if(! allowConnect)
            {
            break; /* failed */
            }
            
#if 0
            /* Treat kSecTrustResultConfirm and kSecTrustResultRecoverableTrustFailure as success */
            /*   since the user will likely tap-through to see the dancing bunnies */
            if(result == kSecTrustResultDeny || result == kSecTrustResultFatalTrustFailure || result == kSecTrustResultOtherError)
                break; /* failed to trust cert (good in this case) */
#endif
            
            // The only good exit point
            NSLog(@"信任该证书");
            return [[challenge sender] useCredential: [NSURLCredential credentialForTrust: serverTrust]
                          forAuthenticationChallenge: challenge];
            
        }
        while(0);
    }
    
    // Bad dog
    return [[challenge sender] cancelAuthenticationChallenge: challenge];
    
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

#pragma mark -- connect的异步代理方法
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSLog(@"请求被响应");
    _mData = [[NSMutableData alloc]init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data {
    NSLog(@"开始返回数据片段");
    
    [_mData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"链接完成");
    //可以在此解析数据
    NSString *receiveInfo = [NSJSONSerialization JSONObjectWithData:self.mData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"received data:\n%@",[[ NSString alloc] initWithData:self.mData encoding:NSUTF8StringEncoding]);
    NSLog(@"received info:\n%@",receiveInfo);
}

//链接出错
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"error - %@",error);
}

@end
