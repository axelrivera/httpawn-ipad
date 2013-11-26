//
//  DetailViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RequestDetailDelegate.h"

@class RequestHeaderView;

typedef NS_ENUM(NSInteger, RequestSegmentIndex) {
    RequestSegmentIndexNone = -1,
    RequestSegmentIndexBody,
    RequestSegmentIndexHeaders,
    RequestSegmentIndexRaw
};

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, RequestDetailDelegate>

@property (strong, nonatomic) RequestHeaderView *headerView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) RCRequest *request;

@end
