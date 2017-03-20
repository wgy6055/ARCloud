//
//  SampleGLResourceHandler.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

@protocol SampleGLResourceHandler

@required
- (void) freeOpenGLESResources;
- (void) finishOpenGLESCommands;

@end
