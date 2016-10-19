//
//  PutViewController.m
//  HttpsTest
//
//  Created by 万浩 on 16/10/19.
//  Copyright © 2016年 Mieasy. All rights reserved.
//

#import "PutViewController.h"
#import "AFNetworking.h"

@interface PutViewController ()

@end

@implementation PutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getData];
    // Do any additional setup after loading the view.
}

- (void)getData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
        
    }];
    
    [manager PUT:@"https://192.168.8.100:8443/smr/user/testUpdate" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
