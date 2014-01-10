//
//  RequestInputViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestInputViewController.h"

#import "UIViewController+Layout.h"
#import <UIView+AutoLayout.h>
#import "HeaderSelectViewController.h"
#import "RCRequestOption.h"
#import "RequestInputCell.h"

#define kRequestInputHeaderViewHeight 84.0

@interface RequestInputViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *myPopoverController;

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) UILabel *emptyLabel;
@property (strong, nonatomic) UILabel *headerLabel;

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;
@property (strong, nonatomic) UIBarButtonItem *clearJSONButton;

@property (strong, nonatomic) UISegmentedControl *segmentedControl;

@property (strong, nonatomic) NSArray *rightItems;
@property (strong, nonatomic) NSArray *editingRightItems;

@property (assign, nonatomic) CGFloat myTopOrigin;

- (void)setEmptyView;
- (void)setMyTableView;
- (void)setMyJSONTableView;
- (void)setupHeaderView;
- (void)updateMainLayout;

@end

@implementation RequestInputViewController

- (instancetype)init
{
    return [self initWithType:RequestInputTypeHeaders dataSource:@[]];
}

- (instancetype)initWithType:(RequestInputType)inputType dataSource:(NSArray *)dataSource
{
    self = [super initWithNibName:@"RequestInputViewController" bundle:nil];
    if (self) {
        _inputType = inputType;
        if (IsEmpty(dataSource)) {
            dataSource = @[];
        }
        _dataSource = [dataSource mutableCopy];

        if (inputType == RequestInputTypeHeaders) {
            self.title = @"Headers";
        } else {
            self.title = @"Parameters";
        }

        _myPopoverController = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    if (self.inputType == RequestInputTypeJSONParameters) {
        self.JSONTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        self.JSONTableView.translatesAutoresizingMaskIntoConstraints = NO;
        self.JSONTableView.dataSource = self;
        self.JSONTableView.delegate = self;

        self.JSONTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.view.frame.size.width - 30.0,
                                                                         300.0)];
        self.JSONTextView.text = @"Sample Text";
        self.JSONTextView.editable = NO;

        [self setupHeaderView];

        self.segmentedControl.selectedSegmentIndex = 0;
        [self parameterChanged:self.segmentedControl];
    } else {
        [self.view addSubview:self.tableView];
    }

    if (!IsEmpty(self.dataSource)) {
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(dismissAction:)];

    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addAction:)];

    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(clearAction:)];

    self.clearJSONButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(clearJSONAction:)];

    self.rightItems = @[ self.doneButton, self.addButton ];
    self.editingRightItems = @[ self.clearButton ];

    [self.navigationItem setRightBarButtonItems:self.rightItems];

    if (IsEmpty(self.dataSource)) {
        [self setEmptyView];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    self.myTopOrigin = [self topOrigin];

    if (self.inputType == RequestInputTypeJSONParameters) {
        [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:self.myTopOrigin];
        [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
        [self.headerView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

        self.myTopOrigin += kRequestInputHeaderViewHeight;

        [self updateMainLayout];
    } else {
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(self.myTopOrigin, 0.0, 0.0, 0.0)];
    }

    [self.view layoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Public Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];

    NSArray *cells = [self.tableView visibleCells];
    for (id cell in cells) {
        if ([cell isKindOfClass:[RequestInputCell class]]) {
            [[cell inputButton] setEnabled:!editing];
            [[cell nameTextField] setEnabled:!editing];
            [[cell valueTextField] setEnabled:!editing];
            [[cell activeSwitch] setEnabled:!editing];
        }
    }

    if (editing) {
        [self.navigationItem setRightBarButtonItems:self.editingRightItems animated:animated];
    } else {
        [self.navigationItem setRightBarButtonItems:self.rightItems animated:animated];
    }

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Private Methods

- (void)setEmptyView
{
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor clearColor];

    if (self.emptyLabel == nil) {
        self.emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.emptyLabel.font = [UIFont systemFontOfSize:28.0];
        self.emptyLabel.backgroundColor = [UIColor clearColor];
        self.emptyLabel.textColor = [UIColor lightGrayColor];
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;

        if (self.inputType == RequestInputCellTypeHeader) {
            self.emptyLabel.text = @"No Headers";
        } else {
            self.emptyLabel.text = @"No Parameters";
        }
    }

    [self.emptyLabel autoRemoveConstraintsAffectingView];

    [view addSubview:self.emptyLabel];

    [self.emptyLabel autoSetDimension:ALDimensionHeight toSize:32.0];
    [self.emptyLabel autoCenterInSuperview];

    self.tableView.backgroundView = view;
}

- (void)setMyTableView
{
    if (self.JSONTableView) {
        [self.JSONTableView removeFromSuperview];
    }

    [self.view addSubview:self.tableView];
    [self updateMainLayout];
}

- (void)setMyJSONTableView
{
    [self.tableView removeFromSuperview];
    [self.view addSubview:self.JSONTableView];
    [self updateMainLayout];
}

- (void)setupHeaderView
{
    self.headerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerView.backgroundColor = [UIColor whiteColor];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    lineView.backgroundColor = [UIColor lightGrayColor];

    [self.headerView addSubview:lineView];

    [lineView autoSetDimension:ALDimensionHeight toSize:0.5];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
    [lineView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];

    [self.view addSubview:self.headerView];

    [self.headerView autoSetDimension:ALDimensionHeight toSize:kRequestInputHeaderViewHeight];

    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"Key Value", @"JSON" ]];
    self.segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.segmentedControl setWidth:250.0 forSegmentAtIndex:0];
    [self.segmentedControl setWidth:250.0 forSegmentAtIndex:1];

    [self.segmentedControl addTarget:self action:@selector(parameterChanged:) forControlEvents:UIControlEventValueChanged];

    [lineView addSubview:self.segmentedControl];

    [self.headerView addSubview:self.segmentedControl];

    [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
    [self.segmentedControl autoCenterInSuperviewAlongAxis:ALAxisVertical];

    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerLabel.font = [UIFont systemFontOfSize:13.0];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.textColor = [UIColor lightGrayColor];
    self.headerLabel.numberOfLines = 2;
    self.headerLabel.lineBreakMode = NSLineBreakByWordWrapping;

    self.headerLabel.text = @"Key Value inputs will override any available JSON content. "
                            @"The request will send the parameters as JSON in the body.";

    [self.headerView addSubview:self.headerLabel];

    [self.headerLabel autoSetDimension:ALDimensionHeight toSize:32.0];
    [self.headerLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];
    [self.headerLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];
    [self.headerLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
}

- (void)updateMainLayout
{
    [self.tableView autoRemoveConstraintsAffectingView];
    [self.JSONTableView autoRemoveConstraintsAffectingView];

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.myTopOrigin, 0.0, 0.0, 0.0);
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self.tableView autoPinEdgesToSuperviewEdgesWithInsets:contentInsets];
    } else {
        [self.JSONTableView autoPinEdgesToSuperviewEdgesWithInsets:contentInsets];
    }
}

