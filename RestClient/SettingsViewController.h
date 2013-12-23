//
//  SettingsViewController.h
//  RestClient
//
//  Created by Axel Rivera on 12/2/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (strong, nonatomic) UISlider *timeoutSlider;
@property (strong, nonatomic) UISegmentedControl *fontSegmentedControl;

@end
