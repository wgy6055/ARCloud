//
//  CoreDataHandler.h
//  ARCloud
//
//  Created by 王冠宇 on 16/8/1.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

@protocol CoreDataHandler

@required
- (void)saveModelsToDataBase;
- (void)saveImageTargetVersionToDataBase;

@end
