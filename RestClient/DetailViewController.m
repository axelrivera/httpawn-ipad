//
//  DetailViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "DetailViewController.h"

#import <UIView+AutoLayout.h>

#import "UIViewController+Layout.h"
#import "RequestHeaderView.h"

#import "URLActionsViewController.h"
#import "RequestInputViewController.h"

@interface DetailViewController ()
<RequestHeaderViewDelegate, URLActionsViewControllerDelegate, RequestInputViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *URLActionsController;

- (void)showURLActions;
- (void)showParameters;
- (void)showHeaders;
- (void)sendRequest;
- (void)showPreview;
- (void)addToGroup;
- (void)resetRequest;

@end

@implementation DetailViewController

- (id)init
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self) {
        self.title = @"Request Details";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.headerView = [[RequestHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.delegate = self;

    [self.view addSubview:self.headerView];

    [self.headerView.URLActionButton setTitle:URLActionGet forState:UIControlStateNormal];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor blackColor];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.font = [UIFont fontWithName:@"Courier" size:12.0];
    self.textView.editable = NO;
    
    [self.view addSubview:self.textView];
}

- (void)viewDidLayoutSubviews
{
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.topOrigin];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    
    [self.textView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];

    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)showURLActions
{
    if ([self.URLActionsController isPopoverVisible]) {
        [self.URLActionsController dismissPopoverAnimated:YES];
        self.URLActionsController = nil;
        return;
    }

    NSString *actionStr = [self.headerView.URLActionButton titleForState:UIControlStateNormal];

    URLActionsViewController *actionsController = [[URLActionsViewController alloc] initWithCurrentAction:actionStr];
    actionsController.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:actionsController];

    self.URLActionsController = [[UIPopoverController alloc] initWithContentViewController:navController];
    [self.URLActionsController presentPopoverFromRect:self.headerView.URLActionButton.frame
                                               inView:self.headerView
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
}

- (void)showParameters
{
    RequestInputViewController *controller = [[RequestInputViewController alloc] initWithType:RequestInputTypeParameters
                                                                                   dataSource:@[]];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showHeaders
{
    RequestInputViewController *controller = [[RequestInputViewController alloc] initWithType:RequestInputTypeHeaders
                                                                                   dataSource:@[]];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)sendRequest
{
    DLog(@"Send Request!");
    
    [self.view endEditing:YES];
    
    NSString *URLString = self.headerView.URLTextField.text;
    NSString *method = [self.headerView.URLActionButton titleForState:UIControlStateNormal];
    
    RCRequest *requestObject = [[RCRequest alloc] initWithMethod:method URLString:URLString];
    [requestObject runWithCompletion:^(RCResponse *response, NSError *error) {
        self.textView.text = [response formattedBodyString];
    }];
}

- (void)showPreview
{
    DLog(@"Show Preview!");
}

- (void)addToGroup
{
    DLog(@"Add To Group!");
}

- (void)resetRequest
{
    DLog(@"Reset Request!");
}

#pragma mark - RequestHeaderViewDelegate Methods

- (void)requestHeaderView:(RequestHeaderView *)headerView didSelectButtonType:(RequestHeaderViewButtonType)buttonType
{
    switch (buttonType) {
        case RequestHeaderViewButtonTypeURLAction:
            [self showURLActions];
            break;
        case RequestHeaderViewButtonTypeParameters:
            [self showParameters];
            break;
        case RequestHeaderViewButtonTypeHeaders:
            [self showHeaders];
            break;
        case RequestHeaderViewButtonTypeSend:
            [self sendRequest];
            break;
        case RequestHeaderViewButtonTypePreview:
            [self showPreview];
            break;
        case RequestHeaderViewButtonTypeGroup:
            [self addToGroup];
            break;
        case RequestHeaderViewButtonTypeReset:
            [self resetRequest];
            break;
        default:
            break;
    }
}

#pragma mark - UIViewControllerDelegate Methods

- (void)URLActionsController:(URLActionsViewController *)controller didSelectAction:(NSString *)action
{
    [self.headerView.URLActionButton setTitle:action forState:UIControlStateNormal];
    [self.URLActionsController dismissPopoverAnimated:YES];
}

- (void)requestInputViewController:(RequestInputViewController *)controller
            didFinishWithInputType:(RequestInputType)inputType
                           objects:(NSArray *)objects
{
    DLog(@"Objects: %@", objects);
    [controller.view endEditing:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SplitViewDelegate Methods

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"Main";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


@end
