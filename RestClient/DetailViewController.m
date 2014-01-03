//
//  DetailViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/12/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "DetailViewController.h"

#import <UIView+AutoLayout.h>
#import <JDStatusBarNotification.h>

#import "UIViewController+Layout.h"
#import "RequestHeaderView.h"
#import "TitleNavigationView.h"

#import "URLActionsViewController.h"
#import "RequestInputViewController.h"
#import "PreviewViewController.h"
#import "GroupAddViewController.h"
#import "AdvancedRequestViewController.h"
#import "SettingsViewController.h"
#import "RCResponse+RestClient.h"

@interface DetailViewController ()
<RequestHeaderViewDelegate, URLActionsViewControllerDelegate, RequestInputViewControllerDelegate,
GroupAddViewControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) TitleNavigationView *titleView;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *URLActionsController;

- (void)updateSubtitle;

- (void)showURLActions;
- (void)showParameters;
- (void)showHeaders;
- (void)sendRequest;
- (void)showPreview;
- (void)saveRequest;
- (void)addToGroup;
- (void)showAdvanced;

- (NSArray *)detailToolBarItems;
- (void)notifyRequestChange:(RCGroup *)group;

@end

@implementation DetailViewController

- (instancetype)init
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

    self.titleView = [[TitleNavigationView alloc] initWithFrame:CGRectZero];
    self.titleView.frame = CGRectMake(0.0,
                                      0.0,
                                      self.titleView.intrinsicContentSize.width,
                                      self.titleView.intrinsicContentSize.height);
    
    self.titleView.textLabel.text = self.title;
    [self updateSubtitle];

    self.navigationItem.titleView = self.titleView;
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor whiteColor];

    [self setToolbarItems:[self detailToolBarItems] animated:NO];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(settingsAction:)];


    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    self.webView.scalesPageToFit = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    [self.view addSubview:self.webView];

    self.headerView = [[RequestHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.URLTextField.delegate = self;
    self.headerView.delegate = self;
    self.headerView.statusLabel.text = @"Waiting to send request...";

    [self.view addSubview:self.headerView];
    
    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];

    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    self.segmentedControl.enabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestDetailsUpdated:)
                                                 name:GroupRequestDetailsUpdatedNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.topOrigin];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.webView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:self.navigationController.toolbar.frame.size.height];

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GroupRequestDetailsUpdatedNotification
                                                  object:nil];
}

#pragma mark - Private Methods

- (void)updateSubtitle
{
    NSString *subtitle = nil;
    if (self.groupRequest == nil) {
        subtitle = self.request.URLString;
    } else {
        NSString *requestStr = nil;
        if (!IsEmpty(self.request.requestName)) {
            requestStr = self.request.requestName;
        } else {
            requestStr = self.request.URLString;
        }

        subtitle = [NSString stringWithFormat:@"%@ (%@)", self.groupRequest.parentGroup.groupName, requestStr];
    }
    self.titleView.detailTextLabel.text = subtitle;
}

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
    [self.view endEditing:YES];

    RequestInputViewController *controller = [[RequestInputViewController alloc] initWithType:RequestInputTypeParameters
                                                                                   dataSource:self.request.parameters];
    controller.delegate = self;

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showHeaders
{
    [self.view endEditing:YES];

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
    
    NSString *URLString = [self.headerView.URLTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (IsEmpty(URLString)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"HTTPawn"
                                                            message:@"Invalid URL"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }

    self.headerView.statusLabel.text = @"Sending request...";

    [[RestClientData sharedData] addRequestToHistory:self.request];


    [self.webView loadHTMLString:@"" baseURL:nil];
    self.segmentedControl.selectedSegmentIndex = RequestSegmentIndexBody;
    self.segmentedControl.enabled = NO;

    [self.request runWithCompletion:^(RCResponse *response, NSError *error) {
        self.headerView.statusLabel.text = [NSString stringWithFormat:@"Response Time: %@", [response responseTimeString]];
        [self segmentedControlChanged:self.segmentedControl];
        self.segmentedControl.enabled = YES;
    }];
}

- (void)showPreview
{
    [self.view endEditing:YES];

    PreviewViewController *controller = [[PreviewViewController alloc] initWithRequest:self.request];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)saveRequest
{
    [self.view endEditing:YES];

    if (self.groupRequest) {
        [self.groupRequest saveDataFromRequest:self.request];
        [JDStatusBarNotification showWithStatus:@"Request Saved..." dismissAfter:2.0 styleName:JDStatusBarStyleSuccess];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupShouldUpdateRequestsNotification
                                                            object:nil
                                                          userInfo:@{ kRCGroupKey : self.groupRequest.parentGroup }];
    } else {
        [JDStatusBarNotification showWithStatus:@"Error Saving Request..."
                                   dismissAfter:2.0
                                      styleName:JDStatusBarStyleError];
    }
}