#pragma mark - Selector Methods

- (void)addAction:(id)sender
{
    RCRequestOption *option = [[RCRequestOption alloc] init];

    if (self.dataSource == nil) {
        self.dataSource = [@[] mutableCopy];
    }

    if (IsEmpty(self.dataSource)) {
        self.tableView.backgroundView = nil;
    }

    [self.dataSource addObject:option];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.dataSource count] - 1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

    if (!IsEmpty(self.dataSource) && self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }
}

- (void)clearAction:(id)sender
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self setEditing:NO animated:YES];

    [self setEmptyView];
}

- (void)clearJSONAction:(id)sender
{
    [self.JSONTextView setText:@""];
}

- (void)dismissAction:(id)sender
{
    [self.delegate requestInputViewController:self didFinishWithInputType:self.inputType objects:self.dataSource];
}

- (void)headerAction:(id)sender
{
    if (self.myPopoverController) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    RequestInputCell *cell = (RequestInputCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    HeaderSelectViewController *controller = [[HeaderSelectViewController alloc] init];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myPopoverController.delegate = self;

    controller.saveBlock = ^(NSString *name, NSString *value) {
        RCRequestOption *requestOption = self.dataSource[indexPath.row];

        requestOption.objectName = cell.nameTextField.text = name;
        requestOption.objectValue = cell.valueTextField.text = value;
        [self.myPopoverController dismissPopoverAnimated:YES];
    };

    controller.cancelBlock = ^{
        [self.myPopoverController dismissPopoverAnimated:YES];
    };

    [self.myPopoverController presentPopoverFromRect:cell.inputButton.frame
                                              inView:cell
                            permittedArrowDirections:UIPopoverArrowDirectionLeft
                                            animated:YES];
}

- (void)parameterChanged:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 0) {
        [self.navigationItem setLeftBarButtonItem:[self editButtonItem] animated:YES];
        [self.navigationItem setRightBarButtonItems:self.rightItems animated:YES];
        [self setMyTableView];
    } else {
        [self.navigationItem setLeftBarButtonItems:@[ self.clearJSONButton ] animated:YES];
        [self.navigationItem setRightBarButtonItems: @[ self.doneButton ] animated:YES];
        [self setMyJSONTableView];
    }
}

