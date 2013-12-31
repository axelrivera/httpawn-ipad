//
//  SelectViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/29/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectViewControllerDelegate;

@interface SelectViewController : UITableViewController

@property (weak, nonatomic) id <SelectViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *dataSource;
@property (copy, nonatomic) NSString *identifier;

- (instancetype)initWithDataSource:(NSArray *)dataSource;

@end

@protocol SelectViewControllerDelegate <NSObject>

- (void)selectViewController:(SelectViewController *)controller didSelectObject:(RCSelect *)object;

@optional

- (void)selectViewControllerDidCancel:(SelectViewController *)controller;

@end
