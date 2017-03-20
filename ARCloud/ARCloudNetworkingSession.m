//
//  ARCloudNetworkingSession.m
//  ARCloud
//
//  Created by 王冠宇 on 16/7/18.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "ARCloudNetworkingSession.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

static NSString * const kModelEntityName = @"Model";
static NSString * const kModelIDKey = @"modelID";
static NSString * const kImageNameKey = @"imageName";
static NSString * const kImageTargetEntityName = @"ImageTarget";
static NSString * const kVersionKey = @"version";

static NSString * const kDownloadStatus = @"downloadStatus";

static NSString * const STATUS_DOWNLOADING = @"status_downloading";
static NSString * const STATUS_FREE = @"status_free";
static NSString * const STATUS_DONE = @"status_done";

@interface ARCloudNetworkingSession()

@property (strong, nonatomic) NSNumber *imageTargetVersion;
@property (strong, nonatomic) NSMutableDictionary *dicRelation;
@property (strong, nonatomic) NSMutableArray *arrayImageName;
@property (assign, nonatomic) BOOL datResult;
@property (assign, nonatomic) BOOL xmlResult;
@property (strong, nonatomic) NSNumber *getVersion;

@end

@implementation ARCloudNetworkingSession

- (NSMutableDictionary *)dicRelationClient{
    if (!_dicRelationClient) {
        _dicRelationClient = [NSMutableDictionary new];
        _dicDownloadStatus = [NSMutableDictionary new];
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kModelEntityName];
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request
                                                  error:&error];
        if (objects == nil) {
            NSLog(@"读取数据库错误：%@", [error localizedDescription]);
        }
        for (int i = 0; i < objects.count; i++) {
            [_dicRelationClient setValue:[objects[i] valueForKey:kModelIDKey] forKey:[objects[i] valueForKey:kImageNameKey]];
            [_dicDownloadStatus setValue:[objects[i] valueForKey:kDownloadStatus] forKey:[objects[i] valueForKey:kImageNameKey]];
        }
    }
    return _dicRelationClient;
}

- (NSMutableDictionary *)dicRelation {
    if (!_dicRelation) {
        _dicRelation = [self.dicRelationClient mutableCopy];
    }
    return _dicRelation;
}

- (NSMutableArray *)arrayModelID {
    if (!_arrayModelID) {
        _arrayModelID = [NSMutableArray new];
        _arrayModelID = [[self.dicRelationClient allValues] mutableCopy];
    }
    return _arrayModelID;
}

- (NSNumber *)imageTargetVersion {
    if (!_imageTargetVersion) {
        _imageTargetVersion = [NSNumber numberWithInt:0];
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        NSManagedObjectContext *context = [delegate managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kImageTargetEntityName];
        NSError *error;
        NSArray *objects = [context executeFetchRequest:request
                                                  error:&error];
        if (objects == nil) {
            NSLog(@"读取数据库错误：%@", [error localizedDescription]);
        }
        for (int i = 0; i < objects.count; i++) {
            _imageTargetVersion = [objects[i] valueForKey:kVersionKey];
        }
    }
    return _imageTargetVersion;
}

- (BOOL)datResult {
    if (!_datResult) {
        _datResult = NO;
    }
    return _datResult;
}

- (BOOL)xmlResult {
    if (!_xmlResult) {
        _xmlResult = NO;
    }
    return _xmlResult;
}

- (void)downloadFileWithOption:(NSDictionary *)paramDic
                      withURL:(NSString *)requestURL
                     savedPath:(NSString *)savedPath
                    withMethod:(NSString *)method
               downloadSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               downloadFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                      progress:(void (^)(float progress))progress {
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request =[serializer requestWithMethod:method
                                                      URLString:requestURL
                                                     parameters:paramDic
                                                          error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savedPath
                                                                 append:NO]];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float p = (float)totalBytesRead / totalBytesExpectedToRead;
        progress(p);
        NSLog(@"download：%f", (float)totalBytesRead / totalBytesExpectedToRead);
        
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation,error);
        
        NSLog(@"%@", [error localizedDescription]);
    }];
    
    [operation start];
}