- (void)keyboardShown:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    UIScrollView *scrollView = nil;
    CGFloat viewOffset = 0.0;

    if (self.inputType == RequestInputTypeJSONParameters && self.segmentedControl.selectedSegmentIndex == 1) {
        scrollView = self.JSONTableView;
        viewOffset = kRequestInputHeaderViewHeight;
    } else {
        scrollView = self.tableView;
        if (self.inputType == RequestInputTypeJSONParameters) {
             viewOffset = kRequestInputHeaderViewHeight;
        }
    }

    CGRect kbIntersectRect = [window convertRect:CGRectIntersection(window.frame, kbRect) toView:scrollView];
    CGRect viewRect = [window convertRect:scrollView.frame
                               fromWindow:window];

    CGFloat bottomInset = (viewRect.size.height + viewOffset) - kbIntersectRect.size.height;

    // get point before contentInset change
    CGPoint pointBefore = scrollView.contentOffset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, bottomInset, 0.0);

    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

    // get point after contentInset change
    CGPoint pointAfter = scrollView.contentOffset;

    // avoid jump by settings contentOffset
    scrollView.contentOffset = pointBefore;

    // and now animate smoothly
    [scrollView setContentOffset:pointAfter animated:YES];
}

- (void)keyboardHidden:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    UIScrollView *scrollView = nil;

    if (self.inputType == RequestInputTypeJSONParameters && self.segmentedControl.selectedSegmentIndex == 1) {
        scrollView = self.JSONTableView;
    } else {
        scrollView = self.tableView;
    }

    CGRect kbIntersectRect = [window convertRect:CGRectIntersection(window.frame, kbRect) toView:scrollView];

    // get point before contentInset change
    CGPoint pointBefore = scrollView.contentOffset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbIntersectRect.size.height, 0.0);

    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

    // get point after contentInset change
    CGPoint pointAfter = scrollView.contentOffset;

    // avoid jump by settings contentOffset
    scrollView.contentOffset = pointBefore;

    // and now animate smoothly
    [scrollView setContentOffset:pointAfter animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (tableView == self.JSONTableView) {
        sections = 2;
    } else {
        sections = 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (tableView == self.JSONTableView) {
        rows = 1;
    } else {
        rows = [self.dataSource count];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *JSONCellIdentifier = @"JSONCell";
    static NSString *JSONPreviewIdentifier = @"JSONPreviewCell";
    static NSString *CellIdentifier = @"Cell";

    if (tableView == self.JSONTableView) {
        if (indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JSONCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JSONCellIdentifier];
            }

            cell.textLabel.text = @"Object";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:JSONPreviewIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:JSONPreviewIdentifier];
                cell.accessoryView = self.JSONTextView;
            }

            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            return cell;
        }
    }

    RequestInputCellType cellType = self.inputType == RequestInputCellTypeHeader ? RequestInputCellTypeHeader : RequestInputCellTypeParameter;

    RequestInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RequestInputCell alloc] initWithType:cellType reuseIdentifier:CellIdentifier];

        if (self.inputType == RequestInputTypeHeaders) {
            cell.nameTextField.placeholder = @"Header Name";
            cell.valueTextField.placeholder = @"Header Value";
            cell.inputButton.tag = indexPath.row;
            [cell.inputButton addTarget:self action:@selector(headerAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            cell.nameTextField.placeholder = @"Parameter Name";
            cell.valueTextField.placeholder = @"Parameter Value";
        }
    }
    
    cell.requestOption = self.dataSource[indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0;
    if (tableView == self.JSONTableView) {
        if (indexPath.section == 0) {
            height = 44.0;
        } else {
            height = 320.0;
        }
    }

    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (tableView == self.JSONTableView) {
        if (section == 1) {
            title = @"Preview";
        }
    }
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if ([cell isKindOfClass:[RequestInputCell class]]) {
            [[cell inputButton] setEnabled:!tableView.isEditing];
            [[cell nameTextField] setEnabled:!tableView.isEditing];
            [[cell valueTextField] setEnabled:!tableView.isEditing];
            [[cell activeSwitch] setEnabled:!tableView.isEditing];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.JSONTableView) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.JSONTableView) {
        return UITableViewCellEditingStyleNone;
    }

    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.JSONTableView) {
        return;
    }

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];

        if (IsEmpty(self.dataSource)) {
            [self.navigationItem setLeftBarButtonItem:nil animated:YES];
            [self setEditing:NO animated:YES];
            [self setEmptyView];
        }
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.JSONTableView) {
        return NO;
    }

    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (tableView == self.JSONTableView) {
        return;
    }

    RCRequestOption *inputObject = self.dataSource[fromIndexPath.row];
    [self.dataSource removeObjectAtIndex:fromIndexPath.row];
    [self.dataSource insertObject:inputObject atIndex:toIndexPath.row];
}

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.myPopoverController = nil;
}

@end
