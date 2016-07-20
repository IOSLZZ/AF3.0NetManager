//
//  NetWorkManager.h
//  AF网络请求3.0最新封装
//
//  Created by admin on 16/7/20.
//  Copyright © 2016年 LZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class LZUploadParam;
typedef void(^SuccessBlock)(NSURLSessionDataTask * task , id  responseBody);
typedef void(^FailureBlock)(NSURLSessionDataTask * task , NSError * error);
typedef void(^ProgressBlock)(NSProgress * downloadProgress);

@interface NetWorkManager : AFHTTPSessionManager
+(NetWorkManager *)sharedManager;
#pragma mark - GET
/**
 simple usage
 */
+(void)get:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;
/**
 usage with progress
 to use progress
 x% = 1.0*downloadProgress.completedUnitCount/ downloadProgress.totalUnitCount
 加载进度百分比
 */
-(void)getResultWithParameter:(NSDictionary *)parameter url:(NSString *)url  progress:(ProgressBlock)progressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
#pragma mark - POST
+(void)post:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock;

-(void)postResultWithParameter:(NSDictionary *)parameter url:(NSString *)url  progress:(ProgressBlock)progressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
#pragma mark upLoad上传
-(void)upLoadFileWithModel:(LZUploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
              successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
#pragma mark downLoad下载
-(void)downLoadFileWithUrl:(NSString *)urlStr progress:(ProgressBlock)progressBlock completionBlock:(void (^)(NSURLResponse * response, NSURL *  filePath, NSError *  error))block;
#pragma makr - 开始监听网络
+ (void)startMonitoring;
+ (NSString *)logDic:(NSDictionary *)dic;
@end
