//
//  ARCloudEAGLView.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Vuforia/UIGLViewProtocol.h>

#import "Texture.h"
#import "ARCloudSession.h"
#import "ARCloud3DModel.h"
#import "SampleGLResourceHandler.h"
#import "ARCloudNetworkingSession.h"
#import "CoreDataHandler.h"

#define kNumAugmentationTextures 4

// EAGLView is a subclass of UIView and conforms to the informal protocol
// UIGLViewProtocol
@interface ARCloudEAGLView : UIView <UIGLViewProtocol,SampleGLResourceHandler> {
@private
    // OpenGL ES context
    EAGLContext *context;
    
    // The OpenGL ES names for the framebuffer and renderbuffers used to render
    // to this view
    GLuint defaultFramebuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderbuffer;
    
    // Shader handles
    GLuint shaderProgramID;
    GLint vertexHandle;
    GLint normalHandle;
    GLint textureCoordHandle;
    GLint mvpMatrixHandle;
    GLint texSampler2DHandle;
    
    // Texture used when rendering augmentation
    Texture* augmentationTexture[kNumAugmentationTextures];
    
    BOOL offTargetTrackingEnabled;
    ARCloud3DModel * showModel;
    ARCloud3DModel * buildingModel;
}

@property (nonatomic, weak) ARCloudSession * vapp;

@property (strong, nonatomic) ARCloudNetworkingSession *session;
@property (weak, nonatomic) id<CoreDataHandler> coreDataHandler;

- (id)initWithFrame:(CGRect)frame appSession:(ARCloudSession *) app;

- (void)finishOpenGLESCommands;
- (void)freeOpenGLESResources;

- (void) setOffTargetTrackingMode:(BOOL) enabled;

- (void)freeTimer;

@end
