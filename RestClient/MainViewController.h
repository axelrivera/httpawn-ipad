//
//  MainViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RequestDetailDelegate.h"

@interface MainViewController : UITableViewController

@property (weak, nonatomic) id <RequestDetailDelegate> delegate;

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSMutableArray *groups;
@property (strong, nonatomic) NSMutableArray *history;

@end
