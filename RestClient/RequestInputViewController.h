//
//  RequestInputViewController.h
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RequestInputType) {
    RequestInputTypeHeaders,
    RequestInputTypeParameters,
    RequestInputTypeJSONParameters
};

@protocol RequestInputViewControllerDelegate;

@class RequestInputView;

@interface RequestInputViewController : UIViewController

@property (weak, nonatomic) id <RequestInputViewControllerDelegate> delegate;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UITableView *JSONTableView;
@property (strong, nonatomic) UITextView *JSONTextView;

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (assign, nonatomic) RequestInputType inputType;
@property (strong, nonatomic) RCJSONObject *JSONParameters;

- (instancetype)initWithType:(RequestInputType)inputType dataSource:(NSArray *)dataSource;

@end

@protocol RequestInputViewControllerDelegate <NSObject>

- (void)requestInputViewController:(RequestInputViewController *)controller
            didFinishWithInputType:(RequestInputType)inputType
                           objects:(NSArray *)objects
                    JSONParameters:(RCJSONObject *)JSONParameters;

@end
