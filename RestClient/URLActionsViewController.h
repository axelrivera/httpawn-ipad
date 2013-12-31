//
//  URLActionsViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol URLActionsViewControllerDelegate;

@interface URLActionsViewController : UITableViewController

@property (weak, nonatomic) id <URLActionsViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) NSString *currentURLAction;

- (instancetype)initWithCurrentAction:(NSString *)action;

@end

@protocol URLActionsViewControllerDelegate <NSObject>

- (void)URLActionsController:(URLActionsViewController *)controller didSelectAction:(NSString *)action;

@end
