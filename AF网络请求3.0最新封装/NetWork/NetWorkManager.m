//
//  NetWorkManager.m
//  AF网络请求3.0最新封装
//
//  Created by admin on 16/7/20.
//  Copyright © 2016年 LZZ. All rights reserved.
//

//请求超时时间

#import "NetWorkManager.h"
#define TIMEOUT 10
#define KLog(...) NSLog(__VA_ARGS__)

@interface LZUploadParam : NSObject
@property (nonatomic, strong) NSData *data;//二进制数据
@property (nonatomic, copy) NSString *name;//名称
@property (nonatomic, copy) NSString *fileName;//文件名称
@property (nonatomic, copy) NSString *mimeType;//文件类型(e.g image/jpeg video/mp4)
@property (nonatomic, copy) NSString *filePath;//文件地址
@end
@implementation LZUploadParam
@end

@implementation NetWorkManager
+(NetWorkManager *)sharedManager{
    static NetWorkManager *sharedNetworkSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate,^{
        sharedNetworkSingleton = [[self alloc] init];
    });
    return sharedNetworkSingleton;
}
-(AFHTTPSessionManager *)baseHtppRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //header 设置
    [manager.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appversion"];
    //设置返回格式
    AFJSONResponseSerializer *jsonRes = [AFJSONResponseSerializer serializer];
    jsonRes.removesKeysWithNullValues=YES;
    manager.responseSerializer = jsonRes;
    //超时时间
    [manager.requestSerializer setTimeoutInterval:TIMEOUT];
    
    return manager;
}
#pragma mark - GET
-(void)getResultWithParameter:(NSDictionary *)parameter url:(NSString *)url  progress:(ProgressBlock)progressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
     KLog(@"请求地址:\n%@\n参数:%@",url,parameter);
    
    AFHTTPSessionManager *manager  =[self baseHtppRequest];
    [manager GET:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    KLog(@"返回结果:\n%@",[[self class] logDic:responseObject]);
        if (successBlock) {
            successBlock(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KLog(@"%@\n返回结果:%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
        if (failureBlock) {
            failureBlock(task,error);
        }
    }];
}
+(void)get:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    [[[self class] sharedManager] getResultWithParameter:parameter url:url progress:nil successBlock:successBlock failureBlock:failureBlock];
}
#pragma mark - POST
+(void)post:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    [[[self class] sharedManager] postResultWithParameter:parameter url:url progress:nil successBlock:successBlock failureBlock:failureBlock];
}

-(void)postResultWithParameter:(NSDictionary *)parameter url:(NSString *)url  progress:(ProgressBlock)progressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    KLog(@"请求地址:\n%@\n参数:%@",url,parameter);
    AFHTTPSessionManager *manager  =[self baseHtppRequest];
    [manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         KLog(@"返回结果:\n%@", [[self class] logDic:responseObject]);
        if (successBlock) {
            successBlock(task,responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          KLog(@"%@\n返回结果:%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
  
        if (failureBlock) {
            failureBlock(task,error);
        }
    }];
}
#pragma mark upLoad上传
-(void)upLoadFileWithModel:(LZUploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
   successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
   AFHTTPSessionManager *manager = [self baseHtppRequest];
    [manager POST:urlStr parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:uploadModel.filePath] name:uploadModel.name fileName:uploadModel.fileName mimeType:uploadModel.mimeType error:nil];
        //e.g: image/jpeg video/mp4 application/octet-stream
    } progress:progressBlock success:successBlock failure:failureBlock];

}
#pragma mark downLoad下载
-(void)downLoadFileWithUrl:(NSString *)urlStr progress:(ProgressBlock)progressBlock completionBlock:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *  error))block{
    
    AFHTTPSessionManager *manager = [self baseHtppRequest];
  
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //设置下载路径，通过沙盒获取缓存地址，最后返回NSURL对象
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
        return [NSURL URLWithString:filePath];

    } completionHandler:block];
    
    //开始启动任务
    [task resume];
}
#pragma makr - 开始监听网络
+ (void)startMonitoring
{
    // 1.获得网络监控的管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    // 2.设置网络状态改变后的处理
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
               
            case AFNetworkReachabilityStatusUnknown:{
                KLog(@"未知");
            }
                
                break;
            case AFNetworkReachabilityStatusNotReachable:
                KLog(@"无网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                KLog(@"蜂窝数据网络");
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                KLog(@"WiFi");
                
                break;
                
            default:
                break;
        }
    }];
    [manager startMonitoring];
    //[manager stopMonitoring]
    
}
+ (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL  error:NULL];
    return str;
}
@end
