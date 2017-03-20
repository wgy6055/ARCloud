//
//  ARCloudShaderUtils.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARCloudShaderUtils : NSObject

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName
                      fragmentShaderFileName:(NSString*) fragmentShaderFileName;

+ (int)createProgramWithVertexShaderFileName:(NSString*) vertexShaderFileName
                        withVertexShaderDefs:(NSString *) vertexShaderDefs
                      fragmentShaderFileName:(NSString *) fragmentShaderFileName
                      withFragmentShaderDefs:(NSString *) fragmentShaderDefs;

@end
