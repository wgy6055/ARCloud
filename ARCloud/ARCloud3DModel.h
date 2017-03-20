//
//  ARCloud3DModel.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARCloud3DModel : NSObject

@property (nonatomic, readonly) NSInteger numVertices;
@property (nonatomic, readonly) float* vertices;
@property (nonatomic, readonly) float* normals;
@property (nonatomic, readonly) float* texCoords;

- (id)initWithTxtResourceName:(NSString *)name;
- (id)initWithTxtExtendedName:(NSString *)name;

- (void) read;

@end