- (void)sendModelIDsToServer {
    NSMutableArray *sortedArrayModelID = [[self.arrayModelID sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }] mutableCopy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *dicRequest = [NSDictionary dictionaryWithObjectsAndKeys:sortedArrayModelID, @"modelId", @"ios", @"device", nil];
    NSLog(@"%@", dicRequest);
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content/Type"];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:@"http://10.8.86.59:9000/app/modelInfo"// 服务器URL
       parameters:dicRequest
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSLog(@"ModelIDs发送成功");
              NSLog(@"responseObject:%@", responseObject);
              
              if ([responseObject[@"result"] isEqualToString:@"yes"]) {
                  NSDictionary *dicModelURL = responseObject[@"modelURL"];
                  self.arrayImageName = [[self.dicRelation allKeys] mutableCopy];
                  NSUInteger imageCount = [self.arrayImageName count];
                  for (NSUInteger i = 0; i < imageCount; i++) {
                      NSString *theImageName = self.arrayImageName[i];
                      NSNumber *theModelID = self.dicRelation[theImageName];
                      
                      if (self.dicRelationClient[theImageName] && ![self.dicRelationClient[theImageName] isEqualToNumber:theModelID]) {
                          self.dicDownloadStatus[theImageName] = STATUS_FREE;
                      }
                      
                      if (![self.dicRelationClient[theImageName] isEqualToNumber:theModelID] && (self.dicDownloadStatus[theImageName] == nil ? YES : [STATUS_FREE isEqualToString:self.dicDownloadStatus[theImageName]])) {
                          NSString *savedPath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.txt", theImageName]];
                          NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                          if ([dicModelURL objectForKey:[numberFormatter stringFromNumber:theModelID]]) {
                              self.dicDownloadStatus[theImageName] = STATUS_DOWNLOADING;
                              [self downloadFileWithOption:@{@"userid":@"123123"}
                                                   withURL:[dicModelURL objectForKey:[numberFormatter stringFromNumber:theModelID]]
                                                 savedPath:savedPath
                                                withMethod:@"GET"
                                           downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               [self.dicRelationClient setValue:theModelID
                                                                         forKey:theImageName];
                                               self.arrayModelID = [[self.dicRelationClient allValues] mutableCopy];
                                               NSLog(@"Model下载成功：%@", theImageName);
                                               [self.delegate showBarWithString:[NSString stringWithFormat:@"Model下载成功：%@", theImageName]];
                                               self.dicDownloadStatus[theImageName] = STATUS_DONE;
                                           }
                                           downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               self.dicDownloadStatus[theImageName] = STATUS_FREE;
                                           }
                                                  progress:^(float progress) {
                                                      
                                                  }];
                          }
                      }
                  }
              }
          }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              NSLog(@"ModelIDs发送失败：%@", [error localizedDescription]);
          }];
}