- (void)addToGroup
{
    [self.view endEditing:YES];

    GroupAddViewController *controller = [[GroupAddViewController alloc] init];
    controller.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)showAdvanced
{
    [self.view endEditing:YES];

    AdvancedRequestViewController *controller = [[AdvancedRequestViewController alloc] initWithRequest:self.request];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)resetRequest
{
    [self.view endEditing:YES];

    [self.headerView setHeaderViewType:RequestHeaderViewTypeSingle];

    self.request = [[RCRequest alloc] init];
    self.groupRequest = nil;

    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self updateSubtitle];

    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    self.segmentedControl.enabled = NO;
    self.headerView.statusLabel.text = @"Waiting to send request...";
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

- (void)notifyRequestChange:(RCGroup *)group
{
    NSDictionary *userInfo = nil;
    if (group) {
        userInfo = @{ kRCGroupKey : group };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GroupDidUpdateNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark - Selector Methods

- (void)segmentedControlChanged:(UISegmentedControl *)segmentedControl
{
    if (self.request.response) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSString *text = nil;
            if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexBody ) {
                text = [self.request.response formattedHTMLBodyString];
            } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexHeaders) {
                text = [self.request.response headerString];
            } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexRaw) {
                text = [self.request.response formattedRawBodyString];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:text baseURL:[[NSBundle mainBundle] resourceURL]];
            });
        });
    }
}

- (void)settingsAction:(id)sender
{
    [self.view endEditing:YES];

    SettingsViewController *controller = [[SettingsViewController alloc] init];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)requestDetailsUpdated:(NSNotification *)notification
{
    RCRequest *request = notification.userInfo[kRCRequestKey];
    if (request && [request isEqual:self.groupRequest]) {
        self.request.requestName = request.requestName;
        self.request.requestDescription = request.requestDescription;
        [self updateSubtitle];
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
        case RequestHeaderViewButtonTypeSave:
            [self saveRequest];
            break;
        case RequestHeaderViewButtonTypeGroup:
            [self addToGroup];
            break;
        case RequestHeaderViewButtonTypeAdvanced:
            [self showAdvanced];
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
    self.request.requestMethod = action;
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

        [self.headerView setHeaderViewType:RequestHeaderViewTypeGrouped];

        self.groupRequest = [self.request copy];
        [group addRequest:self.groupRequest];

        if (![[RestClientData sharedData] containsGroup:group]) {
            [[RestClientData sharedData].groups addObject:group];
            [self notifyRequestChange:group];
        }

        [self updateSubtitle];
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
        self.request = [request copy];
        self.groupRequest = request;
        [self.headerView setHeaderViewType:RequestHeaderViewTypeGrouped];
    } else if (requestType == RCRequestTypeHistory) {
        self.request = [request copy];
        self.groupRequest = nil;
        [self.headerView setHeaderViewType:RequestHeaderViewTypeSingle];
    } else {
        self.request = [[RCRequest alloc] init];
        self.groupRequest = nil;
        [self.headerView setHeaderViewType:RequestHeaderViewTypeSingle];
    }

    self.headerView.statusLabel.text = @"Waiting to send request...";;
    [self updateSubtitle];

    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    [self.masterPopoverController dismissPopoverAnimated:YES];

    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    self.segmentedControl.enabled = NO;
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
        self.request.URLString = self.headerView.URLTextField.text;
        [self updateSubtitle];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self sendRequest];
    return NO;
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    }
}

@end
