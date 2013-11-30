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
#import "PreviewViewController.h"
#import "GroupAddViewController.h"

@interface DetailViewController ()
<RequestHeaderViewDelegate, URLActionsViewControllerDelegate, RequestInputViewControllerDelegate,
GroupAddViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *URLActionsController;
@property (assign, nonatomic) CGFloat topInset;
@property (assign, nonatomic) CGFloat bottomInset;

- (void)showURLActions;
- (void)showParameters;
- (void)showHeaders;
- (void)sendRequest;
- (void)showPreview;
- (void)addToGroup;
- (void)resetRequest;

- (NSArray *)detailToolBarItems;

@end

@implementation DetailViewController

- (id)init
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self) {
        self.title = @"Request Details";
        _request = [[RCRequest alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setToolbarItems:[self detailToolBarItems] animated:NO];

    self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.textColor = [UIColor blackColor];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.font = [UIFont fontWithName:@"Courier" size:12.0];
    self.textView.editable = NO;
    
    [self.view addSubview:self.textView];

    self.headerView = [[RequestHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.URLTextField.delegate = self;
    self.headerView.delegate = self;

    [self.view addSubview:self.headerView];
    
    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    self.headerView.saveButton.enabled = NO;
}

- (void)viewDidLayoutSubviews
{
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.topOrigin];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.textView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];

    self.topInset = self.topOrigin + [RequestHeaderView viewHeight];

    UIEdgeInsets contentInset = self.textView.contentInset;
    contentInset.top = self.topInset;

    UIEdgeInsets scrollInset = self.textView.scrollIndicatorInsets;
    scrollInset.top = self.topInset;

    self.textView.contentInset = contentInset;
    self.textView.scrollIndicatorInsets = scrollInset;

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
                                                                                   dataSource:self.request.parameters];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showHeaders
{
    RequestInputViewController *controller = [[RequestInputViewController alloc] initWithType:RequestInputTypeHeaders
                                                                                   dataSource:self.request.headers];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)sendRequest
{
    DLog(@"Send Request!");
    
    [self.view endEditing:YES];
    
    NSString *URLString = [self.request.URLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (IsEmpty(URLString)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HTTPawn"
                                                            message:@"Invalid URL"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    self.request.URLString = self.headerView.URLTextField.text;
    self.request.requestMethod = [self.headerView.URLActionButton titleForState:UIControlStateNormal];
    
    [[RestClientData sharedData] addRequestToHistory:self.request];

    [self.request runWithCompletion:^(RCResponse *response, NSError *error) {
        self.segmentedControl.selectedSegmentIndex = RequestSegmentIndexBody;
        [self segmentedControlChanged:self.segmentedControl];
    }];
}

- (void)showPreview
{
    PreviewViewController *controller = [[PreviewViewController alloc] initWithRequest:self.request];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)addToGroup
{
    GroupAddViewController *controller = [[GroupAddViewController alloc] init];
    controller.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)resetRequest
{
    [self.view endEditing:YES];
    
    self.request = [[RCRequest alloc] init];
    
    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    self.headerView.saveButton.enabled = NO;
    self.textView.text = @"";
}

- (NSArray *)detailToolBarItems
{
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Body", @"Headers", @"Raw" ]];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedControl setWidth:100.0 forSegmentAtIndex:RequestSegmentIndexBody];
    [self.segmentedControl setWidth:100.0 forSegmentAtIndex:RequestSegmentIndexHeaders];
    [self.segmentedControl setWidth:100.0 forSegmentAtIndex:RequestSegmentIndexRaw];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];

    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];

    return @[ flexibleItem, segmentedItem, flexibleItem ];
}

#pragma mark - Selector Methods

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    if (self.request.response) {
        NSString *text = nil;
        if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexBody) {
            text = [self.request.response formattedBodyString];
        } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexHeaders) {
            text = [self.request.response headerString];
        } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexRaw) {
            text = [self.request.response rawString];
        }

        self.textView.text = text;
        [self.textView setContentOffset:CGPointMake(0.0, -self.topInset) animated:NO];
    }
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

- (void)groupAddViewController:(GroupAddViewController *)controller
            didFinishWithGroup:(RCGroup *)group
                   requestName:(NSString *)requestName
            requestDescription:(NSString *)requestDesription
{
    if (group) {
        if (!IsEmpty(requestName)) {
            self.request.requestName = requestName;
        }
        
        if (!IsEmpty(requestDesription)) {
            self.request.requestDescription = requestDesription;
        }
        
        RCRequest *request = [self.request copy];
        [group addRequest:request];
        self.request = request;
        
        if (![[RestClientData sharedData] containsGroup:group]) {
            [[RestClientData sharedData].groups addObject:group];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GroupDidUpdateNotification
                                                                object:nil
                                                              userInfo:@{ kRCGroupKey : group }];
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupShouldUpdateRequestsNotification
                                                            object:nil
                                                          userInfo:@{ kRCGroupKey : group }];
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)groupAddViewControllerDidCancel:(GroupAddViewController *)controller
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)requestInputViewController:(RequestInputViewController *)controller
            didFinishWithInputType:(RequestInputType)inputType
                           objects:(NSArray *)objects
{
    [controller.view endEditing:YES];

    if (inputType == RequestInputTypeHeaders) {
        self.request.headers = objects;
    } else {
        self.request.parameters = objects;
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)shouldUpdateRequest:(RCRequest *)request requestType:(RCRequestType)requestType
{
    if (requestType == RCRequestTypeGroup) {
        self.headerView.saveButton.enabled = YES;
        self.request = request;
    } else if (requestType == RCRequestTypeHistory) {
        self.headerView.saveButton.enabled = NO;
        self.request = [request copy];
    } else {
        self.headerView.saveButton.enabled = NO;
        self.request = [[RCRequest alloc] init];
    }
        
    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    self.textView.text = @"";
    
    [self.masterPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - SplitViewDelegate Methods

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = @"HTTPawn";
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

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.headerView.URLTextField) {
        self.request.URLString = textField.text;
    }
}

@end
