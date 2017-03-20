//
//  ARCloudViewController.h
//  ARCloud
//
//  Created by 王冠宇 on 16/7/4.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARCloudEAGLView.h"
#import "ARCloudSession.h"
#import "ARCloudMenuViewController.h"
#import <Vuforia/DataSet.h>

@interface ARCloudViewController : UIViewController <ARCloudControl, ARCloudMenuDelegate, GYNotificationBarProtocol> {
    
    Vuforia::DataSet*  dataSetCurrent;
    Vuforia::DataSet*  dataSetARCloud;
    
    BOOL switchToStonesAndChips;
    
    // menu options
    BOOL extendedTrackingEnabled;
    BOOL continuousAutofocusEnabled;
    BOOL flashEnabled;
    BOOL frontCameraEnabled;
}

@property (nonatomic, strong) ARCloudEAGLView* eaglView;
@property (nonatomic, strong) UITapGestureRecognizer * tapGestureRecognizer;
@property (nonatomic, strong) ARCloudSession * vapp;
@property (weak, nonatomic) id<SampleGLResourceHandler> glResourceHandler;


@property (nonatomic, readwrite) BOOL showingMenu;

@end
