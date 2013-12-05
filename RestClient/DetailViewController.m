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
#import "AdvancedRequestViewController.h"
#import "SettingsViewController.h"

@interface DetailViewController ()
<RequestHeaderViewDelegate, URLActionsViewControllerDelegate, RequestInputViewControllerDelegate,
GroupAddViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *URLActionsController;

- (void)showURLActions;
- (void)showParameters;
- (void)showHeaders;
- (void)sendRequest;
- (void)showPreview;
- (void)addToGroup;
- (void)showAdvanced;
- (void)resetRequest;

- (NSArray *)detailToolBarItems;
- (void)notifyRequestChange:(RCGroup *)group;

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
    
    [self.view addSubview:self.webView];

    self.headerView = [[RequestHeaderView alloc] initWithFrame:CGRectZero];
    self.headerView.URLTextField.delegate = self;
    self.headerView.delegate = self;

    [self.view addSubview:self.headerView];
    
    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews
{
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.topOrigin];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.webView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.headerView];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
    [self.webView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];

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

- (void)showAdvanced
{
    AdvancedRequestViewController *controller = [[AdvancedRequestViewController alloc] initWithRequest:self.request];

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
    [self.webView loadHTMLString:@"" baseURL:nil];
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
        NSString *text = nil;
        if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexBody ) {
            text = [self.request.response rawString];
        } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexHeaders) {
            text = [self.request.response headerString];
        } else if (segmentedControl.selectedSegmentIndex == RequestSegmentIndexRaw) {
            text = [self.request.response rawString];
        }

        NSString *formatStr = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\""
        " \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
        "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
        "<head>"
        "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
        "<link href=\"prettify.css\" type=\"text/css\" rel=\"stylesheet\" />"
        "<script type=\"text/javascript\" src=\"prettify.js\"></script>"
        "<script type=\"text/javascript\" src=\"vkbeautify.js\"></script>"
        "<style>"
        "body { margin: 0; padding: 0 }"
        "pre { margin: 0 }"
        "</style>"
        "<script>"
        "function mycode() { document.getElementById(\"mycode\").innerHTML = vkbeautify.json('%@', 2); }"
        "</script>"
        "</head>"
        "<body onload=\"mycode();prettyPrint()\">"
        "<?prettify linenums=1?>"
        "<pre style=\"border:none\" id=\"mycode\" class=\"prettyprint\">"
        "</pre>"
        "</body></html>";

        NSString *htmlStr = [NSString stringWithFormat:formatStr, text];

        DLog(@"%@", htmlStr);

        [self.webView loadHTMLString:htmlStr baseURL:[[NSBundle mainBundle] resourceURL]];
    }
}

- (void)settingsAction:(id)sender
{
    SettingsViewController *controller = [[SettingsViewController alloc] init];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self.navigationController presentViewController:navController animated:YES completion:nil];
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
            
            [self notifyRequestChange:group];
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
        [self notifyRequestChange:self.request.parentGroup];
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)shouldUpdateRequest:(RCRequest *)request requestType:(RCRequestType)requestType
{
    if (requestType == RCRequestTypeGroup) {
        self.request = request;
    } else if (requestType == RCRequestTypeHistory) {
        self.request = [request copy];
    } else {
        self.request = [[RCRequest alloc] init];
    }

    self.headerView.URLTextField.text = self.request.URLString;
    [self.headerView.URLActionButton setTitle:self.request.requestMethod forState:UIControlStateNormal];
    [self.webView loadHTMLString:@"" baseURL:nil];
    
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
        [self notifyRequestChange:self.request.parentGroup];
    }
}

@end
