//
//  HeaderSelectViewController.h
//  RestClient
//
//  Created by Axel Rivera on 12/24/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HeaderSelectViewControllerSaveBlock)(NSString *name, NSString *value);
typedef void (^HeaderSelectViewControllerCancelBlock)(void);

@interface HeaderSelectViewController : UITableViewController

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *dataSource;

@property (copy, nonatomic) HeaderSelectViewControllerSaveBlock saveBlock;
@property (copy, nonatomic) HeaderSelectViewControllerCancelBlock cancelBlock;

@end
