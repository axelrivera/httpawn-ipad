//
//  SelectRecentHostViewController.h
//  RestClient
//
//  Created by Axel Rivera on 1/26/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectRecentHostViewControllerCancelBlock)(void);
typedef void (^SelectRecentHostViewControllerCompletionBlock)(NSString *string);

@interface SelectRecentHostViewController : UITableViewController

@property (strong, nonatomic) NSArray *dataSource;

@property (copy, nonatomic) SelectRecentHostViewControllerCompletionBlock completionBlock;

@end