- (BOOL)askServerIsUpdateImageTarget {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:@"http://10.8.86.59:9000/app/picInfo"
       parameters:nil
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSLog(@"ImageTarget更新询问发送成功");
              NSLog(@"responseObject:%@", responseObject);
              self.getVersion = responseObject[@"version"];
              self.dicRelation = [responseObject[@"relation"] mutableCopy];

              if ([self.getVersion compare:self.imageTargetVersion] == NSOrderedDescending) {
                  
                  NSString *strDatUrl = responseObject[@"dataURL"];
                  NSString *strXmlUrl = responseObject[@"xmlURL"];
                  
                  NSString *datPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/ARCloudTarget.dat"];
                  NSString *xmlPath = [NSHomeDirectory() stringByAppendingString:@"/Documents/ARCloudTarget.xml"];
                  
                  [self downloadFileWithOption:@{@"userid":@"123123"}
                                       withURL:strDatUrl
                                     savedPath:datPath
                                    withMethod:@"GET"
                               downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSLog(@"dat文件下载成功");
                                   self.datResult = YES;
                               }
                               downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSLog(@"dat文件下载失败：%@", [error localizedDescription]);
                                   self.datResult = NO;
                               }
                                      progress:^(float progress) {
                                      
                                      }];
                  [self downloadFileWithOption:@{@"userid":@"123123"}
                                       withURL:strXmlUrl
                                     savedPath:xmlPath
                                    withMethod:@"GET"
                               downloadSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   NSLog(@"xml文件下载成功");
                                   self.xmlResult = YES;
                               }
                               downloadFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                   NSLog(@"xml文件下载失败：%@", [error localizedDescription]);
                                   self.xmlResult = NO;
                               }
                                      progress:^(float progress) {
                                   
                               }];
              }
          }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              NSLog(@"ImageTarget更新询问发送失败：%@", [error localizedDescription]);
          }];
    if (self.datResult && self.xmlResult && self.getVersion != nil) {
        self.imageTargetVersion = self.getVersion;
    }
    return self.datResult && self.xmlResult;
}

- (void)sendScanMessageToServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    [manager GET:@"http://10.8.86.59:9000/app/scancount/scan"
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSLog(@"扫描信号发送成功");
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"扫描信号发送失败：%@", [error localizedDescription]);
         }];
}

- (void)sendLeaveMessageToServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    [manager GET:@"http://10.8.86.59:9000/app/scancount/leave"
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSLog(@"脱离信号发送成功");
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"脱离信号发送失败：%@", [error localizedDescription]);
         }];
}

- (void)sendGestureMessageToServerWithGesture:(NSString *)n {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [[AFCompoundResponseSerializer alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"http://10.8.86.59:9000/app/instructionCode/%@", n];
    
    [manager GET:url
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSLog(@"手势信号发送成功");
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"手势信号发送失败：%@", [error localizedDescription]);
         }];
}
#pragma mark - CoreDataHandler

- (void)saveModelsToDataBase {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    NSArray *arrayModelID = [self.dicRelationClient allValues];
    NSArray *arrayImageName = [self.dicRelationClient allKeys];
    NSDictionary *dicDownloadStatus = [self.dicDownloadStatus copy];
    
    for (int i = 0; i < [arrayModelID count]; i++) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kModelEntityName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", kModelIDKey, arrayModelID[i]];
        [request setPredicate:predicate];
        NSArray *objects = [context executeFetchRequest:request error:&error];
        
        NSManagedObject *theModel = nil;
        if ([objects count] > 0) {
            theModel = [objects objectAtIndex:0];
        } else {
            theModel = [NSEntityDescription insertNewObjectForEntityForName:kModelEntityName
                                                     inManagedObjectContext:context];
        }
        [theModel setValue:arrayModelID[i] forKey:kModelIDKey];
        [theModel setValue:arrayImageName[i] forKey:kImageNameKey];
        [theModel setValue:dicDownloadStatus[arrayImageName[i]] forKey:kDownloadStatus];
    }
    [delegate saveContext];
}

- (void)saveImageTargetVersionToDataBase {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = [delegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:kImageTargetEntityName];
    NSArray *objects = [context executeFetchRequest:request error:&error];
        
    if (objects == nil) {
        NSLog(@"读取数据库错误：%@", [error localizedDescription]);
    }
    NSManagedObject *theImageTarget = nil;
    if ([objects count] > 0) {
        theImageTarget = [objects objectAtIndex:0];
    } else {
        theImageTarget = [NSEntityDescription insertNewObjectForEntityForName:kImageTargetEntityName
                                                       inManagedObjectContext:context];
    }
    [theImageTarget setValue:self.imageTargetVersion forKey:kVersionKey];
    [delegate saveContext];
}

@end
